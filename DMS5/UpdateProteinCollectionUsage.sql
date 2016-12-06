/****** Object:  StoredProcedure [dbo].[UpdateProteinCollectionUsage] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.UpdateProteinCollectionUsage
/****************************************************
**
**	Desc:	Updates the data in T_Protein_Collection_Usage
**
**	Return values: 0: success, otherwise, error code
**
**	Auth:	mem
**	Date:	09/11/2012 mem - Initial version
**			11/20/2012 mem - Now updating Job_Usage_Count_Last12Months
**			08/14/2014 mem - Fixed bug updating Job_Usage_Count_Last12Months (occurred when a protein collection had not been used in the last year)
**			02/23/2016 mem - Add set XACT_ABORT on
**
*****************************************************/
(
	@message varchar(255) = '' output
)
AS

	Set XACT_ABORT, nocount on
	
	Declare @myRowCount int
	Declare @myError int
	Set @myRowCount = 0
	Set @myError = 0

	set @message = ''

	Declare @S varchar(max)

	declare @CallingProcName varchar(128)
	declare @CurrentLocation varchar(128)
	Set @CurrentLocation = 'Start'
	
	---------------------------------------------------
	-- Create the temporary table that will be used to
	-- track the number of inserts, updates, and deletes 
	-- performed by the MERGE statement
	---------------------------------------------------
	
	CREATE TABLE #Tmp_UpdateSummary (
		UpdateAction varchar(32)
	)
		
	Begin Try
				
		Set @CurrentLocation = 'Merge data into T_Protein_Collection_Usage'

		-- Use a MERGE Statement to synchronize T_Protein_Collection_Usage with S_V_Protein_Collection_Picker
		MERGE T_Protein_Collection_Usage AS target
		USING (SELECT DISTINCT ID, Name FROM S_V_Protein_Collection_Picker
			) AS Source (	Protein_Collection_ID, Name)
		ON (target.Protein_Collection_ID = source.Protein_Collection_ID)
		WHEN Matched AND (  Target.Name <> Source.Name ) THEN 
			UPDATE Set
		          Name = Source.Name		         
		WHEN Not Matched THEN
			INSERT ( Protein_Collection_ID, Name, Job_Usage_Count)
			VALUES ( Source.Protein_Collection_ID, Source.Name, 0)
		WHEN NOT MATCHED BY SOURCE THEN
			DELETE
		OUTPUT $action INTO #Tmp_UpdateSummary
		;
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount

		If @myError <> 0
		Begin
			set @message = 'Error merging S_V_Protein_Collection_Picker with T_Protein_Collection_Usage (ErrorID = ' + Convert(varchar(12), @myError) + ')'
			execute PostLogEntry 'Error', @message, 'UpdateProteinCollectionUsage'
		End

		-- Update the usage counts in T_Protein_Collection_Usage
		--
		UPDATE T_Protein_Collection_Usage
		SET Job_Usage_Count_Last12Months = UsageQ.Job_Usage_Count_Last12Months,
		    Job_Usage_Count = UsageQ.Job_Usage_Count,		 
		    Most_Recently_Used = UsageQ.Most_Recent_Date
		FROM T_Protein_Collection_Usage Target
		     INNER JOIN ( SELECT ProteinCollectionName,
		                         COUNT(DISTINCT Job) AS Job_Usage_Count,
								 SUM(CASE WHEN JobDate >= DateAdd(month, -12, GetDate()) THEN 1 
								     ELSE 0 
								     End) As Job_Usage_Count_Last12Months,
		                         MAX(JobDate) AS Most_Recent_Date
		                  FROM ( SELECT AJ_JobID AS Job,
		                                ProteinCollections.Item AS ProteinCollectionName,
		                                COALESCE(AJ_created, AJ_Start, AJ_finish) AS JobDate
		                         FROM T_Analysis_Job
		                              CROSS APPLY dbo.MakeTableFromListDelim ( AJ_ProteinCollectionList, ',' ) ProteinCollections
		                         WHERE AJ_ProteinCollectionList <> 'na' 
		                        ) SplitQ
		                  GROUP BY ProteinCollectionName 
		                 ) AS UsageQ
		       ON Target.Name = UsageQ.ProteinCollectionName
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		
	End Try
	Begin Catch
		-- Error caught; log the error then abort processing
		Set @CallingProcName = IsNull(ERROR_PROCEDURE(), 'UpdateProteinCollectionUsage')
		exec LocalErrorHandler  @CallingProcName, @CurrentLocation, @LogError = 1, 
								@ErrorNum = @myError output, @message = @message output
		Goto Done		
	End Catch

Done:
	Return @myError


GO
GRANT VIEW DEFINITION ON [dbo].[UpdateProteinCollectionUsage] TO [DDL_Viewer] AS [dbo]
GO
