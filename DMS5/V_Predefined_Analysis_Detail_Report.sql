/****** Object:  View [dbo].[V_Predefined_Analysis_Detail_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Predefined_Analysis_Detail_Report]
AS
SELECT PA.AD_ID AS ID, 
    PA.AD_level AS [Level], 
    PA.AD_sequence AS Sequence, 
    PA.AD_instrumentClassCriteria AS [Instrument Class Criteria], 
    PA.AD_nextLevel AS [Next Level], 
    CASE WHEN PA.Trigger_Before_Disposition = 1
		THEN 'Before Disposition' 
		ELSE 'Normal' 
		END AS [Trigger Mode],
	CASE PA.Propagation_Mode
           WHEN 0 THEN 'Export'
           ELSE 'No Export'
       END AS [Export Mode],
    PA.AD_campaignNameCriteria AS [Campaign Criteria], 
    PA.AD_campaignExclCriteria AS [Campaign Exclusion],
    PA.AD_experimentNameCriteria AS [Experiment Criteria], 
    PA.AD_experimentExclCriteria AS [Experiment Exclusion],
    PA.AD_instrumentNameCriteria AS [Instrument Criteria], 
	PA.AD_instrumentExclCriteria AS [Instrument Exclusion], 
    PA.AD_organismNameCriteria AS [Organism Criteria], 
    PA.AD_datasetNameCriteria AS [Dataset Criteria], 
    PA.AD_datasetExclCriteria AS [Dataset Exclusion],
    PA.AD_datasetTypeCriteria AS [Dataset Type Criteria],
    PA.AD_expCommentCriteria AS [Experiment Comment Criteria], 
    PA.AD_labellingInclCriteria AS [Experiment Labelling Criteria], 
    PA.AD_labellingExclCriteria AS [Experiment Labelling Exclusion],
    PA.AD_separationTypeCriteria AS [Separation Criteria],
	PA.AD_scanCountMinCriteria AS [Scan Count Min Criteria],
	PA.AD_scanCountMaxCriteria AS [Scan Count Max Criteria],
    PA.AD_analysisToolName AS [Analysis Tool Name], 
    PA.AD_parmFileName AS [Parmfile Name], 
    PA.AD_settingsFileName AS [Settings File Name], 
    Org.OG_name AS [Organism Name], 
    PA.AD_organismDBName AS [Organism Db Name], 
    PA.AD_proteinCollectionList AS [Protein Collection List], 
    PA.AD_proteinOptionsList AS [Protein Options List], 
    PA.AD_specialProcessing as [Special Processing],
    PA.AD_priority AS priority,
    PA.AD_enabled AS enabled, 
    PA.AD_created AS created, 
    PA.Last_Affected,
    PA.AD_description AS Description, 
    PA.AD_creator AS Creator
FROM T_Predefined_Analysis PA INNER JOIN
     T_Organisms Org ON PA.AD_organism_ID = Org.Organism_ID


GO
GRANT VIEW DEFINITION ON [dbo].[V_Predefined_Analysis_Detail_Report] TO [DDL_Viewer] AS [dbo]
GO
