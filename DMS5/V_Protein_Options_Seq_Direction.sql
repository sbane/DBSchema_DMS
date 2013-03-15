/****** Object:  View [dbo].[V_Protein_Options_Seq_Direction] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW dbo.V_Protein_Options_Seq_Direction
AS
SELECT String_Element AS ex,
       Display_Value AS val
FROM ProteinSeqs.Protein_Sequences.dbo.V_Creation_String_Lookup CSL
WHERE (Keyword = 'seq_direction')


GO
GRANT VIEW DEFINITION ON [dbo].[V_Protein_Options_Seq_Direction] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Protein_Options_Seq_Direction] TO [PNL\D3M580] AS [dbo]
GO