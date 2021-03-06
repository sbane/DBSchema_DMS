/****** Object:  View [dbo].[V_Capture_Check_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Capture_Check_Report
AS
SELECT     J.Job, J.Script, JSN.Name AS State, TX.Steps_Retrying AS Retry, TX.Num_Steps AS Steps, TJSX.Step_Tool + ':' + TSSNX.Name AS Active_Step, 
                      J.Dataset, J.Results_Folder_Name, J.Storage_Server, J.Priority, J.Imported, J.Start, J.Finish, J.Instrument, J.Instrument_Class, 
                      J.Max_Simultaneous_Captures, J.Comment
FROM         dbo.T_Jobs AS J INNER JOIN
                      dbo.T_Job_State_Name AS JSN ON J.State = JSN.ID INNER JOIN
                          (SELECT     TJS.Job, COUNT(TJS.Step_Number) AS Num_Steps, MAX(CASE WHEN TJS.State <> 1 THEN TJS.Step_Number ELSE 0 END) 
                                                   AS Active_Step, SUM(CASE WHEN TJS.Retry_Count > 0 AND TJS.Retry_Count < TST.Number_Of_Retries THEN 1 ELSE 0 END) 
                                                   AS Steps_Retrying
                            FROM          dbo.T_Job_Steps AS TJS INNER JOIN
                                                   dbo.T_Step_Tools AS TST ON TJS.Step_Tool = TST.Name INNER JOIN
                                                   dbo.T_Jobs AS J ON TJS.Job = J.Job
                            WHERE      (NOT (J.State IN (3, 101)))
                            GROUP BY TJS.Job) AS TX ON TX.Job = J.Job INNER JOIN
                      dbo.T_Job_Steps AS TJSX ON J.Job = TJSX.Job AND TX.Active_Step = TJSX.Step_Number INNER JOIN
                      dbo.T_Job_Step_State_Name AS TSSNX ON TJSX.State = TSSNX.ID

GO
GRANT VIEW DEFINITION ON [dbo].[V_Capture_Check_Report] TO [DDL_Viewer] AS [dbo]
GO
