/****** Object:  Table [dbo].[T_Instrument_Operation_History] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Instrument_Operation_History](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Instrument] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Entered] [datetime] NOT NULL,
	[EnteredBy] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Note] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_T_Instrument_Operation_History] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
GRANT VIEW DEFINITION ON [dbo].[T_Instrument_Operation_History] TO [DDL_Viewer] AS [dbo]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Instrument_Operation_History_Instrument_Entered] ******/
CREATE NONCLUSTERED INDEX [IX_T_Instrument_Operation_History_Instrument_Entered] ON [dbo].[T_Instrument_Operation_History]
(
	[Instrument] ASC,
	[Entered] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Instrument_Operation_History] ADD  CONSTRAINT [DF_T_Instrument_Operation_History_Entered]  DEFAULT (getdate()) FOR [Entered]
GO
