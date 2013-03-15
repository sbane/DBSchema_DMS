/****** Object:  StoredProcedure [dbo].[SyncJobInfo] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE SyncJobInfo
/****************************************************
**
**	Desc:
**		Synchronizes job info with DMS, including 
**		updating priorities and assigned processor groups
**
**	Auth:	mem
**			01/17/2009 mem - Initial version (Ticket #716, http://prismtrac.pnl.gov/trac/ticket/716)
**			06/01/2009 mem - Added index to #Tmp_JobProcessorInfo (Ticket #738, http://prismtrac.pnl.gov/trac/ticket/738)
**			06/27/2009 mem - Now only filtering out complete jobs when populating #Tmp_JobProcessorInfo (previously, we were also excluding failed jobs)
**			09/17/2009 mem - Now using a MERGE statement to update T_Local_Job_Processors
**			07/01/2010 mem - Removed old code that was replaced by the MERGE statement in 9/17/2009
**			05/25/2011 mem - Removed priority column from T_Job_Steps
**    
*****************************************************/
(
	@bypassDMS tinyint = 0,
	@message varchar(512)= '' output
)
As
	set nocount on
	
	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0

	Declare @JobUpdateCount int
	
	Declare @MergeUpdateCount int
	Declare @MergeInsertCount int
	Declare @MergeDeleteCount int
	
	Set @message = ''
	
	if @bypassDMS <> 0
		goto Done

	---------------------------------------------------
	-- Create the temporary table that will be used to
	-- track the number of inserts, updates, and deletes 
	-- performed by the MERGE statement
	---------------------------------------------------
	
	CREATE TABLE #Tmp_UpdateSummary (
		UpdateAction varchar(32)
	)
	
	CREATE CLUSTERED INDEX #IX_Tmp_UpdateSummary ON #Tmp_UpdateSummary (UpdateAction)

	---------------------------------------------------
	-- Update archive busy flag for active jobs according to state in DMS
	--  
	-- Use V_DMS_ArchiveBusyJobs (which uses V_GetAnalysisJobsForArchiveBusy in the primary DMS DB) 
	-- to look for jobs that have dataset archive state: 
	--  1=New, 2=Archive In Progress, 6=Operation Failed, 7=Purge In Progress, or 12=Verification In Progress
	-- Jobs matching this criterion are deemed "busy" and thus will get Archive_Busy set to 1 in T_Jobs
	--
	-- However, for QC_Shew datasets, we only exclude jobs if the dataset archive state is 7=Purge In Progress	
	--
	-- Prior to May 2012 we also excluded datasets with archive update state: 3=Update In Progress
	-- However, we now allow jobs to run if a dataset has an archive update job running
	--
	---------------------------------------------------
	--
	UPDATE T_Jobs
	SET Archive_Busy = CASE WHEN TA.Busy = 1 THEN 1 ELSE 0 END
	FROM T_Jobs AS Target
	     LEFT OUTER JOIN ( SELECT Job, 1 AS Busy
	                       FROM V_DMS_ArchiveBusyJobs ) AS TA
	       ON TA.Job = Target.Job
	WHERE Target.State IN (1, 2) AND
	      Target.Archive_Busy <> CASE WHEN TA.Busy = 1 THEN 1 ELSE 0 END
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
    --
	If @myError <> 0
	Begin
		set @message = 'Error updating Archive_Busy in T_Jobs'

		execute PostLogEntry 'Error', @message, 'SyncJobInfo'
		Set @message = ''
	End


	---------------------------------------------------
	-- Update priorities for jobs and job steps based on
	--  the priority defined in DMS
	---------------------------------------------------
	--
	Set @JobUpdateCount = 0

	UPDATE T_Jobs
	SET Priority = PJP.Priority
	FROM T_Jobs J
	     INNER JOIN V_DMS_PipelineJobPriority PJP
	       ON J.Job = PJP.Job
	WHERE PJP.Priority <> J.Priority
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	Set @JobUpdateCount = @myRowCount
	
	If @JobUpdateCount > 0
	Begin
		Set @message = 'Job priorities changed: updated ' + Convert(varchar(12), @JobUpdateCount) + ' job(s) in T_Jobs'
		execute PostLogEntry 'Normal', @message, 'SyncJobInfo'
		Set @message = ''
	End

	---------------------------------------------------
	-- Update the processor groups that jobs belong to,
	--  based on the group membership defined in DMS
	---------------------------------------------------
	
	-- Use a MERGE Statement (introduced in Sql Server 2008) to synchronize T_Local_Job_Processors with V_DMS_PipelineJobProcessors

	MERGE T_Local_Job_Processors AS target
	USING ( SELECT Job, Processor, General_Processing
	        FROM V_DMS_PipelineJobProcessors AS VGP
	        WHERE Job IN ( SELECT Job
	                       FROM T_Jobs
	                       WHERE State NOT IN (4) 
	                     )
	      ) AS Source (Job, Processor, General_Processing)
	       ON (target.Job = source.Job And 
	           target.Processor = source.Processor)
	WHEN Matched AND target.General_Processing <> source.General_Processing THEN 
		UPDATE set General_Processing = source.General_Processing
	WHEN Not Matched THEN
		INSERT (Job, Processor, General_Processing)
		VALUES (source.Job, source.Processor, source.General_Processing)
	WHEN NOT MATCHED BY SOURCE THEN 
		DELETE
	OUTPUT $action INTO #Tmp_UpdateSummary
	;
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount

	if @myError <> 0
	begin
		set @message = 'Error merging V_DMS_PipelineJobProcessors with T_Local_Job_Processors (ErrorID = ' + Convert(varchar(12), @myError) + ')'
		execute PostLogEntry 'Error', @message, 'SyncJobInfo'
		goto Done
	end


	set @MergeUpdateCount = 0
	set @MergeInsertCount = 0
	set @MergeDeleteCount = 0

	SELECT @MergeInsertCount = COUNT(*)
	FROM #Tmp_UpdateSummary
	WHERE UpdateAction = 'INSERT'

	SELECT @MergeUpdateCount = COUNT(*)
	FROM #Tmp_UpdateSummary
	WHERE UpdateAction = 'UPDATE'

	SELECT @MergeDeleteCount = COUNT(*)
	FROM #Tmp_UpdateSummary
	WHERE UpdateAction = 'DELETE'

	
--	If @MergeUpdateCount > 0 Or @MergeInsertCount > 0 Or @MergeDeleteCount > 0 
--	Begin
--		Set @message = 'Updated T_Local_Job_Processors; UpdateCount=' + Convert(varchar(12), @MergeUpdateCount) + '; InsertCount=' + Convert(varchar(12), @MergeInsertCount) + '; DeleteCount=' + Convert(varchar(12), @MergeDeleteCount)
--		execute PostLogEntry 'Normal', @message, 'SyncJobInfo'
--		Set @message = ''
--	End


	---------------------------------------------------
	-- Exit
	---------------------------------------------------
	--
Done:
	return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[SyncJobInfo] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[SyncJobInfo] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[SyncJobInfo] TO [PNL\D3M580] AS [dbo]
GO