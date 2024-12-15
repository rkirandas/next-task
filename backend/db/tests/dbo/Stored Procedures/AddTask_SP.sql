CREATE PROCEDURE AddTask_SP
	@UserID LargeKey_UDT = NULL,
    @Title NVARCHAR(100),
    @Description NVARCHAR(1000) = NULL,
    @StartTime Time_UDT = NULL,
    @EndTime Time_UDT = NULL,
	@Priority LookupKey_UDT,
	@Tags TaskTag_UDTT READONLY
AS
BEGIN 
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @TaskID LargeKey_UDT = NEXT VALUE FOR Task_Master_Seq;
		DECLARE @NewStatusID LookupKey_UDT = 5;

		IF @UserID IS NULL -- Anonymous
		BEGIN
			EXEC AddUser_SP
				@ReturnValue = @UserID OUTPUT

			IF @UserID IS NULL
			BEGIN
				SELECT 2 AS STATUS, 'Failed to add anonymous user' , '' AS LOGMESSAGE,  '' AS ERRORSTATE, NULL AS RESULT
				RETURN
			END
		END
		ELSE  --Prevent task spamming by anony user
		BEGIN 
			DECLARE @IsAnonyUser BIT 
			DECLARE @TaskCount SMALLINT = 0
			SELECT @IsAnonyUser = COUNT(UM_ID_PK)  FROM UserMaster_SView  WHERE UM_ID_PK = @UserID AND UM_UserType_FK = 5
			IF @IsAnonyUser = 1
			BEGIN
				SELECT @TaskCount = COUNT(TM_ID_PK) FROM TaskMaster_SView  WHERE TM_UserID_FK = @UserID AND TM_IsArchived = 0
				IF @TaskCount > 500
				BEGIN
					SELECT 1 AS STATUS, 'Limit exceeded for anonymous user, try deleting older tasks.' , '' AS LOGMESSAGE,  '' AS ERRORSTATE, NULL AS RESULT
					RETURN
				END
			END
		END

		INSERT INTO Task_Master(
				TM_ID_PK,
				TM_Title,
				TM_Description,
				TM_UserID_FK,
				TM_Status_FK,
				TM_StartTime,
				TM_EndTime,
				TM_Priority_FK
				)
		VALUES (
				@TaskID,
				@Title,
				@Description,
				@UserID,
				@NewStatusID, 
				@StartTime,
				@EndTime,
				@Priority
				);

		IF EXISTS (SELECT 1 FROM @Tags)
		BEGIN
				INSERT INTO TaskTag_Map(TT_ID_CPKFK,TT_TagID_CPKFK)
				SELECT @TaskID,TagID
				FROM @Tags;
		END

		SELECT 0 AS STATUS, 'Success' AS MESSAGE, '' AS LOGMESSAGE, -1 AS ERRORSTATE, @UserID AS RESULT

		EXEC GetActiveTasksByUser_SP @UserID

	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE,  ERROR_STATE() AS ERRORSTATE, NULL AS RESULT
	END CATCH
END
