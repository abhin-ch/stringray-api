/*
Author: Habib Shakibanejad
Description: Update Start Date in CARLA
CreatedDate: 01 July 2022
*/
CREATE OR ALTER PROCEDURE [stng].[SP_CARLA_UpdateStartDate](
	@ActivityID		VARCHAR(20)
	,@EmployeeID			INT
	,@NewValue			NVARCHAR(255)
	,@Key				NVARCHAR(20)
)
AS
BEGIN
	-- Not required to update start date on N/CSQ
	DECLARE @IsCSQ INT
	SET @IsCSQ = (SELECT COUNT(*) FROM stng.CARLA_FragnetActivity FA WHERE FA.[NCSQ] IN ('CSQ','NCSQ') AND FA.ActivityID IN (SELECT A.Item FROM stng.FN_0124_SplitString(@ActivityID,',') A))
	IF(@IsCSQ > 0) RETURN	

	-- Don't update if start date is actualized
	DECLARE @Status NVARCHAR(20)
	SELECT @Status = A.[Status] FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID IN (SELECT A.Item FROM stng.FN_0124_SplitString(@ActivityID,',') A)
	IF(@Status = 'Active') RETURN
		
	-- Create changelog for FragnetActivity Start date
	INSERT INTO stng.Common_ChangeLog(ParentID,NewDate,PreviousDate,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)
	SELECT Item,@NewValue,B.NewValue,@Key,B.[Key],'StartDate','FragnetActivity',@EmployeeID FROM stng.FN_0124_SplitString(@ActivityID,',') A
	LEFT JOIN stng.CARLA_ChangeLog B ON B.ActivityID = A.Item AND B.FieldName = 'StartDate' AND B.P6UpdateRequired = 1

	-- Create CARLAChangelog for FragnetActivity Start date
	INSERT INTO stng.CARLA_ChangeLog(ActivityID,FieldName,NewValue,PreviousValue,CreatedBy,[Key])
	SELECT Item,'StartDate',@NewValue,B.NewValue,@EmployeeID,@Key FROM stng.FN_0124_SplitString(@ActivityID,',') A
	LEFT JOIN stng.CARLA_ChangeLog B ON B.ActivityID = A.Item AND B.FieldName = 'StartDate' AND B.P6UpdateRequired = 1
END