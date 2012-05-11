/****** Object:  View [dbo].[V_DMS_Datasets_Stale_and_Failed] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW V_DMS_Datasets_Stale_and_Failed
AS
SELECT Dataset,
       Dataset_ID,
       Dataset_Created,
       Instrument,
       State,
       State_Date,
       Storage_Path
FROM S_DMS_V_Datasets_Stale_and_Failed

GO
GRANT VIEW DEFINITION ON [dbo].[V_DMS_Datasets_Stale_and_Failed] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_DMS_Datasets_Stale_and_Failed] TO [PNL\D3M580] AS [dbo]
GO
