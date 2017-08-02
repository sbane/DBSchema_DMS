/****** Object:  StoredProcedure [dbo].[AddDataFolderCreateTask] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.AddDataFolderCreateTask
/****************************************************
**
**	Desc: 
**		Adds a new entry to T_Data_Folder_Create_Queue
**		The Package Folder Create Manager (aka PkgFolderCreateManager)
**		examines this table to look for folders that need to be created
**
**	Return values: 0:  success, otherwise, error code
**
**	Auth:	mem
**	Date:	03/17/2011 mem - Initial version
**			06/16/2017 mem - Restrict access using VerifySPAuthorized
**			08/01/2017 mem - Use THROW if not authorized
**
*****************************************************/
(
	@PathLocalRoot varchar(256),			-- Required, for example: F:\DataPkgs
	@PathSharedRoot varchar(256),			-- Required, for example: \\protoapps\DataPkgs\
	@FolderPath varchar(512),				-- Required, for example: Public\2011\264_PNWRCE_Dengue_iTRAQ
	@SourceDB varchar(128),					-- Optional, for example: DMS_Data_Package
	@SourceTable varchar(256),				-- Optional, for example: T_Data_Package
	@SourceID int,							-- Optional, for example: 264
	@SourceIDFieldName varchar(128),		-- Optional, for example: ID
	@Command varchar(64) = 'add',			-- Optional, for example: add
	@message varchar(512) = '' output,
	@infoOnly tinyint = 0
)
As
	set nocount on
	
	declare @myError int = 0
	declare @myRowCount int = 0

	Set @message = ''
		
	---------------------------------------------------
	-- Verify that the user can execute this procedure from the given client host
	---------------------------------------------------
		
	Declare @authorized tinyint = 0	
	Exec @authorized = VerifySPAuthorized 'AddDataFolderCreateTask', @raiseError = 1;
	If @authorized = 0
	Begin
		THROW 51000, 'Access denied', 1;
	End
	
	If @infoOnly <> 0
	Begin
		SELECT
			1 AS State,
			@SourceDB as SourceDB,
			@SourceTable as SourceTable,
			@SourceID as SourceID,
			@SourceIDFieldName as SourceIDFieldName,
			@PathLocalRoot as PathLocalRoot,
			@PathSharedRoot as PathSharedRoot,
			@FolderPath as FolderPath,
			@Command as Command
	End
	Else
	Begin
		INSERT INTO T_Data_Folder_Create_Queue
		(
			State,
			Source_DB ,
			Source_Table ,
			Source_ID ,
			Source_ID_Field_Name ,
			Path_Local_Root, 
			Path_Shared_Root ,
			Path_Folder, 
			Command 
		)
		SELECT
			1 AS State,
			@SourceDB ,
			@SourceTable ,
			@SourceID ,
			@SourceIDFieldName ,
			@PathLocalRoot ,
			@PathSharedRoot ,
			@FolderPath ,
			@Command 
	End	

Done:
	Return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[AddDataFolderCreateTask] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddDataFolderCreateTask] TO [DMS_SP_User] AS [dbo]
GO
