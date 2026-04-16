/*
Author: Habib Shakibanejad
Description: Use to update Stat holidays in Workday calendar 
CreatedDate: 13 August 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Admin_WorkDayCRUD](
    @Operation          TINYINT
    ,@Holidays          [stng].[Holiday] READONLY
) AS 
BEGIN
	/*
	Operations:
		1 - Update Holidays
	*/  
    BEGIN TRY
		--Update Holidays
        IF @Operation = 1
            BEGIN
				UPDATE stng.WorkDate SET IsWorkday = 0
				FROM stng.WorkDate W
				INNER JOIN @Holidays H ON H.Date = W.Date
			END

		-- GET Calander
		IF @Operation = 0
			BEGIN 
				DECLARE @Year AS INT = DATENAME(YYYY, GETDATE()) ;  
				DECLARE @FromDate DATE = DATEADD(YYYY, @Year - 1900, 0)
				DECLARE @ToDate DATE = '2040-12-31';
  
				WITH Dates (DateNo) AS (  
					SELECT DATEADD(DAY, DATEDIFF(DAY, 0, @ToDate) - DATEDIFF(DAY, @FromDate, @ToDate), 0)  
					UNION ALL SELECT DATEADD(DAY, 1, DateNo)  
					FROM Dates  
					WHERE DATEADD(DAY, 1, DateNo) <=@ToDate
				)  
				SELECT FORMAT([DateNo],'yyyy-MM-dd') as [Date]
					,DATENAME(DW, DateNo) as [DayName],
					CASE WHEN DATENAME(DW, DateNo) = 'Saturday' THEN 0
						WHEN DATENAME(DW, DateNo) = 'Sunday' THEN 0
						ELSE 1 
					END AS 'IsWorkDay'
				FROM Dates   
				OPTION (maxrecursion 32767);  

			END

    END TRY
	BEGIN CATCH
        INSERT INTO stng.ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @Operation
              )
        SET @Error = ERROR_NUMBER()
		SET @ErrorDescription = ERROR_MESSAGE()
	END CATCH
END
GO

/*
CREATE TYPE [stng].[Holiday] AS TABLE(
	[Date] DATE,
	[ObservedDate] DATE,
	[Name] [nvarchar](255),
	[Federal] BIT,
	IsWorkDay BIT
)
GO
*/