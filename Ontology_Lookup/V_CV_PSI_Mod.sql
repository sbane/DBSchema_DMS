/****** Object:  View [dbo].[V_CV_PSI_Mod] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_CV_PSI_Mod]
AS
	SELECT Entry_ID,
		   Term_Name,
		   identifier,
		   Is_Leaf,
		   Parent_term_name,
		   Parent_term_ID,
		   GrandParent_term_name,
		   GrandParent_term_ID
	FROM T_CV_MOD


GO
GRANT VIEW DEFINITION ON [dbo].[V_CV_PSI_Mod] TO [DDL_Viewer] AS [dbo]
GO
