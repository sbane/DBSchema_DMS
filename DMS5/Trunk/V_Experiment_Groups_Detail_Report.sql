/****** Object:  View [dbo].[V_Experiment_Groups_Detail_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Experiment_Groups_Detail_Report
AS
SELECT     dbo.T_Experiment_Groups.Group_ID AS ID, dbo.T_Experiment_Groups.EG_Group_Type AS Group_Type, 
                      dbo.T_Experiments.Experiment_Num AS Parent_Experiment, COUNT(dbo.T_Experiment_Group_Members.Exp_ID) AS Members, 
                      dbo.T_Experiment_Groups.EG_Description AS Description, dbo.T_Experiment_Groups.EG_Created AS Created, 
                      dbo.T_Experiment_Groups.Prep_LC_Run_ID AS [Prep LC Run]
FROM         dbo.T_Experiment_Groups LEFT OUTER JOIN
                      dbo.T_Experiment_Group_Members ON dbo.T_Experiment_Groups.Group_ID = dbo.T_Experiment_Group_Members.Group_ID INNER JOIN
                      dbo.T_Experiments ON dbo.T_Experiment_Groups.Parent_Exp_ID = dbo.T_Experiments.Exp_ID
GROUP BY dbo.T_Experiment_Groups.Group_ID, dbo.T_Experiment_Groups.EG_Group_Type, dbo.T_Experiment_Groups.EG_Description, 
                      dbo.T_Experiment_Groups.EG_Created, dbo.T_Experiments.Experiment_Num, dbo.T_Experiment_Groups.Prep_LC_Run_ID


GO
GRANT VIEW DEFINITION ON [dbo].[V_Experiment_Groups_Detail_Report] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Experiment_Groups_Detail_Report] TO [PNL\D3M580] AS [dbo]
GO
