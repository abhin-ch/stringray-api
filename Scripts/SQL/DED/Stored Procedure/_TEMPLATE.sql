/*
Author: 
Description: 
CreatedDate: 
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER PROCEDURE [stng].[SP_<Module>_<Name>](
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID INT = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - 
        2 - 
		3 - 
        4 - 
		5 - 
		6 - 
		7 - 
		8 - 
		9 - 
		10 - 
		11 - 
		12 - 
		13 - 
		14 - 
		15 - 
		16 - 
		17 - 
		18 - 
		19 - 
		20 - 
		21 - 
		22 - 
		23 - 
		24 -
		25 - 
	*/  
    BEGIN TRY
		IF(@Operation = 1)

    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],Operation) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @Operation
              );
			  THROW
	END CATCH
	
END
GO