/****** Object:  View [dbo].[V_Dataset_Count_By_Month_11T] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.V_Dataset_Count_By_Month_11T
AS
SELECT year, month, COUNT(*) AS [Number of Datasets Created], 
   CONVERT(varchar(24), month) + '/' + CONVERT(varchar(24), year) 
   AS Date
FROM dbo.V_Dataset_Date_Instr
WHERE (Instrument LIKE '%11T%')
GROUP BY year, month
GO
GRANT VIEW DEFINITION ON [dbo].[V_Dataset_Count_By_Month_11T] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Dataset_Count_By_Month_11T] TO [PNL\D3M580] AS [dbo]
GO
