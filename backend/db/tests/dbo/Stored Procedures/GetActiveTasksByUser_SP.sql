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
	   TM_Status_FK		AS [StatusID],
	   TM_StartTime		AS StartTime,
	   TM_EndTime		AS EndTime,
	   TM_IsArchived	AS IsArchived,
	   TM_Description	AS [Description],
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


