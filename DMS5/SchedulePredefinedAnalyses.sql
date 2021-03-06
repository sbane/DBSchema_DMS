/****** Object:  StoredProcedure [dbo].[SchedulePredefinedAnalyses] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE SchedulePredefinedAnalyses
/****************************************************
** 
**	Desc: Schedules analysis jobs for dataset 
**            according to defaults
**
**	Return values: 0: success, otherwise, error code
** 
**	Auth:	grk
**	Date:	06/29/2005 grk - supersedes "ScheduleDefaultAnalyses"
**			03/28/2006 grk - added protein collection fields
**			04/04/2006 grk - increased sized of param file name
**			06/01/2006 grk - fixed calling sequence to AddUpdateAnalysisJob
**			03/15/2007 mem - Updated call to AddUpdateAnalysisJob (Ticket #394)
**						   - Replaced processor name with associated processor group (Ticket #388)
**			02/29/2008 mem - Added optional parameter @callingUser; If provided, then will call AlterEventLogEntryUser (Ticket #644)
**			04/11/2008 mem - Now passing @RaiseErrorMessages to EvaluatePredefinedAnalysisRules
**			05/14/2009 mem - Added parameters @AnalysisToolNameFilter, @ExcludeDatasetsNotReleased, and @InfoOnly
**			07/22/2009 mem - Improved error reporting for non-zero return values from EvaluatePredefinedAnalysisRules
**			07/12/2010 mem - Expanded protein Collection fields and variables to varchar(4000)
**			08/26/2010 grk - Gutted original and moved guts to CreatePredefinedAnalysesJobs - now just entering dataset into work queue
**			05/24/2011 mem - Added back support for @infoOnly
**			03/27/2013 mem - No longer storing dataset name in T_Predefined_Analysis_Scheduling_Queue
**			02/23/2016 mem - Add set XACT_ABORT on
**			04/12/2017 mem - Log exceptions to T_Log_Entries
**    
*****************************************************/
(
	@datasetNum varchar(128),
	@callingUser varchar(128) = '',
	@AnalysisToolNameFilter varchar(128) = '',		-- Optional: if not blank, then only considers predefines that match the given tool name (can contain wildcards)
	@ExcludeDatasetsNotReleased tinyint = 1,		-- When non-zero, then excludes datasets with a rating of -5 or -6 (we always exclude datasets with a rating < 2 but <> -10)	
	@PreventDuplicateJobs tinyint = 1,				-- When non-zero, then will not create new jobs that duplicate old jobs
	@InfoOnly tinyint = 0
)
As
	Set XACT_ABORT, nocount on
	
	declare @myError int
	declare @myRowCount int
	Set @myError = 0
	Set @myRowCount = 0

	declare @message varchar(512)
	Set @message = ''
	
	Set @AnalysisToolNameFilter = IsNull(@AnalysisToolNameFilter, '')
	Set @ExcludeDatasetsNotReleased = IsNull(@ExcludeDatasetsNotReleased, 1)
	Set @InfoOnly = IsNull(@InfoOnly, 0)

	BEGIN TRY

	---------------------------------------------------
	-- Auto-populate @callingUser if necessary
	---------------------------------------------------
	
	If IsNull(@callingUser, '') = ''
		Set @callingUser = suser_sname()
	
 	---------------------------------------------------
 	-- Lookup dataset ID
 	---------------------------------------------------
 	DECLARE @state VARCHAR(32) = 'New'
	DECLARE @datasetID INT = 0
	--
	SELECT @datasetID = Dataset_ID
	FROM T_Dataset
	WHERE Dataset_Num = @datasetNum
	
	IF @datasetID = 0
	BEGIN
		SET @message = 'Could not find ID for dataset'
		SET @state = 'Error'
	end

 	---------------------------------------------------
 	-- Add a new row to T_Predefined_Analysis_Scheduling_Queue
 	-- However, if the dataset already exists and has state 'New', don't add another row
 	---------------------------------------------------

	IF EXISTS (SELECT * FROM T_Predefined_Analysis_Scheduling_Queue WHERE Dataset_ID = @datasetID AND State = 'New')
	Begin
		If @InfoOnly <> 0
			Print 'Skip ' + @datasetNum + ' since already has a "New" entry in T_Predefined_Analysis_Scheduling_Queue'
	End
	Else
	Begin
		If @InfoOnly <> 0
			Print 'Add new row to T_Predefined_Analysis_Scheduling_Queue for ' + @datasetNum
		Else
			INSERT INTO dbo.T_Predefined_Analysis_Scheduling_Queue( Dataset_ID,
																	CallingUser,
																	AnalysisToolNameFilter,
																	ExcludeDatasetsNotReleased,
																	PreventDuplicateJobs,
																	State,
																	Message )
			VALUES (@datasetID, 
					@callingUser, 
					@AnalysisToolNameFilter, 
					@ExcludeDatasetsNotReleased,
					@PreventDuplicateJobs,
					@state, 
					@message)
	End
	
	END TRY
	BEGIN CATCH 
		EXEC FormatErrorMessage @message output, @myError output
		Exec PostLogEntry 'Error', @message, 'SchedulePredefinedAnalyses'
	END CATCH

	return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[SchedulePredefinedAnalyses] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SchedulePredefinedAnalyses] TO [DMS_Analysis] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[SchedulePredefinedAnalyses] TO [Limited_Table_Write] AS [dbo]
GO
