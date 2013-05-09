/****** Object:  Table [dbo].[T_Data_Package_State] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Data_Package_State](
	[Name] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_T_Data_Package_State] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
GRANT SELECT ON [dbo].[T_Data_Package_State] TO [DMS_SP_User] AS [dbo]
GO
GRANT UPDATE ON [dbo].[T_Data_Package_State] TO [DMS_SP_User] AS [dbo]
GO
