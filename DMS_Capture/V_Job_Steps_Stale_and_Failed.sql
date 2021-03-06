/****** Object:  View [dbo].[V_Job_Steps_Stale_and_Failed] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[V_Job_Steps_Stale_and_Failed] 
AS
SELECT Warning_Message,
       Dataset,
       Dataset_ID,
       Job,
       Script,
       Tool,
       CONVERT(int, RunTime_Minutes) AS RunTime_Minutes,
       CONVERT(decimal(9, 1), Job_Progress) AS Job_Progress,
       RunTime_Predicted_Hours,
       StateName,
       CONVERT(decimal(9, 1), LastCPUStatus_Minutes / 60.0) AS LastCPUStatus_Hours,
       Processor,
       Start,
       Step,
       Completion_Message,
       Evaluation_Message
FROM ( SELECT  CASE WHEN (JS.State = 4 AND DATEDIFF(hour, JS.Start, GetDate()) >= 5 )                               THEN 'Job step running over 5 hours'
                    WHEN (JS.State = 6 AND JS.Start >= DATEADD(day, -14, GETDATE()) AND JS.Job_State <> 101 )       THEN 'Job step failed within the last 14 days'
                    WHEN (NOT FailedJobQ.Job IS Null)                                                               THEN 'Overall job state is "failed"'
                    ELSE ''
                    END AS Warning_Message,
              JS.Job,
              JS.Dataset,
              JS.Dataset_ID,
              JS.Step,
              JS.Script,
              JS.Tool,
              JS.State,
              CASE
                  WHEN JS.State = 4 THEN 'Stale'
                  ELSE CASE WHEN FailedJobQ.Job IS NULL OR JS.State = 6
                       THEN JS.StateName
                       ELSE JS.StateName + ' (Failed in T_Jobs)'
                       END
              END AS StateName,
              JS.Start,
              JS.RunTime_Minutes,
              JS.LastCPUStatus_Minutes,
              JS.Job_Progress,
              JS.RunTime_Predicted_Hours,
              JS.Processor,
              JS.Priority,
              ISNULL(JS.Completion_Message, '') AS Completion_Message,
              ISNULL(JS.Evaluation_Message, '') AS Evaluation_Message
       FROM V_Job_Steps JS
            LEFT OUTER JOIN (
                -- Look for jobs that are failed and started within the last 14 days
                -- The subquery is used to find the highest step state for each job
				SELECT Job,
				       Step_Number AS Step
				FROM ( SELECT JS.Job,
				              JS.Step_Number,
				              JS.State AS StepState,
				              Row_Number() OVER ( PARTITION BY J.Job ORDER BY JS.State DESC ) AS RowRank
				       FROM dbo.T_Jobs J
				            INNER JOIN dbo.T_Job_Steps JS
				              ON J.Job = JS.Job
				       WHERE (J.State = 5) AND
				             (J.Start >= DATEADD(day, -14, GETDATE())) 
				     ) LookupQ
				WHERE RowRank = 1
            ) FailedJobQ ON JS.Job = FailedJobQ.Job AND JS.Step = FailedJobQ.Step
            LEFT OUTER JOIN dbo.T_Local_Processors LP
              ON JS.Processor = LP.Processor_Name
   ) DataQ
WHERE Warning_Message <> ''



GO
GRANT VIEW DEFINITION ON [dbo].[V_Job_Steps_Stale_and_Failed] TO [DDL_Viewer] AS [dbo]
GO
