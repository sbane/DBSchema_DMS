/****** Object:  StoredProcedure [dbo].[GetJobStepParamsAsTable] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.GetJobStepParamsAsTable
/****************************************************
**
**	Desc:
**    Get job step parameters for given job step
**
**	Note: Data comes from table T_Job_Parameters in the DMS_Pipeline DB, not from DMS5
**
**
**	Return values: 0: success, otherwise, error code
**
**	Auth:	mem
**			12/04/2009 mem - initial release
**    
*****************************************************/
(
	@jobNumber int,
	@stepNumber int,
    @message varchar(512) = '' output,
    @DebugMode tinyint = 0
)
AS
	set nocount on

	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0
	--
	set @message = ''
	
	---------------------------------------------------
	-- Temporary table to hold job parameters
	---------------------------------------------------
	--
	CREATE TABLE #Tmp_JobParamsTable (
		[Section] Varchar(128),
		[Name] Varchar(128),
		[Value] Varchar(max)
	)

	---------------------------------------------------
	-- Call GetJobStepParamsWork to populate the temporary table
	---------------------------------------------------
		
	exec @myError = GetJobStepParamsWork @jobNumber, @stepNumber, @message output, @DebugMode
	if @myError <> 0
		Goto Done
	
	---------------------------------------------------
	-- Return the contents of #Tmp_JobParamsTable
	---------------------------------------------------
	
	SELECT *
	FROM #Tmp_JobParamsTable
	ORDER BY [Section], [Name], [Value]
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	
	
	---------------------------------------------------
	-- Exit
	---------------------------------------------------
	--
Done:

	return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[GetJobStepParamsAsTable] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[GetJobStepParamsAsTable] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[GetJobStepParamsAsTable] TO [PNL\D3M580] AS [dbo]
GO
