/****** Object:  StoredProcedure [dbo].[AddUpdateStepTools] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AddUpdateStepTools
/****************************************************
**
**  Desc: Adds new or edits existing T_Step_Tools
**
**  Return values: 0: success, otherwise, error code
**
**  Parameters:
**
**  Auth: grk
**	09/15/2009 -- initial release (http://prismtrac.pnl.gov/trac/ticket/746)
**    
** Pacific Northwest National Laboratory, Richland, WA
** Copyright 2008, Battelle Memorial Institute
*****************************************************/
	@Name varchar(64),
	@Description varchar(512),
	@BionetRequired char(1),
	@OnlyOnStorageServer char(1),
	@InstrumentCapacityLimited char(1),
	@mode varchar(12) = 'add', -- or 'update'
	@message varchar(512) output,
	@callingUser varchar(128) = ''
	As
	set nocount on

	declare @myError int
	set @myError = 0

	declare @myRowCount int
	set @myRowCount = 0

	set @message = ''


	---------------------------------------------------
	-- Validate input fields
	---------------------------------------------------

	-- future: this could get more complicated


	---------------------------------------------------
	-- Is entry already in database?
	---------------------------------------------------

	declare @tmp int
	set @tmp = 0
	--
	SELECT @tmp = ID
	FROM  T_Step_Tools
	WHERE Name = @Name
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
		set @message = 'Error searching for existing entry'
		RAISERROR (@message, 10, 1)
		return 51007
	end

	-- cannot update a non-existent entry
	--
	if @mode = 'update' and @tmp = 0
	begin
		set @message = 'Could not find "' + @Name + '" in database'
		RAISERROR (@message, 10, 1)
		return 51008
	end

	-- cannot add an existing entry
	--
	if @mode = 'add' and @tmp <> 0
	begin
		set @message = '"' + @Name + '" already exists in database'
		RAISERROR (@message, 10, 1)
		return 51009
	end


	---------------------------------------------------
	-- action for add mode
	---------------------------------------------------
	if @Mode = 'add'
	begin

	INSERT INTO T_Step_Tools (
		Name,
		Description,
		Bionet_Required,
		Only_On_Storage_Server,
		Instrument_Capacity_Limited
	) VALUES (
		@Name,
		@Description,
		@BionetRequired,
		@OnlyOnStorageServer,
		@InstrumentCapacityLimited
	)
	/**/
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
	  set @message = 'Insert operation failed'
	  RAISERROR (@message, 10, 1)
	  return 51007
	end

	end -- add mode

	---------------------------------------------------
	-- action for update mode
	---------------------------------------------------
	--
	if @Mode = 'update' 
	begin
	set @myError = 0
	--

	UPDATE T_Step_Tools 
	SET 
		Description = @Description,
		Bionet_Required = @BionetRequired,
		Only_On_Storage_Server = @OnlyOnStorageServer,
		Instrument_Capacity_Limited = @InstrumentCapacityLimited
	WHERE (Name = @Name)
	--
	SELECT @myError = @@error, @myRowCount = @@rowcount
	--
	if @myError <> 0
	begin
	  set @message = 'Update operation failed: "' + @Name + '"'
	  RAISERROR (@message, 10, 1)
	  return 51004
	end
	end -- update mode

	return @myError


GO
GRANT EXECUTE ON [dbo].[AddUpdateStepTools] TO [DMS_SP_User] AS [dbo]
GO