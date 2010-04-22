/****** Object:  View [dbo].[V_Ext_PGDump_Experiment_Ex] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Ext_PGDump_Experiment_Ex
AS
SELECT	E.Exp_ID AS id, 
		E.Experiment_Num AS experiment_name, 
		E.EX_created AS created, 
		O.OG_name AS organism_name, 
		E.EX_reason AS reason, 
		E.EX_cell_culture_list AS biomaterial_list, 
		E.EX_campaign_ID AS campaign_id
FROM	T_Experiments E 
		JOIN	T_Organisms O ON E.EX_organism_ID = O.Organism_ID


GO
GRANT VIEW DEFINITION ON [dbo].[V_Ext_PGDump_Experiment_Ex] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Ext_PGDump_Experiment_Ex] TO [PNL\D3M580] AS [dbo]
GO
