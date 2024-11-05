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
