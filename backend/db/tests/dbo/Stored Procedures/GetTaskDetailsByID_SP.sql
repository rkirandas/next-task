CREATE PROCEDURE GetTaskDetailsByID_SP
    @TaskID LargeKey_UDT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT TM.TM_ID_PK							AS TaskID,
		   TM.TM_Title							AS Title,
		   TM.TM_Status_FK						AS [StatusID],
		   TM.TM_StartTime						AS StartTime,
		   TM.TM_EndTime						AS EndTime,
		   -- TM.TM_IsArchived					AS IsArchived,
		   TM.TM_Description					AS [Description],
		   TM.TM_Priority_FK					AS [Priority],
		   STRING_AGG(TT.TT_TagID_CPKFK, ',')	AS TagID
    FROM 
		TaskMaster_SView TM
	INNER JOIN
		TaskTagMap_SView TT
    ON
		TM_ID_PK = TT_ID_CPKFK
	WHERE 
		TM_ID_PK = @TaskID
	GROUP BY 
		TM.TM_ID_PK,TM.TM_Title,TM.TM_Status_FK,TM.TM_StartTime,TM.TM_EndTime,TM.TM_Description,TM.TM_Priority_FK
END;
