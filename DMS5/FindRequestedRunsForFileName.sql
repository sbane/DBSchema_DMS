/****** Object:  UserDefinedFunction [dbo].[FindRequestedRunsForFileName] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.FindRequestedRunsForFileName
/****************************************************
**	Desc: 
**  Returns list of active requested runs that match given file name
**
**	Return values: 
**
**	Parameters:
**	
**	Auth:	grk   
**	Date:	07/20/2012 grk - initial release
**    
*****************************************************/
(
@fileName VARCHAR(256)
)
RETURNS @TX TABLE (
	Request varchar(256),
	ID int,
	NumCharsMatched INT,
	DatasetID INT
)
AS
	BEGIN
		INSERT INTO @TX (
			Request,
			ID,
			NumCharsMatched,
			DatasetID
		)
		SELECT  RDS_Name ,
				ID,
				LEN(RDS_Name) AS NumCharsMatched,
				DatasetID
		FROM    T_Requested_Run
		WHERE   RDS_Status = 'Active' 
				AND LEN(RDS_Name) <= LEN(@fileName)
				AND RDS_Name = SUBSTRING(@fileName, 1, LEN(RDS_Name))
		ORDER BY NumCharsMatched DESC
	RETURN
	END

GO
GRANT VIEW DEFINITION ON [dbo].[FindRequestedRunsForFileName] TO [DDL_Viewer] AS [dbo]
GO
