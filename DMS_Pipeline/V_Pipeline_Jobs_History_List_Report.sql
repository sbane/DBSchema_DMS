/****** Object:  View [dbo].[V_Pipeline_Jobs_History_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Pipeline_Jobs_History_List_Report]
AS
SELECT J.Job,
       J.Priority,
       J.Script,
       JSN.Name AS Job_State_B,
       'Steps' AS Steps,
       J.Dataset,
       J.Results_Folder_Name,
       J.Imported,
       J.Start,
       J.Finish,
       J.Runtime_Minutes,
       J.DataPkgID,
       J.Owner,
       J.Transfer_Folder_Path,
       J.Comment
FROM dbo.T_Jobs_History J
     INNER JOIN dbo.T_Job_State_Name JSN
       ON J.State = JSN.ID
WHERE J.Most_Recent_Entry = 1


GO
GRANT VIEW DEFINITION ON [dbo].[V_Pipeline_Jobs_History_List_Report] TO [DDL_Viewer] AS [dbo]
GO
