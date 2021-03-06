/****** Object:  Table [dbo].[T_MTS_PT_DBs_Cached] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_MTS_PT_DBs_Cached](
	[Server_Name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Peptide_DB_ID] [int] NOT NULL,
	[Peptide_DB_Name] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[State_ID] [int] NOT NULL,
	[State] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Organism] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Last_Affected] [datetime] NOT NULL,
	[MSMS_Jobs] [int] NULL,
	[SIC_Jobs] [int] NULL,
 CONSTRAINT [PK_T_MTS_PT_DBs_Cached_DBID] PRIMARY KEY NONCLUSTERED 
(
	[Peptide_DB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
GRANT VIEW DEFINITION ON [dbo].[T_MTS_PT_DBs_Cached] TO [DDL_Viewer] AS [dbo]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_MTS_PT_DBs_Cached_DBName] ******/
CREATE CLUSTERED INDEX [IX_T_MTS_PT_DBs_Cached_DBName] ON [dbo].[T_MTS_PT_DBs_Cached]
(
	[Peptide_DB_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_MTS_PT_DBs_Cached_Server_DBName] ******/
CREATE NONCLUSTERED INDEX [IX_T_MTS_PT_DBs_Cached_Server_DBName] ON [dbo].[T_MTS_PT_DBs_Cached]
(
	[Server_Name] ASC,
	[Peptide_DB_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_MTS_PT_DBs_Cached_StateName] ******/
CREATE NONCLUSTERED INDEX [IX_T_MTS_PT_DBs_Cached_StateName] ON [dbo].[T_MTS_PT_DBs_Cached]
(
	[State] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
