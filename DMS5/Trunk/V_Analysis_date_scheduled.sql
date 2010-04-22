/****** Object:  View [dbo].[V_Analysis_date_scheduled] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.V_Analysis_date_scheduled
AS
SELECT AJ_jobID AS job, AJ_StateID AS state, 
   { fn YEAR(AJ_created) } AS y, { fn MONTH(AJ_created) } AS m, 
   day(AJ_created) AS d
FROM T_Analysis_Job
GO
GRANT VIEW DEFINITION ON [dbo].[V_Analysis_date_scheduled] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Analysis_date_scheduled] TO [PNL\D3M580] AS [dbo]
GO
