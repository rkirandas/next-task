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

/*UDDTs*/
GO
CREATE TYPE Large_Key_Type FROM BIGINT;
CREATE TYPE Lookup_Key_Type FROM SMALLINT NOT NULL;
CREATE TYPE Lookup_Value_Type FROM  NVARCHAR(50) NOT NULL;
CREATE TYPE Description_Type FROM NVARCHAR(1000);
CREATE TYPE Mobile_Type FROM VARCHAR(15);
CREATE TYPE Email_Type FROM VARCHAR(15);
CREATE TYPE Country_Code_Type FROM VARCHAR(5);
CREATE TYPE Time_Type FROM DATETIMEOFFSET;
/*End UDDTs*/

/* UDTT */

CREATE TYPE TaskTag_TType AS TABLE (
    TagID INT
);
GO

CREATE TYPE Result_TType AS TABLE (
    Code TINYINT, -- 0- Success, 1 - User Defined Error , 2- DB Error 
    UserMessage NVARCHAR(200),
	ErrorMessage NVARCHAR(4000) NULL
);


/* end UDTT*/

/*Tables*/
GO
CREATE TABLE Status_Lookup(
	SL_ID_PK Lookup_Key_Type PRIMARY KEY,
	SL_Name  Lookup_Value_Type,
	SL_Description Description_Type,
	SL_IsActive  BIT DEFAULT 1,
);

CREATE TABLE UserType_Lookup(
	UTL_ID_PK Lookup_Key_Type PRIMARY KEY,
	UTL_Name  Lookup_Value_Type,
	UTL_Description  Description_Type,
	UTL_IsActive  BIT DEFAULT 1,
);

CREATE TABLE Priority_Lookup(
	PL_ID_PK Lookup_Key_Type PRIMARY KEY,
	PL_Name  Lookup_Value_Type,
	PL_Description  Description_Type,
	PL_IsActive  BIT DEFAULT 1,
);

CREATE TABLE Tag_Lookup(
	TL_ID_PK INT PRIMARY KEY, -- can grow larger
	TL_Name  Lookup_Value_Type,
	TL_Description Description_Type,
	TL_IsActive  BIT DEFAULT 1,
);

GO

CREATE TABLE User_Master(
	UM_ID_PK Large_Key_Type IDENTITY(1,1) PRIMARY KEY,
	UM_UserName VARCHAR(100),
	UM_UserType_FK Lookup_Key_Type,
	UM_Name NVARCHAR(500) NOT NULL,
	UM_Email Email_Type,
	UM_Mobile Mobile_Type,
	UM_CountryCode Country_Code_Type,
	UM_IsVerified  BIT NOT NULL DEFAULT 0,
	UM_IsActive  BIT NOT NULL DEFAULT 1,
	UM_CreatedAt Time_Type NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (UM_UserType_FK) REFERENCES UserType_Lookup(UTL_ID_PK),
);


GO

CREATE SEQUENCE Task_Master_Seq
    START WITH 1
    INCREMENT BY 1 
GO

CREATE TABLE Task_Master(
    TM_ID_PK Large_Key_Type PRIMARY KEY,
	TM_UserID_FK Large_Key_Type,
    TM_Title NVARCHAR(100) NOT NULL,
    TM_Description NVARCHAR(1000),
    TM_StartTime Time_Type,
    TM_EndTime Time_Type,
	TM_Status_FK  Lookup_Key_Type,
	TM_Priority_FK Lookup_Key_Type,
	TM_IsArchived  BIT NOT NULL DEFAULT 0,
	TM_IsActive  BIT NOT NULL DEFAULT 1,
	TM_CreatedAt  Time_Type NOT NULL DEFAULT GETUTCDATE(),
	FOREIGN KEY (TM_UserID_FK) REFERENCES User_Master(UM_ID_PK),
	FOREIGN KEY (TM_Status_FK) REFERENCES Status_Lookup(SL_ID_PK),
	FOREIGN KEY (TM_Priority_FK) REFERENCES Priority_Lookup(PL_ID_PK),
);
GO


CREATE TABLE TaskTag_Map(
	TT_ID_CPKFK Large_Key_Type,
	TT_TagID_CPKFK INT,
	TT_IsActive  BIT NOT NULL DEFAULT 1,
	FOREIGN KEY (TT_ID_CPKFK) REFERENCES Task_Master(TM_ID_PK),
	FOREIGN KEY (TT_TagID_CPKFK) REFERENCES Tag_Lookup(TL_ID_PK),
	PRIMARY KEY (TT_TagID_CPKFK, TT_ID_CPKFK)
);
GO

INSERT INTO Status_Lookup(SL_ID_PK,SL_Name)
VALUES (1, 'New'),(2, 'In Progress'),(3,'Completed')

INSERT INTO UserType_Lookup(UTL_ID_PK,UTL_Name)
VALUES (1, 'Anonymous'),(2, 'Free')

INSERT INTO Priority_Lookup(PL_ID_PK,PL_Name)
VALUES (1, 'High'),(2, 'Medium'),(3, 'Low')

INSERT INTO Tag_Lookup(TL_ID_PK,TL_Name)
VALUES (1, 'Design'),(2, 'Development'),(3, 'Production')

/** TODO LATER
-- GO
--CREATE TABLE Task_Audit(
--	TA_ID_PK Large_Key_Type IDENTITY(1,1) PRIMARY KEY,
--	TA_TaskID_FK Large_Key_Type,
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

/* SPs */
GO
CREATE PROCEDURE GetActiveTasksByUser_SP
    @UserID Large_Key_Type
AS
BEGIN 
    SELECT *
    FROM 
		TaskMaster_SView TM
	WHERE
		TM_UserID_FK = @UserID
	AND
		TM_IsArchived = 0
	ORDER BY
		TM_ID_PK DESC
END 


GO
CREATE PROCEDURE GetTaskDetailsByID_SP
    @TaskID Large_Key_Type
AS
BEGIN
    SELECT TM.*,TT.TT_TagID_CPKFK
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
CREATE PROCEDURE AddTask_SP
	@UserID Large_Key_Type,
    @Title NVARCHAR(100),
    @Description NVARCHAR(1000) NULL,
    @StartTime Time_Type NULL,
    @EndTime Time_Type NULL,
	@Priority Lookup_Key_Type,
	@Tags TaskTag_TType READONLY
AS
BEGIN 
    DECLARE @OutputResult Result_TType;
	BEGIN TRY
		DECLARE @TaskID Large_Key_Type;
		DECLARE @NewStatusID Lookup_Key_Type = 1;
		SET @TaskID = NEXT VALUE FOR Task_Master_Seq
	

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

		INSERT INTO @OutputResult(Code,UserMessage)
		VALUES (0,'Task added successfully')

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		INSERT INTO @OutputResult(Code,UserMessage,ErrorMessage)
		VALUES (2,'DB Error',@ErrorMessage)

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
	SELECT * FROM @OutputResult 
END
GO

CREATE PROCEDURE UpdateTask_SP
	@TaskID Large_Key_Type,
    @Title NVARCHAR(100) NULL,
    @Description NVARCHAR(1000) NULL,
    @StartTime Time_Type NULL,
    @EndTime Time_Type NULL,
	@Priority Lookup_Key_Type NULL,
	@Tags TaskTag_TType READONLY,
	@IsArchived BIT NULL = 0,
	@StatusID Lookup_Key_Type NULL
AS
BEGIN 
    DECLARE @OutputResult Result_TType;
	BEGIN TRY
		IF( @IsArchived = 1)
		BEGIN 
	       UPDATE Task_Master
		   SET TM_IsArchived = 1
		   WHERE TM_ID_PK = @TaskID

		   UPDATE TaskTag_Map
			SET    TT_IsActive = 0
			WHERE  TT_ID_CPKFK = @TaskID

		   INSERT INTO @OutputResult(Code,UserMessage)
		   VALUES (0,'Task deleted successfully')
		END
		ELSE
		BEGIN
			UPDATE Task_Master
			SET 
				TM_Title       = @Title, --COALESCE( @Title,TM_Title),
				TM_Description = @Description,
				TM_Status_FK   = @StatusID,
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

			INSERT INTO @OutputResult(Code,UserMessage)
		    VALUES (0,'Task updated successfully')
		END
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		INSERT INTO @OutputResult(Code,UserMessage,ErrorMessage)
		VALUES (2,'DB Error',@ErrorMessage)

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
	SELECT * FROM @OutputResult 
END
GO


CREATE PROCEDURE AddUser_SP
    @Name NVARCHAR(500) NULL,
	@UserType Lookup_Key_Type = 1 
AS
BEGIN 
    DECLARE @OutputResult Result_TType;
	BEGIN TRY
		SET @Name = 'Anony-' + CAST(NEWID() AS VARCHAR(50))

		INSERT INTO User_Master(
				UM_UserType_FK,
				UM_Name)
		VALUES (
				@UserType,
				@Name
				);

		INSERT INTO @OutputResult(Code,UserMessage)
		VALUES (0,'User added successfully')

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		INSERT INTO @OutputResult(Code,UserMessage,ErrorMessage)
		VALUES (2,'DB Error',@ErrorMessage)

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
	SELECT * FROM @OutputResult 
END
GO
/* End of SP */