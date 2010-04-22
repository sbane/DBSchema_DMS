/****** Object:  View [dbo].[V_MTS_PM_Results_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[V_MTS_PM_Results_List_Report]
AS
SELECT DS.Dataset_Num AS Dataset,
       AJ.AJ_jobID AS Job,
       PM.Tool_Name,
       PM.Job_Start AS Task_Start,
       PM.Results_URL,
       PM.Task_ID,
       PM.State_ID AS Task_State_ID,
       PM.Job_Finish AS Task_Finish,
       PM.Task_Server,
       PM.Task_Database,
       PM.Tool_Version,
       PM.Output_Folder_Path,
       PM.MTS_Job_ID,
       Inst.IN_name AS Instrument
FROM T_Dataset DS
     INNER JOIN T_Analysis_Job AJ
       ON DS.Dataset_ID = AJ.AJ_datasetID
     INNER JOIN T_MTS_Peak_Matching_Tasks_Cached PM
       ON AJ.AJ_jobID = PM.DMS_Job
     INNER JOIN dbo.T_Instrument_Name Inst
       ON DS.DS_instrument_name_ID = Inst.Instrument_ID


GO
