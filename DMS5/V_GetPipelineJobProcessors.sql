/****** Object:  View [dbo].[V_GetPipelineJobProcessors] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_GetPipelineJobProcessors]
AS
SELECT TAJ.AJ_jobID AS Job,
       P.Processor_Name AS Processor,
	   1 AS General_Processing
	   /*
	    * Deprecated in February 2015; now always reports 1 for General_Processing
       SUM(CASE WHEN PG.Available_For_General_Processing = 'Y' 
                THEN 1
                ELSE 0
           END) AS General_Processing
		*/
FROM dbo.T_Analysis_Job AS TAJ
     INNER JOIN dbo.T_Analysis_Job_Processor_Group_Associations AS PGA
       ON TAJ.AJ_jobID = PGA.Job_ID
     INNER JOIN dbo.T_Analysis_Job_Processor_Group AS PG
       ON PGA.Group_ID = PG.ID
     INNER JOIN dbo.T_Analysis_Job_Processor_Group_Membership AS PGM
       ON PG.ID = PGM.Group_ID
     INNER JOIN dbo.T_Analysis_Job_Processors AS P
       ON PGM.Processor_ID = P.ID
WHERE (PG.Group_Enabled = 'Y') AND
      (PGM.Membership_Enabled = 'Y') AND
      (TAJ.AJ_StateID IN (1,2,8) OR                                            -- Jobs new, in progress, or holding
       TAJ.AJ_StateID = 4 AND TAJ.AJ_Finish > DateAdd(Hour, -2, GetDate()) OR  -- Jobs completed within the last 2 hours
       TAJ.AJ_StateID = 5 AND TAJ.AJ_Start  > DateAdd(day, -30, GetDate())     -- Jobs failed within the last 30 days
       )
GROUP BY TAJ.AJ_jobID, P.Processor_Name


GO
GRANT VIEW DEFINITION ON [dbo].[V_GetPipelineJobProcessors] TO [DDL_Viewer] AS [dbo]
GO
