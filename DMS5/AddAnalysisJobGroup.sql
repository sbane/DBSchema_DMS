/****** Object:  StoredProcedure [dbo].[AddAnalysisJobGroup] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddAnalysisJobGroup]
/****************************************************
**
**  Desc:   Adds new analysis jobs for list of datasets
**
**  Return values: 0: success, otherwise, error code
**
**  Auth:   grk
**  Date:   01/29/2004
**          04/01/2004 grk - fixed error return
**          06/07/2004 to 4/04/2006 -- multiple updates
**          04/05/2006 grk - major rewrite
**          04/10/2006 grk - widened size of list argument to 6000 characters
**          11/30/2006 mem - Added column Dataset_Type to #TD (Ticket #335)
**          12/19/2006 grk - Added propagation mode (Ticket #348)
**          12/20/2006 mem - Added column DS_rating to #TD (Ticket #339)
**          02/07/2007 grk - eliminated "Spectra Required" states (Ticket #249)
**          02/15/2007 grk - added associated processor group (Ticket #383)
**          02/21/2007 grk - removed @assignedProcessor  (Ticket #383)
**          10/11/2007 grk - Expand protein collection list size to 4000 characters (https://prismtrac.pnl.gov/trac/ticket/545)
**          02/19/2008 grk - add explicit NULL column attribute to #TD
**          02/29/2008 mem - Added optional parameter @callingUser; if provided, then will call AlterEventLogEntryUser or AlterEventLogEntryUserMultiID (Ticket #644)
**          05/27/2008 mem - Increased @EntryTimeWindowSeconds value to 45 seconds when calling AlterEventLogEntryUserMultiID
**          09/12/2008 mem - Now passing @parmFileName and @settingsFileName ByRef to ValidateAnalysisJobParameters (Ticket #688, http://prismtrac.pnl.gov/trac/ticket/688)
**          02/27/2009 mem - Expanded @comment to varchar(512)
**          04/15/2009 grk - handles wildcard DTA folder name in comment field (Ticket #733, http://prismtrac.pnl.gov/trac/ticket/733)
**          08/05/2009 grk - assign job number from separate table (Ticket #744, http://prismtrac.pnl.gov/trac/ticket/744)
**          08/05/2009 mem - Now removing duplicates when populating #TD
**                         - Updated to use GetNewJobIDBlock to obtain job numbers
**          09/17/2009 grk - Don't make new jobs for datasets with existing jobs (optional mode) (Ticket #747, http://prismtrac.pnl.gov/trac/ticket/747)
**          09/19/2009 grk - Improved return message
**          09/23/2009 mem - Updated to handle requests with state "New (Review Required)"
**          12/21/2009 mem - Now updating field AJR_jobCount in T_Analysis_Job_Request when @requestID is > 1
**          04/22/2010 grk - try-catch for error handling
**          05/05/2010 mem - Now passing @ownerPRN to ValidateAnalysisJobParameters as input/output
**          05/06/2010 mem - Expanded @settingsFileName to varchar(255)
**          01/31/2011 mem - Expanded @datasetList to varchar(max)
**          02/24/2011 mem - No longer skipping jobs with state "No Export" when finding datasets that have existing, matching jobs
**          03/29/2011 grk - added @specialProcessing argument (http://redmine.pnl.gov/issues/304)
**          05/24/2011 mem - Now populating column AJ_DatasetUnreviewed
**          06/15/2011 mem - Now ignoring organism, protein collection, and organism DB when looking for existing jobs and the analysis tool does not use an organism database
**          09/25/2012 mem - Expanded @organismDBName and @organismName to varchar(128)
**          11/08/2012 mem - Now auto-updating @protCollOptionsList to have "seq_direction=forward" if it contains "decoy" and the search tool is MSGFDB and the parameter file does not contain "NoDecoy"
**          01/11/2013 mem - Renamed MSGF-DB search tool to MSGFPlus
**          03/26/2013 mem - Now calling AlterEventLogEntryUser after updating T_Analysis_Job_Request
**          03/27/2013 mem - Now auto-updating @ownerPRN to @callingUser if @callingUser maps to a valid user
**          06/06/2013 mem - Now setting job state to 19="Special Proc. Waiting" if analysis tool has Use_SpecialProcWaiting enabled
**          04/08/2015 mem - Now passing @AutoUpdateSettingsFileToCentroided and @Warning to ValidateAnalysisJobParameters
**          05/28/2015 mem - No longer creating processor group entries (thus @associatedProcessorGroup is ignored)
**          12/17/2015 mem - Now considering @specialProcessing when looking for existing jobs
**          02/23/2016 mem - Add set XACT_ABORT on
**          05/18/2016 mem - Log errors to T_Log_Entries
**          05/18/2016 mem - Include the Request ID in error messages
**          07/12/2016 mem - Pass @priority to ValidateAnalysisJobParameters
**          04/12/2017 mem - Log exceptions to T_Log_Entries
**          06/16/2017 mem - Restrict access using VerifySPAuthorized
**          08/01/2017 mem - Use THROW if not authorized
**          12/06/2017 mem - Set @allowNewDatasets to 0 when calling ValidateAnalysisJobParameters
**          05/11/2018 mem - When the settings file is Decon2LS_DefSettings.xml, also match jobs with a settings file of 'na'
**          06/12/2018 mem - Send @maxLength to AppendToText
**          07/30/2019 mem - Call UpdateCachedJobRequestExistingJobs after creating new jobs
**
*****************************************************/
(
    @datasetList varchar(max),
    @priority int = 2,
    @toolName varchar(64),
    @parmFileName varchar(255),
    @settingsFileName varchar(255),
    @organismDBName varchar(128),                   -- 'na' if using protein collections
    @organismName varchar(128),
    @protCollNameList varchar(4000),
    @protCollOptionsList varchar(256),
    @ownerPRN varchar(32),                          -- Will get updated to @callingUser if @callingUser is valid
    @comment varchar(512) = null,
    @specialProcessing varchar(512) = null,
    @requestID int,                                 -- 0 if not associated with a request; otherwise, Request ID in T_Analysis_Job_Request
    @associatedProcessorGroup varchar(64) = '',     -- Processor group; deprecated in May 2015
    @propagationMode varchar(24) = 'Export',        -- 'Export', 'No Export'
    @removeDatasetsWithJobs VARCHAR(12) = 'Y',
    @mode varchar(12),                              -- 'add', 'update', 'preview'
    @message varchar(512) = '' output,
    @callingUser varchar(128) = ''
)
As
    Set XACT_ABORT, nocount on

    Declare @myError int = 0
    Declare @myRowCount int = 0
    
    Set @message = ''

    Declare @msg varchar(512)
    Declare @list varchar(1024)
    Declare @jobID int
    Declare @JobIDStart int
    Declare @JobIDEnd int
        
    Declare @jobStateID int
    Declare @requestStateID int = 0
    
    Declare @jobsCreated INT
    Set @jobsCreated = 0

    ---------------------------------------------------
    -- Verify that the user can execute this procedure from the given client host
    ---------------------------------------------------
        
    Declare @authorized tinyint = 0    
    Exec @authorized = VerifySPAuthorized 'AddAnalysisJobGroup', @raiseError = 1
    If @authorized = 0
    Begin;
        THROW 51000, 'Access denied', 1;
    End;

    BEGIN TRY 

    ---------------------------------------------------
    -- list shouldn't be empty
    ---------------------------------------------------
    If @datasetList = ''
        RAISERROR ('Dataset list is empty for request %d', 11, 1, @requestID)

    /*
    ---------------------------------------------------
    -- Deprecated in May 2015: resolve processor group ID
    ---------------------------------------------------
    --
    Declare @gid int
    Set @gid = 0
    --
    If @associatedProcessorGroup <> ''
    Begin
        SELECT @gid = ID
        FROM T_Analysis_Job_Processor_Group
        WHERE (Group_Name = @associatedProcessorGroup)    
        --
        SELECT @myError = @@error, @myRowCount = @@rowcount
        --
        If @myError <> 0
            RAISERROR ('Error trying to resolve processor group name for request %d', 11, 8, @requestID)
        --
        If @gid = 0
            RAISERROR ('Processor group name not found for request %d', 11, 9, @requestID)
    End
    */
    
    ---------------------------------------------------
    -- Create temporary table to hold list of datasets
    ---------------------------------------------------

    CREATE TABLE #TD (
        Dataset_Num varchar(128),
        Dataset_ID int NULL,
        IN_class varchar(64) NULL, 
        DS_state_ID int NULL, 
        AS_state_ID int NULL,
        Dataset_Type varchar(64) NULL,
        DS_rating smallint NULL,
        Job int NULL,
        Dataset_Unreviewed tinyint NULL
    )
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount
    --
    If @myError <> 0
        RAISERROR ('Failed to create temporary table for request %d', 11, 7, @requestID)

    CREATE CLUSTERED INDEX #IX_TD_Dataset_Num ON #TD (Dataset_Num)

    ---------------------------------------------------
    -- Populate table from dataset list  
    -- Using Select Distinct to make sure any duplicates are removed
    ---------------------------------------------------
    --
    INSERT INTO #TD
        (Dataset_Num)
    SELECT
        DISTINCT LTrim(RTrim(Item))
    FROM
        MakeTableFromList(@datasetList)
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount
    --
    If @myError <> 0
        RAISERROR ('Error populating temporary table for request %d', 11, 7, @requestID)
    --
    Set @jobsCreated = @myRowCount

    -- Make sure the Dataset names do not have carriage returns or line feeds
        
    UPDATE #td
    SET Dataset_Num = Replace(Dataset_Num, char(13), '')
    WHERE Dataset_Num LIKE '%' + char(13) + '%'
    
    UPDATE #td
    SET Dataset_Num = Replace(Dataset_Num, char(10), '')
    WHERE Dataset_Num LIKE '%' + char(10) + '%'


    ---------------------------------------------------
    -- Auto-update @protCollOptionsList if it specifies a decoy search, but we're running MSGFPlus and the parameter file does not contain "NoDecoy"
    ---------------------------------------------------
    --
    If @toolName LIKE 'MSGFPlus%' And @protCollOptionsList Like '%decoy%' And @parmFileName Not Like '%[_]NoDecoy%'
    Begin
        Set @protCollOptionsList = 'seq_direction=forward,filetype=fasta'
        If IsNull(@message, '') = ''
            Set @message = 'Note: changed protein options to forward-only since MSGF+ parameter file should have tda=1'
    End
    ---------------------------------------------------
    -- Auto-update @ownerPRN to @callingUser if possible
    ---------------------------------------------------
    If Len(@callingUser) > 0
    Begin
        Declare @newPRN varchar(128) = @callinguser
        Declare @slashIndex int = CHARINDEX('\', @newPRN)
        
        If @slashIndex > 0
            Set @newPRN = SUBSTRING(@newPRN, @slashIndex+1, LEN(@newPRN))
        
        If Exists (SELECT * FROM T_Users Where U_PRN = @newPRN)
            Set @ownerPRN = @newPRN
    End
    ---------------------------------------------------
    -- If @removeDatasetsWithJobs is not "N" then
    --  find datasets from temp table that have existing
    --  jobs that match criteria from request
    -- If AJT_orgDbReqd = 0, then we ignore organism, protein collection, and organism DB
    ---------------------------------------------------
    --
    Declare @numMatchingDatasets INT = 0
    
    Declare @removedDatasets VARCHAR(4096) = ''
    --
    If @removeDatasetsWithJobs <> 'N'
    Begin --<remove>
        Declare @matchingJobDatasets Table (
            Dataset varchar(128)
        )
        --
        INSERT INTO @matchingJobDatasets(Dataset)
        SELECT 
            DS.Dataset_Num AS Dataset
        FROM
            T_Dataset DS INNER JOIN
            T_Analysis_Job AJ ON AJ.AJ_datasetID = DS.Dataset_ID INNER JOIN
            T_Analysis_Tool AJT ON AJ.AJ_analysisToolID = AJT.AJT_toolID INNER JOIN
            T_Organisms Org ON AJ.AJ_organismID = Org.Organism_ID  INNER JOIN
            T_Analysis_State_Name ASN ON AJ.AJ_StateID = ASN.AJS_stateID INNER JOIN
            #TD ON #TD.Dataset_Num = DS.Dataset_Num
        WHERE
            (NOT (AJ.AJ_StateID IN (5))) AND
            AJT.AJT_toolName = @toolName AND 
            AJ.AJ_parmFileName = @parmFileName AND
            (AJ.AJ_settingsFileName = @settingsFileName OR
             AJ.AJ_settingsFileName = 'na' AND @settingsFileName = 'Decon2LS_DefSettings.xml') AND 
            ( (    @protCollNameList = 'na' AND AJ.AJ_organismDBName = @organismDBName AND 
                Org.OG_name = IsNull(@organismName, Org.OG_name)
              ) OR
              (    @protCollNameList <> 'na' AND 
                AJ.AJ_proteinCollectionList = IsNull(@protCollNameList, AJ.AJ_proteinCollectionList) AND 
                AJ.AJ_proteinOptionsList = IsNull(@protCollOptionsList, AJ.AJ_proteinOptionsList)
              ) OR
              (
                AJT.AJT_orgDbReqd = 0
              )
            ) AND
            IsNull(AJ.AJ_specialProcessing, '') = IsNull(@SpecialProcessing, '')
        GROUP BY DS.Dataset_Num
        --
        SELECT @myError = @@error, @myRowCount = @@rowcount
        --
        If @myError <> 0
            RAISERROR ('Error trying to find datasets with existing jobs for request %d', 11, 97, @requestID)
        
        Set @numMatchingDatasets = @myRowCount
        
        If @numMatchingDatasets > 0
        Begin --<remove-a>
            -- remove datasets from list that have existing jobs
            --
            DELETE FROM #TD
            WHERE Dataset_Num IN (SELECT Dataset FROM @matchingJobDatasets)
            --
            SELECT @myError = @@error, @myRowCount = @@rowcount
            --
            Set @jobsCreated = @jobsCreated - @myRowCount
            
            -- make list of removed datasets
            --
            Declare @threshold SMALLINT
            Set @threshold = 5
            Set @removedDatasets = CONVERT(varchar(12), @numMatchingDatasets) + ' skipped datasets that had existing jobs:'
            SELECT TOP(@threshold) @removedDatasets =  @removedDatasets + Dataset + ', ' FROM @matchingJobDatasets
            If @numMatchingDatasets > @threshold
            Begin
                Set @removedDatasets = @removedDatasets + ' (more datasets not shown)'
            End
        End --<remove-a>
    End --<remove>

    
    ---------------------------------------------------
    -- Resolve propagation mode 
    ---------------------------------------------------
    Declare @propMode smallint
    Set @propMode = CASE @propagationMode 
                        WHEN 'Export' THEN 0 
                        WHEN 'No Export' THEN 1 
                        ELSE 0 
                    End
    ---------------------------------------------------
    -- validate job parameters
    ---------------------------------------------------
    --
    Declare @userID int
    Declare @analysisToolID int
    Declare @organismID int
    --
    Declare @result int = 0
    Declare @Warning varchar(255) = ''
    --
    exec @result = ValidateAnalysisJobParameters
                            @toolName = @toolName,
                            @parmFileName = @parmFileName output,
                            @settingsFileName = @settingsFileName output,
                            @organismDBName = @organismDBName output,
                            @organismName = @organismName,
                            @protCollNameList = @protCollNameList output,
                            @protCollOptionsList = @protCollOptionsList output,
                            @ownerPRN = @ownerPRN output,
                            @mode = @mode, 
                            @userID = @userID output,
                            @analysisToolID = @analysisToolID output, 
                            @organismID = @organismID output,
                            @message = @msg output,
                            @AutoRemoveNotReleasedDatasets = 0,
                            @AutoUpdateSettingsFileToCentroided = 1,
                            @allowNewDatasets = 0,
                            @Warning = @Warning output,
                            @priority = @priority output
    --
    If @result <> 0
        RAISERROR ('ValidateAnalysisJobParameters: %s for request %d', 11, 8, @msg, @requestID)
    
    If IsNull(@Warning, '') <> ''
    Begin
        Set @comment = dbo.AppendToText(@comment, @Warning, 0, '; ', 512)
    End
    ---------------------------------------------------
    -- New jobs typically have state 1
    -- Update @jobStateID to 19="Special Proc. Waiting" if necessary
    ---------------------------------------------------
    --
    Set @jobStateID = 1
    --
    If IsNull(@specialProcessing, '') <> '' AND
       Exists (SELECT * FROM T_Analysis_Tool WHERE AJT_toolName = @toolName AND Use_SpecialProcWaiting > 0) 
    Begin
        Set @jobStateID = 19
    End
    ---------------------------------------------------
    -- Populate the Dataset_Unreviewed column in #TD
    ---------------------------------------------------
    --
    UPDATE #TD
    SET Dataset_Unreviewed = CASE WHEN DS.DS_rating = -10 THEN 1 ELSE 0 END
    FROM T_Dataset DS
        INNER JOIN #TD
        ON DS.Dataset_Num = #TD.Dataset_Num
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount

    
    If @mode = 'add'
    Begin
        If @jobsCreated = 0 AND @numMatchingDatasets > 0
            RAISERROR ('No jobs were made for request %d because there were existing jobs for all datasets in the list', 11, 94, @requestID)

        ---------------------------------------------------
        -- start transaction
        ---------------------------------------------------
        --
        Declare @transName varchar(32)
        Set @transName = 'AddAnalysisJobGroup'
        Begin transaction @transName

        ---------------------------------------------------
        -- create a new batch if multiple jobs being created
        ---------------------------------------------------
        Declare @batchID int
        Set @batchID = 0
        --
        Declare @numDatasets int
        Set @numDatasets = 0
        SELECT @numDatasets = count(*) FROM #TD
        --
        If @numDatasets = 0
            RAISERROR ('No datasets in list to create jobs for request %d', 11, 17, @requestID)
        --
        If @numDatasets > 1
        Begin
            INSERT INTO T_Analysis_Job_Batches
                (Batch_Description)
            VALUES ('Auto')    
            --
            SELECT @myError = @@error, @myRowCount = @@rowcount
            --
            If @myError <> 0
                RAISERROR ('Error trying to create new batch when making jobs for request %d', 11, 7, @requestID)
            
            -- return ID of newly created batch
            --
            Set @batchID = SCOPE_IDENTITY()
        End

        ---------------------------------------------------
        -- Deal with request
        ---------------------------------------------------
        --
        If @requestID = 0
        Begin
            Set @requestID = 1 -- for the default request
        End
        Else
        Begin
            -- make sure @requestID is in state 1=new or state 5=new (Review Required)
                    
            SELECT @requestStateID = AJR_State
            FROM T_Analysis_Job_Request
            WHERE AJR_RequestID = @requestID
            --
            SELECT @myError = @@error, @myRowCount = @@rowcount
            --
            If @myError <> 0
                RAISERROR ('Error looking up request state in T_Analysis_Job_Request for request %d', 11, 7, @requestID)
            
            Set @requestStateID = IsNull(@requestStateID, 0)

            If @requestStateID IN (1, 5)
            Begin
                If @mode in ('add', 'update')
                Begin
                    -- Mark request as used
                    --
                    Set @requestStateID = 2
                    
                    UPDATE T_Analysis_Job_Request
                    SET AJR_state = @requestStateID
                    WHERE AJR_requestID = @requestID
                    --
                    SELECT @myError = @@error, @myRowCount = @@rowcount
                    --
                    If @myError <> 0
                        RAISERROR ('Update operation failed setting state to %d for request %d', 11, 8, @requestStateID, @requestID)
                        
                    If Len(@callingUser) > 0
                    Begin
                        -- @callingUser is defined; call AlterEventLogEntryUser or AlterEventLogEntryUserMultiID
                        -- to alter the Entered_By field in T_Event_Log
                        --
                        Exec AlterEventLogEntryUser 12, @requestID, @requestStateID, @callingUser
                    End
                End
            End
            Else
            Begin
                -- Request ID is non-zero and request is not in state 1 or state 5
                RAISERROR ('Request is not in state New; cannot create jobs for request %d', 11, 9, @requestID)
            End
        End

        ---------------------------------------------------
        -- Get new job number for every dataset 
        -- in temporary table
        ---------------------------------------------------

        -- Stored procedure GetNewJobIDBlock will populate #TmpNewJobIDs
        CREATE TABLE #TmpNewJobIDs (ID int)

        exec @myError = GetNewJobIDBlock @numDatasets, 'Job created in DMS'
        If @myError <> 0
            RAISERROR ('Error obtaining block of Job IDs', 11, 10)

        -- Use the job number information in #TmpNewJobIDs to update #TD
        -- If we know the first job number in #TmpNewJobIDs, then we can use
        --  the Row_Number() function to update #TD
        
        Set @JobIDStart = 0
        Set @JobIDEnd = 0
        
        SELECT @JobIDStart = MIN(ID), 
               @JobIDEnd = MAX(ID)
        FROM #TmpNewJobIDs

        -- Make sure @JobIDStart and @JobIDEnd define a contiguous block of jobs
        If @JobIDEnd - @JobIDStart + 1 <> @numDatasets
            RAISERROR ('GetNewJobIDBlock did not return a contiguous block of jobs; requested %d jobs but job range is %d to %d', 11, 11, @numDatasets, @JobIDStart, @JobIDEnd)
        
        -- The JobQ subquery uses Row_Number() and @JobIDStart to define the new job numbers for each entry in #TD
        UPDATE #TD
        SET Job = JobQ.ID
        FROM #TD
             INNER JOIN ( SELECT Dataset_ID,
                                 Row_Number() OVER ( ORDER BY Dataset_ID ) + @JobIDStart - 1 AS ID
                          FROM #TD ) JobQ
               ON #TD.Dataset_ID = JobQ.Dataset_ID
        --
        SELECT @myError = @@error, @myRowCount = @@rowcount


        ---------------------------------------------------
        -- insert a new job in analysis job table for
        -- every dataset in temporary table
        ---------------------------------------------------
        --
        INSERT INTO T_Analysis_Job (
            AJ_jobID,
            AJ_priority, 
            AJ_created, 
            AJ_analysisToolID, 
            AJ_parmFileName, 
            AJ_settingsFileName,
            AJ_organismDBName, 
            AJ_proteinCollectionList, 
            AJ_proteinOptionsList,
            AJ_organismID, 
            AJ_datasetID, 
            AJ_comment,
            AJ_specialProcessing,
            AJ_owner,
            AJ_batchID,
            AJ_StateID,
            AJ_requestID,
            AJ_propagationMode,
            AJ_DatasetUnreviewed
        ) SELECT
            Job,
            @priority, 
            getdate(), 
            @analysisToolID, 
            @parmFileName, 
            @settingsFileName,
            @organismDBName, 
            @protCollNameList,
            @protCollOptionsList,
            @organismID, 
            #TD.Dataset_ID, 
            REPLACE(@comment, '#DatasetNum#', CONVERT(varchar(12), #TD.Dataset_ID)),
            @specialProcessing,
            @ownerPRN,
            @batchID,
            @jobStateID,
            @requestID,
            @propMode,
            IsNull(Dataset_Unreviewed, 1)
        FROM #TD        
        --
        SELECT @myError = @@error, @myRowCount = @@rowcount
        --
        If @myError <> 0
        Begin
            -- set request status to 'incomplete'
            If @requestID > 1
            Begin
                Set @requestStateID = 4
                
                UPDATE    T_Analysis_Job_Request
                SET        AJR_state = @requestStateID
                WHERE    AJR_requestID = @requestID
                
                If Len(@callingUser) > 0
                Begin
                    -- @callingUser is defined; call AlterEventLogEntryUser or AlterEventLogEntryUserMultiID
                    -- to alter the Entered_By field in T_Event_Log
                    --
                    Exec AlterEventLogEntryUser 12, @requestID, @requestStateID, @callingUser
                End
            End
            --
            RAISERROR ('Insert new job operation failed', 11, 7)
        End
        --
        Set @jobsCreated = @myRowCount

        If @batchID = 0 AND @myRowCount = 1
        Begin
            -- Added a single job; cache the jobID value
            Set @jobID = SCOPE_IDENTITY()
        End
        /*
        ---------------------------------------------------
        -- Deprecated in May 2015: create associations with processor group for new
        -- jobs, if group ID is given
        ---------------------------------------------------

        If @gid <> 0
        Begin
            -- if single job was created, get its identity directly
            --
            If @batchID = 0 AND @myRowCount = 1
            Begin
                INSERT INTO T_Analysis_Job_Processor_Group_Associations
                    (Job_ID, Group_ID)
                VALUES
                    (@jobID, @gid)
                --
                SELECT @myError = @@error, @myRowCount = @@rowcount
            End
            --
            -- if multiple jobs were created, get job identities
            -- from all jobs using new batch ID
            --
            If @batchID <> 0 AND @myRowCount >= 1
            Begin
                INSERT INTO T_Analysis_Job_Processor_Group_Associations
                    (Job_ID, Group_ID)
                SELECT
                    AJ_jobID, @gid
                FROM
                    T_Analysis_Job
                WHERE
                    (AJ_batchID = @batchID)
                --
                SELECT @myError = @@error, @myRowCount = @@rowcount
            End
            --
            If @myError <> 0
                RAISERROR ('Error Associating job with processor group', 11, 7)
        End
        */

        commit transaction @transName

        If @requestID > 1
        Begin
            -------------------------------------------------
            -- Update the AJR_jobCount field for this job request
            -------------------------------------------------

            UPDATE T_Analysis_Job_Request
            SET AJR_jobCount = StatQ.JobCount
            FROM T_Analysis_Job_Request AJR
                INNER JOIN ( SELECT AJR.AJR_requestID,
                                    SUM(CASE WHEN AJ.AJ_jobID IS NULL 
                                             THEN 0
                                             ELSE 1
                                        END) AS JobCount
                            FROM T_Analysis_Job_Request AJR
                                INNER JOIN T_Users U
                                    ON AJR.AJR_requestor = U.ID
                                INNER JOIN T_Analysis_Job_Request_State AJRS
                                    ON AJR.AJR_state = AJRS.ID
                                INNER JOIN T_Organisms Org
                                    ON AJR.AJR_organism_ID = Org.Organism_ID
                                LEFT OUTER JOIN T_Analysis_Job AJ
                                    ON AJR.AJR_requestID = AJ.AJ_requestID
                            WHERE AJR.AJR_requestID = @requestID
                            GROUP BY AJR.AJR_requestID 
                            ) StatQ
                ON AJR.AJR_requestID = StatQ.AJR_requestID
            --    
            SELECT @myError = @@error, @myRowCount = @@rowcount
            
            Exec UpdateCachedJobRequestExistingJobs @processingMode = 0, @requestId = @requestId, @infoOnly = 0

        End

        If Len(@callingUser) > 0
        Begin
            -- @callingUser is defined; call AlterEventLogEntryUser or AlterEventLogEntryUserMultiID
            -- to alter the Entered_By field in T_Event_Log
            --
            If @batchID = 0
                Exec AlterEventLogEntryUser 5, @jobID, @jobStateID, @callingUser
            Else
            Begin
                -- Populate a temporary table with the list of Job IDs just created
                CREATE TABLE #TmpIDUpdateList (
                    TargetID int NOT NULL
                )
                
                CREATE UNIQUE CLUSTERED INDEX #IX_TmpIDUpdateList ON #TmpIDUpdateList (TargetID)
                
                INSERT INTO #TmpIDUpdateList (TargetID)
                SELECT DISTINCT AJ_jobID
                FROM T_Analysis_Job
                WHERE AJ_batchID = @batchID
                    
                Exec AlterEventLogEntryUserMultiID 5, @jobStateID, @callingUser, @EntryTimeWindowSeconds=45
            End
        End
    End -- mode 'add'

    ---------------------------------------------------
    -- build message
    ---------------------------------------------------
Explain:
    If @mode = 'add'
        Set @message = ' There were '
    Else
        Set @message = ' There would be '
    Set @message = @message + CONVERT(varchar(12), @jobsCreated) + ' jobs created. '
    --
    If @numMatchingDatasets > 0
    Begin
        If @mode = 'add'
            Set @removedDatasets = ' Jobs were not made for ' + @removedDatasets
        Else
            Set @removedDatasets = ' Jobs would not be made for ' + @removedDatasets
        Set @message = @message + @removedDatasets
    End
    End Try
    Begin Catch
        EXEC FormatErrorMessage @message output, @myError output
        
        Declare @msgForLog varchar(512) = ERROR_MESSAGE()
        
        -- rollback any open transactions
        If (XACT_STATE()) <> 0
            ROLLBACK TRANSACTION;
        
        Exec PostLogEntry 'Error', @msgForLog, 'AddAnalysisJobGroup'
    End Catch
    return @myError


GO
GRANT VIEW DEFINITION ON [dbo].[AddAnalysisJobGroup] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddAnalysisJobGroup] TO [DMS_Analysis] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[AddAnalysisJobGroup] TO [DMS2_SP_User] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[AddAnalysisJobGroup] TO [Limited_Table_Write] AS [dbo]
GO
