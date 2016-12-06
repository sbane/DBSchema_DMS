/****** Object:  View [dbo].[V_LC_Cart_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_LC_Cart_List_Report]
AS
SELECT Cart.ID,
       Cart.Cart_Name AS [Cart Name],
       Cart.Cart_Description AS Description,
       CartState.Name AS [State],
	   Cart.Created
FROM dbo.T_LC_Cart AS Cart
     INNER JOIN dbo.T_LC_Cart_State_Name AS CartState
       ON Cart.Cart_State_ID = CartState.ID
WHERE Cart.ID > 1


GO
GRANT VIEW DEFINITION ON [dbo].[V_LC_Cart_List_Report] TO [DDL_Viewer] AS [dbo]
GO
GRANT SELECT ON [dbo].[V_LC_Cart_List_Report] TO [DMS_LCMSNet_User] AS [dbo]
GO
