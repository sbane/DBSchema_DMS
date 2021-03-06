/****** Object:  View [dbo].[V_Settings_Files_Detail_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Settings_Files_Detail_Report]
AS
SELECT ID,
       Analysis_Tool AS [Analysis Tool],
       File_Name AS [File Name],
       Description,
       Active,
	   Job_Usage_Count,
	   MSGFPlus_AutoCentroid,
       HMS_AutoSupersede,
       dbo.[XmlToHTML](contents) AS Contents
FROM dbo.T_Settings_Files



GO
GRANT VIEW DEFINITION ON [dbo].[V_Settings_Files_Detail_Report] TO [DDL_Viewer] AS [dbo]
GO
