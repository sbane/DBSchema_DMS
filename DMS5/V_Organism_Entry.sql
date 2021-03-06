/****** Object:  View [dbo].[V_Organism_Entry] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Organism_Entry]
AS
SELECT Organism_ID AS ID,
       OG_name AS orgName,
       OG_organismDBName AS orgDBName,
       OG_description AS orgDescription,
       OG_Short_Name AS orgShortName,
       OG_Storage_Location AS orgStorageLocation,
       NCBI_Taxonomy_ID AS NCBITaxonomyID,
       T_YesNo.Description AS AutoDefineTaxonomy,
       OG_Domain AS orgDomain,
       OG_Kingdom AS orgKingdom,
       OG_Phylum AS orgPhylum,
       OG_Class AS orgClass,
       OG_Order AS orgOrder,
       OG_Family AS orgFamily,
       OG_Genus AS orgGenus,
       OG_Species AS orgSpecies,
       OG_Strain AS orgStrain,
       NEWT_ID_List AS NEWT_ID_List,
       OG_Active AS orgActive
FROM dbo.T_Organisms Org
     INNER JOIN T_YesNo
       ON Org.Auto_Define_Taxonomy = T_YesNo.Flag


GO
GRANT VIEW DEFINITION ON [dbo].[V_Organism_Entry] TO [DDL_Viewer] AS [dbo]
GO
