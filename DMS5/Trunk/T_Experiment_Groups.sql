/****** Object:  Table [dbo].[T_Experiment_Groups] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Experiment_Groups](
	[Group_ID] [int] IDENTITY(1,1) NOT NULL,
	[EG_Group_Type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EG_Created] [datetime] NOT NULL,
	[EG_Description] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Parent_Exp_ID] [int] NOT NULL CONSTRAINT [DF_T_Experiment_Groups_Parent_Exp_ID]  DEFAULT (0),
 CONSTRAINT [PK_T_Experiment_Groups] PRIMARY KEY CLUSTERED 
(
	[Group_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_T_Experiment_Groups] ******/
CREATE NONCLUSTERED INDEX [IX_T_Experiment_Groups] ON [dbo].[T_Experiment_Groups] 
(
	[Group_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
GRANT DELETE ON [dbo].[T_Experiment_Groups] TO [PNL\D3M578]
GO
GRANT INSERT ON [dbo].[T_Experiment_Groups] TO [PNL\D3M578]
GO
GRANT SELECT ON [dbo].[T_Experiment_Groups] TO [PNL\D3M578]
GO
GRANT UPDATE ON [dbo].[T_Experiment_Groups] TO [PNL\D3M578]
GO
ALTER TABLE [dbo].[T_Experiment_Groups]  WITH NOCHECK ADD  CONSTRAINT [FK_T_Experiment_Groups_T_Experiments] FOREIGN KEY([Parent_Exp_ID])
REFERENCES [T_Experiments] ([Exp_ID])
GO
ALTER TABLE [dbo].[T_Experiment_Groups] CHECK CONSTRAINT [FK_T_Experiment_Groups_T_Experiments]
GO
