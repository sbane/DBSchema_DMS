/****** Object:  StoredProcedure [dbo].[AddNewDataset] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure dbo.AddNewDataset
/****************************************************
**
**	Desc: 
**		Adds new dataset entry to DMS database from contents of XML.
**
**		This is for use by sample automation software
**		associated with the mass spec instrument to
**		create new datasets automatically following
**		an instrument run.
**
**		This procedure is called by the DataImportManager (DIM)
**
**	Return values: 0: success, otherwise, error code
** 
**	Auth:	grk
**			05/04/2007 grk - Ticket #434
**			10/02/2007 grk - Automatically release QC datasets (http://prismtrac.pnl.gov/trac/ticket/540)
**			10/02/2007 mem - Updated to query T_DatasetRatingName for rating 5=Released
**			10/16/2007 mem - Added support for the 'DS Creator (PRN)' field
**			01/02/2008 mem - Now setting the rating to 'Released' for datasets that start with "Blank" (Ticket #593)
**			02/13/2008 mem - Increased size of @Dataset_Name to varchar(128) (Ticket #602)
**			02/26/2010 grk - merged T_Requested_Run_History with T_Requested_Run
**			09/09/2010 mem - Now always looking up the request number associated with the new dataset
**			03/04/2011 mem - Now validating that @Run_Finish is not a future date
**			03/07/2011 mem - Now auto-defining experiment name if empty for QC_Shew and Blank datasets
**						   - Now auto-defining EMSL usage type to Maintenance for QC_Shew and Blank datasets
**			05/12/2011 mem - Now excluding Blank%-bad datasets when auto-setting rating to 'Released'
**			01/25/2013 mem - Now converting @xmlDoc to an XML variable instead of using sp_xml_preparedocument and OpenXML
**			11/15/2013 mem - Now scrubbing "Buzzard:" out of the comment if there is no other text
**			06/20/2014 mem - Now removing "Buzzard:" from the end of the comment
**			12/18/2014 mem - Replaced QC_Shew_1[0-9] with QC_Shew[_-][0-9][0-9]
**			03/25/2015 mem - Now also checking the dataset's experiment name against dbo.DatasetPreference() to see if we should auto-release the dataset
**			05/29/2015 mem - Added support for "Capture Subfolder"
**			06/22/2015 mem - Now ignoring "Capture Subfolder" if it is an absolute path
**			11/21/2016 mem - Added parameter @logDebugMessages
**    
*****************************************************/
(
	@xmlDoc varchar(4000),
	@mode varchar(24) = 'add', --  'add', 'parse_only', 'update', 'bad', 'check_add', 'check_update'
    @message varchar(512) output,
    @logDebugMessages tinyint = 1
)
AS
	Set nocount on

	Declare @myError int
	Declare @myRowCount int
	Set @myError = 0
	Set @myRowCount = 0

	Declare @hDoc int
	Declare @dsid int

	Declare @tmp int

	Declare @internalStandards varchar(64)
	Declare @AddUpdateTimeStamp datetime
	
	Declare @RunStartDate datetime
	Declare @RunFinishDate datetime
	
	Set @message = ''
	Set @logDebugMessages = IsNull(@logDebugMessages, 0)
	
	Declare
		@Dataset_Name		varchar(128) = '',
		@Experiment_Name	varchar(64)  = '',
		@Instrument_Name	varchar(64)  = '',
		@CaptureSubfolder   varchar(255) = '',
		@Separation_Type	varchar(64)  = '',
		@LC_Cart_Name		varchar(128) = '',
		@LC_Column			varchar(64)  = '',
		@Wellplate_Number	varchar(64)  = '',
		@Well_Number		varchar(64)  = '',
		@Dataset_Type		varchar(64)  = '',
		@Operator_PRN		varchar(64)  = '',
		@Comment			varchar(512) = '',
		@Interest_Rating	varchar(32)  = '',
		@Request			int          = '', -- @requestID; this might get updated by AddUpdateDataset
		@EMSL_Usage_Type	varchar(50)  = '',
		@EMSL_Proposal_ID	varchar(10)  = '',
		@EMSL_Users_List	varchar(1024)  = '',
		@Run_Start		    varchar(64)    = '',
		@Run_Finish		    varchar(64)    = '',
		@DatasetCreatorPRN	varchar(128)   = ''
		
		-- Note that @DatasetCreatorPRN is the PRN of the person that created the dataset; 
		-- It is typically only present in trigger files created due to a dataset manually being created by a user

	---------------------------------------------------
	--  Create temporary table to hold list of parameters
	---------------------------------------------------
 
 	CREATE TABLE #TPAR (
		paramName varchar(128),
		paramValue varchar(512)
	)
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	If @myError <> 0
	Begin
		Set @message = 'Failed to create temporary parameter table'
		goto DONE
	End

	---------------------------------------------------
	-- Convert @xmlDoc to XML
	---------------------------------------------------
	
	Declare @xml xml = Convert(xml, @xmlDoc)
	
 	---------------------------------------------------
	-- Populate parameter table from XML parameter description  
	---------------------------------------------------

	INSERT INTO #TPAR (paramName, paramValue)
	SELECT [Name], IsNull([Value], '')
	FROM ( SELECT  xmlNode.value('@Name', 'varchar(128)') AS [Name], 
	               xmlNode.value('@Value', 'varchar(512)') AS [Value]
	       FROM @xml.nodes('/Dataset/Parameter') AS R(xmlNode)
	) LookupQ
	WHERE NOT [Name] IS NULL
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	If @myError <> 0
	Begin
		Set @message = 'Error populating temporary parameter table'
		goto DONE
	End

	---------------------------------------------------
	-- Trap 'parse_only' mode here
	---------------------------------------------------
	If @mode = 'parse_only'
	Begin
		--
		SELECT CONVERT(char(24), paramName) AS Name, paramValue FROM #TPAR
		goto DONE
	End

 	---------------------------------------------------
	-- Get agruments from parsed parameters
 	---------------------------------------------------

	SELECT	@Dataset_Name		 = paramValue FROM #TPAR WHERE paramName = 'Dataset Name' 
	SELECT	@Experiment_Name	 = paramValue FROM #TPAR WHERE paramName = 'Experiment Name' 
	SELECT	@Instrument_Name	 = paramValue FROM #TPAR WHERE paramName = 'Instrument Name' 
	SELECT  @CaptureSubfolder    = paramValue FROM #TPAR WHERE paramName = 'Capture Subfolder' 
	SELECT	@Separation_Type	 = paramValue FROM #TPAR WHERE paramName = 'Separation Type' 
	SELECT	@LC_Cart_Name		 = paramValue FROM #TPAR WHERE paramName = 'LC Cart Name' 
	SELECT	@LC_Column			 = paramValue FROM #TPAR WHERE paramName = 'LC Column' 
	SELECT	@Wellplate_Number	 = paramValue FROM #TPAR WHERE paramName = 'Wellplate Number' 
	SELECT	@Well_Number		 = paramValue FROM #TPAR WHERE paramName = 'Well Number' 
	SELECT	@Dataset_Type		 = paramValue FROM #TPAR WHERE paramName = 'Dataset Type' 
	SELECT	@Operator_PRN		 = paramValue FROM #TPAR WHERE paramName = 'Operator (PRN)' 
	SELECT	@Comment			 = paramValue FROM #TPAR WHERE paramName = 'Comment' 
	SELECT	@Interest_Rating	 = paramValue FROM #TPAR WHERE paramName = 'Interest Rating' 
	SELECT	@Request			 = paramValue FROM #TPAR WHERE paramName = 'Request' 
	SELECT	@EMSL_Usage_Type	 = paramValue FROM #TPAR WHERE paramName = 'EMSL Usage Type' 
	SELECT	@EMSL_Proposal_ID	 = paramValue FROM #TPAR WHERE paramName = 'EMSL Proposal ID' 
	SELECT	@EMSL_Users_List	 = paramValue FROM #TPAR WHERE paramName = 'EMSL Users List' 
	SELECT	@Run_Start		   	 = paramValue FROM #TPAR WHERE paramName = 'Run Start' 
	SELECT	@Run_Finish		   	 = paramValue FROM #TPAR WHERE paramName = 'Run Finish' 
	SELECT  @DatasetCreatorPRN   = paramValue FROM #TPAR WHERE paramName = 'DS Creator (PRN)'

	
 	---------------------------------------------------
	-- check for QC or Blank datasets
 	---------------------------------------------------

	If dbo.DatasetPreference(@Dataset_Name) <> 0 OR 
	   dbo.DatasetPreference(@Experiment_Name) <> 0 OR
	   (@Dataset_Name LIKE 'Blank%' AND Not @Dataset_Name LIKE '%-bad')
	Begin
		-- Auto set interest rating to 5
		-- Initially set @Interest_Rating to the text 'Released' but then query
		--  T_DatasetRatingName for rating 5 in case the rating name has changed
		
		Set @Interest_Rating = 'Released'

		SELECT @Interest_Rating = DRN_name
		FROM T_DatasetRatingName
		WHERE (DRN_state_ID = 5)
	End

 	---------------------------------------------------
	-- Possibly auto-define the experiment
 	---------------------------------------------------
 	--
	If @Experiment_Name = ''
	Begin
		If @Dataset_Name Like 'Blank%'
			Set @Experiment_Name = 'Blank'
		Else
		If @Dataset_Name Like 'QC_Shew[_-][0-9][0-9][_-][0-9][0-9]%'
			Set @Experiment_Name = Substring(@Dataset_Name, 1, 13)
		
	End
	
 	---------------------------------------------------
	-- Possibly auto-define the @EMSL_Usage_Type
 	---------------------------------------------------
 	--
	If @EMSL_Usage_Type = ''
	Begin
		If @Dataset_Name Like 'Blank%' OR @Dataset_Name Like 'QC_Shew%'
			Set @EMSL_Usage_Type = 'MAINTENANCE'
	End

 	---------------------------------------------------
	-- establish default parameters
 	---------------------------------------------------

	Set @internalStandards  = 'none'
	Set @AddUpdateTimeStamp = GetDate()
	
	---------------------------------------------------
	-- Check for the comment ending in "Buzzard:"
	---------------------------------------------------
	
	Set @Comment = LTrim(RTrim(@Comment))
	If @Comment Like '%Buzzard:'
		Set @Comment = Substring(@Comment, 1, Len(@Comment) - 8)
	
	If @CaptureSubfolder LIKE '[C-Z]:\%'
	Begin
		Set @message = 'Capture subfolder is not a relative path for dataset ' + @Dataset_Name + '; ignoring'
		
		exec PostLogEntry 'Error', @message, 'AddNewDataset'
	   
        Set @CaptureSubfolder = ''
	End
 
	---------------------------------------------------
	-- Create new dataset
	---------------------------------------------------
	exec @myError = AddUpdateDataset
						@Dataset_Name,
						@Experiment_Name,
						@Operator_PRN,
						@Instrument_Name,
						@Dataset_Type,
						@LC_Column,
						@Wellplate_Number,
						@Well_Number,
						@Separation_Type,
						@internalStandards,
						@Comment,
						@Interest_Rating,
						@LC_Cart_Name,
						@EMSL_Proposal_ID,
						@EMSL_Usage_Type,
						@EMSL_Users_List,
						@Request,
						@mode,
						@message output,
						@CaptureSubfolder=@CaptureSubfolder,
						@logDebugMessages=@logDebugMessages
	If @myError <> 0
	Begin
		RAISERROR (@message, 10, 1)
		return 51032
	End

	---------------------------------------------------
	-- Trap 'check' modes here
	---------------------------------------------------
	If @mode = 'check_add' OR @mode = 'check_update'
		goto DONE


	---------------------------------------------------
	-- It's possible that @Request got updated by AddUpdateDataset
	-- Lookup the current value
	---------------------------------------------------
	
	-- First use Dataset Name to lookup the Dataset ID
	--		
	Set @dsid = 0
	--
	SELECT @dsid = Dataset_ID
	FROM T_Dataset
	WHERE (Dataset_Num = @Dataset_Name)
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	If @myError <> 0
	Begin
		Set @message = 'Error trying to resolve dataset ID'
		RAISERROR (@message, 10, 1)
		return 51034
	End
	If @dsid = 0
	Begin
		Set @message = 'Could not resolve dataset ID'
		RAISERROR (@message, 10, 1)
		return 51035
	End
	
	---------------------------------------------------
	-- Find request associated with dataset
	---------------------------------------------------
	
	Set @tmp = 0
	--
	SELECT @tmp = ID
	FROM T_Requested_Run
	WHERE (DatasetID = @dsid)		
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	If @myError <> 0
	Begin
		Set @message = 'Error trying to resolve request ID'
		RAISERROR (@message, 10, 1)
		return 51036
	End
	
	If @tmp <> 0
		Set @Request = @tmp
	
	
	If Len(@DatasetCreatorPRN) > 0
	Begin -- <a>
		---------------------------------------------------
		-- Update T_Event_Log to reflect @DatasetCreatorPRN creating this dataset
		---------------------------------------------------
		
		UPDATE T_Event_Log
		SET Entered_By = @DatasetCreatorPRN + '; via ' + IsNull(Entered_By, '')
		FROM T_Event_Log
		WHERE Target_ID = @dsid AND
				Target_State = 1 AND 
				Target_Type = 4 AND 
				Entered Between @AddUpdateTimeStamp AND DateAdd(minute, 1, @AddUpdateTimeStamp)
			
	End -- </a>
		

	---------------------------------------------------
	-- Update the associated request with run start/finish values
	---------------------------------------------------

	If @Request <> 0
	Begin
	
		If @Run_Start <> ''
			Set @RunStartDate = Convert(datetime, @Run_Start)
		Else
			Set @RunStartDate = Null
			
		If @Run_Finish <> ''
			Set @RunFinishDate = Convert(datetime, @Run_Finish)
		Else
			Set @RunFinishDate = Null
			
		If Not @RunStartDate Is Null and Not @RunFinishDate Is Null
		Begin
			-- Check whether the @RunFinishDate value is in the future
			-- If it is, update it to match @RunStartDate
			If DateDiff(day, GetDate(), @RunFinishDate) > 1
				Set @RunFinishDate = @RunStartDate			
		End
		
		UPDATE T_Requested_Run
		SET
			RDS_Run_Start = @RunStartDate, 
			RDS_Run_Finish = @RunFinishDate
		WHERE (ID = @Request)
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		--
		If @myError <> 0
		Begin
			set @message = 'Error trying to update run times'
			RAISERROR (@message, 10, 1)
			return 51033
		End
	End

 	---------------------------------------------------
	-- Done
 	---------------------------------------------------
Done:
	return @myError


GO
GRANT VIEW DEFINITION ON [dbo].[AddNewDataset] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddNewDataset] TO [DMS_Analysis_Job_Runner] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddNewDataset] TO [DMS_DS_Entry] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[AddNewDataset] TO [Limited_Table_Write] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddNewDataset] TO [svc-dms] AS [dbo]
GO
