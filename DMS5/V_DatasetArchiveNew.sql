/****** Object:  View [dbo].[V_DatasetArchiveNew] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/****** Object:  View dbo.V_DatasetArchiveNew ******/

/****** Object:  View dbo.V_DatasetArchiveNew    Script Date: 1/17/2001 2:15:34 PM ******/
CREATE VIEW dbo.V_DatasetArchiveNew
AS
SELECT Dataset_Number, Folder_Name, Server_Vol, Client_Vol, 
   Storage_Path, Archive_Path, Instrument_Class, 
   Last_Update
FROM V_DatasetArchive
WHERE (Archive_State = 1)
GO
GRANT VIEW DEFINITION ON [dbo].[V_DatasetArchiveNew] TO [DDL_Viewer] AS [dbo]
GO
