/*
*FR001 - Add task
*FR002 - View tasks
*FR003 - Edit tasks
*FR004 - Complete Task
*FR005 - Delete Task
*FR006 - Prioritize Tasks

TODO - Add description for SPs
*/
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'NextTask')
BEGIN
	USE master;
	ALTER DATABASE NextTask SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NextTask;
END
GO

CREATE DATABASE NextTask;
GO

USE NextTask;

/*UDTs*/
GO
CREATE TYPE LargeKey_UDT FROM BIGINT;
CREATE TYPE LookupKey_UDT FROM SMALLINT NOT NULL;
CREATE TYPE LookupValue_UDT FROM  NVARCHAR(50) NOT NULL;
CREATE TYPE Description_UDT FROM NVARCHAR(1000);
CREATE TYPE Mobile_UDT FROM VARCHAR(15);
CREATE TYPE Email_UDT FROM VARCHAR(15);
CREATE TYPE CountryCode_UDT FROM VARCHAR(5);
CREATE TYPE Time_UDT FROM INT; -- Timestamp
/*End UDTs*/

/* UDTT */

CREATE TYPE TaskTag_UDTT AS TABLE (
    TagID INT
);
GO

/* end UDTT*/

/*Tables*/
GO
CREATE TABLE TaskStatus_Lookup(
	SL_ID_PK LookupKey_UDT PRIMARY KEY,
	SL_Name  LookupValue_UDT,
	SL_Description Description_UDT,
	SL_IsActive  BIT DEFAULT 1,
);

CREATE TABLE UserType_Lookup(
	UTL_ID_PK LookupKey_UDT PRIMARY KEY,
	UTL_Name  LookupValue_UDT,
	UTL_Description  Description_UDT,
	UTL_IsActive  BIT DEFAULT 1,
);

CREATE TABLE TaskPriority_Lookup(
	PL_ID_PK LookupKey_UDT PRIMARY KEY,
	PL_Name  LookupValue_UDT,
	PL_Description  Description_UDT,
	PL_IsActive  BIT DEFAULT 1,
);

CREATE TABLE Tag_Lookup(
	TL_ID_PK INT PRIMARY KEY, -- can grow larger
	TL_Name  LookupValue_UDT,
	TL_Description Description_UDT,
	TL_IsActive  BIT DEFAULT 1,
);

GO

CREATE SEQUENCE User_Master_SEQ
    START WITH 1
    INCREMENT BY 1 
GO

CREATE TABLE User_Master(
	UM_ID_PK LargeKey_UDT PRIMARY KEY,
	UM_UserName VARCHAR(100),
	UM_UserType_FK LookupKey_UDT,
	UM_Name NVARCHAR(500) NOT NULL,
	UM_Email Email_UDT,
	UM_Mobile Mobile_UDT,
	UM_CountryCode CountryCode_UDT,
	UM_IsVerified  BIT NOT NULL DEFAULT 0,
	UM_IsActive  BIT NOT NULL DEFAULT 1,
	UM_CreatedAt DATETIME NOT NULL DEFAULT  SYSUTCDATETIME(),
    FOREIGN KEY (UM_UserType_FK) REFERENCES UserType_Lookup(UTL_ID_PK),
);


GO

CREATE SEQUENCE Task_Master_SEQ
    START WITH 1
    INCREMENT BY 1 
GO

CREATE TABLE Task_Master(
    TM_ID_PK LargeKey_UDT PRIMARY KEY,
	TM_UserID_FK LargeKey_UDT,
    TM_Title NVARCHAR(100) NOT NULL,
    TM_Description NVARCHAR(1000),
    TM_StartTime Time_UDT,
    TM_EndTime Time_UDT,
	TM_Status_FK  LookupKey_UDT,
	TM_Priority_FK LookupKey_UDT,
	TM_IsArchived  BIT NOT NULL DEFAULT 0,
	TM_IsActive  BIT NOT NULL DEFAULT 1,
	TM_CreatedAt  DATETIME NOT NULL DEFAULT  SYSUTCDATETIME(),
	FOREIGN KEY (TM_UserID_FK) REFERENCES User_Master(UM_ID_PK),
	FOREIGN KEY (TM_Status_FK) REFERENCES TaskStatus_Lookup(SL_ID_PK),
	FOREIGN KEY (TM_Priority_FK) REFERENCES TaskPriority_Lookup(PL_ID_PK),
);
GO


CREATE TABLE TaskTag_Map(
	TT_ID_CPKFK LargeKey_UDT,
	TT_TagID_CPKFK INT,
	TT_IsActive  BIT NOT NULL DEFAULT 1,
	FOREIGN KEY (TT_ID_CPKFK) REFERENCES Task_Master(TM_ID_PK),
	FOREIGN KEY (TT_TagID_CPKFK) REFERENCES Tag_Lookup(TL_ID_PK),
	PRIMARY KEY (TT_TagID_CPKFK, TT_ID_CPKFK)
);
GO

INSERT INTO TaskStatus_Lookup(SL_ID_PK,SL_Name)
VALUES (5, 'New'),(10, 'In Progress'),(15,'Completed')  -- added +5 buffer b/w keys to accomodate new lookups 

INSERT INTO UserType_Lookup(UTL_ID_PK,UTL_Name)
VALUES (5, 'Anonymous'),(10, 'Free')

INSERT INTO TaskPriority_Lookup(PL_ID_PK,PL_Name)
VALUES (5, 'High'),(10, 'Medium'),(15, 'Low')

INSERT INTO Tag_Lookup(TL_ID_PK,TL_Name)
VALUES (1, 'Design'),(2, 'Development'),(3, 'Production')

/** TODO LATER
-- GO
--CREATE TABLE Task_Audit(
--	TA_ID_PK Large_Key_UDT IDENTITY(1,1) PRIMARY KEY,
--	TA_TaskID_FK Large_Key_UDT,
--	TA_Log NVARCHAR(MAX)  NOT NULL,
--	FOREIGN KEY (TA_TaskID_FK) REFERENCES Task_Master(TM_ID_PK),
--);

--GO 

--CREATE TRIGGER Task_Master_Trigger
--ON Task_Master
--AFTER INSERT, UPDATE, DELETE
--AS
--BEGIN
--      -- For Inserts
--    IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
--    BEGIN
--        INSERT INTO Task_Audit (TA_TaskID_FK,TA_Log)
--        SELECT 'Added ' + STRING_AGG(CAST(inserted.TM_ID_PK AS NVARCHAR) + ',' + inserted.TM_UserID_FK --Later 
--        FROM inserted;
--    END
--END;
 **/
/*End Of Tables*/

/* Views */
GO
CREATE VIEW TaskMaster_SView
AS
SELECT 
   TM_ID_PK,
   TM_Title,
   TM_UserID_FK,
   TM_Status_FK,
   TM_StartTime,
   TM_EndTime,
   TM_IsArchived,
   TM_Description,
   TM_Priority_FK
FROM 
    Task_Master 
WHERE 
    TM_IsActive = 1
GO

CREATE TRIGGER TaskMaster_SView_TRIGGER
ON TaskMaster_SView
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    RAISERROR ('This view is read-only.', 16, 1);
END;

GO
CREATE VIEW TaskTagMap_SView
AS
SELECT 
	TT_ID_CPKFK,
	TT_TagID_CPKFK
FROM 
	TaskTag_Map 
WHERE 
   TT_IsActive = 1
GO

CREATE TRIGGER TaskTag_SView_TRIGGER
ON TaskTagMap_SView
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    RAISERROR ('This view is read-only.', 16, 1);
END;


GO
CREATE VIEW UserMaster_SView
AS
SELECT 
   UM.UM_ID_PK,
   UM.UM_Name,
   UM.UM_UserType_FK,
   UM.UM_IsVerified,
   UM.UM_CountryCode,
   UM.UM_Mobile,
   UM.UM_Email
FROM 
    User_Master UM
WHERE
    UM.UM_IsActive = 1

GO

CREATE TRIGGER UserMaster_SView_TRIGGER
ON UserMaster_SView
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    RAISERROR ('This view is read-only.', 16, 1);
END;
/* End Of Views */

/* Functions */
GO
CREATE FUNCTION FormatedErrorMessage_FUNC() RETURNS VARCHAR(300)
AS 
BEGIN
DECLARE @ERRORPROCEDURE AS VARCHAR(100)		
DECLARE @ERRORMESSAGE	AS VARCHAR(150)		
DECLARE @ERRORLINE		AS VARCHAR(10)		
DECLARE @FINALMESSAGE	AS VARCHAR(300)		

	--Get Error message
	SELECT @ERRORMESSAGE   = ERROR_MESSAGE()			

	--Get Procedure name
	SELECT @ERRORPROCEDURE = ERROR_PROCEDURE()

	--Get Line number
	SELECT @ERRORLINE = ERROR_LINE()

	--Form the final message
	EXEC XP_SPRINTF @FINALMESSAGE OUTPUT, 'ERR - %s - occured in PROCEDURE - %s - at LINE - %s '
										, @ERRORMESSAGE, @ERRORPROCEDURE, @ERRORLINE

	--Return the final message
	RETURN @FINALMESSAGE

END

/* EO Functions */


/* SPs */

GO

CREATE PROCEDURE GetLookups_SP
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  'Status' AS [Lookup],
			TSL.SL_Name AS [Key],
			TSL.SL_ID_PK AS [Value] 
	FROM TaskStatus_Lookup TSL WHERE TSL.SL_IsActive = 1
	UNION ALL
	SELECT  'Priority' AS [Lookup],
			TPL.PL_Name AS [Key],
			TPL.PL_ID_PK AS [Value]
	FROM TaskPriority_Lookup TPL  WHERE TPL.PL_IsActive = 1
	UNION ALL
	SELECT 'Tags' AS [Lookup],
			TL.TL_Name  AS [Key],
			TL.TL_ID_PK  AS [Value]
	FROM Tag_Lookup TL WHERE TL.TL_IsActive  = 1
END



GO
CREATE PROCEDURE GetActiveTasksByUser_SP
    @UserID		LargeKey_UDT,
	@PageIndex  INT = 0,
	@PageSize	TINYINT = 25
AS
BEGIN 
	SET NOCOUNT ON;

    SELECT 
	   TM_ID_PK			AS TaskID,
	   TM_Title			AS Title,
	   TM_Description	AS [Description],
	   TM_Status_FK		AS [StatusID],
	   TM_StartTime		AS StartTime,
	   TM_EndTime		AS EndTime,
	   TM_Priority_FK	AS [Priority]
    FROM 
		TaskMaster_SView TM
	WHERE
		TM_UserID_FK = @UserID
	AND
		TM_IsArchived = 0
	ORDER BY
		TM_Priority_FK DESC
	OFFSET (@PageIndex) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY
END 


GO
CREATE PROCEDURE GetTaskDetailsByID_SP
    @TaskID LargeKey_UDT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT TM.TM_ID_PK			AS TaskID,
		   TM.TM_Title			AS Title,
		   TM.TM_Status_FK		AS [StatusID],
		   TM.TM_StartTime		AS StartTime,
		   TM.TM_EndTime		AS EndTime,
		   -- TM.TM_IsArchived		AS IsArchived,
		   TM.TM_Description	AS [Description],
		   TM.TM_Priority_FK	AS [Priority],
		   TT.TT_TagID_CPKFK	AS TagID
    FROM 
		TaskMaster_SView TM
	INNER JOIN
		TaskTagMap_SView TT
    ON
		TM_ID_PK = TT_ID_CPKFK
	WHERE 
		TM_ID_PK = @TaskID
END;
GO


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
		SELECT 0 AS STATUS, 'Success' AS MESSAGE, '' AS LOGMESSAGE, -1 AS ERRORSTATE, @ReturnValue AS RESULT
	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE,  ERROR_STATE() AS ERRORSTATE, NULL AS RESULT
	END CATCH
END
GO


GO
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
GO

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
GO

/* End of SP */