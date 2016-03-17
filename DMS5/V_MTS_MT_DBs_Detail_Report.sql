/****** Object:  View [dbo].[V_MTS_MT_DBs_Detail_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_MTS_MT_DBs_Detail_Report]
AS
SELECT MTDBs.MT_DB_Name,
       MTDBs.MT_DB_ID,
       MTDBs.Description,
       MTDBs.Organism,
       MTDBs.Campaign,
       MTDBs.MSMS_Jobs,
       MTDBs.MS_Jobs,
       SUM(CASE
               WHEN Task_ID IS NULL THEN 0
               ELSE 1
           END) AS PM_Task_Count,
       MTDBs.Peptide_DB,
       MTDBs.Peptide_DB_Count,
       MTDBs.Server_Name,
       MTDBs.State,
       MTDBs.State_ID,
       MTDBs.Last_Affected
FROM T_MTS_MT_DBs_Cached MTDBs
     LEFT OUTER JOIN T_MTS_Peak_Matching_Tasks_Cached PMTasks
       ON MTDBs.MT_DB_Name = PMTasks.Task_Database
GROUP BY MTDBs.MT_DB_Name, MTDBs.MT_DB_ID, MTDBs.Description, MTDBs.Organism, MTDBs.Campaign,
         MTDBs.MSMS_Jobs, MTDBs.MS_Jobs, MTDBs.Peptide_DB, MTDBs.Peptide_DB_Count, 
         MTDBs.Server_Name, MTDBs.State, MTDBs.State_ID, MTDBs.Last_Affected


GO
GRANT VIEW DEFINITION ON [dbo].[V_MTS_MT_DBs_Detail_Report] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_MTS_MT_DBs_Detail_Report] TO [PNL\D3M580] AS [dbo]
GO
