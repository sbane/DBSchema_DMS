/****** Object:  View [dbo].[V_Instrument_OpsRole_Picklist] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW V_Instrument_OpsRole_Picklist
AS
SELECT DISTINCT IN_operations_role AS val
FROM         dbo.T_Instrument_Name

GO
GRANT VIEW DEFINITION ON [dbo].[V_Instrument_OpsRole_Picklist] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Instrument_OpsRole_Picklist] TO [PNL\D3M580] AS [dbo]
GO
