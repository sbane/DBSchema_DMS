/****** Object:  View [dbo].[V_Local_Processor_Job_Step_Exclusion] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW V_Local_Processor_Job_Step_Exclusion
AS
SELECT LP.Processor_Name, LP.ID, JSE.Step
FROM T_Local_Processor_Job_Step_Exclusion JSE INNER JOIN
   T_Local_Processors LP ON JSE.ID = LP.ID
GO