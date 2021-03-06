/****** Object:  UserDefinedFunction [dbo].[CheckDataPackageDatasetJobCoverage] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.CheckDataPackageDatasetJobCoverage
/****************************************************
**
**  Desc: 
**  Returns a table of dataset job coverage
**
**  Return values: 
**
**  Parameters:
**    
**  Auth:   grk
**  Date:   05/22/2010
**          04/25/2018 - Now joining T_Data_Package_Datasets and T_Data_Package_Analysis_Jobs on Dataset_ID
**    
*****************************************************/
(
    @packageID INT,
    @tool VARCHAR(128),
    @mode VARCHAR(32)
)
RETURNS @table_variable TABLE (Dataset VARCHAR(128), Num int)
AS
BEGIN

    -- Package datasets with no package jobs for tool
    --
    IF @mode = 'NoPackageJobs'
    BEGIN 
        INSERT INTO @table_variable
            ( Dataset, Num )
        SELECT Dataset,
               NULL AS Num
        FROM T_Data_Package_Datasets AS TD
        WHERE (Data_Package_ID = @packageID) AND
              (NOT EXISTS ( SELECT Dataset
                            FROM T_Data_Package_Analysis_Jobs AS TA
                            WHERE Tool = @tool AND
                                  TD.Dataset = Dataset AND
                                  TD.Data_Package_ID = Data_Package_ID 
                          ))
    END
          
    -- Package datasets with no dms jobs for tool
    --
    IF @mode = 'NoDMSJobs'
    BEGIN 
        INSERT INTO @table_variable
            ( Dataset, Num )
        SELECT Dataset,
               NULL AS Num
        FROM T_Data_Package_Datasets AS TD
        WHERE (Data_Package_ID = @packageID) AND
              (NOT EXISTS ( SELECT Dataset
                            FROM S_V_Analysis_Job_List_Report_2 AS TA
                            WHERE Tool = @tool AND
                                  TD.Dataset = Dataset AND
                                  TD.Data_Package_ID = Data_Package_ID 
              ))
    END
  
    IF @mode = 'PackageJobCount'
    BEGIN 
        INSERT INTO @table_variable
            ( Dataset, Num )
        SELECT TD.Dataset,
               SUM(CASE
                       WHEN TJ.Job IS NULL THEN 0
                       ELSE 1
                   END) AS Num
        FROM T_Data_Package_Datasets AS TD
             LEFT OUTER JOIN T_Data_Package_Analysis_Jobs AS TJ
               ON TD.Dataset_ID = TJ.Dataset_ID AND
                  TD.Data_Package_ID = TJ.Data_Package_ID
        GROUP BY TD.Data_Package_ID, TD.Dataset, TJ.Tool
        HAVING TD.Data_Package_ID = @packageID AND
               TJ.Tool = @tool
    END

    RETURN
END


GO
GRANT VIEW DEFINITION ON [dbo].[CheckDataPackageDatasetJobCoverage] TO [DDL_Viewer] AS [dbo]
GO
