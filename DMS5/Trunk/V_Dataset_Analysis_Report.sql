/****** Object:  View [dbo].[V_Dataset_Analysis_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.V_Dataset_Analysis_Report
AS
SELECT T_Dataset.Dataset_Num AS Dataset, 
   T_Experiments.Experiment_Num AS Experiment, 
   T_Campaign.Campaign_Num AS Campaign, 
   T_Instrument_Name.IN_name AS Instrument, 
   T_Instrument_Name.IN_class AS Class, 
   T_Dataset.DS_created AS Created, 
   T_DatasetStateName.DSS_name AS State, 
   T_Dataset.DS_folder_name AS [Folder Name], 
   t_storage_path.SP_vol_name_client + t_storage_path.SP_path AS
    Storage, T_DatasetRatingName.DRN_name AS Rating
FROM T_Dataset INNER JOIN
   T_DatasetStateName ON 
   T_Dataset.DS_state_ID = T_DatasetStateName.Dataset_state_ID INNER
    JOIN
   T_Instrument_Name ON 
   T_Dataset.DS_instrument_name_ID = T_Instrument_Name.Instrument_ID
    INNER JOIN
   T_DatasetTypeName ON 
   T_Dataset.DS_type_ID = T_DatasetTypeName.DST_Type_ID INNER
    JOIN
   T_Experiments ON 
   T_Dataset.Exp_ID = T_Experiments.Exp_ID INNER JOIN
   t_storage_path ON 
   T_Dataset.DS_storage_path_ID = t_storage_path.SP_path_ID INNER
    JOIN
   T_Users ON 
   T_Dataset.DS_Oper_PRN = T_Users.U_PRN INNER JOIN
   T_DatasetRatingName ON 
   T_Dataset.DS_rating = T_DatasetRatingName.DRN_state_ID INNER
    JOIN
   T_Campaign ON 
   T_Experiments.EX_campaign_ID = T_Campaign.Campaign_ID
GO
GRANT VIEW DEFINITION ON [dbo].[V_Dataset_Analysis_Report] TO [PNL\D3M578] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[V_Dataset_Analysis_Report] TO [PNL\D3M580] AS [dbo]
GO
