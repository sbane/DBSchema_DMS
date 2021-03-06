/****** Object:  View [dbo].[V_EUS_Import_Instruments] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_EUS_Import_Instruments]
as
SELECT INSTRUMENT_ID,
       INSTRUMENT_NAME,
       EUS_DISPLAY_NAME,
       AVAILABLE_HOURS,
       ACTIVE_SW,
       PRIMARY_INSTRUMENT
FROM OPENQUERY ( EUS, 'SELECT * FROM VW_INSTRUMENTS' ) AS TX

GO
GRANT VIEW DEFINITION ON [dbo].[V_EUS_Import_Instruments] TO [DDL_Viewer] AS [dbo]
GO
