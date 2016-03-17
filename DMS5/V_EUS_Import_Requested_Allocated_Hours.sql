/****** Object:  View [dbo].[V_EUS_Import_Requested_Allocated_Hours] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW V_EUS_Import_Requested_Allocated_Hours
as
SELECT     INSTRUMENT_ID, EUS_DISPLAY_NAME, PROPOSAL_ID, REQUESTED_HOURS, ALLOCATED_HOURS, FY
FROM         OPENQUERY(EUS, 'SELECT * FROM VW_REQUESTED_ALLOCATED_HOURS') AS TX
GO
GRANT VIEW DEFINITION ON [dbo].[V_EUS_Import_Requested_Allocated_Hours] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_EUS_Import_Requested_Allocated_Hours] TO [PNL\D3M580] AS [dbo]
GO
