/*
Author: Habib Shakibanejad
Description: Post process operations for CARLA P6 data migration
CreatedDate: 18 Jan 2022
*/
CREATE OR ALTER PROCEDURE [stng].[SP_CARLA_PostCARLAImport](
    @Operation TINYINT,
	@FADetails [stng].CARLA_FADetails READONLY
)
AS
BEGIN
    /*
        Operations:
        1 - UPDATE P6 matching fields
		2 - GET Activities used for CARLA Importer
    */
    BEGIN TRY
		DECLARE @Start DATETIME
		SET @Start = GETDATE()
        
		IF @Operation = 1
		BEGIN
			UPDATE C SET C.P6UpdateRequired = 0 FROM stng.CARLA_ChangeLog C
			INNER JOIN stng.CARLA_FragnetActivity A ON A.ActivityID = C.ActivityID AND A.ActivityID NOT LIKE 'Online%' AND A.ActivityID NOT LIKE 'Outage%' 
			INNER JOIN stng.VV_CARLA_P6UpdateRequired P ON C.ActivityID = P.ActivityID
			AND C.NewValue = A.ActualStartDate
			WHERE C.FieldName = 'StartDate' 
			AND C.P6UpdateRequired = 1
			AND C.[Key] = 'Actual'

			UPDATE C SET C.P6UpdateRequired = 0 FROM stng.CARLA_ChangeLog C
			INNER JOIN stng.CARLA_FragnetActivity A ON A.ActivityID = C.ActivityID AND A.ActivityID NOT LIKE 'Online%' AND A.ActivityID NOT LIKE 'Outage%' 
			INNER JOIN stng.VV_CARLA_P6UpdateRequired P ON C.ActivityID = P.ActivityID
			AND C.NewValue = A.StartDate
			WHERE C.FieldName = 'StartDate' 
			AND C.P6UpdateRequired = 1
			AND C.[Key] = 'Anticipated'

			UPDATE C SET C.P6UpdateRequired = 0 FROM stng.CARLA_ChangeLog C
			INNER JOIN stng.CARLA_FragnetActivity A ON A.ActivityID = C.ActivityID AND A.ActivityID NOT LIKE 'Online%' AND A.ActivityID NOT LIKE 'Outage%' 
			INNER JOIN stng.VV_CARLA_P6UpdateRequired P ON C.ActivityID = P.ActivityID
			AND C.NewValue = A.ActualEndDate
			WHERE C.FieldName = 'FinishDate' 
			AND C.P6UpdateRequired = 1
			AND C.[Key] = 'Actual'

			UPDATE C SET C.P6UpdateRequired = 0 FROM stng.CARLA_ChangeLog C
			INNER JOIN stng.CARLA_FragnetActivity A ON A.ActivityID = C.ActivityID AND A.ActivityID NOT LIKE 'Online%' AND A.ActivityID NOT LIKE 'Outage%' 
			INNER JOIN stng.VV_CARLA_P6UpdateRequired P ON C.ActivityID = P.ActivityID
			AND C.NewValue = A.ReendDate
			WHERE C.FieldName = 'FinishDate' 
			AND C.P6UpdateRequired = 1
			AND C.[Key] = 'Anticipated'

			UPDATE C SET C.P6UpdateRequired = 0 FROM stng.CARLA_ChangeLog C
			INNER JOIN stng.CARLA_FragnetActivity A ON A.ActivityID = C.ActivityID AND A.ActivityID NOT LIKE 'Online%' AND A.ActivityID NOT LIKE 'Outage%' 
			INNER JOIN stng.VV_CARLA_P6UpdateRequired P ON C.ActivityID = P.ActivityID
			AND C.NewValue = A.EndDate
			WHERE C.FieldName = 'FinishDate' 
			AND C.P6UpdateRequired = 1
			AND C.[Key] = 'Anticipated'


			/*Delete the fragnet update where the commitment date is matching the revised date. This means the change has been updated in P6. 
			--By deleting the record it will flush the Status,Revised Date, and Category.*/
			DELETE FROM stng.CARLA_FragnetUpdate
			WHERE stng.CARLA_FragnetUpdate.ActivityID IN (
				SELECT U.ActivityID FROM stng.CARLA_FragnetUpdate U
				INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = U.ActivityID
				WHERE IIF(FA.[Status] = 'Active', FA.[ReendDate],FA.[EndDate]) = U.RevisedCommitmentDate
			)

			/*Update P6Required if activity is actualized*/
			UPDATE C SET C.P6UpdateRequired = 0 FROM stng.CARLA_ChangeLog C WHERE CCLID IN (
			SELECT A.CCLID FROM stng.CARLA_ChangeLog A
			INNER JOIN stng.CARLA_FragnetActivity B ON B.ActivityID = A.ActivityID AND B.Actualized = 1
			WHERE A.P6UpdateRequired = 1)
		END

		IF @Operation = 2
		BEGIN
			SELECT FA.ActivityID,FA.ActivityName,F.FragnetName AS SubFragnetName,FF.FragnetName 
			FROM stng.CARLA_FragnetActivity FA
			INNER JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
			CROSS APPLY (
				SELECT TOP 1 F.FragnetID AS 'ParentID',F.FragnetName 
				FROM stng.CARLA_Fragnet F WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S WHERE S.FragnetID = FA.FragnetID)
			) AS FF
			WHERE (F.FragnetName LIKE '%PO#%' 
			OR F.FragnetName LIKE '%PR#%'
			OR F.FragnetName LIKE '%Contract#%'
			OR F.FragnetName LIKE '%TDS#%'
			OR F.FragnetName LIKE '%RFQ#%'
			OR F.FragnetName LIKE '%RFP#%'
			OR F.FragnetName LIKE '%WO#%'
			OR F.FragnetName LIKE '%Item#%')
			AND FA.[NCSQ] IN ('CSQ','NCSQ')

			/* We want to track when Commitment Dates have changed */
			-- Create a status log if the commitment date has changed
			INSERT INTO stng.Common_ChangeLog(ParentID,AffectedField,AffectedTable,NewDate,PreviousDate,CreatedBy)
			SELECT FA.ActivityID,
				'CommitmentDate'
				,'FragnetActivity'
				,FA.[EndDate]
				,C.CommitmentDate
				,'SYSTEM'
			FROM stng.CARLA_FragnetActivity FA 
			LEFT JOIN stng.CARLA_CommitmentDate C ON C.ActivityID = FA.ActivityID
			WHERE FA.[EndDate] != C.CommitmentDate

			-- Remove all previous dates
			DELETE FROM stng.CARLA_CommitmentDate

			-- Insert new commitment dates
			INSERT INTO stng.CARLA_CommitmentDate(ActivityID,CommitmentDate)
			SELECT ActivityID,EndDate FROM stng.CARLA_FragnetActivity FA
			WHERE (FA.ProjShortName LIKE 'CS-[0-9][0-9][0-9][0-9][0-9]'
					OR FA.ProjShortName = 'CS-PMCIND' 
					OR FA.ProjShortName = 'CS-PMCENG'
					OR FA.ProjShortName = 'CS-PMOSUP')
			AND FA.NCSQ IN ('CSQ','NCSQ')

		END

		IF @Operation = 3
		BEGIN
			DELETE FROM stng.CARLA_FragnetActivityDetail
			DBCC CHECKIDENT ('[stng].[FragnetActivityDetail]', RESEED, 0);
			INSERT INTO stng.CARLA_FragnetActivityDetail(ActivityID,DetailName,DetailValue,Type) SELECT DISTINCT FAD.ActivityID,FAD.DetailName,FAD.DetailValue,'Number' FROM @FADetails FAD

		END

		IF @Operation = 4
		BEGIN
			UPDATE stng.MPL SET ProjectName = A.ProjectName 
				--Unit = A.Unit,
				--Baselined = A.Baselined,
				--[Site] = A.[Site]
			FROM (
				SELECT DISTINCT F.ActivityID 'ProjectID',F.DetailName 'ProjectName',F.DetailValue 'Unit',F.DetailValue1 'Site',F.DetailValue2 'Baselined' FROM @FADetails F
			) A
			WHERE stng.MPL.ProjectID = A.ProjectID
		END



    END TRY
    BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation])
            VALUES
                (
                    ERROR_NUMBER(),
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE(),
					@Operation
                )
    END CATCH
END

/*
CREATE TYPE [stng].[CARLA_FADetails] AS TABLE(
	[ActivityID] [nvarchar](20) NULL,
	[DetailName] [nvarchar](255) NULL,
	[DetailValue] [nvarchar](255) NULL,
	[DetailValue1] [nvarchar](255) NULL,
	[DetailValue2] [nvarchar](255) NULL
)
GO
*/
