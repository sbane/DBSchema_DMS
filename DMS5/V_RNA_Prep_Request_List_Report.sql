/****** Object:  View [dbo].[V_RNA_Prep_Request_List_Report] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[V_RNA_Prep_Request_List_Report]
AS
SELECT SPR.ID ,
       SPR.Request_Name AS RequestName ,
       SPR.Created ,
       SPR.Estimated_Completion AS [Est. Complete] ,
	   TA.Attachments AS Files ,
       SN.State_Name AS [State],
       SPR.Reason ,
       SPR.Number_of_Samples AS NumSamples ,
	   QT.[Days In Queue] ,
       SPR.Prep_Method AS PrepMethod ,
       QP.Name_with_PRN AS Requester ,
       SPR.Organism ,
       SPR.Biohazard_Level AS BiohazardLevel ,
       SPR.Campaign ,
       SPR.Work_Package_Number AS WP ,
       ISNULL(CC.Activation_State_Name, '') AS [WP State],
       SPR.Instrument_Name AS Instrument ,
       SPR.Instrument_Analysis_Specifications AS [Inst. Analysis] ,
	   SPR.EUS_Proposal_ID,
	   SPR.Sample_Naming_Convention As [Sample Prefix],
       SUM (Case When DATEDIFF(day, E.EX_created, GETDATE()) < 8 Then 1 Else 0 End) AS Experiments_Last_7Days,
       SUM (Case When DATEDIFF(day, E.EX_created, GETDATE()) < 32 Then 1 Else 0 End) AS Experiments_Last_31Days,
       SUM (Case When DATEDIFF(day, E.EX_created, GETDATE()) < 181 Then 1 Else 0 End) AS Experiments_Last_180Days,
       SUM (Case When Not E.EX_created Is Null Then 1 Else 0 End) AS Experiments_Total,
       Case 
			When SPR.State In (4,5) Then 0			-- Request is complete or closed
			When QT.[Days In Queue] <= 30 Then	30	-- Request is 0 to 30 days old
			When QT.[Days In Queue] <= 60 Then	60	-- Request is 30 to 60 days old
			When QT.[Days In Queue] <= 90 Then	90	-- Request is 60 to 90 days old
			Else 120								-- Request is over 90 days old
		END AS #DaysInQueue,
	   CASE
           WHEN SPR.State <> 5 AND
                CC.Activation_State >= 3 THEN 10	-- If the request is not closed, but the charge code is inactive, then return 10 for #WPActivationState
           ELSE CC.Activation_State
       END AS #WPActivationState
FROM    T_Sample_Prep_Request AS SPR
        INNER JOIN T_Sample_Prep_Request_State_Name AS SN ON SPR.State = SN.State_ID
        LEFT OUTER JOIN T_Users AS QP ON SPR.Requester_PRN = QP.U_PRN
		LEFT OUTER JOIN V_Sample_Prep_Request_Queue_Times AS QT ON SPR.ID = QT.Request_ID
        LEFT OUTER JOIN ( SELECT    Entity_ID AS [Entity ID] ,
                                    COUNT(*) AS Attachments
                          FROM      T_File_Attachment
                          WHERE     ( Entity_Type = 'sample_prep_request' ) And Active > 0
                          GROUP BY  Entity_ID
                        ) AS TA ON SPR.ID = TA.[Entity ID]
        LEFT OUTER JOIN T_Experiments E ON SPR.ID = E.EX_sample_prep_request_ID
        LEFT OUTER JOIN V_Charge_Code_Status CC ON SPR.Work_Package_Number = CC.Charge_Code
WHERE (SPR.State > 0) And SPR.Request_Type = 'RNA'
GROUP BY SPR.ID, SPR.Request_Name, SPR.Created, SPR.Estimated_Completion, TA.Attachments,
         SPR.State, SN.State_Name, SPR.Reason, SPR.Number_of_Samples, 
		 QT.[Days In Queue], SPR.Prep_Method, 
         QP.Name_with_PRN, SPR.Organism, SPR.Biohazard_Level, SPR.Campaign,
         SPR.Work_Package_Number, SPR.Instrument_Name,
         SPR.Instrument_Analysis_Specifications,  SPR.EUS_Proposal_ID,
	     SPR.Sample_Naming_Convention,
         CC.Activation_State, CC.Activation_State_Name




GO
GRANT VIEW DEFINITION ON [dbo].[V_RNA_Prep_Request_List_Report] TO [DDL_Viewer] AS [dbo]
GO
