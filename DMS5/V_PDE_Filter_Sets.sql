/****** Object:  View [dbo].[V_PDE_Filter_Sets] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_PDE_Filter_Sets]
AS
SELECT     Filter_Set_ID AS Filter_Set_ID, Filter_Set_Name AS Name, Filter_Set_Description AS Description
FROM         dbo.T_Filter_Sets


GO
GRANT VIEW DEFINITION ON [dbo].[V_PDE_Filter_Sets] TO [DDL_Viewer] AS [dbo]
GO
