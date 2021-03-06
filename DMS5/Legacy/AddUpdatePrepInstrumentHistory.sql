/****** Object:  StoredProcedure [dbo].[AddUpdatePrepInstrumentHistory] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddUpdatePrepInstrumentHistory]
/****************************************************
**
**  Desc: Adds new or edits existing T_Prep_Instrument_History
**
**  Return values: 0: success, otherwise, error code
**
**  Parameters:
**
**    Auth: grk
**    Date: 09/30/2008
**    
** Pacific Northwest National Laboratory, Richland, WA
** Copyright 2005, Battelle Memorial Institute
*****************************************************/
  @ID int,
  @Instrument varchar(128),
  @DateOfChange varchar(24),
  @Description varchar(128),
  @Note text,
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
  -- Is entry already in database? (only applies to updates)
  ---------------------------------------------------

  if @mode = 'update'
  begin
    -- cannot update a non-existent entry
    --
    declare @tmp int
  set @tmp = 0
  --
  SELECT @tmp = ID
     FROM  T_Prep_Instrument_History
    WHERE (ID = @ID)
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount
    --
    if @myError <> 0 OR @tmp = 0
    begin
      set @message = 'No entry could be found in database for update'
      RAISERROR (@message, 10, 1)
      return 51007
    end
  
  end


  ---------------------------------------------------
  -- action for add mode
  ---------------------------------------------------
  if @Mode = 'add'
  begin
 
  INSERT INTO T_Prep_Instrument_History (
    Instrument, 
    Date_Of_Change, 
    Description, 
    Note, 
    Entered, 
    EnteredBy
  ) VALUES (
    @Instrument, 
    @DateOfChange,
    @Description, 
    @Note, 
    getdate(), 
    @callingUser
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
    
    -- return IDof newly created entry
    --
    set @ID = IDENT_CURRENT('T_Prep_Instrument_History')

  end -- add mode

  ---------------------------------------------------
  -- action for update mode
  ---------------------------------------------------
  --
  if @Mode = 'update' 
  begin
    set @myError = 0
    --

    UPDATE T_Prep_Instrument_History 
    SET 
      Instrument = @Instrument, 
      Date_Of_Change = @DateOfChange,
      Description = @Description, 
      Note = @Note, 
      EnteredBy = @callingUser
    WHERE (ID = @ID)
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount
    --
    if @myError <> 0
    begin
      set @message = 'Update operation failed: "' + @ID + '"'
      RAISERROR (@message, 10, 1)
      return 51004
    end
  end -- update mode

  return @myError
GO

GRANT EXECUTE ON [dbo].[AddUpdatePrepInstrumentHistory] TO [DMS2_SP_User] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[AddUpdatePrepInstrumentHistory] TO [Limited_Table_Write] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[AddUpdatePrepInstrumentHistory] TO [Limited_Table_Write] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[AddUpdatePrepInstrumentHistory] TO [PNL\D3M578] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[AddUpdatePrepInstrumentHistory] TO [PNL\D3M580] AS [dbo]
GO

