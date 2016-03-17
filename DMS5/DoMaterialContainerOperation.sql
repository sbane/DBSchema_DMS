/****** Object:  StoredProcedure [dbo].[DoMaterialContainerOperation] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure DoMaterialContainerOperation
/****************************************************
**
**  Desc: 
**
**  Return values: 0: success, otherwise, error code
**
**  Parameters:
**
**	Auth:	grk
**	Date:	07/23/2008 grk - Initial version (ticket http://prismtrac.pnl.gov/trac/ticket/603)
**			10/01/2009 mem - Expanded error message
**			08/19/2010 grk - try-catch for error handling
**			02/23/2016 mem - Add set XACT_ABORT on
**    
** Pacific Northwest National Laboratory, Richland, WA
** Copyright 2008, Battelle Memorial Institute
*****************************************************/
(
	@name varchar(128),
	@mode varchar(32),					-- 'retire_container'
    @message varchar(512) output,
	@callingUser varchar (128) = ''
)
As
	Set XACT_ABORT, nocount on

	declare @myError int
	declare @myRowCount int
	set @myError = 0
	set @myRowCount = 0
	
	set @message = ''
    declare @msg varchar(512)

	BEGIN TRY 

	---------------------------------------------------
	-- convert name to ID
	---------------------------------------------------
	declare @tmpID int
	set @tmpID = 0
	--
	SELECT @tmpID = ID
	FROM T_Material_Containers
	WHERE Tag = @name
	
	---------------------------------------------------
	-- 
	---------------------------------------------------
	--
	if @tmpID = 0
	begin
		set @msg = 'Could not find the container for @mode="' + @mode + '" and @name="' + @name + '"'
		RAISERROR (@msg, 11, 1)
	end
	else
	begin
		declare
			@iMode varchar(32),
			@containerList varchar(4096),
			@newValue varchar(128),
			@comment varchar(512)

			set @iMode = @mode
			set @containerList = @tmpID
			set @newValue  = ''
			set @comment  = ''

		exec @myError = UpdateMaterialContainers
							@iMode,
							@containerList,
							@newValue,
							@comment,
							@msg output,
   							@callingUser


		if @myError <> 0
		begin
			RAISERROR (@msg, 11, 2)
		end
	end

	END TRY
	BEGIN CATCH 
		EXEC FormatErrorMessage @message output, @myError output
		
		-- rollback any open transactions
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION;
	END CATCH
	return @myError

GO
GRANT EXECUTE ON [dbo].[DoMaterialContainerOperation] TO [DMS2_SP_User] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[DoMaterialContainerOperation] TO [Limited_Table_Write] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[DoMaterialContainerOperation] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[DoMaterialContainerOperation] TO [PNL\D3M580] AS [dbo]
GO
