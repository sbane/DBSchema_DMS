/****** Object:  StoredProcedure [dbo].[CreateJobSteps] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CreateJobSteps
/****************************************************
**
**	Desc: 
**    Make entries in job steps table and job step 
**    dependency table for each newly added job
**    according to definition of script for that job
**	
**	Return values: 0: success, otherwise, error code
**
**
**	Example usage for debugging:
**
**		DECLARE @message VARCHAR(256)
**		EXEC CreateJobSteps @message output, 1, 'CreateFromImportedJobs', @existingJob=555225
**		SELECT @message
**
**
**	Auth:	grk
**			05/06/2008 grk - Initial release (http://prismtrac.pnl.gov/trac/ticket/666)
**			01/28/2009 grk - Modified for parallelization (http://prismtrac.pnl.gov/trac/ticket/718)
**			01/30/2009 grk - Modified output folder name initiation (http://prismtrac.pnl.gov/trac/ticket/719)
**			02/06/2009 grk - modified for extension jobs (http://prismtrac.pnl.gov/trac/ticket/720)
**			02/08/2009 mem - Added parameters @DebugMode and @JobOverride
**			02/26/2009 mem - Removed old Script_ID column from the temporary tables
**			03/11/2009 mem - Removed parameter @JobOverride since @existingJob can be used to specify an existing job
**						   - Added mode 'UpdateExistingJob' (Ticket #725, http://prismtrac.pnl.gov/trac/ticket/725)
**			06/01/2009 mem - Added indices on the temporary tables (Ticket #738, http://prismtrac.pnl.gov/trac/ticket/738)
**						   - Added parameter @MaxJobsToProcess
**			06/04/2009 mem - Added parameters @LogIntervalThreshold, @LoggingEnabled, and @LoopingUpdateInterval
**			12/21/2009 mem - Now displaying additional information when @DebugMode is non-zero
**			01/05/2010 mem - Renamed parameter @extensionScriptNameList to @extensionScriptName
**						   - Added parameter @extensionScriptSettingsFileOverride
**			10/22/2010 mem - Now passing @DebugMode to MergeJobsToMainTables
**			01/06/2011 mem - Now passing @IgnoreSignatureMismatch to CrossCheckJobParameters
**			03/21/2011 mem - Now passing @DebugMode to FinishJobCreation
**			05/25/2011 mem - Updated call to CreateStepsForJob
**			10/17/2011 mem - Now populating column Memory_Usage_MB using UpdateJobStepMemoryUsage
**			09/24/2014 mem - Rename Job in T_Job_Step_Dependencies
**			09/14/2015 mem - Now passing @DebugMode to MoveJobsToMainTables
**						   - Verify that T_Step_Tool_Versions has Tool_Version_ID 1 (unknown)
**			11/09/2015 mem - Assure that Dataset_ID is only if the dataset name is 'Aggregation'
**			05/12/2017 mem - Verify that T_Remote_Info has Remote_Info_ID 1 (unknown)
**    
*****************************************************/
(
	@message varchar(512) output,
	@mode varchar(32) = 'CreateFromImportedJobs',	-- Modes: CreateFromImportedJobs, ExtendExistingJob, UpdateExistingJob (rarely used)
	@existingJob int = 0,							-- Used If @mode = 'ExtendExistingJob' or @mode = 'UpdateExistingJob'; when @DebugMode <> 1, then can also be used when @mode = 'CreateFromImportedJobs'
	@extensionScriptName varchar(512) = '',						-- Only used If @mode = 'ExtendExistingJob'; name of the job script to apply when extending an existing job
	@extensionScriptSettingsFileOverride varchar(256) = '',		-- Only used If @mode = 'ExtendExistingJob'; new settings file to use instead of the one defined in DMS
	@MaxJobsToProcess int = 0,
	@LogIntervalThreshold int = 15,		-- If this procedure runs longer than this threshold, then status messages will be posted to the log
	@LoggingEnabled tinyint = 0,		-- Set to 1 to immediately enable progress logging; If 0, then logging will auto-enable If @LogIntervalThreshold seconds elapse
	@LoopingUpdateInterval int = 5,		-- Seconds between detailed logging while looping through the dependencies
	@infoOnly tinyint = 0,
	@DebugMode tinyint = 0				-- When setting this to 1, you can optionally specify a job using @existingJob to view the steps that would be created for that job.  Also, when this is non-zero, various debug tables will be shown
)
As
	Set nocount on
	
	declare @myError int
	declare @myRowCount int
	Set @myError = 0
	Set @myRowCount = 0
	
	declare @StepCount int
	declare @StepCountNew int
	Set @StepCount= 0
	Set @StepCountNew = 0
	
	Declare @MaxJobsToAdd int

	declare @StartTime datetime
	declare @LastLogTime datetime
	declare @StatusMessage varchar(512)	

	Declare @JobCountToProcess int
	Declare @JobsProcessed int

	Declare @errorMessage varchar(512)
	
	---------------------------------------------------
	-- create temporary tables to accumulate job steps
	-- job step dependencies, and job parameters for
	-- jobs being created
	---------------------------------------------------

	CREATE TABLE #Jobs (
		[Job] int NOT NULL,
		[Priority] int NULL,
		[Script] varchar(64) NULL,
		[State] int NOT NULL,
		[Dataset] varchar(128) NULL,
		[Dataset_ID] int NULL,
		[Results_Folder_Name] varchar(128) NULL
	)

	CREATE INDEX #IX_Jobs_Job ON #Jobs (Job)
	
	CREATE TABLE #Job_Steps (
		[Job] int NOT NULL,
		[Step_Number] int NOT NULL,
		[Step_Tool] varchar(64) NOT NULL,
		[CPU_Load] [smallint] NULL,
		[Memory_Usage_MB] [int] NULL,
		[Dependencies] tinyint NULL ,
		[Shared_Result_Version] smallint NULL,
		[Filter_Version] smallint NULL,
		[Signature] int NULL,
		[State] tinyint NULL ,
		[Input_Folder_Name] varchar(128) NULL,
		[Output_Folder_Name] varchar(128) NULL,
		[Processor] varchar(128) NULL,
		Special_Instructions varchar(128) NULL
	)

	CREATE INDEX #IX_Job_Steps_Job_Step ON #Job_Steps (Job, Step_Number)

	CREATE TABLE #Job_Step_Dependencies (
		[Job] int NOT NULL,
		[Step_Number] int NOT NULL,
		[Target_Step_Number] int NOT NULL,
		[Condition_Test] varchar(50) NULL,
		[Test_Value] varchar(256) NULL,
		[Enable_Only] tinyint NULL
	)

	CREATE INDEX #IX_Job_Step_Dependencies_Job_Step ON #Job_Step_Dependencies (Job, Step_Number)


	CREATE TABLE #Job_Parameters (
		[Job] int NOT NULL,
		[Parameters] xml NULL
	)

	CREATE INDEX #IX_Job_Parameters_Job ON #Job_Parameters (Job)

	
	---------------------------------------------------
	-- Validate the inputs
	---------------------------------------------------
	Set @message = ''
	Set @infoOnly = IsNull(@infoOnly, 0)
	Set @DebugMode = IsNull(@DebugMode, 0)
	Set @existingJob = IsNull(@existingJob, 0)
	Set @extensionScriptName = IsNull(@extensionScriptName, '')
	Set @extensionScriptSettingsFileOverride = IsNull(@extensionScriptSettingsFileOverride, '')
	
	Set @mode = IsNull(@mode, '')
	Set @MaxJobsToProcess = IsNull(@MaxJobsToProcess, 0)
	
	If @mode Not In ('CreateFromImportedJobs', 'ExtendExistingJob', 'UpdateExistingJob')
	Begin
		Set @message = 'Unknown mode: ' + @Mode
		Set @myError = 50001
		Goto Done
	End

	If @mode = 'ExtendExistingJob'
	Begin
		-- Make sure @existingJob is non-zero
		If @existingJob = 0
		Begin
			Set @message = 'Error: Parameter @existingJob must contain a valid job number to extend an existing job'
			Set @myError = 50002
			Goto Done
		End			

		-- Make sure a valid extension script is defined
		If IsNull(@extensionScriptName, '') = ''
		Begin
			Set @message = 'Error: Parameter @extensionScriptName must be defined when extending an existing job'
			Set @myError = 50002
			Goto Done
		End

		If Not Exists (Select * from T_Scripts WHERE Script = @extensionScriptName)
		Begin
			Set @message = 'Error: Extension script "' + @extensionScriptName + '" not found in T_Scripts'
			Set @myError = 50003
			Goto Done
		End
		
		-- Make sure there are no conflicts in the step numbers in the extension script vs. the script used for the existing job
		
		Exec @myError = ValidateExtensionScriptForJob @existingJob, @extensionScriptName, @message = @message output
		If @myError <> 0
			Goto Done
		
	End
	Else
	Begin
		Set @extensionScriptName = ''
		Set @extensionScriptSettingsFileOverride = ''
	End
	
	Set @StartTime = GetDate()
	Set @LoggingEnabled = IsNull(@LoggingEnabled, 0)
	Set @LogIntervalThreshold = IsNull(@LogIntervalThreshold, 15)
	Set @LoopingUpdateInterval = IsNull(@LoopingUpdateInterval, 5)
	
	If @LogIntervalThreshold = 0
		Set @LoggingEnabled = 1
		
	If @LoopingUpdateInterval < 2
		Set @LoopingUpdateInterval = 2
	
	---------------------------------------------------
	-- Get recently imported jobs that need to be processed
	---------------------------------------------------
	--
	If @mode = 'CreateFromImportedJobs'
	Begin
		If @MaxJobsToProcess > 0
			Set @MaxJobsToAdd = @MaxJobsToProcess
		Else
			Set @MaxJobsToAdd = 1000000
		
		If @DebugMode = 0 OR (@DebugMode <> 0 And @existingJob = 0)
		Begin
			INSERT INTO #Jobs (Job, Priority,  Script,  State,  Dataset,  Dataset_ID, Results_Folder_Name)
			SELECT TOP (@MaxJobsToAdd) Job, Priority,  Script,  State,  Dataset,  Dataset_ID, NULL
			FROM T_Jobs
			WHERE State = 0	
			--
			SELECT @myError = @@error, @myRowCount = @@rowcount
			--
			If @myError <> 0
			Begin
				Set @message = 'Error trying to get jobs for processing'
				goto Done
			End
		End

		If @DebugMode <> 0 And @existingJob <> 0
		Begin
			INSERT INTO #Jobs (Job, Priority,  Script,  State,  Dataset,  Dataset_ID, Results_Folder_Name)
			SELECT Job, Priority,  Script,  State,  Dataset,  Dataset_ID, NULL
			FROM T_Jobs
			WHERE Job = @existingJob
			--
			SELECT @myError = @@error, @myRowCount = @@rowcount

			If @myRowCount = 0
			Begin
				Set @message = 'Job ' + Convert(varchar(12), @existingJob) + ' not found in T_Jobs; unable to continue debugging'
				Set @myError = 50000
				goto Done
			End
		End
	End
	
	---------------------------------------------------
	-- Set up to process extension job
	---------------------------------------------------
	--
	If @mode = 'ExtendExistingJob'
	Begin
		-- populate #jobs with info from existing job
		-- If it only exists in history, restore it to main tables
		exec @myError = SetUpToExtendExistingJob @existingJob, @message
	End
	
	If @mode = 'UpdateExistingJob'
	Begin
		-- Note: As of April 4, 2011, the 'UpdateExistingJob' mode is not used in the DMS_Pipeline database
		--
		If Not Exists (SELECT Job FROM T_Jobs Where Job = @existingJob)
		Begin
			Set @message = 'Job ' + Convert(varchar(12), @existingJob) + ' not found in T_Jobs; unable to update it'
			Set @myError = 50000
			goto Done
		End
		
		INSERT INTO #Jobs
		SELECT Job, Priority,  Script,  State,  Dataset,  Dataset_ID, Results_Folder_Name
		FROM T_Jobs
		WHERE Job = @existingJob
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		--
		If @myError <> 0
		Begin
			Set @message = 'Error trying to get jobs for processing'
			goto Done
		End
	End

	---------------------------------------------------
	-- Make sure T_Step_Tool_Versions as the "Unknown" version (ID=1)
	---------------------------------------------------
	--	
	If Not Exists (Select * from T_Step_Tool_Versions WHERE Tool_Version_ID = 1)
	Begin
		Set IDENTITY_INSERT T_Step_Tool_Versions ON

		Insert Into T_Step_Tool_Versions (Tool_Version_ID, Tool_Version)
		Values (1, 'Unknown')

		Set IDENTITY_INSERT T_Step_Tool_Versions OFF
	End

	---------------------------------------------------
	-- Make sure T_Remote_Info as the "Unknown" version (ID=1)
	---------------------------------------------------
	--	
	If Not Exists (Select * from T_Remote_Info WHERE Remote_Info_ID = 1)
	Begin
		Set IDENTITY_INSERT T_Remote_Info ON

		Insert Into T_Remote_Info (Remote_Info_ID, Remote_Info)
		Values (1, 'Unknown')

		Set IDENTITY_INSERT T_Remote_Info OFF
	End

	---------------------------------------------------
	-- loop through jobs and process them into temp tables
	---------------------------------------------------
	declare @job int
	declare @prevJob int
	declare @scriptName varchar(64)
	declare @resultsFolderName varchar(128)
	declare @dataset varchar(128)
	declare @datasetID int
	declare @done tinyint
	declare @JobList varchar(max)
	
	SELECT @JobCountToProcess = COUNT(*)
	FROM #Jobs
	--
	Set @JobCountToProcess = IsNull(@JobCountToProcess, 0)
	
	Set @done = 0
	Set @prevJob = 0
	Set @JobsProcessed = 0
	Set @LastLogTime = GetDate()
	Set @JobList = ''
	--
	while @done = 0
	Begin -- <a>
		---------------------------------------------------
		-- get next unprocessed job and 
		-- build it into the temporary tables
		---------------------------------------------------
		-- 
		Set @job = 0
		--
		SELECT TOP 1 
			@job = Job,
			@scriptName = Script,
			@dataset = Dataset,
			@datasetID = Dataset_ID,
			@resultsFolderName = ISNULL(Results_Folder_Name, '')
		FROM 
			#Jobs
		WHERE Job > @prevJob
		ORDER BY Job		
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		--
		If @myError <> 0
		Begin
			Set @message = 'Error trying to get next unitiated job'
			goto Done
		End

		---------------------------------------------------
		-- If no job was found, we are done
		-- otherwise, process the job
		---------------------------------------------------
		If @job = 0
			Set @done = 1
		Else
		Begin -- <b>
		
			-- Set up to get next job on next pass
			Set @prevJob = @job
			
			If @datasetID = 0 And @dataset <> 'Aggregation'
			Begin
				Set @errorMessage = 'Dataset_ID can be 0 only when the Dataset name is "Aggregation"'
				Set @myError = 1
			End

			If @datasetID <> 0 And @dataset = 'Aggregation'
			Begin
				Set @errorMessage = 'Dataset_ID must be 0 when the Dataset name is "Aggregation"'
				Set @myError = 1
			End
			
			
			If @myError <> 0
			Begin
				exec PostLogEntry 'Error', @errorMessage, 'CreateJobSteps'

				UPDATE #Jobs
				SET State = 5
				WHERE Job = @job
								
			End
			Else
			Begin -- <c>
				
				If @JobList = ''
					Set @JobList = Convert(varchar(12), @job)
				Else
					Set @JobList = @JobList + ',' + Convert(varchar(12), @job)
				
				declare @pXML xml
				declare @scriptXML xml
				declare @tag varchar(8)
				Set @tag = 'unk'

				-- get contents of script and tag for results folder name
				SELECT @scriptXML = Contents, @tag = Results_Tag 
				FROM T_Scripts 
				WHERE Script = @scriptName

				-- add additional script If extending an existing job
				If @mode = 'ExtendExistingJob' and @extensionScriptName <> ''
				Begin
					declare @scriptXML2 xml
					
					SELECT @scriptXML2 = Contents 
					FROM T_Scripts 
					WHERE Script = @extensionScriptName
					
					Set @scriptXML = convert(varchar(2048), @scriptXML) + convert(varchar(2048), @scriptXML2)
				End
				
				If @debugMode <> 0
					SELECT @scriptXML AS Script_XML
			
				-- get results folder name (and store in job)
				If @mode = 'CreateFromImportedJobs' or @mode = 'UpdateExistingJob'
				Begin
					exec @myError = CreateResultsFolderName @job, @tag, @resultsFolderName output, @message output
				End

				-- get parameters for job (and also store in job parameters)
				-- Parameters are returned in @pXML
				exec @myError = CreateParametersForJob
										@job,
										@pXML output,
										@message output,
										@SettingsFileOverride = @extensionScriptSettingsFileOverride, 
										@DebugMode = @DebugMode

				If @debugMode <> 0
					SELECT @job AS Job, @pXML as PXML

				-- create the basic job structure (steps and dependencies)
				-- Details are stored in #Job_Steps and #Job_Step_Dependencies
				exec @myError = CreateStepsForJob @job, @scriptXML, @resultsFolderName, @message output
					
				-- Calculate signatures for steps that require them (and also handle shared results folders)
				-- Details are stored in #Job_Steps
				exec @myError = CreateSignaturesForJobSteps @job, @pXML, @datasetID, @message output, @DebugMode = @DebugMode

				-- Update the memory usage for job steps that have JavaMemorySize entries defined in the parameters
				-- This updates Memory_Usage_MB in #Job_Steps
				exec @myError = UpdateJobStepMemoryUsage @job, @pXML, @message output

				If @DebugMode <> 0
				Begin
					SELECT @StepCount = COUNT(*) FROM #Job_Steps
					SELECT '#Job_Steps' as [Table], * FROM #Job_Steps
					SELECT '#Job_Step_Dependencies' as [Table], * FROM #Job_Step_Dependencies
				End

				-- handle any step cloning
				exec @myError = CloneJobStep @job, @pXML, @message output

				If @DebugMode <> 0
				Begin
					SELECT @StepCountNew = COUNT(*) FROM #Job_Steps
					
					If @StepCountNew <> @StepCount
					Begin
						SELECT 'Data after Cloning' as Message, * FROM #Job_Steps
						SELECT 'Data after Cloning' as Message, * FROM #Job_Step_Dependencies
					End
				End
				
				-- Handle external DTAs If any
				-- This updates DTA_Gen steps in #Job_Steps for which the job parameters contain parameter 'ExternalDTAFolderName' with value 'DTA_Manual'
				exec @myError = OverrideDTAGenForExternalDTA @job, @pXML, @message output

				-- Perform a mixed bag of operations on the jobs in the temporary tables to finalize them before
				--  copying to the main database tables
				exec @myError = FinishJobCreation @job, @message output, @DebugMode
				
				-- Do current job parameters conflict with existing job?
				If @mode = 'ExtendExistingJob' or @mode = 'UpdateExistingJob'
				Begin -- <d>
					exec @myError = CrossCheckJobParameters @job, @message output, @IgnoreSignatureMismatch=1
					
					If @myError <> 0
					Begin -- <e>
						If @mode = 'UpdateExistingJob'
						Begin
							-- If None of the job steps has completed yet, then it's OK If there are parameter differences
							If Exists (SELECT * FROM T_Job_Steps WHERE Job = @job AND State = 5)
							Begin
								Set @message = 'Conflicting parameters are not allowed when one or more job steps has completed: ' + @message
								Goto Done
							End
							Else
							Begin
								Set @message = ''
								Set @myError = 0
							End
							
						End
						Else
						Begin
							-- Mode is 'ExtendExistingJob'; jump out of the loop
							Goto Done
						End
					End -- <e>
				End -- </d>
				
			End -- </c>
			
			Set @JobsProcessed = @JobsProcessed + 1
		End -- </b>
		
		If DateDiff(second, @LastLogTime, GetDate()) >= @LoopingUpdateInterval
		Begin
			-- Make sure @LoggingEnabled is 1
			Set @LoggingEnabled = 1
			
			Set @StatusMessage = '... Creating job steps: ' + Convert(varchar(12), @JobsProcessed) + ' / ' + Convert(varchar(12), @JobCountToProcess)
			exec PostLogEntry 'Progress', @StatusMessage, 'CreateJobSteps'
			Set @LastLogTime = GetDate()
		End

	End -- </a>

	---------------------------------------------------
	-- we've got new jobs in temp tables - what to do?
	---------------------------------------------------

	If @infoOnly = 0
	Begin
		If @mode = 'CreateFromImportedJobs'
		Begin
			-- Move temp tables to main tables
			exec MoveJobsToMainTables @message output, @DebugMode

			-- Possibly update the input folder using the 
			-- Special_Processing param in the job parameters
			exec UpdateInputFolderUsingSpecialProcessingParam @JobList, @infoOnly=0, @ShowResults=0
		End

		If @mode = 'ExtendExistingJob'
		Begin
			-- Merge temp tables with existing job
			exec MergeJobsToMainTables @message output, @infoOnly = @infoOnly
		End

		If @mode = 'UpdateExistingJob'
		Begin
			-- Merge temp tables with existing job
			exec UpdateJobInMainTables @message output
		End
		
	End
	Else
	Begin
		If @mode = 'ExtendExistingJob'
		Begin
			-- Preview changes that would be made
			exec MergeJobsToMainTables @message output, @infoOnly = @infoOnly
		End
	End
	
	If @LoggingEnabled = 1 Or DateDiff(second, @StartTime, GetDate()) >= @LogIntervalThreshold
	Begin
		Set @LoggingEnabled = 1
		Set @StatusMessage = 'CreateJobSteps complete'
		exec PostLogEntry 'Progress', @StatusMessage, 'CreateJobSteps'
	End
	
	---------------------------------------------------
	-- Exit
	---------------------------------------------------
	--
Done:

	If @DebugMode <> 0 and @mode <> 'ExtendExistingJob'
	Begin
		-- Display the data in #Jobs
		--  (If @mode is 'ExtendExistingJob' then we will have
		--   already done this in MergeJobsToMainTables)
		SELECT * FROM #Jobs
	End

	return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[CreateJobSteps] TO [DDL_Viewer] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[CreateJobSteps] TO [Limited_Table_Write] AS [dbo]
GO
