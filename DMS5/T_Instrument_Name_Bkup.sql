/****** Object:  Table [dbo].[T_Instrument_Name_Bkup] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Instrument_Name_Bkup](
	[IN_name] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Instrument_ID] [int] NOT NULL,
	[IN_class] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_source_path_ID] [int] NULL,
	[IN_storage_path_ID] [int] NULL,
	[IN_capture_method] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_default_CDburn_sched] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Room_Number] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Created] [datetime] NULL,
 CONSTRAINT [PK_T_Instrument_Name_Bkup] PRIMARY KEY CLUSTERED 
(
	[Instrument_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[T_Instrument_Name_Bkup] ADD  CONSTRAINT [DF_T_Instrument_Name_Bkup_IN_Created]  DEFAULT (getdate()) FOR [IN_Created]
GO