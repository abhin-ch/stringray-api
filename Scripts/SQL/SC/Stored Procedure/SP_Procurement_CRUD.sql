/*
Author: Habib Shakibanejad
Description: A procedure used for CRUD operations on budget & procurement. This will execute complete work flows.
CreatedDate: 26 April 2021
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Procurement_CRUD](
     @Operation TINYINT
	,@EmployeeID INT
    
    ,@PK_POID NVARCHAR(255)
    ,@Description NVARCHAR(2000) = NULL
    ,@PONum NVARCHAR(255) = NULL
    ,@ItemNum NVARCHAR(255) = NULL
    ,@PaymentDate NVARCHAR(255) = NULL
    ,@ItemCost NVARCHAR(255) = NULL
    ,@InvoiceNum NVARCHAR(255) = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - Create Budget
        2 - Read Budget
		3 - Update Budget
        4 - Delete Milestone
	*/  
    BEGIN TRY
        IF @Operation = 1
            BEGIN
                INSERT INTO stng.POItemMilestones(PK_POID,Description,FK_PO_Num,FK_Item_Num,Payment_Date,Item_Cost,Invoice_Num)
                    VALUES (@PK_POID,@Description,@PONum,@ItemNum,@PaymentDate,@ItemCost,@InvoiceNum)


                INSERT INTO stng.[ChangeLog](PK_ID,MilestoneRevisionID,NewValue,FK_Username,ChangeDate,AffectedField,AffectedTable)
                    VALUES (NEWID(),@PK_POID,'New Payment Milestone created by '+@Username,@Username,@CreatedDate,'ProcurementFields','PODetails')
            END

        IF @Operation = 2
            BEGIN
                print 'read'
            END

        IF @Operation = 3
            BEGIN
                print 'update'
            END
        IF @Operation = 4
            BEGIN
                print 'delete'
            END
    END TRY
	BEGIN CATCH


	END CATCH

END