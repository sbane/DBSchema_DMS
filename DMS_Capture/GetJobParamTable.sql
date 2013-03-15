/****** Object:  StoredProcedure [dbo].[GetJobParamTable] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetJobParamTable
/****************************************************
**
**	Desc: 
**		Returns a table filled with the parameters for the
**		given job (from #Jobs) in Section/Name/Value rows
**
**		The calling procedure must create table #Jobs
**
**		CREATE TABLE #Jobs (
**			[Job] int NOT NULL,
**			[Priority] int NULL,
**			[Script] varchar(64) NULL,
**			[State] int NOT NULL,
**			[Dataset] varchar(128) NULL,
**			[Dataset_ID] int NULL,
**			[Results_Folder_Name] varchar(128) NULL,
**			Storage_Server varchar(64) NULL,
**			Instrument varchar(24) NULL,
**			Instrument_Class VARCHAR(32),
**			Max_Simultaneous_Captures int NULL
**		)
**	
**
**	Auth:	grk
**	Date:	09/05/2009 grk - Initial release (http://prismtrac.pnl.gov/trac/ticket/746)
**			01/14/2010 grk - Removed path ID fields
**			05/04/2010 grk - Added instrument class params
**			03/23/2012 mem - Now including EUS_Instrument_ID
**    
*****************************************************/
  (
    @job INT,
    @datasetID INT
  )
AS 
  DECLARE @myError INT
  SET @myError = 0

  DECLARE @myRowCount INT
  SET @myRowCount = 0

  DECLARE @message varchar(512)
  SET @message = ''

	---------------------------------------------------
	-- Table variable to hold job parameters
	---------------------------------------------------
	--
  DECLARE @paramTab TABLE
    (
      [Step_Number] varchar(24),
      [Section] varchar(128),
      [Name] varchar(128),
      [Value] varchar(2000)
    )

  	---------------------------------------------------
	-- locally cached params
	---------------------------------------------------
	--
	declare
		@dataset varchar(255),
		@storage_server_name varchar(255),
		@instrument_name varchar(255),
		@instrument_class varchar(255),
		@max_simultaneous_captures varchar(255)
	--

	SELECT
		@dataset = Dataset,
		@storage_server_name = Storage_Server,
		@instrument_name = Instrument,
		@instrument_class = Instrument_Class,
		@max_simultaneous_captures = Max_Simultaneous_Captures
	FROM
		#Jobs
	WHERE
		Dataset_ID = @datasetID
		AND Job = @job
	--	
	SELECT @myError = @@error, @myRowCount = @@rowcount
		
	INSERT INTO @paramTab ([Step_Number], [Section], [Name], [Value]) VALUES (NULL, 'JobParameters', 'Dataset_ID', @datasetID)
	INSERT INTO @paramTab ([Step_Number], [Section], [Name], [Value]) VALUES (NULL, 'JobParameters', 'Dataset', @dataset)
	INSERT INTO @paramTab ([Step_Number], [Section], [Name], [Value]) VALUES (NULL, 'JobParameters', 'Storage_Server_Name', @storage_server_name)
	INSERT INTO @paramTab ([Step_Number], [Section], [Name], [Value]) VALUES (NULL, 'JobParameters', 'Instrument_Name', @instrument_name)
	INSERT INTO @paramTab ([Step_Number], [Section], [Name], [Value]) VALUES (NULL, 'JobParameters', 'Instrument_Class', @instrument_class)
	INSERT INTO @paramTab ([Step_Number], [Section], [Name], [Value]) VALUES (NULL, 'JobParameters', 'Max_Simultaneous_Captures', @max_simultaneous_captures)

/**/	
  	---------------------------------------------------
	-- basic params
	---------------------------------------------------
	--
	INSERT INTO @paramTab
	SELECT
	  NULL AS Step_Number,
	  'JobParameters' AS [Section],
	  TP.Name,
	  TP.Value
	FROM
	  ( SELECT
		  CONVERT(varchar(2000), Type) AS Dataset_Type,
		  CONVERT(varchar(2000), Folder) AS Folder,
		  CONVERT(varchar(2000), Method) AS Method,
		  CONVERT(varchar(2000), Capture_Exclusion_Window) AS Capture_Exclusion_Window,
		  CONVERT(varchar(2000), Created) AS Created ,
		  CONVERT(varchar(2000), sourceVol) AS Source_Vol,
		  CONVERT(varchar(2000), sourcePath) AS Source_Path,
		  CONVERT(varchar(2000), Storage_Vol) AS Storage_Vol,
		  CONVERT(varchar(2000), Storage_Path) AS Storage_Path,
		  CONVERT(varchar(2000), Storage_Vol_External) AS Storage_Vol_External,
		  CONVERT(varchar(2000), Archive_Server) AS Archive_Server,
		  CONVERT(varchar(2000), Archive_Path) AS Archive_Path,
		  CONVERT(varchar(2000), Archive_Network_Share_Path) AS Archive_Network_Share_Path,
		  CONVERT(varchar(2000), EUS_Instrument_ID) AS EUS_Instrument_ID
		FROM
		  V_DMS_Capture_Job_Parameters
		WHERE
		  Dataset_ID = @datasetID
	  ) TD UNPIVOT ( Value FOR [Name] IN ( Dataset_Type, Folder, Method, Capture_Exclusion_Window, Created , 
											Source_Vol, Source_Path, Storage_Vol, Storage_Path, Storage_Vol_External, 
											Archive_Server, Archive_Path, Archive_Network_Share_Path,
											EUS_Instrument_ID
                   ) ) as TP
	--	
	SELECT @myError = @@error, @myRowCount = @@rowcount
                     
  	---------------------------------------------------
	-- instrument class params
	---------------------------------------------------
	--
	DECLARE @paramXML XML
	DECLARE @rawDataType varchar(32)
	--
	SELECT
		@rawDataType = raw_data_type,
		@paramXML = Params
	FROM
		V_DMS_Instrument_Class
	WHERE
		InstrumentClass = @instrument_class

	INSERT INTO @paramTab
    (Step_Number, [Section], [Name], Value )
	SELECT 
		NULL AS  [Step_Number],
		xmlNode.value('../@name', 'nvarchar(256)') [Section],
		xmlNode.value('@key', 'nvarchar(256)') [Name], 
		xmlNode.value('@value', 'nvarchar(4000)') [Value]
	FROM   @paramXML.nodes('//item') AS R(xmlNode)

	INSERT INTO @paramTab
		( Step_Number, [Section], [Name], Value )
	VALUES
		(NULL, 'JobParameters', 'RawDataType', @rawDataType)
    
  	---------------------------------------------------
	-- output the table of parameters
	---------------------------------------------------

  SELECT
    @job AS Job,
    [Step_Number],
    [Section],
    [Name],
    [Value]
  FROM
    @paramTab
  ORDER BY
    [Section],
    [Name]

  RETURN @myError

GO