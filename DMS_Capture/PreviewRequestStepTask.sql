/****** Object:  StoredProcedure [dbo].[PreviewRequestStepTask] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.PreviewRequestStepTask
/****************************************************
**
**	Desc: Previews the next step task that would be returned for a given processor
**
**	Auth:	mem
**			01/06/2011 mem
**			07/26/2012 mem - Now looking up "perspective" for the given manager and then passing @serverPerspectiveEnabled into RequestStepTask
**
*****************************************************/
(
	@processorName varchar(128),
	@JobCountToPreview int = 10,		-- The number of jobs to preview
	@jobNumber int = 0 output,			-- Job number assigned; 0 if no job available
	@parameters varchar(max)='' output, -- job step parameters (in XML)
    @message varchar(512)='' output,
    @infoOnly tinyint = 1				-- 1 to preview the assigned task; 2 to preview the task and see extra status messages; 3 to dump candidate tables and variables
)
As
	set nocount on

	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0
	
	Declare @serverPerspectiveEnabled tinyint = 0
	Declare @perspective varchar(64) = ''
	
	Set @infoOnly = IsNull(@infoOnly, 1)
	If @infoOnly < 1
		Set @infoOnly = 1
	
	-- Lookup the value for "perspective" for this manager in the manager control DB
	SELECT @perspective = ParameterValue
	FROM V_Mgr_Params
	WHERE (ManagerName = @processorName) AND (ParameterName = 'perspective')
	
	If IsNull(@perspective, '') = ''
	Begin
		Set @message = 'The "Perspective" parameter was not found for manager "' + @processorName + '" in V_Mgr_Params'
	End
	
	If @perspective = 'server'
		Set @serverPerspectiveEnabled = 1
	
	Exec RequestStepTask    @processorName, 
							@jobNumber = @jobNumber output, 
							@message = @message output, 
							@infoonly = @infoOnly,
							@JobCountToPreview=@JobCountToPreview,
							@serverPerspectiveEnabled=@serverPerspectiveEnabled

	If Exists (Select * FROM T_Jobs WHERE Job = @JobNumber)
		SELECT @jobNumber AS JobNumber,
		       Dataset,
		       @ProcessorName AS Processor,
		       @parameters AS Parameters,
		       @message AS Message
		FROM T_Jobs
		WHERE Job = @JobNumber
	Else
		SELECT @message as Message

	
	---------------------------------------------------
	-- Exit
	---------------------------------------------------
	--
Done:

	--
	return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[PreviewRequestStepTask] TO [DDL_Viewer] AS [dbo]
GO
