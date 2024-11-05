CREATE PROCEDURE GetActiveTasksByUser_SP
    @UserID LargeKey_UDT
AS
BEGIN 
	SET NOCOUNT ON;

    SELECT *
    FROM 
		TaskMaster_SView TM
	WHERE
		TM_UserID_FK = @UserID
	AND
		TM_IsArchived = 0
	ORDER BY
		TM_Priority_FK DESC
END 


