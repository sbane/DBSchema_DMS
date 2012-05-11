/****** Object:  Table [dbo].[T_Creation_Option_Values] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Creation_Option_Values](
	[Value_ID] [int] IDENTITY(1,1) NOT NULL,
	[Value_String] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Display] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Keyword_ID] [int] NOT NULL,
 CONSTRAINT [PK_T_Creation_Option_Values] PRIMARY KEY CLUSTERED 
(
	[Value_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
