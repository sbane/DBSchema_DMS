/****** Object:  Table [dbo].[T_Analysis_Job] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Analysis_Job](
	[AJ_jobID] [int] IDENTITY(20000,1) NOT NULL,
	[AJ_batchID] [int] NULL,
	[AJ_priority] [int] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_priority]  DEFAULT (2),
	[AJ_created] [smalldatetime] NOT NULL,
	[AJ_start] [smalldatetime] NULL,
	[AJ_finish] [smalldatetime] NULL,
	[AJ_analysisToolID] [int] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_analysisToolID]  DEFAULT (0),
	[AJ_parmFileName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AJ_settingsFileName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AJ_organismDBName] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AJ_organismID] [int] NOT NULL,
	[AJ_datasetID] [int] NOT NULL,
	[AJ_comment] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AJ_owner] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AJ_StateID] [int] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_StateID]  DEFAULT (1),
	[AJ_assignedProcessorName] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AJ_resultsFolderName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AJ_proteinCollectionList] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_proteinCollectionList]  DEFAULT ('na'),
	[AJ_proteinOptionsList] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_proteinOptionsList]  DEFAULT ('na'),
	[AJ_requestID] [int] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_requestID]  DEFAULT (1),
	[AJ_extractionProcessor] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AJ_extractionStart] [smalldatetime] NULL,
	[AJ_extractionFinish] [smalldatetime] NULL,
	[AJ_Analysis_Manager_Error] [smallint] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_Analysis_Manager_Error]  DEFAULT (0),
	[AJ_Data_Extraction_Error] [smallint] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_Data_Extraction_Error]  DEFAULT (0),
	[AJ_propagationMode] [smallint] NOT NULL CONSTRAINT [DF_T_Analysis_Job_AJ_propogation_mode]  DEFAULT (0),
 CONSTRAINT [T_Analysis_Job_PK] PRIMARY KEY CLUSTERED 
(
	[AJ_jobID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_T_Analysis_Job_OrganismDBName] ******/
CREATE NONCLUSTERED INDEX [IX_T_Analysis_Job_OrganismDBName] ON [dbo].[T_Analysis_Job] 
(
	[AJ_organismDBName] ASC
) ON [PRIMARY]
GO

/****** Object:  Index [IX_T_Analysis_Job_RequestID] ******/
CREATE NONCLUSTERED INDEX [IX_T_Analysis_Job_RequestID] ON [dbo].[T_Analysis_Job] 
(
	[AJ_requestID] ASC
) ON [PRIMARY]
GO

/****** Object:  Index [IX_T_Analysis_Job_State] ******/
CREATE NONCLUSTERED INDEX [IX_T_Analysis_Job_State] ON [dbo].[T_Analysis_Job] 
(
	[AJ_StateID] ASC
) ON [PRIMARY]
GO

/****** Object:  Trigger [trig_i_AnalysisJob] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE Trigger trig_i_AnalysisJob on T_Analysis_Job
For Insert
AS
	declare @oldState int
	set @oldState = 0
	declare @newState int
	declare @jobID int
	
	declare @done int
	set @done = 0

	declare curStateChange Cursor
	For
	select 
		inserted.AJ_jobID,
		inserted.AJ_StateID 
	From 
		inserted
		
	Open curStateChange
	while(@done = 0)
		begin -- while
		
		Fetch Next From curStateChange Into @jobID, @newState
		if @@fetch_status = -1
			begin
				set @done = 1
			end
		else
			begin
				INSERT INTO T_Event_Log
				(
					Target_Type, 
					Target_ID, 
					Target_State, 
					Prev_Target_State, 
					Entered
				)
				VALUES
				(
					5, 
					@jobID, 
					@newState, 
					@oldState, 
					GETDATE()
				)
			end 
		end-- while
	
	Deallocate curStateChange

GO

/****** Object:  Trigger [trig_u_AnalysisJob] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE Trigger trig_u_AnalysisJob on T_Analysis_Job
For Update
AS
	if update(AJ_StateID)
	Begin -- if update
		declare @oldState int
		declare @newState int
		declare @jobID int
		declare @done int
		set @done = 0

		declare curStateChange Cursor
		For
		select 
			deleted.AJ_jobID,
			deleted.AJ_StateID, 
			inserted.AJ_StateID 
		From 
			deleted inner join 
			inserted on deleted.AJ_jobID = inserted.AJ_jobID
			
		Open curStateChange
		while(@done = 0)
			begin -- while
			
			Fetch Next From curStateChange Into @jobID, @oldState, @newState
			if @@fetch_status = -1
				begin
					set @done = 1
				end
			else
				begin
					INSERT INTO T_Event_Log
					(
						Target_Type, 
						Target_ID, 
						Target_State, 
						Prev_Target_State, 
						Entered
					)
					VALUES
					(
						5, 
						@jobID, 
						@newState, 
						@oldState, 
						GETDATE()
					)
				end 
			end-- while
		
		Deallocate curStateChange
	End  -- if update

GO
GRANT SELECT ON [dbo].[T_Analysis_Job] TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_jobID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_jobID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_batchID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_batchID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_priority]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_priority]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_created]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_created]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_start]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_start]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_finish]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_finish]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_analysisToolID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_analysisToolID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_parmFileName]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_parmFileName]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_settingsFileName]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_settingsFileName]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_organismDBName]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_organismDBName]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_organismID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_organismID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_datasetID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_datasetID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_comment]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_comment]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_owner]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_owner]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_StateID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_StateID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_assignedProcessorName]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_assignedProcessorName]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_resultsFolderName]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_resultsFolderName]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_proteinCollectionList]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_proteinCollectionList]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_proteinOptionsList]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_proteinOptionsList]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_requestID]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_requestID]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_extractionProcessor]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_extractionProcessor]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_extractionStart]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_extractionStart]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_extractionFinish]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_extractionFinish]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_Analysis_Manager_Error]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_Analysis_Manager_Error]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_Data_Extraction_Error]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_Data_Extraction_Error]) TO [Limited_Table_Write]
GO
GRANT SELECT ON [dbo].[T_Analysis_Job] ([AJ_propagationMode]) TO [Limited_Table_Write]
GO
GRANT UPDATE ON [dbo].[T_Analysis_Job] ([AJ_propagationMode]) TO [Limited_Table_Write]
GO
ALTER TABLE [dbo].[T_Analysis_Job]  WITH CHECK ADD  CONSTRAINT [FK_T_Analysis_Job_T_Analysis_Job_Batches] FOREIGN KEY([AJ_batchID])
REFERENCES [T_Analysis_Job_Batches] ([Batch_ID])
GO
ALTER TABLE [dbo].[T_Analysis_Job]  WITH CHECK ADD  CONSTRAINT [FK_T_Analysis_Job_T_Analysis_Job_Request] FOREIGN KEY([AJ_requestID])
REFERENCES [T_Analysis_Job_Request] ([AJR_requestID])
GO
ALTER TABLE [dbo].[T_Analysis_Job]  WITH CHECK ADD  CONSTRAINT [FK_T_Analysis_Job_T_Analysis_State_Name] FOREIGN KEY([AJ_StateID])
REFERENCES [T_Analysis_State_Name] ([AJS_stateID])
GO
ALTER TABLE [dbo].[T_Analysis_Job]  WITH NOCHECK ADD  CONSTRAINT [FK_T_Analysis_Job_T_Analysis_Tool] FOREIGN KEY([AJ_analysisToolID])
REFERENCES [T_Analysis_Tool] ([AJT_toolID])
GO
ALTER TABLE [dbo].[T_Analysis_Job] CHECK CONSTRAINT [FK_T_Analysis_Job_T_Analysis_Tool]
GO
ALTER TABLE [dbo].[T_Analysis_Job]  WITH NOCHECK ADD  CONSTRAINT [FK_T_Analysis_Job_T_Dataset] FOREIGN KEY([AJ_datasetID])
REFERENCES [T_Dataset] ([Dataset_ID])
GO
ALTER TABLE [dbo].[T_Analysis_Job] CHECK CONSTRAINT [FK_T_Analysis_Job_T_Dataset]
GO
ALTER TABLE [dbo].[T_Analysis_Job]  WITH NOCHECK ADD  CONSTRAINT [FK_T_Analysis_Job_T_Organisms] FOREIGN KEY([AJ_organismID])
REFERENCES [T_Organisms] ([Organism_ID])
GO
ALTER TABLE [dbo].[T_Analysis_Job] CHECK CONSTRAINT [FK_T_Analysis_Job_T_Organisms]
GO
