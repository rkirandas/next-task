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

