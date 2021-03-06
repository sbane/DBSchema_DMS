/****** Object:  StoredProcedure [dbo].[AddUpdateCampaign] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure dbo.AddUpdateCampaign
/****************************************************
**
**	Desc: Adds new or updates existing campaign in database
**
**	Return values: 0: success, otherwise, error code
**
**	Auth:	grk
**	Date:	01/08/2002
**			03/25/2008 mem - Added optional parameter @callingUser; if provided, then will call AlterEventLogEntryUser (Ticket #644)
**			01/15/2010 grk - Added new fields (http://prismtrac.pnl.gov/trac/ticket/753)
**			02/05/2010 grk - Split team member field
**			02/07/2010 grk - Added validation for campaign name
**			02/07/2010 mem - No longer validating @progmgrPRN or @piPRN in this procedure since this is now handled by UpdateResearchTeamForCampaign
**			03/17/2010 grk - DataReleaseRestrictions (Ticket http://prismtrac.pnl.gov/trac/ticket/758)
**			04/21/2010 grk - try-catch for error handling
**			10/27/2011 mem - Added parameter @FractionEMSLFunded
**			12/01/2011 mem - Updated @FractionEMSLFunded to be a required value
**			               - Now calling AlterEventLogEntryUser for updates to CM_Fraction_EMSL_Funded or CM_Data_Release_Restrictions
**			10/23/2012 mem - Now validating that @FractionEMSLFunded is a number between 0 and 1 using a real (since conversion of 100 to Decimal(3, 2) causes an overflow error)
**			06/02/2015 mem - Replaced IDENT_CURRENT with SCOPE_IDENTITY()
**			02/23/2016 mem - Add set XACT_ABORT on\
**			02/26/2016 mem - Define a default for @FractionEMSLFunded
**			04/06/2016 mem - Now using Try_Convert to convert from text to int
**          07/20/2016 mem - Tweak error messages
**			11/18/2016 mem - Log try/catch errors using PostLogEntry
**			11/23/2016 mem - Include the campaign name when calling PostLogEntry from within the catch block
**						   - Trim trailing and leading spaces from input parameters
**			12/05/2016 mem - Exclude logging some try/catch errors
**			12/16/2016 mem - Use @logErrors to toggle logging errors caught by the try/catch block
**			06/13/2017 mem - Disable logging when the campaign name has invalid characters
**			06/14/2017 mem - Allow @FractionEMSLFundedValue to be empty
**			06/16/2017 mem - Restrict access using VerifySPAuthorized
**			08/01/2017 mem - Use THROW if not authorized
**			08/18/2017 mem - Disable logging certain messages to T_Log_Entries
**    
*****************************************************/
(
	@campaignNum varchar(64),				-- Campaign name
	@projectNum varchar(64),				-- Project name
	@progmgrPRN varchar(64),				-- Project Manager PRN (required)
	@piPRN varchar(64),						-- Principal Investigator PRN (required)
	@TechnicalLead varchar(256),			-- Technical Lead
	@SamplePreparationStaff varchar(256),	-- Sample Prep Staff
	@DatasetAcquisitionStaff varchar(256),	-- Dataset acquisition staff
	@InformaticsStaff varchar(256),			-- Informatics staff
	@Collaborators varchar(256),			-- Collaborators
	@comment varchar(500),
	@State varchar(24),
	@Description varchar(512),
	@ExternalLinks varchar(512),
	@EPRList varchar(256),
	@EUSProposalList varchar(256),
	@Organisms varchar(256),
	@ExperimentPrefixes varchar(256),
	@DataReleaseRestrictions varchar(128),
	@FractionEMSLFunded varchar(24) = '0',
	@mode varchar(12) = 'add', -- or 'update'
	@message varchar(512) output,
   	@callingUser varchar(128) = ''
)
As
	Set XACT_ABORT, nocount on

	Declare @myError int = 0
	Declare @myRowCount int = 0
	
	Set @message = ''
	
	Declare @msg varchar(256)
	
	Declare @StateID int
	Declare @PercentEMSLFunded int

	-- Leave this as Null for now
	Declare @FractionEMSLFundedValue decimal(3, 2) = 0
	
	Declare @logErrors tinyint = 0
	
	---------------------------------------------------
	-- Verify that the user can execute this procedure from the given client host
	---------------------------------------------------
		
	Declare @authorized tinyint = 0	
	Exec @authorized = VerifySPAuthorized 'AddUpdateCampaign', @raiseError = 1
	If @authorized = 0
	Begin
		THROW 51000, 'Access denied', 1;
	End

	BEGIN TRY 

	---------------------------------------------------
	-- Validate input fields
	---------------------------------------------------

	Set @campaignNum = LTrim(RTrim(IsNull(@campaignNum, '')))
	Set @projectNum = LTrim(RTrim(IsNull(@projectNum, '')))
	Set @progmgrPRN = LTrim(RTrim(IsNull(@progmgrPRN, '')))
	Set @piPRN = LTrim(RTrim(IsNull(@piPRN, '')))

	Set @myError = 0
	If LEN(@campaignNum) < 1
		RAISERROR ('Campaign name is blank', 11, 1)
	--
	If LEN(@projectNum) < 1
		RAISERROR ('Project Number is blank', 11, 1)
	--
	If LEN(@progmgrPRN) < 1
		RAISERROR ('Project Manager PRN is blank', 11, 2)
	--
	If LEN(@piPRN) < 1
		RAISERROR ('Principle Investigator PRN is blank', 11, 3)
	
	---------------------------------------------------
	-- Is entry already in database?
	---------------------------------------------------

	Declare @campaignID int = 0
	Declare @researchTeamID INT = 0
	--
	SELECT
		@campaignID = Campaign_ID, 
		@researchTeamID = ISNULL(CM_Research_Team, 0)
	FROM
		T_Campaign
	WHERE
		Campaign_Num = @campaignNum

	-- Cannot create an entry that already exists
	--
	If @campaignID <> 0 and @mode = 'add'
		RAISERROR ('Cannot add: Campaign "%s" already in database', 11, 4, @campaignNum)

	-- Cannot update a non-existent entry
	--
	If @campaignID = 0 and @mode = 'update'
		RAISERROR ('Cannot update: Campaign "%s" is not in database', 11, 5, @campaignNum)

	---------------------------------------------------
	-- Resolve data release restriction name to ID
	---------------------------------------------------
	--
	Declare @DataReleaseRestrictionsID int = -1
	-- 
	SELECT
		@DataReleaseRestrictionsID = ID
	FROM
		T_Data_Release_Restrictions
	WHERE
		Name = @DataReleaseRestrictions
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	If @myError <> 0
		RAISERROR ('Error resolving data release restriction', 11, 6)
	--
	If @DataReleaseRestrictionsID < 0
		RAISERROR ('Could not resolve data release restriction; please select a valid entry from the list', 11, 7)

	---------------------------------------------------
	-- Validate Fraction EMSL Funded
	-- If @FractionEMSLFunded is empty we treat it as a Null value
	---------------------------------------------------
	--
	
	Set @FractionEMSLFunded = IsNull(@FractionEMSLFunded, '')
	If Len(@FractionEMSLFunded) > 0
	Begin
		Set @FractionEMSLFundedValue = Try_Convert(real, @FractionEMSLFunded)
		If @FractionEMSLFundedValue Is Null
		Begin
			RAISERROR ('Fraction EMSL Funded must be a number between 0 and 1', 11, 4)
		End
	
		If @FractionEMSLFundedValue > 1
		Begin
			Set @msg = 'Fraction EMSL Funded must be a number between 0 and 1 (' + @FractionEMSLFunded + ' is greater than 1)'
			RAISERROR (@msg, 11, 4)
		End

		If @FractionEMSLFundedValue < 0
		Begin
			Set @msg = 'Fraction EMSL Funded must be a number between 0 and 1 (' + @FractionEMSLFunded + ' is less than 0)'
			RAISERROR (@msg, 11, 4)
		End
		
		Set @FractionEMSLFundedValue = Convert(decimal(3, 2), @FractionEMSLFunded)

	End
	Else
		Set @FractionEMSLFundedValue = 0
	
	---------------------------------------------------
	-- Validate campaign name
	---------------------------------------------------
	--
	If @mode = 'add'
	Begin
		Declare @badCh varchar(128)
		Set @badCh = dbo.ValidateChars(@campaignNum, '')
		Set @badCh = REPLACE(@badCh, '[space]', '')
		
		If @badCh <> ''
		Begin
			If @badCh = '[space]'
				RAISERROR ('Campaign name may not contain spaces', 11, 8)
			Else
				RAISERROR ('Campaign name may not contain the character(s) "%s"', 11, 9, @badCh)
		End
	End
	
	Set @logErrors = 1
	
	---------------------------------------------------
	-- Transaction name
	---------------------------------------------------
	--
	Declare @transName varchar(32) = 'AddUpdateCampaign'

	---------------------------------------------------
	-- Action for add mode
	---------------------------------------------------
	If @mode = 'add'
	Begin

		Begin transaction @transName

		---------------------------------------------------
		-- Create research team
		---------------------------------------------------
		--
		EXEC @myError = UpdateResearchTeamForCampaign
							@campaignNum, 
							@progmgrPRN , 
							@piPRN, 
							@TechnicalLead,
							@SamplePreparationStaff,
							@DatasetAcquisitionStaff,
							@InformaticsStaff,
							@Collaborators,
							@researchTeamID output,
							@message output
		--
		If @myError <> 0
			RAISERROR (@message, 11, 11)

		---------------------------------------------------
		-- Create campaign
		---------------------------------------------------
		--
		INSERT INTO T_Campaign (
			Campaign_Num, 
			CM_Project_Num, 
			CM_comment, 
			CM_State,
			CM_Description,
			CM_External_Links,
			CM_EPR_List,
			CM_EUS_Proposal_List,
			CM_Organisms,
			CM_Experiment_Prefixes,
			CM_created,
			CM_Research_Team,
			CM_Data_Release_Restrictions,
			CM_Fraction_EMSL_Funded
		) VALUES (
			@campaignNum, 
			@projectNum, 
			@comment, 
			@State,
			@Description,
			@ExternalLinks,
			@EPRList,
			@EUSProposalList,
			@Organisms,
			@ExperimentPrefixes,
			GETDATE(),
			@researchTeamID,
			@DataReleaseRestrictionsID,
			@FractionEMSLFundedValue
		)
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		--
		If @myError <> 0
			RAISERROR ('Insert operation failed: "%s"', 11, 12, @campaignNum )
		
		-- Get the ID of newly created campaign
		Set @CampaignID = SCOPE_IDENTITY()		

		-- As a precaution, query T_Campaign using Campaign name to make sure we have the correct Campaign_ID
		Declare @IDConfirm int = 0
		
		SELECT @IDConfirm = Campaign_ID
		FROM T_Campaign
		WHERE Campaign_Num = @campaignNum
		
		If @CampaignID <> IsNull(@IDConfirm, @CampaignID)
		Begin
			Declare @DebugMsg varchar(512)
			Set @DebugMsg = 'Warning: Inconsistent identity values when adding campaign ' + @campaignNum + ': Found ID ' +
			                Cast(@IDConfirm as varchar(12)) + ' but SCOPE_IDENTITY reported ' + 
			                Cast(@CampaignID as varchar(12))
			                
			exec PostLogEntry 'Error', @DebugMsg, 'AddUpdateCampaign'
			
			Set @CampaignID = @IDConfirm
		End
		

		commit transaction @transName
		
		Set @StateID = 1
		Set @PercentEMSLFunded = CONVERT(int, @FractionEMSLFundedValue * 100)
		
		-- If @callingUser is defined, then call AlterEventLogEntryUser to alter the Entered_By field in T_Event_Log
		If Len(@callingUser) > 0
		Begin
			Exec AlterEventLogEntryUser 1, @CampaignID, @StateID, @callingUser
			Exec AlterEventLogEntryUser 9, @CampaignID, @PercentEMSLFunded, @callingUser
			Exec AlterEventLogEntryUser 10, @CampaignID, @DataReleaseRestrictionsID, @callingUser
		End
			
	End -- add mode

	---------------------------------------------------
	-- Action for update mode
	---------------------------------------------------
	--
	If @mode = 'update' 
	Begin
		Begin transaction @transName
		--
		Set @myError = 0
		--
		---------------------------------------------------
		-- Update campaign
		---------------------------------------------------
		--
		UPDATE T_Campaign 
		SET 
			CM_Project_Num = @projectNum, 
			CM_comment = @comment,
			CM_State = @State,
			CM_Description = @Description,
			CM_External_Links = @ExternalLinks,
			CM_EPR_List = @EPRList,
			CM_EUS_Proposal_List = @EUSProposalList,
			CM_Organisms = @Organisms,
			CM_Experiment_Prefixes = @ExperimentPrefixes,
			CM_Data_Release_Restrictions = @DataReleaseRestrictionsID,
			CM_Fraction_EMSL_Funded = @FractionEMSLFundedValue
		WHERE (Campaign_Num = @campaignNum)
		--
		SELECT @myError = @@error, @myRowCount = @@rowcount
		--
		If @myError <> 0
			RAISERROR ('Update operation failed: "%s"', 11, 14, @campaignNum)

		---------------------------------------------------
		-- Update research team membershipe
		---------------------------------------------------
		--
		EXEC @myError = UpdateResearchTeamForCampaign
							@campaignNum, 
							@progmgrPRN , 
							@piPRN, 
							@TechnicalLead,
							@SamplePreparationStaff,
							@DatasetAcquisitionStaff,
							@InformaticsStaff,
							@Collaborators,
							@researchTeamID output,
							@message output
		--
		If @myError <> 0
			RAISERROR (@message, 11, 1)

		commit transaction @transName
		
		Set @PercentEMSLFunded = CONVERT(int, @FractionEMSLFundedValue * 100)
		
		-- If @callingUser is defined, then call AlterEventLogEntryUser to alter the Entered_By field in T_Event_Log
		If Len(@callingUser) > 0
		Begin
			Exec AlterEventLogEntryUser 9, @CampaignID, @PercentEMSLFunded, @callingUser
			Exec AlterEventLogEntryUser 10, @CampaignID, @DataReleaseRestrictionsID, @callingUser
		End
	End -- update mode

	END TRY
	BEGIN CATCH 
		EXEC FormatErrorMessage @message output, @myError output
		
		-- Rollback any open transactions
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION;


		If @logErrors > 0
		Begin
			Declare @logMessage varchar(1024) = @message + '; Campaign ' + @campaignNum		
			exec PostLogEntry 'Error', @logMessage, 'AddUpdateCampaign'
		End

	END CATCH
	
	return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[AddUpdateCampaign] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddUpdateCampaign] TO [DMS_User] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddUpdateCampaign] TO [DMS2_SP_User] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[AddUpdateCampaign] TO [Limited_Table_Write] AS [dbo]
GO
