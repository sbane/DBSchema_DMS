/****** Object:  StoredProcedure [dbo].[DeleteAnalysisRequest] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[DeleteAnalysisRequest]
/****************************************************
**
**  Desc: Delete the analysis job request if it is not associated with any jobs
**
**  Return values: 0: success, otherwise, error code
**
**  Auth:   grk
**  Date:   10/13/2004
**          04/07/2006 grk - Eliminated job to request map table
**          06/16/2017 mem - Restrict access using VerifySPAuthorized
**          08/01/2017 mem - Use THROW if not authorized
**          07/30/2019 mem - Delete datasets from T_Analysis_Job_Request_Datasets
**    
*****************************************************/
(
    @requestID int,
    @message varchar(512) output
)
As    
    set nocount on

    Declare @myError int = 0
    Declare @myRowCount int = 0

    set @message = ''

    ---------------------------------------------------
    -- Verify that the user can execute this procedure from the given client host
    ---------------------------------------------------
        
    Declare @authorized tinyint = 0    
    Exec @authorized = VerifySPAuthorized 'DeleteAnalysisRequest', @raiseError = 1
    If @authorized = 0
    Begin;
        THROW 51000, 'Access denied', 1;
    End;
    
    ---------------------------------------------------
    -- Does request exist?
    ---------------------------------------------------
    --
    Declare @tempID Int = 0
    --
    SELECT @tempID = AJR_requestID
    FROM T_Analysis_Job_Request
    WHERE AJR_requestID = @requestID
    --
    SELECT @myError = @@error
    --
    if @myError <> 0
    begin
        set @message = 'Error looking for job request'
        goto Done
    end

    if @tempID = 0
    begin
        set @message = 'Could not find job request'
        set @myError = 9
        goto Done
    end

    ---------------------------------------------------
    -- Look up number of jobs made from the request
    ---------------------------------------------------
    --
    Declare @jobCount int = 1
    --
    SELECT @jobCount = count(*)
    FROM T_Analysis_Job
    WHERE AJ_requestID = @requestID
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount
    --
    if @myError <> 0
    begin
        set @message = 'Error looking for job request'
        goto Done
    end

    if @jobCount <> 0
    begin
        set @message = 'Cannot delete an analysis request that has jobs made from it'
        set @myError = 10
        goto Done
    end
    
    ---------------------------------------------------
    -- Delete the analysis request
    ---------------------------------------------------
    --
    DELETE FROM T_Analysis_Job_Request_Datasets
    WHERE Request_ID = @requestID
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount

    DELETE FROM T_Analysis_Job_Request
    WHERE AJR_requestID = @requestID
    --
    SELECT @myError = @@error, @myRowCount = @@rowcount
    --
    if @myError <> 0
    begin
        set @message = 'Error deleting analysis request'
        goto Done
    end

    ---------------------------------------------------
    -- 
    ---------------------------------------------------
Done:
    return @myError



GO
GRANT VIEW DEFINITION ON [dbo].[DeleteAnalysisRequest] TO [DDL_Viewer] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[DeleteAnalysisRequest] TO [DMS_Analysis] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[DeleteAnalysisRequest] TO [DMS_SP_User] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[DeleteAnalysisRequest] TO [Limited_Table_Write] AS [dbo]
GO
