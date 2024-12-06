CREATE PROCEDURE GetActiveTasksByUser_SP
    @UserID		LargeKey_UDT,
	@PageIndex  INT = 0,
	@PageSize	TINYINT = 25
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
	OFFSET (@PageIndex) * @PageSize ROWS
	FETCH NEXT @PageSize ROWS ONLY
END 


