CREATE PROCEDURE UpdateTask_SP
	@TaskID LargeKey_UDT,
    @Title NVARCHAR(100) = NULL,
    @Description NVARCHAR(1000) = NULL,
    @StartTime Time_UDT = NULL,
    @EndTime Time_UDT = NULL,
	@Priority LookupKey_UDT = NULL,
	@Tags TaskTag_UDTT READONLY,
	@IsArchived BIT NULL = 0,
	@Status LookupKey_UDT = NULL
AS
BEGIN 
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @UserID LargeKey_UDT;
		SELECT @UserID  =  TM.TM_UserID_FK FROM TaskMaster_SView TM WHERE TM.TM_ID_PK = @TaskID
		IF @UserID IS NOT NULL
		BEGIN
			IF( @IsArchived = 1)
			BEGIN 
			   UPDATE	Task_Master
			   SET		TM_IsArchived = 1
			   WHERE	TM_ID_PK = @TaskID

			   UPDATE	TaskTag_Map
			   SET		TT_IsActive = 0
			   WHERE	TT_ID_CPKFK = @TaskID
			END
			ELSE
			BEGIN
				UPDATE Task_Master
				SET 
					TM_Title       = @Title,
					TM_Description = @Description,
					TM_Status_FK   = @Status,
					TM_StartTime   = @StartTime,
					TM_EndTime     = @EndTime,
					TM_Priority_FK = @Priority
				WHERE 
					TM_ID_PK = @TaskID

				UPDATE TaskTag_Map
				SET    TT_IsActive = 0
				WHERE  TT_ID_CPKFK = @TaskID
  
				IF EXISTS (SELECT 1 FROM @Tags)
				BEGIN
					INSERT INTO TaskTag_Map(TT_ID_CPKFK,TT_TagID_CPKFK)
					SELECT @TaskID,TagID
					FROM @Tags;
				END
			END
			SELECT 0 AS STATUS, 'Success' AS MESSAGE, '' AS LOGMESSAGE, -1 AS ERRORSTATE, @TaskID AS RESULT
			EXEC GetActiveTasksByUser_SP @UserID
		END
		ELSE
		BEGIN
			SELECT 1 AS STATUS, 'No record to update' AS MESSAGE, '' AS LOGMESSAGE, -1 AS ERRORSTATE, @TaskID AS RESULT
		END
	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE,  ERROR_STATE() AS ERRORSTATE, NULL AS RESULT
	END CATCH
END