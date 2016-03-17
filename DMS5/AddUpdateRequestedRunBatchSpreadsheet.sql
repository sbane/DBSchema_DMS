/****** Object:  StoredProcedure [dbo].[AddUpdateRequestedRunBatchSpreadsheet] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddUpdateRequestedRunBatchSpreadsheet
/****************************************************
**
**  Desc: Adds new or edits existing requested run batch
**
**  Return values: 0: success, otherwise, error code
**
**  Parameters:
**
**    Auth: jds
**    Date: 05/18/2009
**			08/27/2010 mem - Expanded @RequestedCompletionDate to varchar(24) to support long dates of the form 'Jan 01 2010 12:00:00AM'
**    
**
** Pacific Northwest National Laboratory, Richland, WA
** Copyright 2005, Battelle Memorial Institute
*****************************************************/
(
	@ID int output,
	@Name varchar(50),
	@Description varchar(256),
	@RequestNameList varchar(8000),
	@OwnerPRN varchar(24),
	@RequestedBatchPriority varchar(24),
	@RequestedCompletionDate varchar(24),
	@JustificationHighPriority varchar(512),
	@RequestedInstrument varchar(24),						-- Will typically contain an instrument group, not an instrument name
	@Comment varchar(512),
	@mode varchar(12) = 'add', -- or 'update'
	@message varchar(512) output
)
As
	set nocount on

	declare @myError int
	set @myError = 0

	declare @myRowCount int
	set @myRowCount = 0

	set @message = ''

	---------------------------------------------------
	-- get list of request ids based on Request name list
	---------------------------------------------------
	--
	declare @RequestedRunList varchar(4000)

	SELECT @RequestedRunList = COALESCE(@RequestedRunList + ', ', '') + cast(rr.ID as varchar(32))
	FROM MakeTableFromList(@RequestNameList) r
		join T_Requested_Run rr on r.Item = rr.RDS_Name
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Failed to populate temporary table for requests'
		RAISERROR (@message, 10, 1)
		return 51219
	end


	if @myRowCount = 0
	begin
		set @message = 'The requests submitted in the list do not exist in the database.  Check the requests and try again.'
		RAISERROR (@message, 10, 1)
		return 51220
	end

	exec AddUpdateRequestedRunBatch @ID output, 
									@Name, 
									@Description, 
									@RequestedRunList, 
									@OwnerPRN, 
									@RequestedBatchPriority, 
									@RequestedCompletionDate, 
									@JustificationHighPriority, 
									@RequestedInstrument, 
									@Comment, 
									@mode, 
									@message output

	--check for any errors from stored procedure
	if @message <> ''
	begin
		RAISERROR (@message, 10, 1)
		return 51219
	end

	return @myError

GO
GRANT EXECUTE ON [dbo].[AddUpdateRequestedRunBatchSpreadsheet] TO [DMS_User] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddUpdateRequestedRunBatchSpreadsheet] TO [DMS2_SP_User] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[AddUpdateRequestedRunBatchSpreadsheet] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[AddUpdateRequestedRunBatchSpreadsheet] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[AddUpdateRequestedRunBatchSpreadsheet] TO [PNL\D3M580] AS [dbo]
GO
