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
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'NextTask_Dev')
BEGIN
	USE master;
	ALTER DATABASE NextTask_Dev SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NextTask_Dev;
END
GO

CREATE DATABASE NextTask_Dev;
GO

USE NextTask_Dev;

/*UDTs*/
GO
CREATE TYPE LargeKey_UDT FROM BIGINT;
CREATE TYPE LookupKey_UDT FROM SMALLINT;
CREATE TYPE LookupValue_UDT FROM  NVARCHAR(50);
CREATE TYPE Description_UDT FROM NVARCHAR(1000);
CREATE TYPE Mobile_UDT FROM VARCHAR(15);
CREATE TYPE Email_UDT FROM VARCHAR(15);
CREATE TYPE CountryCode_UDT FROM VARCHAR(5);
CREATE TYPE Time_UDT FROM BIGINT; --  Unix epoch time 
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
	TL_ID_PK INT PRIMARY KEY IDENTITY(1,1),
	TL_Name  LookupValue_UDT,
	TL_Description Description_UDT,
	TL_IsActive  BIT DEFAULT 1,
);

CREATE SEQUENCE User_Master_SEQ
    START WITH 1
    INCREMENT BY 1 
GO

CREATE TABLE User_Master(
	UM_ID_PK LargeKey_UDT PRIMARY KEY,
	UM_UUID uniqueidentifier NOT NULL DEFAULT NEWSEQUENTIALID(),
	UM_UserType_FK LookupKey_UDT NOT NULL,
	UM_Name NVARCHAR(500) NOT NULL,
	UM_Email Email_UDT,
	UM_Mobile Mobile_UDT,
	UM_CountryCode CountryCode_UDT,
	UM_IsVerified  BIT NOT NULL DEFAULT 0,
	UM_IsActive  BIT NOT NULL DEFAULT 1,
	UM_CreatedAt Time_UDT NOT NULL DEFAULT  DATEDIFF_BIG(millisecond, '1970-01-01 00:00:00', GETUTCDATE()),
    FOREIGN KEY (UM_UserType_FK) REFERENCES UserType_Lookup(UTL_ID_PK),
);
GO

CREATE NONCLUSTERED INDEX IX_User_Master_UUID
ON User_Master (UM_ID_PK)
INCLUDE (UM_UUID);
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
	TM_Status_FK LookupKey_UDT NOT NULL,
	TM_Priority_FK LookupKey_UDT,
	TM_IsArchived  BIT NOT NULL DEFAULT 0,
	TM_IsActive  BIT NOT NULL DEFAULT 1,
	TM_CreatedAt  Time_UDT NOT NULL DEFAULT DATEDIFF_BIG(millisecond, '1970-01-01 00:00:00', GETUTCDATE()),
	FOREIGN KEY (TM_UserID_FK) REFERENCES User_Master(UM_ID_PK),
	FOREIGN KEY (TM_Status_FK) REFERENCES TaskStatus_Lookup(SL_ID_PK),
	FOREIGN KEY (TM_Priority_FK) REFERENCES TaskPriority_Lookup(PL_ID_PK),
);
GO

CREATE NONCLUSTERED INDEX IX_Task_Master_UserID
ON Task_Master (TM_ID_PK)
INCLUDE (TM_UserID_FK);
GO


CREATE TABLE TaskTag_Map(
	TT_ID_CPKFK LargeKey_UDT,
	TT_TagID_CPKFK INT,
	TT_IsActive  BIT NOT NULL DEFAULT 1,
	FOREIGN KEY (TT_ID_CPKFK) REFERENCES Task_Master(TM_ID_PK),
	FOREIGN KEY (TT_TagID_CPKFK) REFERENCES Tag_Lookup(TL_ID_PK),
	PRIMARY KEY (TT_ID_CPKFK,TT_TagID_CPKFK)
);
GO

INSERT INTO TaskStatus_Lookup(SL_ID_PK,SL_Name)
VALUES (5, 'New'),(10, 'In Progress'),(15,'Completed')  -- added +5 buffer b/w keys to accomodate new lookups 

INSERT INTO UserType_Lookup(UTL_ID_PK,UTL_Name)
VALUES (5, 'Anonymous')

INSERT INTO TaskPriority_Lookup(PL_ID_PK,PL_Name)
VALUES (5, 'High'),(10, 'Medium'),(15, 'Low')

INSERT INTO Tag_Lookup(TL_Name)
VALUES ( 'Design'),('Development'),('Production')


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
   UM.UM_UUID,
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
	DECLARE @ERRORPROCEDURE VARCHAR(100)	= ERROR_MESSAGE()		
	DECLARE @ERRORMESSAGE	VARCHAR(150)	= ERROR_PROCEDURE()	
	DECLARE @ERRORLINE		VARCHAR(10)		= ERROR_LINE()	
	DECLARE @FINALMESSAGE	VARCHAR(300)		

	EXEC XP_SPRINTF @FINALMESSAGE OUTPUT, 'ERR - %s - occured in PROCEDURE - %s - at LINE - %s '
										, @ERRORMESSAGE, @ERRORPROCEDURE, @ERRORLINE
	RETURN @FINALMESSAGE

END

GO
CREATE FUNCTION ValidateUser_FUNC(@UserID LargeKey_UDT, @UUID CHAR(36)) RETURNS BIT
AS 
BEGIN
	DECLARE @Result BIT

	SELECT @Result = CASE WHEN EXISTS (
		SELECT 1 
		FROM UserMaster_SView UM
		WHERE UM.UM_ID_PK = @UserID AND UM.UM_UUID = @UUID
		) THEN 1 ELSE 0 END;

	RETURN @Result 
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

CREATE PROCEDURE GetUser_SP
	@UUID CHAR(36)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  UM.UM_ID_PK			AS UserID,
			UM.UM_Name			AS [Name],
			UM.UM_UserType_FK	AS UserType,
			''					AS UUID
	FROM	UserMaster_SView UM 
	WHERE	UM_UUID = @UUID
END

GO
CREATE PROCEDURE GetActiveTasksByUser_SP
	@UUID		CHAR(36),
    @UserID		LargeKey_UDT,
	@Title		NVARCHAR(50) = NULL,
	@Status 	LookupKey_UDT = NULL,
	@Priority	LookupKey_UDT = NULL,
	@StartTime	Time_UDT  = NULL,
	@EndTime	Time_UDT  = NULL,
	@Tags		TaskTag_UDTT READONLY,
	@PageIndex  INT	 = 0,
	@PageSize	TINYINT = 25
AS
BEGIN 
	SET NOCOUNT ON;

	IF dbo.ValidateUser_FUNC(@UserID,@UUID) = 0
	BEGIN
		SELECT 1 AS STATUS, 'Invalid User' , '' AS LOGMESSAGE,  NULL AS RESULT
		RETURN
	END

	SELECT 
	   TM_ID_PK			AS TaskID,
	   TM_Title			AS Title,
	   TM_Description	AS [Description],
	   TM_Status_FK		AS [Status],
	   TM_StartTime		AS StartTime,
	   TM_EndTime		AS EndTime,
	   TM_Priority_FK	AS [Priority],
	   TM_UserID_FK		AS UserID,
	   STRING_AGG(TT.TT_TagID_CPKFK, ',')	AS Tags
	FROM 
		TaskMaster_SView TM
	LEFT JOIN
		TaskTagMap_SView TT
	ON 
		TM.TM_ID_PK = TT.TT_ID_CPKFK
	WHERE
		TM.TM_UserID_FK = @UserID
	AND
		TM.TM_IsArchived = 0
	AND	
		(@Status IS NULL OR TM.TM_Status_FK = @Status)
	AND
		(@StartTime IS NULL OR TM.TM_StartTime >=  @StartTime)
	AND
		(@EndTime IS NULL OR TM.TM_EndTime <= @EndTime)
	AND	
		(@Priority IS NULL OR TM.TM_Priority_FK = @Priority)
	AND
		(@Title IS NULL OR TM_Title LIKE '%'+ @Title + '%')
	AND 
		(
			NOT EXISTS (SELECT 1 FROM @Tags) 
			OR TM.TM_ID_PK IN
			(
				SELECT DISTINCT TT.TT_ID_CPKFK
				FROM TaskTagMap_SView TT
				WHERE TT.TT_TagID_CPKFK IN (SELECT T.TagID FROM @Tags T)
			)
		)
	GROUP BY 
		TM.TM_ID_PK,TM.TM_Title,TM.TM_Status_FK,TM.TM_StartTime,TM.TM_EndTime,TM.TM_Description,TM.TM_Priority_FK,TM.TM_UserID_FK	
	ORDER BY
		TaskID DESC
	OFFSET @PageIndex * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY
END

GO
CREATE PROCEDURE AddUser_SP
	@UserType LookupKey_UDT = 5, -- Anonymous default
	@Name NVARCHAR(500)
AS
BEGIN 
	SET NOCOUNT ON;
	DECLARE @UserID LargeKey_UDT = NEXT VALUE FOR User_Master_SEQ;
	-- Current Scope is for anonymous user
	BEGIN TRY
		INSERT INTO User_Master(
				UM_ID_PK,
				UM_Name,
				UM_UserType_FK)
		VALUES (
		        @UserID,
				@Name,
				@UserType
				);

		SELECT 0 AS STATUS, 'Success' AS MESSAGE, '' AS LOGMESSAGE,NULL AS RESULT

		SELECT  UM.UM_ID_PK								AS UserID,
				UM.UM_Name								AS [Name],
				UM.UM_UserType_FK						AS UserType,
				CAST ( UM.UM_UUID AS CHAR(36))			AS UUID
		FROM	UserMaster_SView UM 
		WHERE	UM.UM_ID_PK = @UserID

	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE, NULL AS RESULT
	END CATCH
END
GO


GO
CREATE PROCEDURE AddTask_SP
	@UUID			CHAR(36),
	@UserID			LargeKey_UDT,
    @Title			NVARCHAR(100),
    @Description	NVARCHAR(1000) = NULL,
    @StartTime		Time_UDT = NULL,
    @EndTime		Time_UDT = NULL,
	@Priority		LookupKey_UDT,
	@Tags			TaskTag_UDTT READONLY,
	-- Search params --
	@SearchTitle	NVARCHAR(50) = NULL,
	@SearchStatus 	LookupKey_UDT = NULL,
	@SearchPriority	LookupKey_UDT = NULL,
	@SearchStartTime	Time_UDT  = NULL,
	@SearchEndTime	Time_UDT  = NULL,
	@PageIndex  INT= NULL,
	@PageSize	TINYINT = NULL,
	@SearchTags	TaskTag_UDTT READONLY
AS
BEGIN 
	SET NOCOUNT ON;

	IF dbo.ValidateUser_FUNC(@UserID,@UUID) = 0
	BEGIN
		SELECT 1 AS STATUS, 'Invalid User' , '' AS LOGMESSAGE,  NULL AS RESULT
		RETURN
	END

	--Prevent task spamming by anony user
	DECLARE @TaskCount SMALLINT = 0
	IF EXISTS (
			SELECT	1 
			FROM	UserMaster_SView 
			WHERE	UM_ID_PK = @UserID AND UM_UserType_FK = 5
		)
	BEGIN
		SELECT @TaskCount = COUNT(*) FROM TaskMaster_SView  WHERE TM_UserID_FK = @UserID AND TM_IsArchived = 0
		IF @TaskCount > 500
		BEGIN
			SELECT 1 AS STATUS, 'Limit exceeded for anonymous user, try deleting older tasks.' , '' AS LOGMESSAGE,  NULL AS RESULT
			RETURN
		END
	END

	BEGIN TRY
		DECLARE @TaskID LargeKey_UDT = NEXT VALUE FOR Task_Master_Seq;
		DECLARE @NewStatusID LookupKey_UDT = 5;

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

		SELECT 0 AS STATUS, 'Success' AS MESSAGE, '' AS LOGMESSAGE,@TaskID AS RESULT
		EXEC GetActiveTasksByUser_SP 
			   @UUID
			  ,@UserID
			  ,@SearchTitle
			  ,@SearchStatus
			  ,@SearchPriority
			  ,@SearchStartTime
			  ,@SearchEndTime
			  ,@SearchTags
			  ,@PageIndex
			  ,@PageSize 
	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE,  NULL AS RESULT
	END CATCH
END
GO

CREATE PROCEDURE UpdateTask_SP
	@UUID			CHAR(36),
	@UserID			LargeKey_UDT,
	@TaskID			LargeKey_UDT,
    @Title			NVARCHAR(100) = NULL,
    @Description	NVARCHAR(1000) = NULL,
    @StartTime		Time_UDT = NULL,
    @EndTime		Time_UDT = NULL,
	@Priority		LookupKey_UDT = NULL,
	@Tags			TaskTag_UDTT READONLY,
	@IsArchived		BIT NULL = 0,
	@Status			LookupKey_UDT = NULL,
		-- Search params --
	@SearchTitle	NVARCHAR(50) = NULL,
	@SearchStatus 	LookupKey_UDT = NULL,
	@SearchPriority	LookupKey_UDT = NULL,
	@SearchStartTime	Time_UDT  = NULL,
	@SearchEndTime	Time_UDT  = NULL,
	@PageIndex  INT= NULL,
	@PageSize	TINYINT = NULL,
	@SearchTags	TaskTag_UDTT READONLY
AS
BEGIN 
	SET NOCOUNT ON;

	IF dbo.ValidateUser_FUNC(@UserID,@UUID) = 0
	BEGIN
			SELECT 1 AS STATUS, 'Invalid User' , '' AS LOGMESSAGE,  NULL AS RESULT
			RETURN
	END

	IF NOT EXISTS(SELECT 1 FROM Task_Master WHERE TM_ID_PK = @TaskID AND TM_UserID_FK = @UserID) 
	BEGIN
		SELECT 1 AS STATUS, 'No record to update' , '' AS LOGMESSAGE, NULL AS RESULT
		RETURN
	END

	BEGIN TRY
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

				DELETE TaskTag_Map
				WHERE  TT_ID_CPKFK = @TaskID
  
				IF EXISTS (SELECT 1 FROM @Tags)
				BEGIN
					INSERT INTO TaskTag_Map(TT_ID_CPKFK,TT_TagID_CPKFK)
					SELECT @TaskID,TagID
					FROM @Tags;
				END
		END
		SELECT 0 AS STATUS, 'Success' AS MESSAGE, '' AS LOGMESSAGE, NULL AS RESULT
		EXEC GetActiveTasksByUser_SP 
			   @UUID
			  ,@UserID
			  ,@SearchTitle
			  ,@SearchStatus
			  ,@SearchPriority
			  ,@SearchStartTime
			  ,@SearchEndTime
			  ,@SearchTags
			  ,@PageIndex
			  ,@PageSize 
	END TRY
	BEGIN CATCH
		SELECT 2 AS STATUS, ERROR_MESSAGE() AS MESSAGE , dbo.FormatedErrorMessage_FUNC() AS LOGMESSAGE,  NULL AS RESULT
	END CATCH
END
GO

/* End of SP */