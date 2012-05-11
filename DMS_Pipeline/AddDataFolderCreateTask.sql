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
**
**	Return values: 0:  success, otherwise, error code
**
**	Parameters:
**
**	Auth:	mem
**	Date:	03/17/2011 mem - Initial version
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
	
	declare @myError int
	declare @myRowcount int
	set @myRowcount = 0
	set @myError = 0

	Set @message = ''
		
	
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
GRANT EXECUTE ON [dbo].[AddDataFolderCreateTask] TO [DMS_SP_User] AS [dbo]
GO
