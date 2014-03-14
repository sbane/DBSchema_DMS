/****** Object:  UserDefinedFunction [dbo].[DecodeBase64] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.DecodeBase64
/****************************************************
**
**	Desc: 
**		Decodes the given text using base-64 encoding
**
**		From http://stackoverflow.com/questions/5082345/base64-encoding-in-sql-server-2005-t-sql
**
**	Auth:	mem
**	Date:	09/12/2013
**    
*****************************************************/
(
	@EncodedText varchar(max)
)
RETURNS varchar(max)
AS
BEGIN
	Declare @DecodedText varchar(max)

	SELECT @DecodedText = 
	CAST(
		CAST(N'' AS XML).value(
			'xs:base64Binary(sql:column("bin"))'
		, 'VARBINARY(MAX)'
		) 
		AS VARCHAR(MAX)
	) 
	FROM (
		SELECT CAST(@EncodedText AS VARCHAR(MAX)) AS bin
	) AS ConvertQ;
	
	Return @DecodedText
END

GO