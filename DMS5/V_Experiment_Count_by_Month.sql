/****** Object:  View [dbo].[V_Experiment_Count_by_Month] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Experiment_Count_by_Month
AS
SELECT year, month, COUNT(*) 
   AS [Number of Experiments Created], CONVERT(varchar(24), 
   month) + '/' + CONVERT(varchar(24), year) AS Date
FROM dbo.V_Experiment_Date
GROUP BY year, month

GO
GRANT VIEW DEFINITION ON [dbo].[V_Experiment_Count_by_Month] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Experiment_Count_by_Month] TO [PNL\D3M580] AS [dbo]
GO