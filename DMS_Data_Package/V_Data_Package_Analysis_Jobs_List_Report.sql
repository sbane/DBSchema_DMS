/****** Object:  View [dbo].[V_Data_Package_Analysis_Jobs_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Data_Package_Analysis_Jobs_List_Report
AS
SELECT        DPJ.Data_Package_ID AS ID, DPJ.Job, DPJ.Dataset, DPJ.Tool, DPJ.[Package Comment], AJL.Campaign, AJL.Experiment, AJL.Instrument, AJL.[Parm File], 
                         AJL.Settings_File, AJL.Organism, AJL.[Organism DB], AJL.[Protein Collection List], AJL.[Protein Options], AJL.Finished, AJL.Runtime, AJL.[Job Request], 
                         AJL.[Results Folder], AJL.[Archive Folder Path], DPJ.[Item Added], AJL.Comment AS Comment
FROM            dbo.T_Data_Package_Analysis_Jobs AS DPJ INNER JOIN
                         dbo.S_V_Analysis_Job_List_Report_2 AS AJL ON DPJ.Job = AJL.Job

GO
GRANT SELECT ON [dbo].[V_Data_Package_Analysis_Jobs_List_Report] TO [DMS_SP_User] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Data_Package_Analysis_Jobs_List_Report] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Data_Package_Analysis_Jobs_List_Report] TO [PNL\D3M580] AS [dbo]
GO