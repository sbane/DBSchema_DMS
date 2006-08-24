/****** Object:  View [dbo].[V_DEPkgr_Experiments] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_DEPkgr_Experiments
AS
SELECT     TOP 100 PERCENT dbo.T_Experiments.Exp_ID AS Experiment_ID, dbo.T_Experiments.Experiment_Num AS Experiment_Name, 
                      dbo.T_Experiments.EX_organism_name AS Organism, dbo.T_Experiments.EX_reason AS Experiment_Description, 
                      dbo.T_Experiments.EX_comment AS Comments, dbo.T_Experiments.EX_created AS Date_Created, 
                      dbo.T_Experiments.EX_Labelling AS Labelling_Type, dbo.T_Enzymes.Enzyme_Name, dbo.T_Users.U_Name AS Prepared_By, 
                      dbo.T_Campaign.Campaign_Num AS Campaign_Name, dbo.T_Experiments.EX_campaign_ID AS Campaign_ID
FROM         dbo.T_Experiments INNER JOIN
                      dbo.T_Enzymes ON dbo.T_Experiments.EX_enzyme_ID = dbo.T_Enzymes.Enzyme_ID INNER JOIN
                      dbo.T_Users ON dbo.T_Experiments.EX_researcher_PRN = dbo.T_Users.U_PRN INNER JOIN
                      dbo.T_Campaign ON dbo.T_Experiments.EX_campaign_ID = dbo.T_Campaign.Campaign_ID
ORDER BY dbo.T_Experiments.Exp_ID

GO
