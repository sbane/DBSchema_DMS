/****** Object:  Table [dbo].[T_URI_Paths] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_URI_Paths](
	[URI_PathID] [int] IDENTITY(100,1) NOT NULL,
	[URI_Path] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Entered] [datetime] NOT NULL,
 CONSTRAINT [PK_T_URI_Paths] PRIMARY KEY CLUSTERED 
(
	[URI_PathID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
GRANT VIEW DEFINITION ON [dbo].[T_URI_Paths] TO [DDL_Viewer] AS [dbo]
GO
ALTER TABLE [dbo].[T_URI_Paths] ADD  CONSTRAINT [DF_T_URI_Paths_Entered]  DEFAULT (getdate()) FOR [Entered]
GO
