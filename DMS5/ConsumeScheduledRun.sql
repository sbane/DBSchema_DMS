/****** Object:  StoredProcedure [dbo].[ConsumeScheduledRun] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure ConsumeScheduledRun
/****************************************************
**
**	Desc:
**	Associates given requested run with the given dataset
**
**	Return values: 0: success, otherwise, error code
**
**
**	Auth:	grk
**	Date:	02/13/2003
**			01/05/2002 grk - Added stuff for Internal Standard and cart parameters
**          03/01/2004 grk - Added validation for experiments matching between request and dataset
**          10/12/2005 grk - Added stuff to copy new work package and proposal fields.
**          01/13/2006 grk - Handling for new blocking columns in request and history tables.
**          01/17/2006 grk - Handling for new EUS tracking columns in request and history tables.
**			04/08/2008 grk - Added handling for separation field (Ticket #658)
**			03/26/2009 grk - Added MRM transition list attachment (Ticket #727)
**			02/26/2010 grk - Merged T_Requested_Run_History with T_Requested_Run
**			11/29/2011 mem - Now calling AddRequestedRunToExistingDataset if re-using an existing request
**			12/05/2011 mem - Updated call to AddRequestedRunToExistingDataset to include @DatasetNum
**						   - Now copying batch and blocking info from the existing request to the new auto-request created by AddRequestedRunToExistingDataset
**			12/12/2011 mem - Updated log message when re-using an existing request
**			12/14/2011 mem - Added parameter @callingUser, which is passed to AddRequestedRunToExistingDataset and AlterEventLogEntryUser
**			11/16/2016 mem - Call UpdateCachedRequestedRunEUSUsers to update T_Active_Requested_Run_Cached_EUS_Users
**    
*****************************************************/
(
	@datasetID int,
	@requestID int,
	@message varchar(255) output,
	@callingUser varchar(128) = ''
)
As
	set nocount on

	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0
	
	Declare @ExistingDatasetID int
	Declare @LogMessage varchar(512)
	
	set @message = ''


	---------------------------------------------------
	-- Validate that experiments match
	---------------------------------------------------
	
	-- get experiment ID from dataset
	--
	declare @experimentID int
	set @experimentID = 0
	--
	SELECT   @experimentID = Exp_ID
	FROM T_Dataset
	WHERE Dataset_ID = @datasetID
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error trying to look up experiment for dataset'
		RAISERROR (@message, 10, 1)
		return 51085
	end

	-- get experiment ID from scheduled run
	--
	declare @reqExperimentID int
	set @reqExperimentID = 0
	--
	SELECT @reqExperimentID = Exp_ID
	FROM T_Requested_Run
	WHERE ID = @requestID
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error trying to look up experiment for request'
		RAISERROR (@message, 10, 1)
		return 51086
	end
	
	-- validate that experiments match
	--
	if @experimentID <> @reqExperimentID
	begin
		set @message = 'Experiment in dataset does not match with one in scheduled run'
		RAISERROR (@message, 10, 1)
		return 51072
	end

	---------------------------------------------------
	-- start transaction
	---------------------------------------------------	
	
	declare @transName varchar(128)
	set @transName = 'ConsumeScheduledRun_' + convert(varchar(12), @datasetID) + '_' + convert(varchar(12), @requestID)
	
	begin transaction @transName

	-- If request already has a dataset associated with it, then we need to create a new auto-request for that dataset
	Set @ExistingDatasetID = 0
	--	
	SELECT @ExistingDatasetID = DatasetID
	FROM T_Requested_Run
	WHERE ID = @requestID AND Not DatasetID Is Null
	
	If @ExistingDatasetID <> 0 And @ExistingDatasetID <> @datasetID
	Begin -- <a>
		---------------------------------------------------
		-- Create new auto-request, but only if the dataset doesn't already have one
		---------------------------------------------------
		
		Declare @ExistingDatasetName varchar(255) = ''
		
		SELECT @ExistingDatasetName = Dataset_Num
		FROM T_Dataset
		WHERE Dataset_ID = @ExistingDatasetID
		
		IF Exists (Select * FROM T_Requested_Run WHERE RDS_Name = 'AutoReq_' + @ExistingDatasetName)
		Begin
			Set @LogMessage = 'Cannot add new automatic requested run for dataset "' + @ExistingDatasetName + '" since AutoReq already exists'
			exec PostLogEntry 'Error', @LogMessage, 'ConsumeScheduledRun'
		End
		Else
		Begin -- <b>
			-- Change DatasetID to Null for this request before calling AddRequestedRunToExistingDataset
			UPDATE T_Requested_Run
			SET DatasetID = Null
			WHERE ID = @requestID
	
			exec AddRequestedRunToExistingDataset @datasetID=@ExistingDatasetID, @datasetNum='', @templateRequestID=@requestID, @mode='add', @message=@message output, @callingUser=@callingUser

			-- Lookup the request ID created for @ExistingDatasetName
			DECLARE @NewAutoRequestID INT = 0
		
			SELECT @NewAutoRequestID = RR.ID
			FROM   T_Requested_Run AS RR
			WHERE  RR.DatasetID = @ExistingDatasetID
	
			If @NewAutoRequestID <> 0
			Begin -- <c1>

				Set @LogMessage = 'Added new automatic requested run since re-using request ' + Convert(varchar(12), @requestID) + '; dataset "' + @ExistingDatasetName + '" is now associated with request ' + Convert(varchar(12), @NewAutoRequestID)
				exec PostLogEntry 'Warning', @LogMessage, 'ConsumeScheduledRun'
			
				-- Copy batch and blocking information from the existing request to the new request
				UPDATE Target
				SET RDS_BatchID = Source.RDS_BatchID,
				    RDS_Blocking_Factor = Source.RDS_Blocking_Factor,
				    RDS_Block = Source.RDS_Block,
				    RDS_Run_Order = Source.RDS_Run_Order
				FROM T_Requested_Run Target
				     CROSS JOIN ( SELECT RDS_BatchID,
				                         RDS_Blocking_Factor,
				                         RDS_Block,
				                         RDS_Run_Order
				                  FROM T_Requested_Run
				                  WHERE ID = @requestID
				                ) Source
				WHERE Target.ID = @NewAutoRequestID
				
			End -- </c1>
			Else
			Begin -- <c2>
			
				Set @LogMessage = 'Tried to add a new automatic requested run for dataset "' + @ExistingDatasetName + '" since re-using request ' + Convert(varchar(12), @requestID) + '; however, AddRequestedRunToExistingDataset was unable to auto-create a new Requested Run'
				exec PostLogEntry 'Error', @LogMessage, 'ConsumeScheduledRun'

			End -- </c2>

		End -- </b>
		
	End -- </a>
	
	
	---------------------------------------------------
	-- Change the status of the Requested Run to Completed
	---------------------------------------------------
	
	Declare @status varchar(24) = 'Completed'
	
	UPDATE T_Requested_Run
	SET DatasetID = @datasetID,
	    RDS_Status = @status
	WHERE ID = @requestID
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Failed to update dataset field in request'
		rollback transaction @transName
		return 51009
	end

	-- If @callingUser is defined, then call AlterEventLogEntryUser to alter the Entered_By field in T_Event_Log
	If Len(@callingUser) > 0
	Begin
		Declare @StatusID int = 0
		
		SELECT @StatusID = State_ID
		FROM T_Requested_Run_State_Name
		WHERE (State_Name = @status)
		
		Exec AlterEventLogEntryUser 11, @requestID, @StatusID, @callingUser
	End
	
	---------------------------------------------------
	-- Finalize the changes
	---------------------------------------------------
	--
	commit transaction @transName

	---------------------------------------------------
	-- Make sure that T_Active_Requested_Run_Cached_EUS_Users is up-to-date
	-- This procedure will delete the cached EUS user list from T_Active_Requested_Run_Cached_EUS_Users for this request ID
	---------------------------------------------------
	--
	exec UpdateCachedRequestedRunEUSUsers @requestID
		
	return 0

GO
GRANT EXECUTE ON [dbo].[ConsumeScheduledRun] TO [DMS_SP_User] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[ConsumeScheduledRun] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[ConsumeScheduledRun] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[ConsumeScheduledRun] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[ConsumeScheduledRun] TO [PNL\D3M580] AS [dbo]
GO
