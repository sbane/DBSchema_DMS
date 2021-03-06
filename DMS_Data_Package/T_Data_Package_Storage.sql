/****** Object:  Table [dbo].[T_Data_Package_Storage] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Data_Package_Storage](
	[ID] [int] IDENTITY(10,1) NOT NULL,
	[Path_Local_Root] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Path_Shared_Root] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Path_Web_Root] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Path_Archive_Root] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[State] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_T_Data_Package_Storage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
GRANT VIEW DEFINITION ON [dbo].[T_Data_Package_Storage] TO [DDL_Viewer] AS [dbo]
GO
GRANT SELECT ON [dbo].[T_Data_Package_Storage] TO [DMS_SP_User] AS [dbo]
GO
GRANT UPDATE ON [dbo].[T_Data_Package_Storage] TO [DMS_SP_User] AS [dbo]
GO
ALTER TABLE [dbo].[T_Data_Package_Storage] ADD  CONSTRAINT [DF_T_Data_Package_Storage_State]  DEFAULT ('Active') FOR [State]
GO
