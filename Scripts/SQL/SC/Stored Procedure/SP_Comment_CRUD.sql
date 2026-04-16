/*
Author: Arvind Dhinakar
Description: A procedure used for CRUD operations to Add/ Remove and Edit Comments
CreatedDate: 29 Sept 2021 
RevisedDate: 24 Jan 2023
RevisedBy: Habib Shakibanejad
*/

CREATE OR ALTER PROCEDURE [stng].[SP_Comment_CRUD](
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
	,@Istrue1 BIT = NULL
	,@Istrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - Add a comment
		2 - DELETE comment
		3 - Pin a comment
		4 - Edit comment
		5 - GET comments
		6 - GET related comments
	*/  
    BEGIN TRY
		/*Add Comment*/
        IF @Operation = 1
            BEGIN
				INSERT INTO [stng].Common_Comment(ParentID, Body, ParentTable, RelatedID, RelatedType, CreatedBy,RelatedTable)
				VALUES (@Value1, @Value6, @Value3, @Value4, @Value2, @EmployeeID, @Value5) 

				SELECT CommentID AS CID
					,C.ParentID
					,C.ParentTable
					,C.Body
					,C.CreatedBy
					,C.CreatedDate
					,C.ModifiedDate
					,C.RelatedID
					,C.RelatedType
					,C.RelatedTable
					,C.Pinned
					,U.FullName
					,U.Username
				FROM stng.Common_Comment AS C
				LEFT JOIN stng.Admin_User U ON U.EmployeeID = C.CreatedBy
				WHERE C.ParentID = @Value1 AND C.ParentTable = @Value3
				OR (C.RelatedID = @Value1 AND C.RelatedTable = @Value3)
				ORDER BY C.Pinned DESC, C.CreatedDate DESC
			END

		/*Remove Comment*/
        IF @Operation = 2
            BEGIN
				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,AffectedField,AffectedTable,PreviousValue,CreatedBy)
				SELECT C.ParentID,NULL,'Body','Comment',C.Body,C.CreatedBy FROM stng.Common_Comment C WHERE C.CommentID = @Num1 AND C.CreatedBy = @EmployeeID
				DELETE C FROM [stng].Common_Comment C WHERE C.CommentID = @Num1 AND C.CreatedBy = @EmployeeID
            END

        /*Pin Comment*/
		IF @Operation = 3 UPDATE stng.Common_Comment SET Pinned = @IsTrue1 WHERE CommentID = @Num1;			 

		/*Edit comment*/
		IF @Operation = 4
			BEGIN
				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,AffectedField,AffectedTable,PreviousValue,CreatedBy)
				SELECT C.ParentID,@Value6,'Body','Comment',C.Body,C.CreatedBy FROM stng.Common_Comment C WHERE C.CommentID = @Num1 AND C.CreatedBy = @EmployeeID;
				UPDATE stng.Common_Comment SET Body = @Value6,ModifiedDate = GETDATE() WHERE CommentID = @Num1
			END
		
		/*GET comments*/
		IF @Operation = 5
			BEGIN
				SELECT CommentID AS CID
					,C.ParentID
					,C.ParentTable
					,C.Body
					,C.CreatedBy
					,C.CreatedDate
					,C.ModifiedDate
					,C.RelatedID
					,C.RelatedType
					,C.RelatedTable
					,C.Pinned
					,U.FullName
					,U.Username
				FROM stng.Common_Comment AS C
				LEFT JOIN stng.Admin_User U ON U.EmployeeID = C.CreatedBy
				WHERE C.ParentID = @Value1 AND C.ParentTable = @Value2
				OR (C.RelatedID = @Value1 AND C.RelatedTable = @Value2)
			END

		/*GET related comments*/
		IF @Operation = 6
			BEGIN
				SELECT C.CommentID AS CID
					,C.ParentID
					,C.ParentTable
					,C.Body
					,C.CreatedBy
					,C.CreatedDate
					,C.ModifiedDate
					,C.RelatedID
					,C.RelatedType
					,C.RelatedTable
					,C.Pinned
					,U.FullName
					,U.Username
				FROM stng.Common_Comment AS C
				LEFT JOIN stng.Admin_User U ON U.EmployeeID = C.CreatedBy
				WHERE C.RelatedID = @Value1 AND C.RelatedTable = @Value2
				ORDER BY C.Pinned DESC, C.CreatedDate DESC
			END
    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) VALUES (
			ERROR_NUMBER(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			@Operation
		);
		THROW
	END CATCH
END
