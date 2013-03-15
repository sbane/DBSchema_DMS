/****** Object:  View [dbo].[V_Capture_Local_Processors_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.V_Capture_Local_Processors_List_Report
AS
SELECT     Processor_Name AS [Processor Name], State, Machine, Manager_Version, dbo.GetProcessorStepToolList(Processor_Name) AS Tools, 
                      dbo.GetProcessorAssignedInstrumentList(Processor_Name) AS Instruments, Latest_Request AS [Latest Request], ID
FROM         dbo.T_Local_Processors

GO