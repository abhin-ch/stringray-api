/*
Author: Caleb Depatie
Description: A procedure to pull all related records for a commitment with a 'snapshot' of the data.
CreatedDate: 14 Feb 2022
*/
CREATE OR ALTER PROCEDURE [stng].[SP_CARLA_RelatedRecords] (
    @Operation TINYINT
    ,@id VARCHAR(255) = NULL
    ,@LinkToId VARCHAR(255) = NULL
    ,@Type VARCHAR(255) = NULL
) AS
BEGIN
    BEGIN TRY
        /* 
            Opertations:
            1 - Pull related records for a given commitment ID
            2 - Pull a specific record type given an id
            3 - Link a record type to a commitment
        */

        IF @Operation = 1
        BEGIN
            SELECT 
                FA.ActivityName AS [Name], 
                FORMAT(FA.EndDate,'dd-MMM-yyyy') AS [Date], 
                'CARLA' AS [Type],
                FA.ActivityID AS [PK],
                'ActivityID' AS [PK_Col],
                IIF(FA.Actualized = 1					
                    AND (FA.NCSQ = 'CSQ' OR FA.NCSQ = 'NCSQ')
                    AND (FA.EndDate > stng.FN_0021_PreviousThursday() AND FA.EndDate < stng.FN_0022_PreviousWednesday())
                    AND M.Status = 'ACTIVE', 'CARLAReview',
                        IIF(FA.Actualized = 1					
                        AND (FA.NCSQ = 'CSQ' OR FA.NCSQ = 'NCSQ')
                        AND M.Status = 'ACTIVE', 'CARLAReviewAll', 'Carla')) AS [Link],
                U.[Status]
            FROM stng.[CARLA_FragnetActivity] AS FA
            LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName
            LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID 
            WHERE FA.ActivityID = @id

            UNION

            SELECT 
                Title, 
                FORMAT(CAST(ActionDue AS date),'dd-MMM-yyyy'), 
                'Escalation',
                [Title],
                'Title',
                IIF([Status] = 14 OR [Status] = 17, 'EscalationsArchive', 'Escalations'),
                R.Label
            FROM [stng].[Escalation]
            LEFT JOIN stng.RecordStatus R ON R.StatusID = stng.[Escalations].[Status]
            WHERE CommitmentID = @id

            UNION

            SELECT 
                Title, 
                FORMAT(CAST(NeedDate AS date),'dd-MMM-yyyy'), 
                'ETDB',
                SheetID,
                'SheetID',
                IIF([Status] = 2 OR [Status] = 3, 'ETDBArchive', 'ETDB'),
                R.Label
            FROM [stng].[ScopingSheet] S
            LEFT JOIN stng.RecordStatus R ON R.StatusID = S.[Status]
            WHERE CommitmentID = @id
        END

        IF @Operation = 2
        BEGIN
            IF @Type = 'TDS'
            BEGIN
                SELECT [SheetID], [Title]
                FROM [stng].[ScopingSheet]
                WHERE [ProjectID] = @id
                AND [Status] <> 2 and [Status] <>  3
            END
        END

        IF @Operation = 3
        BEGIN
            IF @Type = 'TDS'
            BEGIN
                UPDATE [stng].[ScopingSheet]
                SET [CommitmentID] = @id
                WHERE [SheetID] = @LinkToId
            END
        END
    END TRY
    BEGIN CATCH
        INSERT INTO stng.ErrorLog([Number],[Procedure],[Line],[Message]) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE()
              )
	END CATCH
END