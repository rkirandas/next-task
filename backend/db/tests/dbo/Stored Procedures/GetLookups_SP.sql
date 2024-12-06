
CREATE PROCEDURE GetLookups_SP
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 'Status' AS [Lookup], TSL.SL_Name AS [Key], TSL.SL_ID_PK AS [Value] FROM TaskStatus_Lookup TSL WHERE TSL.SL_IsActive = 1
	UNION ALL
	SELECT 'Priority' AS [Lookup], TPL.PL_Name AS [Key], TPL.PL_ID_PK AS [Value] FROM TaskPriority_Lookup TPL  WHERE TPL.PL_IsActive = 1
	UNION ALL
	SELECT 'Tags' AS [Lookup], TL.TL_Name  AS [Key], TL.TL_ID_PK  AS [Value] FROM Tag_Lookup TL WHERE TL.TL_IsActive  = 1
END



