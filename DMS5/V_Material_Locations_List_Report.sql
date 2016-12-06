/****** Object:  View [dbo].[V_Material_Locations_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Material_Locations_List_Report]
AS
SELECT ML.Tag AS Location,
       T_Material_Freezers.Freezer,
       ML.Shelf,
       ML.Rack,
       ML.Row,
       ML.Col,
       ML.Barcode,
       ML.[Comment],
       ML.Container_Limit AS Limit,
       COUNT(MC.ID) AS Containers,
       ML.Container_Limit - COUNT(MC.ID) AS Available,
       ML.Status,
       ML.ID AS [#ID]
FROM dbo.T_Material_Locations ML
     INNER JOIN T_Material_Freezers
       ON ML.Freezer_Tag = T_Material_Freezers.Freezer_Tag
     LEFT OUTER JOIN dbo.T_Material_Containers MC
       ON ML.ID = MC.Location_ID
WHERE (ML.Status = 'Active')
GROUP BY ML.ID, T_Material_Freezers.Freezer, ML.Shelf, ML.Rack, ML.Row, ML.Barcode, 
         ML.[Comment], ML.Tag, ML.Col, ML.Status, ML.Container_Limit


GO
GRANT VIEW DEFINITION ON [dbo].[V_Material_Locations_List_Report] TO [DDL_Viewer] AS [dbo]
GO
