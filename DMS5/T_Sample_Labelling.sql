/****** Object:  Table [dbo].[T_Sample_Labelling] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Sample_Labelling](
	[Label] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ID] [int] NOT NULL,
	[Reporter_Mz_Min] [float] NULL,
	[Reporter_Mz_Max] [float] NULL,
 CONSTRAINT [PK_T_Sample_Labelling] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
GRANT VIEW DEFINITION ON [dbo].[T_Sample_Labelling] TO [DDL_Viewer] AS [dbo]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Sample_Labelling] ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Sample_Labelling] ON [dbo].[T_Sample_Labelling]
(
	[Label] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
