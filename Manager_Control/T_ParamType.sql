/****** Object:  Table [dbo].[T_ParamType] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_ParamType](
	[ParamID] [int] IDENTITY(1,1) NOT NULL,
	[ParamName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PicklistName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Comment] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_T_ParamType] PRIMARY KEY CLUSTERED 
(
	[ParamID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_T_ParamType_ParamName] ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_ParamType_ParamName] ON [dbo].[T_ParamType] 
(
	[ParamName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
