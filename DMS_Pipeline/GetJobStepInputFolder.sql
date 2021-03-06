/****** Object:  StoredProcedure [dbo].[GetJobStepInputFolder] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetJobStepInputFolder
/****************************************************
**
**	Desc:	Returns the input folder for a given job and optionally job step
**			Useful for determining the input folder for MSGF+ or MzRefinery
**			Use @jobStep and/or @stepToolFilter to specify which job step to target
**
**			If @jobStep is 0 (or null) and @stepToolFilter is '' (or null) preferentially returns
**			the input folder for the primary step tool used by a job (e.g. MSGFPlus)
**
**			First looks for completed job steps in T_Job_Steps
**			If no match, looks in T_Job_Steps_History
**
**	Auth:	mem
**	Date:	02/02/2017 mem - Initial release
**    
*****************************************************/
(
	@job int,									-- Job to search
	@jobStep int = null,						-- Optional job step; 0 or null to use the folder associated with the highest job step
	@stepToolFilter varchar(64) = null,			-- Optional filter, like Mz_Refinery or MSGFPlus
	@inputFolderName varchar(128) = '' output,		-- Matched InputFolder, or '' if no match
	@stepToolMatch varchar(64) = '' output
)
AS
	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0

	declare @message varchar(512)
	set @message  = ''

	Set @job = IsNull(@job, 0)
	Set @jobStep = IsNull(@jobStep, 0)
	Set @stepToolFilter = IsNull(@stepToolFilter, '')
	Set @inputFolderName = ''
	Set @stepToolMatch = ''
	
	---------------------------------------------------
	-- First look in T_Job_Steps
	---------------------------------------------------
	--
	SELECT TOP 1 @inputFolderName = Input_Folder_Name,
	             @stepToolMatch = Step_Tool
	FROM T_Job_Steps JS
	     INNER JOIN T_Step_Tools Tools
	       ON JS.Step_Tool = Tools.Name
	WHERE NOT Step_Tool IN ('Results_Transfer') AND
	      Job = @job AND
	      (@jobStep <= 0 OR
	       Step_Number = @jobStep) AND
	      (@stepToolFilter = '' OR
	       Step_Tool = @stepToolFilter)
	ORDER BY Tools.Primary_Step_Tool DESC, Step_Number DESC
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount

	If @myRowCount = 0
	Begin
		-- No match; try T_Job_Steps_History
		SELECT TOP 1 @inputFolderName = Input_Folder_Name,
		             @stepToolMatch = Step_Tool
		FROM T_Job_Steps_History JS
		     INNER JOIN T_Step_Tools Tools
		       ON JS.Step_Tool = Tools.Name
		WHERE NOT Step_Tool IN ('Results_Transfer') AND
		      Job = @job AND
		      (@jobStep <= 0 OR
		       Step_Number = @jobStep) AND
		      (@stepToolFilter = '' OR
		       Step_Tool = @stepToolFilter)
		ORDER BY Tools.Primary_Step_Tool DESC, Step_Number DESC
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount

	End
  	
	RETURN

GO
GRANT VIEW DEFINITION ON [dbo].[GetJobStepInputFolder] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[GetJobStepInputFolder] TO [DMS_Analysis_Job_Runner] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[GetJobStepInputFolder] TO [Limited_Table_Write] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[GetJobStepInputFolder] TO [svc-dms] AS [dbo]
GO
