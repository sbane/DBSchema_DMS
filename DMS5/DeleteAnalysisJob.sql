/****** Object:  StoredProcedure [dbo].[DeleteAnalysisJob] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure dbo.DeleteAnalysisJob
/****************************************************
**
**	Desc: Deletes given analysis job from the analysis job table
**        and all referencing tables 
**
**	Return values: 0: success, otherwise, error code
**
**	Parameters: 
**
**	
**
**	Auth:	grk
**	Date:	03/06/2001
**			06/09/2004 grk - added delete for analysis job request reference
**			04/07/2006 grk - eliminated job to request map table
**			02/20/2007 grk - added code to remove any job-to-group associations
**			03/16/2007 mem - Fixed bug that required 1 or more rows be deleted from T_Analysis_Job_Processor_Group_Associations (Ticket #393)
**			02/29/2008 mem - Added optional parameter @callingUser; if provided, then will call AlterEventLogEntryUser (Ticket #644)
**			12/31/2008 mem - Now calling DMS_Pipeline.dbo.DeleteJob
**			02/19/2008 grk - Modified not to call broker DB (Ticket #723)
**			05/28/2015 mem - No longer deleting processor group entries
**			03/08/2017 mem - Delete jobs in the DMS_Pipeline database if they are new, holding, or failed
**			04/21/2017 mem - Added parameter @previewMode
**
*****************************************************/
(
    @jobNum varchar(32),
	@callingUser varchar(128) = '',
	@previewMode tinyint = 0
)
As
	Set nocount on

	Declare @myError int
	Declare @myRowCount int
	Set @myError = 0
	Set @myRowCount = 0

	Set @jobNum = IsNull(@jobNum, '')
	Set @previewMode = IsNull(@previewMode, 0)	

	Declare @message varchar(512)
	Declare @msg varchar(128)

	Declare @jobID int = Try_Cast(@jobNum as int)
	
	If @jobID is null
	Begin
		Set @msg = 'Job number is not numeric: ' + @jobNum
		RAISERROR (@msg, 10, 1)
		return 54449
	End
	
	-------------------------------------------------------
	-- Validate that the job exists
	-------------------------------------------------------
	--
	If Not Exists (SELECT * FROM T_Analysis_Job WHERE AJ_jobID = @jobID)
	Begin
		Set @msg = 'Job not found; nothing to delete: ' + @jobNum
		If @previewMode > 0
			Print @msg
		Else
		Begin
			RAISERROR (@msg, 10, 1)
			return 54450
		End
	End

	If @previewMode > 0
	Begin
		SELECT 'To be deleted' as Action, *
		FROM T_Analysis_Job
		WHERE (AJ_jobID = @jobID)
	End
	Else
	Begin
		-------------------------------------------------------
		-- Start transaction
		-------------------------------------------------------
		--
		Declare @transName varchar(32) = 'DeleteAnalysisJob'
		Begin transaction @transName	

		-------------------------------------------------------	
		-- Delete the analysis job
		-------------------------------------------------------
		--
		DELETE FROM T_Analysis_Job 
		WHERE (AJ_jobID = @jobID)
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		--
		If @myError <> 0 or @myRowCount = 0
		Begin
			rollback transaction @transName
			RAISERROR ('Delete job operation failed', 10, 1)
			return 54451
		End
		
		-------------------------------------------------------
		-- If @callingUser is defined, then call AlterEventLogEntryUser to alter the Entered_By field in T_Event_Log
		-------------------------------------------------------
		--
		If Len(@callingUser) > 0
		Begin
			Declare @stateID int
			Set @stateID = 0

			Exec AlterEventLogEntryUser 5, @jobID, @stateID, @callingUser
		End
		
		commit transaction @transName
	End
	
	-------------------------------------------------------
	-- Also delete from the DMS_Pipeline database if the state is New, Failed, or Holding
	-- Ignore any jobs with running job steps (though if the step started over 48 hours ago, ignore that job step)
	-------------------------------------------------------
	--
	exec S_DeleteJobIfNewOrFailed @jobID, @callingUser, @message output, @previewMode
	
	return 0

GO
GRANT VIEW DEFINITION ON [dbo].[DeleteAnalysisJob] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[DeleteAnalysisJob] TO [DMS_Ops_Admin] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[DeleteAnalysisJob] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[DeleteAnalysisJob] TO [Limited_Table_Write] AS [dbo]
GO
