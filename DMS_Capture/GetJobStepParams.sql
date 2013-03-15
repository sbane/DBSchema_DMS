/****** Object:  StoredProcedure [dbo].[GetJobStepParams] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetJobStepParams
/****************************************************
**
**	Desc:
**    Get job step parameters for given job step
**    Into temporary table created by caller
**	
**	Return values: 0: success, otherwise, error code
**
**
**	Auth:	grk
**	09/08/2009 -- initial release (http://prismtrac.pnl.gov/trac/ticket/746)
**    
*****************************************************/
(
	@jobNumber int,
	@stepNumber int,
    @message varchar(512) output,
    @DebugMode tinyint = 0
)
AS
	set nocount on

	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0
	--
	declare @stepTool varchar(64)
	declare @inputFolderName varchar(128)
	declare @outputFolderName varchar(128)
	set @stepTool = ''
	set @inputFolderName = ''
	set @outputFolderName = ''
	declare @resultsFolderName varchar(128)
	SET @resultsFolderName = ''

	set @message = ''
		
	---------------------------------------------------
	-- Get basic job step parameters
	---------------------------------------------------
	--
	SELECT
		@stepTool = Step_Tool, 
		@inputFolderName = Input_Folder_Name, 
		@outputFolderName = Output_Folder_Name,
		@resultsFolderName = Results_Folder_Name
	FROM  T_Job_Steps INNER JOIN T_Jobs ON T_Job_Steps.Job = T_Jobs.Job
	WHERE
		T_Job_Steps.Job = @jobNumber AND 
		Step_Number = @stepNumber
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error getting basic job step parameters'
		goto Done
	end
	--
	if @myRowCount = 0
	begin
		set @myError = 42
		set @message = 'Could not find basic job step parameters'
		goto Done
	end

	---------------------------------------------------
	-- Get job step parameters
	---------------------------------------------------
	--
	declare @stepParmSectionName varchar(32)
	set @stepParmSectionName = 'StepParameters'
	--
	INSERT INTO #ParamTab ([Section], [Name], Value) VALUES (@stepParmSectionName, 'Job', @jobNumber)
	INSERT INTO #ParamTab ([Section], [Name], Value) VALUES (@stepParmSectionName, 'Step', @stepNumber)
	INSERT INTO #ParamTab ([Section], [Name], Value) VALUES (@stepParmSectionName, 'StepTool', @stepTool)
	INSERT INTO #ParamTab ([Section], [Name], Value) VALUES (@stepParmSectionName, 'ResultsFolderName', @resultsFolderName)
	INSERT INTO #ParamTab ([Section], [Name], Value) VALUES (@stepParmSectionName, 'InputFolderName', @inputFolderName)
	INSERT INTO #ParamTab ([Section], [Name], Value) VALUES (@stepParmSectionName, 'OutputFolderName', @outputFolderName)

	---------------------------------------------------
	-- Get job parameters
	---------------------------------------------------
	--
	-- to allow for more than one instance of a tool
	-- in a single script, look at parameters in sections 
	-- that either are not locked to any setp 
	-- (step number is null) or are locked to the current step
	--
	INSERT INTO #ParamTab
	SELECT
		xmlNode.value('@Section', 'nvarchar(256)') Section,
		xmlNode.value('@Name', 'nvarchar(256)') Name,
		xmlNode.value('@Value', 'nvarchar(4000)') Value
	FROM
		T_Job_Parameters cross apply Parameters.nodes('//Param') AS R(xmlNode)
	WHERE
		T_Job_Parameters.Job = @jobNumber AND
		((xmlNode.value('@Step', 'nvarchar(128)') IS NULL) OR (xmlNode.value('@Step', 'nvarchar(128)') = @stepNumber))
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error getting job parameters'
		goto Done
	end

	---------------------------------------------------
	-- Exit
	---------------------------------------------------
	--
Done:
	--
	return @myError

GO