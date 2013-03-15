/****** Object:  View [dbo].[V_Material_Containers_Picklist] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Material_Containers_Picklist
AS
SELECT     dbo.T_Material_Containers.Tag AS Container, dbo.T_Material_Containers.Type, dbo.T_Material_Containers.Status, 
                      dbo.T_Material_Containers.Comment, dbo.T_Material_Locations.Tag AS Location
FROM         dbo.T_Material_Containers INNER JOIN
                      dbo.T_Material_Locations ON dbo.T_Material_Containers.Location_ID = dbo.T_Material_Locations.ID

GO
GRANT VIEW DEFINITION ON [dbo].[V_Material_Containers_Picklist] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Material_Containers_Picklist] TO [PNL\D3M580] AS [dbo]
GO