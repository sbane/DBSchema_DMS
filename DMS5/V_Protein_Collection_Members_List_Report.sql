/****** Object:  View [dbo].[V_Protein_Collection_Members_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[V_Protein_Collection_Members_List_Report]
AS
SELECT Protein_Collection_ID,
		Protein_Collection,
		Protein_Name,
		Description,
		Reference_ID,
		Residue_Count,
		Monoisotopic_Mass,
		Protein_ID
FROM S_V_Protein_Collection_Member_Names


GO
GRANT VIEW DEFINITION ON [dbo].[V_Protein_Collection_Members_List_Report] TO [DDL_Viewer] AS [dbo]
GO
