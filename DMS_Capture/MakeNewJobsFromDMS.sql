/****** Object:  StoredProcedure [dbo].[MakeNewJobsFromDMS] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MakeNewJobsFromDMS]
/****************************************************
**
**  Desc:
**      Add dataset capture jobs for datasets in state New in DMS5
**
**  Auth:   grk
**  Date:   09/02/2009 grk - Initial release (http://prismtrac.pnl.gov/trac/ticket/746)
**          02/10/2010 dac - Removed comment stating that jobs were created from test script
**          03/09/2011 grk - Added logic to choose different capture script based on instrument group
**          09/17/2015 mem - Added parameter @infoOnly
**          06/16/2017 mem - Restrict access using VerifySPAuthorized
**          08/01/2017 mem - Use THROW if not authorized
**          06/27/2019 mem - Use GetDatasetCapturePriority to determine capture job priority using dataset name and instrument group
**    
*****************************************************/
(
    @bypassDMS tinyint = 0,
    @message varchar(512) = '' output,
    @maxJobsToProcess int = 0,
    @logIntervalThreshold int = 15,        -- If this procedure runs longer than this threshold, then status messages will be posted to the log
    @loggingEnabled tinyint = 0,        -- Set to 1 to immediately enable progress logging; if 0, then logging will auto-enable if @logIntervalThreshold seconds elapse
    @loopingUpdateInterval int = 5,        -- Seconds between detailed logging while looping through the dependencies
    @infoOnly tinyint = 0,                -- 1 to preview changes that would be made; 2 to add new jobs but do not create job steps
    @debugMode tinyint = 0                -- 0 for no debugging; 1 to see debug messages
)
As
    set nocount on
    
    Declare @myError int = 0
    Declare @myRowCount int = 0

    Declare @currJob int
    Declare @Dataset varchar(128)
    Declare @continue tinyint

    Declare @JobsProcessed int
    Declare @JobCountToResume int
    Declare @JobCountToReset int
    
    Declare @MaxJobsToAddResetOrResume int

    Declare @StartTime datetime
    Declare @LastLogTime datetime
    Declare @StatusMessage varchar(512)    

    ---------------------------------------------------
    -- Verify that the user can execute this procedure from the given client host
    ---------------------------------------------------
        
    Declare @authorized tinyint = 0    
    Exec @authorized = VerifySPAuthorized 'MakeNewJobsFromDMS', @raiseError = 1;
    If @authorized = 0
    Begin;
        THROW 51000, 'Access denied', 1;
    End;
        
    ---------------------------------------------------
    -- Validate the inputs
    ---------------------------------------------------
    --
    Set @infoOnly = IsNull(@infoOnly, 0)
    Set @bypassDMS = IsNull(@bypassDMS, 0)
    Set @debugMode = IsNull(@debugMode, 0)
    Set @maxJobsToProcess = IsNull(@maxJobsToProcess, 0)
    
    set @message = ''

    If @maxJobsToProcess <= 0
        Set @MaxJobsToAddResetOrResume = 1000000
    Else
        Set @MaxJobsToAddResetOrResume = @maxJobsToProcess

    Set @StartTime = GetDate()
    Set @loggingEnabled = IsNull(@loggingEnabled, 0)
    Set @logIntervalThreshold = IsNull(@logIntervalThreshold, 15)
    Set @loopingUpdateInterval = IsNull(@loopingUpdateInterval, 5)
    
    If @logIntervalThreshold = 0
        Set @loggingEnabled = 1
        
    If @loopingUpdateInterval < 2
        Set @loopingUpdateInterval = 2

    If @loggingEnabled = 1 Or DateDiff(second, @StartTime, GetDate()) >= @logIntervalThreshold
    Begin
        Set @StatusMessage = 'Entering (' + CONVERT(VARCHAR(12), @bypassDMS) + ')'
        exec PostLogEntry 'Progress', @StatusMessage, 'MakeNewJobsFromDMS'
    End
    
    ---------------------------------------------------
    -- Add new jobs
    ---------------------------------------------------
    --
    IF @bypassDMS = 0
    BEGIN -- <AddJobs>
    
        If @loggingEnabled = 1 Or DateDiff(second, @StartTime, GetDate()) >= @logIntervalThreshold
        Begin
            Set @StatusMessage = 'Querying DMS'
            exec PostLogEntry 'Progress', @StatusMessage, 'MakeNewJobsFromDMS'
        End

        If @infoOnly = 0
        Begin -- <InsertQuery>
        
            INSERT INTO T_Jobs( Script,
                                [Comment],
                                Dataset,
                                Dataset_ID,
                                Priority)
            SELECT CASE
                       WHEN Src.IN_Group = 'IMS' THEN 'IMSDatasetCapture'
                       ELSE 'DatasetCapture'
                   END AS Script,
                   '' AS [Comment],
                   Src.Dataset,
                   Src.Dataset_ID,
                   dbo.GetDatasetCapturePriority(Src.Dataset, Src.IN_Group)
            FROM V_DMS_Get_New_Datasets Src
                 LEFT OUTER JOIN T_Jobs Target
                   ON Src.Dataset_ID = Target.Dataset_ID
            WHERE Target.Dataset_ID IS NULL
            --
            SELECT @myError = @@error, @myRowCount = @@rowcount
            --
            if @myError <> 0
            begin
                set @message = 'Error adding new DatasetCapture tasks'
                goto Done
            end
            
        End -- </InsertQuery>
        Else
        Begin -- <Preview>

            SELECT CASE
                       WHEN Src.IN_Group = 'IMS' THEN 'IMSDatasetCapture'
                       ELSE 'DatasetCapture'
                   END AS Script,
                   '' AS [Comment],
                   Src.Dataset,
                   Src.Dataset_ID,
                   dbo.GetDatasetCapturePriority(Src.Dataset, Src.IN_Group) As Priority
            FROM V_DMS_Get_New_Datasets Src
                 LEFT OUTER JOIN T_Jobs Target
                   ON Src.Dataset_ID = Target.Dataset_ID
            WHERE Target.Dataset_ID IS NULL
            --
            SELECT @myError = @@error, @myRowCount = @@rowcount
            
        End -- </Preview>
        
    END -- </AddJobs>

    ---------------------------------------------------
    -- Exit
    ---------------------------------------------------
    --
Done:
    If @loggingEnabled = 1 Or DateDiff(second, @StartTime, GetDate()) >= @logIntervalThreshold
    Begin
        Set @StatusMessage = 'Exiting'
        exec PostLogEntry 'Progress', @StatusMessage, 'MakeNewJobsFromDMS'
    End

    return @myError

GO
GRANT VIEW DEFINITION ON [dbo].[MakeNewJobsFromDMS] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[MakeNewJobsFromDMS] TO [DMS_SP_User] AS [dbo]
GO
