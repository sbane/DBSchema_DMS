/****** Object:  View [dbo].[V_Purgable_Datasets_NoInterest_NoRecentJob] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[V_Purgable_Datasets_NoInterest_NoRecentJob]
AS
SELECT Dataset_ID,
       StorageServerName,
       ServerVol,
       Created,
       raw_data_type,
       StageMD5_Required,
       MostRecentJob,
       Purge_Priority
FROM V_Purgable_Datasets_NoInterest
WHERE DATEDIFF(DAY, MostRecentJob, GETDATE()) > 60


GO
GRANT VIEW DEFINITION ON [dbo].[V_Purgable_Datasets_NoInterest_NoRecentJob] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Purgable_Datasets_NoInterest_NoRecentJob] TO [PNL\D3M580] AS [dbo]
GO