/****** Object:  Table [dbo].[T_Dataset_ScanTypes] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Dataset_ScanTypes](
	[Entry_ID] [int] IDENTITY(1,1) NOT NULL,
	[Dataset_ID] [int] NOT NULL,
	[ScanType] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ScanCount] [int] NULL,
	[ScanFilter] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_T_Dataset_ScanTypes] PRIMARY KEY NONCLUSTERED 
(
	[Entry_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
GRANT VIEW DEFINITION ON [dbo].[T_Dataset_ScanTypes] TO [DDL_Viewer] AS [dbo]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Dataset_ScanTypes_DatasetID_ScanType] ******/
CREATE CLUSTERED INDEX [IX_T_Dataset_ScanTypes_DatasetID_ScanType] ON [dbo].[T_Dataset_ScanTypes]
(
	[Dataset_ID] ASC,
	[ScanType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Dataset_ScanTypes_ScanType_DatasetID] ******/
CREATE NONCLUSTERED INDEX [IX_T_Dataset_ScanTypes_ScanType_DatasetID] ON [dbo].[T_Dataset_ScanTypes]
(
	[ScanType] ASC,
	[Dataset_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
