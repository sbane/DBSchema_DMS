/****** Object:  StoredProcedure [dbo].[GetParamFileCrosstab] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure dbo.GetParamFileCrosstab
/****************************************************
** 
**	Desc:	Returns a crosstab table displaying modification details
**			by Sequset or X!Tandem parameter file
**		
**	Return values: 0: success, otherwise, error code
** 
**	Date:	12/05/2006 mem - Initial version (Ticket #337)
**			12/11/2006 mem - Renamed from GetSequestParamFileCrosstab to GetParamFileCrosstab (Ticket #342)
**						   - Added parameters @ParameterFileTypeName and @ShowValidOnly
**						   - Updated to call PopulateParamFileInfoTableSequest and PopulateParamFileModInfoTable 
**    
*****************************************************/
(
	@ParameterFileTypeName varchar(64) = 'Sequest',		-- Should be 'Sequest' or 'XTandem'
	@ParameterFileFilter varchar(128) = '',				-- Optional parameter file name filter
	@ShowValidOnly tinyint = 0,							-- Set to 1 to only show "Valid" parameter files
	@ShowModSymbol tinyint = 0,							-- Set to 1 to display the modification symbol
	@ShowModName tinyint = 1,							-- Set to 1 to display the modification name
	@ShowModMass tinyint = 1,							-- Set to 1 to display the modification mass
	@UseModMassAlternativeName tinyint = 1,
	@message varchar(512) = '' output
)
As
	set nocount on
	
	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0

	Declare @ParamFileInfoColumnList varchar(512)
	Set @ParamFileInfoColumnList = ''

	Declare @S varchar(2048)

	Declare @AddWildcardChars tinyint
	Set @AddWildcardChars = 1
	
	-----------------------------------------------------------
	-- Validate the inputs
	-----------------------------------------------------------
	Set @ParameterFileTypeName = IsNull(@ParameterFileTypeName, 'Sequest')
	Set @ParameterFileFilter = IsNull(@ParameterFileFilter, '')
	Set @ShowValidOnly = IsNull(@ShowValidOnly, 0)
	Set @ShowModSymbol = IsNull(@ShowModSymbol, 0)
	Set @ShowModName = IsNull(@ShowModName, 1)
	Set @ShowModMass = IsNull(@ShowModMass, 1)
	Set @UseModMassAlternativeName = IsNull(@UseModMassAlternativeName, 1)
	Set @message = ''
	
	-- Make sure @ParameterFileTypeName is of a known type
	If @ParameterFileTypeName <> 'Sequest' and @ParameterFileTypeName <> 'XTandem'
	Begin
		Set @message = 'Uknown parameter file type: ' + @ParameterFileTypeName + '; should be Sequest or XTandem'
		Set @myError = 50000
		Goto Done
	End
	
	If Len(@ParameterFileFilter) > 0
	Begin
		If @AddWildcardChars <> 0
			If CharIndex('%', @ParameterFileFilter) = 0
				Set @ParameterFileFilter = '%' + @ParameterFileFilter + '%'
	End
	Else
		Set @ParameterFileFilter = '%'

	-- Assure that one of the following is non-zero
	If @ShowModSymbol = 0 AND @ShowModName = 0 AND @ShowModMass = 0 
		Set @ShowModName = 1


	-----------------------------------------------------------
	-- Create some temporary tables
	-----------------------------------------------------------

	CREATE TABLE #TmpParamFileInfo (
		Param_File_ID Int NOT NULL,
		Date_Created datetime NULL,
		Date_Modified datetime NULL
	)
	CREATE UNIQUE CLUSTERED INDEX #IX_TempTable_ParamFileInfo_Param_File_ID ON #TmpParamFileInfo(Param_File_ID)

	CREATE TABLE #TmpParamFileModResults (
		Param_File_ID int
	)
	CREATE UNIQUE INDEX #IX_TempTable_TmpParamFileModResults_Param_File_ID ON #TmpParamFileModResults(Param_File_ID)

	-----------------------------------------------------------
	-- Populate a temporary table with the parameter files
	-- matching @ParameterFileFilter
	-----------------------------------------------------------

	INSERT INTO #TmpParamFileInfo (Param_File_ID, Date_Created, Date_Modified)
	SELECT PF.Param_File_ID, PF.Date_Created, PF.Date_Modified
	FROM T_Param_File_Types PFT INNER JOIN
		 T_Param_Files PF ON PFT.Param_File_Type_ID = PF.Param_File_Type_ID
	WHERE PFT.Param_File_Type = @ParameterFileTypeName AND 
		  (PF.Valid = 1 OR @ShowValidOnly = 0) AND 
		  PF.Param_File_Name LIKE @ParameterFileFilter
	--	  
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error finding matching parameter files: ' + Convert(varchar(19), @myError)
		goto done
	end

	-----------------------------------------------------------
	-- Possibly append some additional columns to #TmpParamFileInfo,
	--  to be included at the beginning of the crosstab report
	-----------------------------------------------------------
	
	If @ParameterFileTypeName = 'Sequest'
	Begin
		Exec @myError = PopulateParamFileInfoTableSequest
								@ParamFileInfoColumnList = @ParamFileInfoColumnList output, 
								@message = @message output
		If @myError <> 0
			Goto Done
	End
	
	-----------------------------------------------------------
	-- Populate #TmpParamFileModResults
	-----------------------------------------------------------
	Exec @myError = PopulateParamFileModInfoTable	@ShowModSymbol, @ShowModName, @ShowModMass, 
													@UseModMassAlternativeName, 
													@message = @message output
	If @myError <> 0
		Goto Done

	-----------------------------------------------------------
	-- Return the results
	-----------------------------------------------------------
	Set @S = ''
	Set @S = @S + ' SELECT PF.Param_File_Name, PF.Param_File_Description, '
	
	If Len(IsNull(@ParamFileInfoColumnList, '')) > 0
		Set @S = @S +      @ParamFileInfoColumnList + ', '
	
	Set @S = @S +        ' PFMR.*,'
	Set @S = @S +        ' PF.Date_Created, PF.Date_Modified, PF.Valid'
	Set @S = @S + ' FROM #TmpParamFileInfo PFI INNER JOIN'
	Set @S = @S +    ' T_Param_Files PF ON PFI.Param_File_ID = PF.Param_File_ID LEFT OUTER JOIN'
	Set @S = @S +    ' #TmpParamFileModResults PFMR ON PFI.Param_File_ID = PFMR.Param_File_ID'
	Set @S = @S +    ' ORDER BY PF.Param_File_Name'
	
	Exec (@S)
	--	  
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error returning the results: ' + Convert(varchar(19), @myError)
		goto done
	end
	
	-----------------------------------------------------------
	-- Exit
	-----------------------------------------------------------
Done:
	return @myError

GO
GRANT EXECUTE ON [dbo].[GetParamFileCrosstab] TO [DMS_User]
GO
