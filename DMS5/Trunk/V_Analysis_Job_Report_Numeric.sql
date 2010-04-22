/****** Object:  View [dbo].[V_Analysis_Job_Report_Numeric] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_Analysis_Job_Report_Numeric]
AS
SELECT AJ.AJ_jobID AS Job,
       AJ.AJ_priority AS [Pri.],
       AJ.AJ_StateNameCached AS State,
       ATool.AJT_toolName AS [Tool Name],
       DS.Dataset_Num AS Dataset,
       InstName.IN_name AS Instrument,
       AJ.AJ_parmFileName AS [Parm File],
       AJ.AJ_settingsFileName AS [Settings File],
       Org.OG_name AS Organism,
       AJ.AJ_organismDBName AS [Organism DB],
       AJ.AJ_proteinCollectionList AS [Protein Collection List],
       AJ.AJ_proteinOptionsList AS [Protein Options],
       AJ.AJ_comment AS Comment,
       AJ.AJ_created AS Created,
       AJ.AJ_start AS Started,
       AJ.AJ_finish AS Finished,
       Convert(decimal(9,2), AJ.AJ_ProcessingTimeMinutes) AS Runtime,
       ISNULL(AJ.AJ_assignedProcessorName, '(none)') AS CPU,
       ISNULL(AJ.AJ_resultsFolderName, '(none)') AS [Results Folder],
       AJ.AJ_batchID AS Batch,
       AJ.AJ_requestID AS Request,
       AJPG.Group_Name AS [Associated Processor Group],
       Spath.SP_machine_name AS [Storage Server]
FROM dbo.T_Analysis_Job_Processor_Group AS AJPG
     INNER JOIN dbo.T_Analysis_Job_Processor_Group_Associations AS AJPGA
       ON AJPG.ID = AJPGA.Group_ID
     RIGHT OUTER JOIN dbo.T_Analysis_Job AS AJ
                      INNER JOIN dbo.T_Dataset AS DS
                        ON AJ.AJ_datasetID = DS.Dataset_ID
                      INNER JOIN dbo.T_Organisms AS Org
                        ON AJ.AJ_organismID = Org.Organism_ID
                      INNER JOIN dbo.t_storage_path AS Spath
                        ON DS.DS_storage_path_ID = Spath.SP_path_ID
                      INNER JOIN dbo.T_Analysis_Tool AS ATool
                        ON AJ.AJ_analysisToolID = ATool.AJT_toolID
                      INNER JOIN dbo.T_Instrument_Name AS InstName
                        ON DS.DS_instrument_name_ID = InstName.Instrument_ID
       ON AJPGA.Job_ID = AJ.AJ_jobID



GO
GRANT VIEW DEFINITION ON [dbo].[V_Analysis_Job_Report_Numeric] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Analysis_Job_Report_Numeric] TO [PNL\D3M580] AS [dbo]
GO
