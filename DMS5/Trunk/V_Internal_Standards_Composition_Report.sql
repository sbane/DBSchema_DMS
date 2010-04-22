/****** Object:  View [dbo].[V_Internal_Standards_Composition_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.V_Internal_Standards_Composition_Report
AS
SELECT dbo.T_Internal_Std_Components.Name AS Component, 
    dbo.T_Internal_Std_Components.Description AS [Component Description],
     dbo.T_Internal_Std_Composition.Concentration, 
    dbo.T_Internal_Std_Components.Monoisotopic_Mass, 
    dbo.T_Internal_Std_Components.Charge_Minimum, 
    dbo.T_Internal_Std_Components.Charge_Maximum, 
    dbo.T_Internal_Std_Components.Charge_Highest_Abu, 
    dbo.T_Internal_Std_Components.Expected_GANET, 
    dbo.T_Internal_Std_Components.Internal_Std_Component_ID AS
     ID, dbo.T_Internal_Standards.Name AS [#Name]
FROM dbo.T_Internal_Std_Parent_Mixes INNER JOIN
    dbo.T_Internal_Standards ON 
    dbo.T_Internal_Std_Parent_Mixes.Parent_Mix_ID = dbo.T_Internal_Standards.Internal_Std_Parent_Mix_ID
     INNER JOIN
    dbo.T_Internal_Std_Components INNER JOIN
    dbo.T_Internal_Std_Composition ON 
    dbo.T_Internal_Std_Components.Internal_Std_Component_ID = dbo.T_Internal_Std_Composition.Component_ID
     ON 
    dbo.T_Internal_Std_Parent_Mixes.Parent_Mix_ID = dbo.T_Internal_Std_Composition.Mix_ID

GO
GRANT VIEW DEFINITION ON [dbo].[V_Internal_Standards_Composition_Report] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Internal_Standards_Composition_Report] TO [PNL\D3M580] AS [dbo]
GO
