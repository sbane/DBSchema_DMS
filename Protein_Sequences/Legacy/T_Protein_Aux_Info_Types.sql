/****** Object:  Table [dbo].[x_T_Protein_Aux_Info_Types] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[x_T_Protein_Aux_Info_Types](
	[Info_Type_ID] [int] NOT NULL,
	[Info_Type_Name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_T_Protein_Aux_Info_Types] PRIMARY KEY CLUSTERED 
(
	[Info_Type_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
