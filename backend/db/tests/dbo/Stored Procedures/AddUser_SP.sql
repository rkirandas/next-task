

CREATE PROCEDURE addUser_SP
    @Name NVARCHAR(500) = NULL,
	@UserType LookupKey_UDT = 5, -- Anonymous default
	@ReturnValue LargeKey_UDT = NULL OUT
AS
BEGIN 
	SET NOCOUNT ON;

	DECLARE @UserID LargeKey_UDT = NEXT VALUE FOR User_Master_SEQ;
	BEGIN TRY
		IF @Name IS NULL AND @UserType = 5
		BEGIN
			SET @Name = 'Anony-' + CAST(NEWID() AS VARCHAR(50))
		END

		INSERT INTO User_Master(
				UM_ID_PK,
				UM_UserType_FK,
				UM_Name)
		VALUES (
		        @UserID,
				@UserType,
				@Name
				);

		SET @ReturnValue = @UserID
	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE,  ERROR_STATE() AS ERRORSTATE, NULL AS RESULT
	END CATCH
END
