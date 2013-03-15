/****** Object:  StoredProcedure [dbo].[UpdateDatasetFileInfoXML] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure dbo.UpdateDatasetFileInfoXML
/****************************************************
** 
**	Desc:	Updates the information for the dataset specified by @DatasetID
**			If @DatasetID is 0, then will use the dataset name defined in @DatasetInfoXML
**			If @DatasetID is non-zero, then will validate that the Dataset Name in the XML corresponds
**			to the dataset ID specified by @DatasetID
**
**			Typical XML file contents
**
**			<?xml version="1.0" encoding="utf-8" standalone="yes"?>
**			<DatasetInfo>
**			<Dataset>Shew119-01_17july02_earth_0402-10_4-20</Dataset>
**			<ScanTypes>
**				<ScanType ScanCount="1062" ScanFilterText="+ c ESI Full ms">MS</ScanType>
**				<ScanType ScanCount="3098" ScanFilterText="+ c d Full ms2 0@cid45.00">CID-MSn</ScanType>
**			</ScanTypes>
**			<AcquisitionInfo>
**				<ScanCount>4160</ScanCount>
**				<ScanCountMS>1062</ScanCountMS>
**				<ScanCountMSn>3098</ScanCountMSn>
**				<Elution_Time_Max>150.07</Elution_Time_Max>
**				<AcqTimeMinutes>150.07</AcqTimeMinutes>
**				<StartTime>2002-07-17 05:54:34 PM</StartTime>
**				<EndTime>2002-07-17 08:24:38 PM</EndTime>
**				<FileSizeBytes>10221594</FileSizeBytes>
**			</AcquisitionInfo>
**			<TICInfo>
**				<TIC_Max_MS>3.0909E+08</TIC_Max_MS>
**				<TIC_Max_MSn>8.5635E+07</TIC_Max_MSn>
**				<BPI_Max_MS>1.0159E+08</BPI_Max_MS>
**				<BPI_Max_MSn>1.7138E+07</BPI_Max_MSn>
**				<TIC_Median_MS>1.7715E+07</TIC_Median_MS>
**				<TIC_Median_MSn>37630</TIC_Median_MSn>
**				<BPI_Median_MS>473109</BPI_Median_MS>
**				<BPI_Median_MSn>5512</BPI_Median_MSn>
**			</TICInfo>
**			</DatasetInfo>
**
**
**	Return values: 0: success, otherwise, error code
** 
**	Parameters:
**
**	Auth:	mem
**	Date:	05/03/2010 mem - Initial version
**			05/13/2010 mem - Added parameter @ValidateDatasetType
**			05/14/2010 mem - Now updating T_Dataset_Info.Scan_Types
**			08/03/2010 mem - Removed unneeded fields from the T_Dataset_Info MERGE Source
**			09/01/2010 mem - Now checking for invalid dates and storing Null in Acq_Time_Start and Acq_Time_End if invalid
**			09/09/2010 mem - Fixed bug extracting StartTime and EndTime values
**			09/02/2011 mem - Now calling PostUsageLogEntry
**			08/21/2012 mem - Now including DatasetID in the error message
**    
*****************************************************/
(
	@DatasetID int = 0,					-- If this value is 0, then will determine the dataset name using the contents of @DatasetInfoXML
	@DatasetInfoXML xml,				-- XML describing the properties of a single dataset
	@message varchar(255) = '' output,
	@infoOnly tinyint = 0,
	@ValidateDatasetType tinyint = 1	-- If non-zero, then will call ValidateDatasetType after updating T_Dataset_ScanTypes
)
As
	set nocount on
	
	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0

	Declare @DatasetName varchar(128)
	Declare @DatasetIDCheck int

	Declare @StartTime varchar(32)
	Declare @EndTime varchar(32)
	
	Declare @AcqTimeStart datetime
	Declare @AcqTimeEnd datetime
	
	-----------------------------------------------------------
	-- Create the table to hold the data
	-----------------------------------------------------------

	Declare @DSInfoTable table (
		Dataset_ID int NULL ,
		Dataset_Name varchar (128) NOT NULL ,
		ScanCount int NULL,
		ScanCountMS int NULL,
		ScanCountMSn int NULL,
		Elution_Time_Max real NULL,
		AcqTimeMinutes real NULL,
		Acq_Time_Start datetime NULL,
		Acq_Time_End datetime NULL,
		FileSizeBytes bigint NULL,
	    TIC_Max_MS real NULL,
		TIC_Max_MSn real NULL,
		BPI_Max_MS real NULL,
		BPI_Max_MSn real NULL,
		TIC_Median_MS real NULL,
		TIC_Median_MSn real NULL,
		BPI_Median_MS real NULL,
		BPI_Median_MSn real NULL
	)


	Declare @ScanTypesTable table (
		ScanType varchar(64) NOT NULL,
		ScanCount int NULL,
		ScanFilter varchar(256) NULL
	)

	
	---------------------------------------------------
	-- Validate the inputs
	---------------------------------------------------
	
	Set @DatasetID = IsNull(@DatasetID, 0)
	Set @message = ''
	Set @infoOnly = IsNull(@infoOnly, 0)
	Set @ValidateDatasetType = IsNull(@ValidateDatasetType, 1)

	
	---------------------------------------------------
	-- Parse out the dataset name from @DatasetInfoXML
	-- If this parse fails, there is no point in continuing
	---------------------------------------------------
	
	SELECT @DatasetName = DSName
	FROM (SELECT @DatasetInfoXML.value('(/DatasetInfo/Dataset)[1]', 'varchar(128)') AS DSName
	     ) LookupQ
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error extracting the dataset name from @DatasetInfoXML for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML'
		goto Done
	end
		
	If @myRowCount = 0 or IsNull(@DatasetName, '') = ''
	Begin
		set @message = 'XML in @DatasetInfoXML is not in the expected form for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML; Could not match /DatasetInfo/Dataset'
		Set @myError = 50000
		goto Done
	End
	
	---------------------------------------------------
	-- Parse the contents of @DatasetInfoXML to populate @DSInfoTable
	-- Skip the StartTime and EndTime values for now since they might have invalid dates
	---------------------------------------------------
	--
	INSERT INTO @DSInfoTable (
		Dataset_ID,
		Dataset_Name,
		ScanCount,
		ScanCountMS,
		ScanCountMSn,
		Elution_Time_Max,
		AcqTimeMinutes,
		FileSizeBytes,
		TIC_Max_MS,
		TIC_Max_MSn,
		BPI_Max_MS,
		BPI_Max_MSn,
		TIC_Median_MS,
		TIC_Median_MSn,
		BPI_Median_MS,
		BPI_Median_MSn
	)
	SELECT	@DatasetID AS DatasetID,
			@DatasetName AS Dataset,
			@DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/ScanCount)[1]', 'int') AS ScanCount,
			@DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/ScanCountMS)[1]', 'int') AS ScanCountMS,
			@DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/ScanCountMSn)[1]', 'int') AS ScanCountMSn,
			@DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/Elution_Time_Max)[1]', 'real') AS Elution_Time_Max,
			@DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/AcqTimeMinutes)[1]', 'real') AS AcqTimeMinutes,
			@DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/FileSizeBytes)[1]', 'bigint') AS FileSizeBytes,       
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/TIC_Max_MS)[1]', 'real') AS TIC_Max_MS,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/TIC_Max_MSn)[1]', 'real') AS TIC_Max_MSn,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/BPI_Max_MS)[1]', 'real') AS BPI_Max_MS,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/BPI_Max_MSn)[1]', 'real') AS BPI_Max_MSn,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/TIC_Median_MS)[1]', 'real') AS TIC_Median_MS,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/TIC_Median_MSn)[1]', 'real') AS TIC_Median_MSn,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/BPI_Median_MS)[1]', 'real') AS BPI_Median_MS,
			@DatasetInfoXML.value('(/DatasetInfo/TICInfo/BPI_Median_MSn)[1]', 'real') AS BPI_Median_MSn       
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error extracting data from @DatasetInfoXML for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML'
		goto Done
	end


	---------------------------------------------------
	-- Now parse out the start and end times
	-- Initially extract as strings in case they're out of range for Sql Server's datetime date type
	---------------------------------------------------
	--
	SELECT @StartTime = @DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/StartTime)[1]', 'varchar(32)'),
		   @EndTime = @DatasetInfoXML.value('(/DatasetInfo/AcquisitionInfo/EndTime)[1]', 'varchar(32)')

			
	If IsDate(@StartTime) <> 0
		Set @AcqTimeStart = Convert(datetime, @StartTime)

	If IsDate(@EndTime) <> 0
		Set @AcqTimeEnd = Convert(datetime, @EndTime)
	Else
	Begin
		-- End Time is invalid
		-- If the start time is valid, add the acquisition time length to the end time 
		-- (though, typically, if one is invalid the other will be invalid too)
		-- IMS .UIMF files acquired in summer 2010 had StartTime values of 0410-08-29 (year 410) due to a bug
				
		If Not @AcqTimeStart Is Null
			SELECT @AcqTimeEnd = DateAdd(minute, AcqTimeMinutes, @AcqTimeStart)
			FROM @DSInfoTable
	End
		
	UPDATE @DSInfoTable
	Set Acq_Time_Start = @AcqTimeStart,
		Acq_Time_End = @AcqTimeEnd
		
	
	---------------------------------------------------
	-- Now extract out the ScanType information
	---------------------------------------------------
	--
	INSERT INTO @ScanTypesTable (ScanType, ScanCount, ScanFilter)
	SELECT ScanType, ScanCount, ScanFilter
	FROM (	SELECT  xmlNode.value('.', 'varchar(64)') AS ScanType,
					xmlNode.value('@ScanCount', 'int') AS ScanCount,
					xmlNode.value('@ScanFilterText', 'varchar(256)') AS ScanFilter		
			FROM   @DatasetInfoXML.nodes('/DatasetInfo/ScanTypes/ScanType') AS R(xmlNode)
	) LookupQ
	WHERE Not ScanType IS NULL 	
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error parsing ScanType nodes in @DatasetInfoXML for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML'
		goto Done
	end
	
	---------------------------------------------------
	-- Update or Validate Dataset_ID in @DSInfoTable
	---------------------------------------------------
	--
	If @DatasetID = 0
	Begin
		UPDATE @DSInfoTable
		SET Dataset_ID = DS.Dataset_ID
		FROM @DSInfoTable Target
		     INNER JOIN T_Dataset DS
		       ON Target.Dataset_Name = DS.Dataset_Num
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		
		If @myRowCount = 0
		Begin
			Set @message = 'Warning: dataset "' + @DatasetName + '" not found in table T_Dataset by SP UpdateDatasetFileInfoXML'
			Set @myError = 50001
			Goto Done
		End
		
		-- Update @DatasetID
		SELECT @DatasetID = Dataset_ID
		FROM @DSInfoTable
		
	End
	Else
	Begin
	
		-- @DatasetID was non-zero
		-- Validate the dataset name in @DSInfoTable against T_Dataset
	
		SELECT @DatasetIDCheck = DS.Dataset_ID
		FROM @DSInfoTable Target
		     INNER JOIN T_Dataset DS
		     ON Target.Dataset_Name = DS.Dataset_Num
		       
		If @DatasetIDCheck <> @DatasetID
		Begin
			Set @message = 'Error: dataset ID values for ' + @DatasetName + ' do not match; expecting ' + Convert(varchar(12), @DatasetIDCheck) + ' but stored procedure param @DatasetID is ' + Convert(varchar(12), @DatasetID)
			Set @myError = 50002
			Goto Done
		End
	End
	
	
	If @infoOnly <> 0
	Begin
		-----------------------------------------------
		-- Preview the data, then exit
		-----------------------------------------------
		
		SELECT *
		FROM @DSInfoTable

		SELECT *
		FROM @ScanTypesTable
		
		Goto Done
	End
	
	
	
	-----------------------------------------------
	-- Validate/fix the Acq_Time entries
	-----------------------------------------------

	-- First look for any entries in the temporary table
	-- where Acq_Time_Start is Null while Acq_Time_End is defined
	--	
	UPDATE @DSInfoTable
	SET Acq_Time_Start = Acq_Time_End
	WHERE Acq_Time_Start IS NULL AND NOT Acq_Time_End IS NULL
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount

	-- Now look for the reverse case
	--
	UPDATE @DSInfoTable
	SET Acq_Time_End = Acq_Time_Start
	WHERE Acq_Time_End IS NULL AND NOT Acq_Time_Start IS NULL
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount

	
	-----------------------------------------------
	-- Update T_Dataset with any new or changed values
	-- If Acq_Time_Start Is Null or is <= 1/1/1900 then
	--  the DS_Created time is used for both 
	--  Acq_Time_Start and Acq_Time_End
	-----------------------------------------------
	
	UPDATE T_Dataset
	SET Acq_Time_Start= CASE WHEN IsNull(NewInfo.Acq_Time_Start, '1/1/1900') <= '1/1/1900'
						THEN DS.DS_Created 
						ELSE NewInfo.Acq_Time_Start END,
		Acq_Time_End =  CASE WHEN IsNull(NewInfo.Acq_Time_Start, '1/1/1900') <= '1/1/1900' 
						THEN DS.DS_Created 
						ELSE NewInfo.Acq_Time_End END,
		Scan_Count = NewInfo.ScanCount, 
		File_Size_Bytes = NewInfo.FileSizeBytes, 
		File_Info_Last_Modified = GetDate()		
	FROM @DSInfoTable NewInfo INNER JOIN 
	     T_Dataset DS ON 
		  NewInfo.Dataset_Name = DS.Dataset_Num
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error updating T_Dataset for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML'
		goto Done
	end	
	
	
	-----------------------------------------------
	-- Add/Update T_Dataset_Info using a MERGE statement
	-----------------------------------------------
	--
	MERGE T_Dataset_Info AS target
	USING 
		(SELECT		Dataset_ID, ScanCountMS, ScanCountMSn,
					Elution_Time_Max, AcqTimeMinutes, 
					TIC_Max_MS, TIC_Max_MSn,
					BPI_Max_MS, BPI_Max_MSn,
					TIC_Median_MS, TIC_Median_MSn,
					BPI_Median_MS, BPI_Median_MSn
		 FROM @DSInfoTable
		) AS Source (Dataset_ID, ScanCountMS, ScanCountMSn,
					Elution_Time_Max, AcqTimeMinutes, 
					TIC_Max_MS, TIC_Max_MSn,
					BPI_Max_MS, BPI_Max_MSn,
					TIC_Median_MS, TIC_Median_MSn,
					BPI_Median_MS, BPI_Median_MSn)
	ON (target.Dataset_ID = Source.Dataset_ID)
	WHEN Matched 
		THEN UPDATE 
			Set	ScanCountMS = Source.ScanCountMS,
				ScanCountMSn = Source.ScanCountMSn,
				Elution_Time_Max = Source.Elution_Time_Max,
				TIC_Max_MS = Source.TIC_Max_MS,
				TIC_Max_MSn = Source.TIC_Max_MSn,
				BPI_Max_MS = Source.BPI_Max_MS,
				BPI_Max_MSn = Source.BPI_Max_MSn,
				TIC_Median_MS = Source.TIC_Median_MS,
				TIC_Median_MSn = Source.TIC_Median_MSn,
				BPI_Median_MS = Source.BPI_Median_MS,
				BPI_Median_MSn = Source.BPI_Median_MSn,
				Last_Affected = GetDate()
	WHEN Not Matched THEN
		INSERT ( Dataset_ID, ScanCountMS , 
				ScanCountMSn , Elution_Time_Max , 
				TIC_Max_MS , TIC_Max_MSn , 
				BPI_Max_MS , BPI_Max_MSn , 
				TIC_Median_MS , TIC_Median_MSn , 
				BPI_Median_MS , BPI_Median_MSn , 
				Last_Affected )
		VALUES ( Source.Dataset_ID, Source.ScanCountMS, Source.ScanCountMSn, Source.Elution_Time_Max,
				Source.TIC_Max_MS, Source.TIC_Max_MSn,
				Source.BPI_Max_MS, Source.BPI_Max_MSn,
				Source.TIC_Median_MS, Source.TIC_Median_MSn,
				Source.BPI_Median_MS, Source.BPI_Median_MSn,
				GetDate())
	;
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error updating T_Dataset_Info for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML'
		goto Done
	end	
	

	-----------------------------------------------
	-- Cannot use a Merge statement on T_Dataset_ScanTypes
	--  since some datasets (e.g. MRM) will have multiple entries 
	--  of the same scan type but different ScanFilter values
	-- Thus, simply delete existing rows then add new ones
	-----------------------------------------------
	--
	DELETE FROM T_Dataset_ScanTypes
	WHERE Dataset_ID = @DatasetID
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	
	
	INSERT INTO T_Dataset_ScanTypes ( Dataset_ID, ScanType, ScanCount, ScanFilter )
	SELECT @DatasetID AS Dataset_ID, ScanType, ScanCount, ScanFilter
	FROM @ScanTypesTable
	ORDER BY Dataset_ID, ScanType
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error updating T_Dataset_ScanTypes for DatasetID ' + Convert(varchar(12), @DatasetID) + ' in SP UpdateDatasetFileInfoXML'
		goto Done
	end	
	
	
	-----------------------------------------------
	-- Update the Scan_Types field in T_Dataset_Info for this dataset
	-----------------------------------------------
	--
	UPDATE T_Dataset_Info
	SET Scan_Types = DSTypes.ScanTypeList
	FROM T_Dataset DS
	     INNER JOIN T_Dataset_Info DSInfo
	       ON DSInfo.Dataset_ID = DS.Dataset_ID
	     CROSS APPLY GetDatasetScanTypeList ( DS.Dataset_ID ) DSTypes
	WHERE DS.Dataset_ID = @DatasetID
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount


	-----------------------------------------------
	-- Possibly validate the dataset type defined for this dataset
	-----------------------------------------------
	--
	If @ValidateDatasetType <> 0
		exec dbo.ValidateDatasetType @DatasetID, @message=@message output, @infoonly=@infoOnly

		
	Set @message = 'Dataset info update successful'
	
Done:

	If @myError <> 0
	Begin
		If @message = ''
			Set @message = 'Error in UpdateDatasetFileInfoXML'
		
		Set @message = @message + '; error code = ' + Convert(varchar(12), @myError)
		
		If @InfoOnly = 0
			Exec PostLogEntry 'Error', @message, 'UpdateDatasetFileInfoXML'
	End
	
	If Len(@message) > 0 AND @InfoOnly <> 0
		Print @message

	---------------------------------------------------
	-- Log SP usage
	---------------------------------------------------

	Declare @UsageMessage varchar(512)
	If IsNull(@DatasetName, '') = ''
		Set @UsageMessage = 'Dataset ID: ' + Convert(varchar(12), @DatasetID)
	Else
		Set @UsageMessage = 'Dataset: ' + @DatasetName

	If @InfoOnly = 0
		Exec PostUsageLogEntry 'UpdateDatasetFileInfoXML', @UsageMessage

	Return @myError


GO
GRANT VIEW DEFINITION ON [dbo].[UpdateDatasetFileInfoXML] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[UpdateDatasetFileInfoXML] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[UpdateDatasetFileInfoXML] TO [PNL\D3M580] AS [dbo]
GO