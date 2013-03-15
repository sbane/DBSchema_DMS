/****** Object:  View [dbo].[V_GetPipelineJobs] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_GetPipelineJobs]
AS
SELECT AJ.AJ_jobID AS Job,
       AJ.AJ_priority AS Priority,
       AnTool.AJT_toolName AS Tool,
       DS.Dataset_Num AS Dataset,
       DS.Dataset_ID,
       AJ.AJ_settingsFileName AS Settings_File_Name,
       AJ.AJ_StateID AS State,
       SPath.SP_vol_name_client + 'DMS3_XFER\' + DS.Dataset_Num + '\' AS Transfer_Folder_Path,
       AJ.AJ_Comment AS Comment,
       AJ.AJ_specialProcessing as Special_Processing,
       AJ.AJ_Owner AS Owner
FROM dbo.T_Analysis_Job AS AJ
     INNER JOIN dbo.T_Dataset_Archive AS DA
       ON AJ.AJ_datasetID = DA.AS_Dataset_ID
     INNER JOIN dbo.T_Analysis_Tool AnTool
       ON AJ.AJ_analysisToolID = AnTool.AJT_toolID
     INNER JOIN dbo.T_Dataset DS
       ON AJ.AJ_datasetID = DS.Dataset_ID AND
          DA.AS_Dataset_ID = DS.Dataset_ID
     INNER JOIN dbo.t_storage_path SPath
       ON DS.DS_storage_path_ID = SPath.SP_path_ID
WHERE (AJ.AJ_StateID IN (1, 8)) AND
      (
		-- If a QC_Shew dataset has been dispositioned (DS_Rating >= 1), then allow an analysis job to run even if the dataset has not yet been archived (or archiving is in progress)
		--   We do, however, prevent analysis if a purge is in progress
		-- For all other datasets, we require that the dataset be archived (states 3 or 10) or purged (states 4, 9, 14, 15)
        (Dataset_Num Like 'QC_Shew%' AND DS.DS_Rating >= 1 AND NOT DA.AS_state_ID IN (5,6,7))
        OR
        (DA.AS_state_ID IN (3, 4, 9, 10, 14, 15))
      )


GO
GRANT VIEW DEFINITION ON [dbo].[V_GetPipelineJobs] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_GetPipelineJobs] TO [PNL\D3M580] AS [dbo]
GO