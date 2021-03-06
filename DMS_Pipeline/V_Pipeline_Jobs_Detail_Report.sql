/****** Object:  View [dbo].[V_Pipeline_Jobs_Detail_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Pipeline_Jobs_Detail_Report]
AS
SELECT J.Job,
       J.Priority,
       J.Script,
       JSN.Name AS Job_State,
       J.State AS Job_State_ID,
       ISNULL(JS.Steps, 0) AS Steps,
       J.Dataset,
       AJ.AJ_settingsFileName AS Settings_File,
       AJ.AJ_parmFileName AS Parameter_File,
       J.Comment,
       J.Owner,
       J.Special_Processing,
       J.DataPkgID AS Data_Package_ID,
       J.Results_Folder_Name,
       J.Imported,
       J.Start,
       J.Finish,
       J.Runtime_Minutes,
       J.Transfer_Folder_Path,
       J.Archive_Busy,
       CONVERT(varchar(MAX), JP.Parameters) AS Parameters
FROM dbo.T_Jobs AS J
     INNER JOIN dbo.T_Job_State_Name AS JSN
       ON J.State = JSN.ID
     INNER JOIN dbo.T_Job_Parameters AS JP
       ON J.Job = JP.Job
     LEFT OUTER JOIN ( SELECT Job,
                              COUNT(*) Steps
                       FROM T_Job_Steps
                       GROUP BY Job ) JS
       ON J.Job = JS.Job
     LEFT OUTER JOIN dbo.S_DMS_T_Analysis_Job AS AJ
       ON J.Job = AJ.AJ_jobID

GO
GRANT VIEW DEFINITION ON [dbo].[V_Pipeline_Jobs_Detail_Report] TO [DDL_Viewer] AS [dbo]
GO
