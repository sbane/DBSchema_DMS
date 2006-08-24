/****** Object:  Table [dbo].[T_Residues_Change_History] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Residues_Change_History](
	[Event_ID] [int] IDENTITY(1,1) NOT NULL,
	[Residue_ID] [int] NOT NULL,
	[Residue_Symbol] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Average_Mass] [float] NOT NULL,
	[Monoisotopic_Mass] [float] NOT NULL,
	[Num_C] [smallint] NOT NULL,
	[Num_H] [smallint] NOT NULL,
	[Num_N] [smallint] NOT NULL,
	[Num_O] [smallint] NOT NULL,
	[Num_S] [smallint] NOT NULL,
	[Monoisotopic_Mass_Change] [float] NULL,
	[Average_Mass_Change] [float] NULL,
	[Entered] [datetime] NOT NULL CONSTRAINT [DF_T_Residues_Change_History_Entered]  DEFAULT (getdate()),
	[Entered_By] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_T_Residues_Change_History_Entered_By]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_T_Residues_Change_History] PRIMARY KEY CLUSTERED 
(
	[Event_ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
