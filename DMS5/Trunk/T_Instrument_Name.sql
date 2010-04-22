/****** Object:  Table [dbo].[T_Instrument_Name] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Instrument_Name](
	[IN_name] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Instrument_ID] [int] NOT NULL,
	[IN_class] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_source_path_ID] [int] NULL,
	[IN_storage_path_ID] [int] NULL,
	[IN_capture_method] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_status] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_default_CDburn_sched] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Room_Number] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Description] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_usage] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IN_operations_role] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IN_max_simultaneous_captures] [smallint] NOT NULL,
	[IN_Max_Queued_Datasets] [smallint] NOT NULL,
	[IN_Capture_Exclusion_Window] [real] NOT NULL,
	[IN_Capture_Log_Level] [tinyint] NOT NULL,
 CONSTRAINT [PK_T_Instrument_Name] PRIMARY KEY NONCLUSTERED 
(
	[Instrument_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 10) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_T_Instrument_Name] ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Instrument_Name] ON [dbo].[T_Instrument_Name] 
(
	[IN_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 10) ON [PRIMARY]
GO

/****** Object:  Index [IX_T_Instrument_Name_Class_Name_InstrumentID] ******/
CREATE NONCLUSTERED INDEX [IX_T_Instrument_Name_Class_Name_InstrumentID] ON [dbo].[T_Instrument_Name] 
(
	[IN_class] ASC,
	[IN_name] ASC,
	[Instrument_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 10) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Class] FOREIGN KEY([IN_class])
REFERENCES [T_Instrument_Class] ([IN_class])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Class]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [CK_T_Instrument_Name] CHECK  (([IN_operations_role] = 'Unused' or ([IN_operations_role] = 'QC' or ([IN_operations_role] = 'Research' or ([IN_operations_role] = 'Production' or [IN_operations_role] = 'Unknown')))))
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [CK_T_Instrument_Name]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_status]  DEFAULT ('active') FOR [IN_status]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_usage]  DEFAULT ('') FOR [IN_usage]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_operations_role]  DEFAULT ('Unknown') FOR [IN_operations_role]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_capture_count_max]  DEFAULT (1) FOR [IN_max_simultaneous_captures]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_max_queued_datasets]  DEFAULT (1) FOR [IN_Max_Queued_Datasets]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_capture_exclusion_window]  DEFAULT (11) FOR [IN_Capture_Exclusion_Window]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_capture_log_level]  DEFAULT (1) FOR [IN_Capture_Log_Level]
GO
