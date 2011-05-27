/****** Object:  StoredProcedure [dbo].[UpdateEUSInfoFromEUSImports] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[UpdateEUSInfoFromEUSImports]
/****************************************************
**
**	Desc: 
**      Wrapper procedure to call UpdateEUSProposalsFromEUSImports
**	    and UpdateEUSUsersFromEUSImports.  Intended to be manually
**		run on an on-demand basis
**
**	Return values: 0: success, otherwise, error code
**
**	Parameters: 
**
**	Auth:	mem
**	Date:	03/25/2011 mem - Initial version
**    
*****************************************************/
(
	@message varchar(512)='' output
)
As
	Set Nocount On

	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0

	Declare @EntryID int = 0
	
	set @message= ''
	
	-- Lookup the highest entry_ID in T_Log_Entries
	SELECT @EntryID = MAX(entry_ID) 
	FROM T_Log_Entries

	-- Update EUS proposals
	exec @myError = UpdateEUSProposalsFromEUSImports

	If @myError <> 0 and @message = ''
		Set @message = 'Error calling UpdateEUSProposalsFromEUSImports'
	
	If @myError = 0
	Begin
	
		-- Update EUS users
		exec @myError = UpdateEUSUsersFromEUSImports
		
		If @myError <> 0  And @message = ''
			Set @message = 'Error calling UpdateEUSUsersFromEUSImports'
	End

	If @myError = 0
	Begin
		If @message = ''
			Set @message = 'Update complete'
		
		SELECT @message AS Message
	End
	Else
	Begin
		SELECT ISNULL(@message, '??') AS [Error Message]
	End	
 
	-- Show any new entries to T_Log_Entrires
	If Exists (Select * from T_Log_Entries WHERE Entry_ID > @EntryID AND posted_By Like 'UpdateEUS%')
	Begin
		SELECT *
		FROM T_Log_Entries
		WHERE Entry_ID > @EntryID AND
		      posted_By LIKE 'UpdateEUS%'
	End
	
 	Return @myError


GO
GRANT EXECUTE ON [dbo].[UpdateEUSInfoFromEUSImports] TO [DMS_EUS_Admin] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[UpdateEUSInfoFromEUSImports] TO [DMS_EUS_Admin] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[UpdateEUSInfoFromEUSImports] TO [Limited_Table_Write] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[UpdateEUSInfoFromEUSImports] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[UpdateEUSInfoFromEUSImports] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[UpdateEUSInfoFromEUSImports] TO [PNL\D3M580] AS [dbo]
GO
