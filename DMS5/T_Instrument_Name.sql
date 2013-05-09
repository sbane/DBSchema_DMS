/****** Object:  Table [dbo].[T_Instrument_Name] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Instrument_Name](
	[IN_name] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Instrument_ID] [int] NOT NULL,
	[IN_class] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Group] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IN_source_path_ID] [int] NULL,
	[IN_storage_path_ID] [int] NULL,
	[IN_capture_method] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_status] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Room_Number] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IN_usage] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IN_operations_role] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Percent_EMSL_Owned] [int] NOT NULL,
	[IN_max_simultaneous_captures] [smallint] NOT NULL,
	[IN_Max_Queued_Datasets] [smallint] NOT NULL,
	[IN_Capture_Exclusion_Window] [real] NOT NULL,
	[IN_Capture_Log_Level] [tinyint] NOT NULL,
	[IN_Created] [datetime] NULL,
	[Auto_Define_Storage_Path] [tinyint] NOT NULL,
	[Auto_SP_Vol_Name_Client] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Auto_SP_Vol_Name_Server] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Auto_SP_Path_Root] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Auto_SP_Archive_Server_Name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Auto_SP_Archive_Path_Root] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Auto_SP_Archive_Share_Path_Root] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Default_Purge_Policy] [tinyint] NOT NULL,
	[Perform_Calibration] [tinyint] NOT NULL,
 CONSTRAINT [PK_T_Instrument_Name] PRIMARY KEY CLUSTERED 
(
	[Instrument_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_T_Instrument_Name] ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Instrument_Name] ON [dbo].[T_Instrument_Name] 
(
	[IN_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

/****** Object:  Index [IX_T_Instrument_Name_Class_Name_InstrumentID] ******/
CREATE NONCLUSTERED INDEX [IX_T_Instrument_Name_Class_Name_InstrumentID] ON [dbo].[T_Instrument_Name] 
(
	[IN_class] ASC,
	[IN_name] ASC,
	[Instrument_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Class] FOREIGN KEY([IN_class])
REFERENCES [T_Instrument_Class] ([IN_class])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Class]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Name_Instrument_Group] FOREIGN KEY([IN_Group])
REFERENCES [T_Instrument_Group] ([IN_Group])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Name_Instrument_Group]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Ops_Role] FOREIGN KEY([IN_operations_role])
REFERENCES [T_Instrument_Ops_Role] ([Role])
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_Instrument_Ops_Role]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_storage_path_SourcePathID] FOREIGN KEY([IN_source_path_ID])
REFERENCES [T_Storage_Path] ([SP_path_ID])
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_storage_path_SourcePathID]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_storage_path_StoragePathID] FOREIGN KEY([IN_storage_path_ID])
REFERENCES [T_Storage_Path] ([SP_path_ID])
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_storage_path_StoragePathID]
GO
ALTER TABLE [dbo].[T_Instrument_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Instrument_Name_T_YesNo] FOREIGN KEY([Auto_Define_Storage_Path])
REFERENCES [T_YesNo] ([Flag])
GO
ALTER TABLE [dbo].[T_Instrument_Name] CHECK CONSTRAINT [FK_T_Instrument_Name_T_YesNo]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_Group]  DEFAULT ('Other') FOR [IN_Group]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_status]  DEFAULT ('active') FOR [IN_status]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_usage]  DEFAULT ('') FOR [IN_usage]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_operations_role]  DEFAULT ('Unknown') FOR [IN_operations_role]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_Percent_EMSL_Owned]  DEFAULT ((0)) FOR [Percent_EMSL_Owned]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_capture_count_max]  DEFAULT ((1)) FOR [IN_max_simultaneous_captures]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_max_queued_datasets]  DEFAULT ((1)) FOR [IN_Max_Queued_Datasets]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_capture_exclusion_window]  DEFAULT ((11)) FOR [IN_Capture_Exclusion_Window]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_capture_log_level]  DEFAULT ((1)) FOR [IN_Capture_Log_Level]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_IN_Created]  DEFAULT (getdate()) FOR [IN_Created]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_Auto_Define_Storage_Path]  DEFAULT ((0)) FOR [Auto_Define_Storage_Path]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_Default_Purge_Policy]  DEFAULT ((0)) FOR [Default_Purge_Policy]
GO
ALTER TABLE [dbo].[T_Instrument_Name] ADD  CONSTRAINT [DF_T_Instrument_Name_Perform_Calibration]  DEFAULT ((0)) FOR [Perform_Calibration]
GO
