/****** Object:  View [dbo].[V_Instrument_Class_Detail_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.V_Instrument_Class_Detail_Report
AS
SELECT IN_class AS [Instrument Class], 
    is_purgable AS [Is Purgable], 
    raw_data_type AS [Raw Data Type], 
    requires_preparation AS [Requires Preparation], 
    Allowed_Dataset_Types AS [Allowed Dataset Types]
FROM dbo.T_Instrument_Class

GO
