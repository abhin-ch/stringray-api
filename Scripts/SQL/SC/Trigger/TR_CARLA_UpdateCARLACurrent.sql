/*
Author: Habib Shakibanejad
Description: Update Carla Change Log record to current on insert and set old records to 0
CreatedDate: 8 February 2022
RevisedDate:
RevisedBy:
*/
CREATE OR ALTER TRIGGER stng.TR_CARLA_UpdateCARLACurrent ON stng.CARLA_ChangeLog
AFTER INSERT
AS 
BEGIN
	UPDATE stng.CARLA_ChangeLog SET P6UpdateRequired = 0 
	WHERE stng.CARLA_ChangeLog.CCLID IN (
		SELECT A.CCLID FROM (
			SELECT 
				I.CCLID,
				ROW_NUMBER() OVER(PARTITION BY I.ActivityID,I.FieldName,I.FKID ORDER BY I.CreatedDate DESC) AS 'RN',
				I.ActivityID,
				I.NewValue
			FROM [stng].[CARLA_ChangeLog] I
			) A 
			WHERE A.RN > 1
			OR A.NewValue IS NULL
		)
END
	