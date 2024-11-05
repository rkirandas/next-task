
CREATE PROCEDURE GetLookups_SP
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM TaskStatus_Lookup
	SELECT * FROM TaskPriority_Lookup
	SELECT * FROM Tag_Lookup
END



