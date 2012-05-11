/****** Object:  StoredProcedure [dbo].[GetJobStepParamsToXML] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetJobStepParamsToXML
/****************************************************
**
**	Desc:
**    Get job step parameters as XML
**    from temporary table created and populated by caller
**	
**	Return values: 0: success, otherwise, error code
**
**
**	Auth:	grk
**	09/08/2009 -- initial release (http://prismtrac.pnl.gov/trac/ticket/746)
**    
*****************************************************/
(
	@parameters varchar(max) output, -- job step parameters (in XML)
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
	set @message = ''
	set @parameters = ''

	-- need a separate table to hold sections
	-- for outer nested 'for xml' query
	--
	declare @st table (
		name varchar(64)
	)
	insert into @st(name)
	select distinct Section
	from #ParamTab 

	-- run nested query with sections as outer
	-- query and values as inner query to shape XML
	--
	declare @x xml
	set @x = (
		SELECT 
		  name,
		  (SELECT 
			Name  AS [key],
			IsNull(Value, '') AS [value]
		   FROM   
			#ParamTab item
		   WHERE item.Section = section.name
		         AND Not item.name Is Null
		   for xml auto, type
		  )
		FROM   
		  @st section
		for xml auto, type
	)

	-- add XML version of all parameters to parameter list as its own parameter
	--
	declare @xp varchar(max)
	set @xp = '<sections>' + convert(varchar(max), @x) + '</sections>'

	If @DebugMode > 1
		Print Convert(varchar(32), GetDate(), 21) + ', ' + 'GetJobStepParamsXML: exiting'

	-- Return parameters in XML
	--
	set @parameters = @xp
	--
	return @myError

GO
