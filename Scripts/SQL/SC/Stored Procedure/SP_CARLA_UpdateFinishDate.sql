/*
Author: Habib Shakibanejad
Description: Update Finish Date in CARLA
CreatedDate: 01 July 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER PROCEDURE [stng].[SP_CARLA_UpdateFinishDate](
	@ActivityID VARCHAR(20)
	,@EmployeeID			INT
	,@NewValue			NVARCHAR(255)
	,@Key				NVARCHAR(20)
)
AS
BEGIN	
	 -- Create changelog for Fragnet Update
	INSERT INTO stng.Common_ChangeLog(ParentID,NewDate,PreviousDate,AffectedField,AffectedTable,CreatedBy,PreviousValue,NewValue)
	SELECT F.ActivityID,IIF(@NewValue = '',NULL, @NewValue),U.RevisedCommitmentDate,'RevisedCommitmentDate','FragnetUpdate',@EmployeeID,U.[Status],U.[Status]
	FROM stng.CARLA_FragnetActivity F 
	LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = F.ActivityID
	WHERE F.ActivityID IN (SELECT Item FROM stng.FN_0124_SplitString(@ActivityID,',')) AND @NewValue IS NOT NULL AND F.NCSQ IN ('CSQ','NCSQ')
	AND F.NCSQ IN ('CSQ','NCSQ')

	-- Update Fragnet update record on existing activity record
	UPDATE stng.CARLA_FragnetUpdate SET RevisedCommitmentDate = IIF(@NewValue = '',NULL, @NewValue),ModifiedBy = @EmployeeID,LastModified = stng.GetBPTime(GETDATE())
	WHERE stng.CARLA_FragnetUpdate.ActivityID IN (SELECT Item FROM stng.FN_0124_SplitString(@ActivityID,','))			

	-- Create new Fragnet update if activity record does not exist
	INSERT INTO stng.CARLA_FragnetUpdate(ActivityID,CreatedDate,CreatedBy,RevisedCommitmentDate) 
	SELECT A.Item, GETDATE(),@EmployeeID,@NewValue FROM stng.FN_0124_SplitString(@ActivityID,',') A
	WHERE A.Item NOT IN (SELECT U.ActivityID FROM stng.CARLA_FragnetUpdate U)

	-- Create changelog for FragnetActivity Finish date
	INSERT INTO stng.Common_ChangeLog(ParentID,NewDate,PreviousDate,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)
	SELECT Item,@NewValue,B.NewValue,@Key,B.[Key],'FinishDate','FragnetActivity',@EmployeeID FROM stng.FN_0124_SplitString(@ActivityID,',') A
	LEFT JOIN stng.CARLA_ChangeLog B ON B.ActivityID = A.Item AND B.FieldName = 'FinishDate' AND B.P6UpdateRequired = 1

	-- Create CARLAChangelog for FragnetActivity Finish date
	INSERT INTO stng.CARLA_ChangeLog(ActivityID,FieldName,NewValue,PreviousValue,CreatedBy,[Key])
	SELECT Item,'FinishDate',@NewValue,B.NewValue,@EmployeeID,@Key FROM stng.FN_0124_SplitString(@ActivityID,',') A
	LEFT JOIN stng.CARLA_ChangeLog B ON B.ActivityID = A.Item AND B.FieldName = 'FinishDate' AND B.P6UpdateRequired = 1
END
