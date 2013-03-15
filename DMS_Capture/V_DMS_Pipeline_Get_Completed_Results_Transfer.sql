/****** Object:  View [dbo].[V_DMS_Pipeline_Get_Completed_Results_Transfer] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW V_DMS_Pipeline_Get_Completed_Results_Transfer
AS
SELECT JS.Finish,
       JS.Input_Folder_Name,
       JS.Output_Folder_Name,
       J.Dataset,
       J.Dataset_ID,
       JS.Step_Number,
       JS.Job
FROM S_DMS_Pipeline_T_Job_Steps AS JS
     INNER JOIN S_DMS_Pipeline_T_Jobs AS J
       ON JS.Job = J.Job
WHERE (JS.State = 5) AND
      (JS.Step_Tool = 'Results_Transfer')

GO