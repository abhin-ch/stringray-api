/*
Author: Arvind Dhinakar
Description: A procedure used for CRUD operations on TWP. This will execute complete work flows.
CreatedDate: 21 Dec 2021
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER   PROCEDURE [stng].[SP_TWP_CRUD](
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID INT = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@GCActivity [stngetl].TWP_TaskGrandChildUpdate READONLY -- cant make null
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
	,@PK_ID NVARCHAR(255) = NULL
	,@PROJECTID NVARCHAR(255) = NULL
    ,@Flagged bit = NULL
	,@Parent_ID NVARCHAR(255) = NULL

	,@EC NVARCHAR(255) = NULL
	,@Description NVARCHAR(1000) = NULL
	,@Site NVARCHAR(255) = NULL
	,@JPNum NVARCHAR(255) = NULL
	,@Status NVARCHAR(255) = NULL
) AS 
BEGIN
	/*
	Operations:
        1 - GET Activity Data -- not being used
		2 - GET Child Activity Data
		3 - GET Project Data for main view
		4 - GET Activity Data for First Nesting level
		5 - Flagging child activity
		6 - Updating User defined fields


	*/  
    BEGIN TRY

	DECLARE @Endpoints stng.[App_Endpoint]

        IF (@Operation = 1) 
			BEGIN
				SELECT * FROM [stng].[VV_TWP_Main] C ORDER BY c.PROJECT 
			END
		/*GET Child Activities*/
        IF (@Operation = 2)
            BEGIN
			IF @SubOp = 0
				BEGIN
				SELECT D.*, U.AssignedResource, U.StatusID,usr.EmpName as EmployeeName , Vl.[Label] as [Status] , U.HardCopyReceived, U.Labour, U.NumITPs, U.[Type], U.ECNum, U.AssessingComp, U.ReceivedDate, U.ITPNum, U.Discipline, U.TCD FROM stng.VV_TWP_Details D LEFT JOIN
				stngetl.TWP_TaskChildUpdate U ON U.TASK_ID = D.TASK_ID and U.PARENTTASK = D.PARENTTASK LEFT JOIN
				stng.Common_ValueLabel vl ON vl.Value = U.StatusID and vl.[Group] = 'TWP' and vl.[Field] = 'Status' LEFT JOIN
				stng.VV_Admin_UserView usr On usr.EmployeeID = U.AssignedResource
				WHERE D.PARENTTASK = @PK_ID
				END
			IF @SubOp = 1
				BEGIN
				SELECT D.*, U.AssignedResource, U.StatusID,usr.EmpName as EmployeeName , Vl.[Label] as [Status] , U.HardCopyReceived, U.Labour,U.NumITPs, U.[Type], U.ECNum, U.AssessingComp, U.ReceivedDate, U.ITPNum, U.Discipline, U.TCD FROM stng.VV_TWP_Details D LEFT JOIN
				stngetl.TWP_TaskChildUpdate U ON U.TASK_ID = D.TASK_ID and U.PARENTTASK = D.PARENTTASK LEFT JOIN
				stng.Common_ValueLabel vl ON vl.Value = U.StatusID and vl.[Group] = 'TWP' and vl.[Field] = 'Status' LEFT JOIN
				stng.VV_Admin_UserView usr On usr.EmployeeID = U.AssignedResource
				WHERE D.PARENTTASK = @PK_ID AND ((ABS(DATEDIFF(DAY,GETDATE(), D.CHILDTARGETENDDATE)) < 14 AND D.COMPLETED = 0) OR (ABS(DATEDIFF(DAY,GETDATE(), D.CHILDTARGETSTARTDATE)) < 14 AND D.COMPLETED = 0))
				END
			IF @SubOp = 2
				BEGIN
				SELECT D.*, U.AssignedResource, U.StatusID,usr.EmpName as EmployeeName , Vl.[Label] as [Status] , U.HardCopyReceived, U.Labour,U.NumITPs, U.[Type], U.ECNum, U.AssessingComp, U.ReceivedDate, U.ITPNum, U.Discipline, U.TCD FROM stng.VV_TWP_Details D LEFT JOIN
				stngetl.TWP_TaskChildUpdate U ON U.TASK_ID = D.TASK_ID and U.PARENTTASK = D.PARENTTASK LEFT JOIN
				stng.Common_ValueLabel vl ON vl.Value = U.StatusID and vl.[Group] = 'TWP' and vl.[Field] = 'Status' LEFT JOIN
				stng.VV_Admin_UserView usr On usr.EmployeeID = U.AssignedResource
				WHERE D.PARENTTASK = @PK_ID AND ((ABS(DATEDIFF(MONTH,GETDATE(), D.CHILDTARGETENDDATE)) < 6 AND D.COMPLETED = 0) OR (ABS(DATEDIFF(MONTH,GETDATE(), D.CHILDTARGETSTARTDATE)) < 6 AND D.COMPLETED = 0))
				END
			IF @SubOp = 3
				BEGIN
				SELECT D.*, U.AssignedResource, U.StatusID,usr.EmpName as EmployeeName , Vl.[Label] as [Status] , U.HardCopyReceived, U.Labour, U.NumITPs, U.[Type], U.ECNum, U.AssessingComp, U.ReceivedDate, U.ITPNum, U.Discipline, U.TCD FROM stng.VV_TWP_Details D LEFT JOIN
				stngetl.TWP_TaskChildUpdate U ON U.TASK_ID = D.TASK_ID and U.PARENTTASK = D.PARENTTASK LEFT JOIN
				stng.Common_ValueLabel vl ON vl.Value = U.StatusID and vl.[Group] = 'TWP' and vl.[Field] = 'Status' LEFT JOIN
				stng.VV_Admin_UserView usr On usr.EmployeeID = U.AssignedResource
				WHERE D.PARENTTASK = @PK_ID AND ((ABS(DATEDIFF(YEAR,GETDATE(), D.CHILDTARGETENDDATE)) < 1 AND D.COMPLETED = 0) OR (ABS(DATEDIFF(YEAR,GETDATE(), D.CHILDTARGETSTARTDATE)) < 1 AND D.COMPLETED = 0))
				END

            END

		/*All PMC Projects*/
        IF (@Operation = 3)
            BEGIN

			IF @SubOp = 0
				BEGIN
					SELECT N.*,CASE WHEN (twpa.ActTot) > 0 THEN 1 ELSE 0 END AS HasParentTasks, CASE WHEN (twp.FlagTot) > 0 THEN 1 ELSE 0 END AS HasFlag, CASE WHEN (twpb.NotCompTot) > 0 THEN 1 ELSE 0 END AS HasIncompActivities  FROM stng.VV_MPL_PMC N INNER JOIN
					(Select M.PROJECT , SUM(M.FlaggedCount) as FlagTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twp ON
					twp.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.ActivityCount) as ActTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpa ON
					twpa.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.NotCompletedCount) as NotCompTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpb ON
					twpb.PROJECT = N.ProjectID
					ORDER by N.ProjectID
				END
			IF @SubOp = 1
				BEGIN
					With Activity AS(
						SELECT TC.PARENTTASK, TC.TASK_ID, TC.CHILDACTIVITYID, PT.PROJECT FROM stngetl.TWP_TaskChild TC INNER JOIN
						stngetl.TWP_Task PT ON PT.TASK_ID = TC.PARENTTASK
						WHERE (ABS(DATEDIFF(DAY,GETDATE(), TC.CHILDTARGETENDDATE)) < 14 AND TC.COMPLETED = 0) OR (ABS(DATEDIFF(DAY,GETDATE(), TC.CHILDTARGETSTARTDATE)) < 14 AND TC.COMPLETED = 0)
						
					)
					
					SELECT N.*,CASE WHEN (twpa.ActTot) > 0 THEN 1 ELSE 0 END AS HasParentTasks, CASE WHEN (twp.FlagTot) > 0 THEN 1 ELSE 0 END AS HasFlag, CASE WHEN (twpb.NotCompTot) > 0 THEN 1 ELSE 0 END AS HasIncompActivities FROM stng.VV_MPL_PMC N INNER JOIN
					(Select M.PROJECT , SUM(M.FlaggedCount) as FlagTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twp ON
					twp.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.ActivityCount) as ActTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpa ON
					twpa.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.NotCompletedCount) as NotCompTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpb ON
					twpb.PROJECT = N.ProjectID
					WHERE N.ProjectID IN (SELECT distinct Project FROM Activity)
					ORDER by N.ProjectID
				END
			IF @SubOp = 2
				BEGIN
					With Activity AS(
						SELECT TC.PARENTTASK, TC.TASK_ID, TC.CHILDACTIVITYID, PT.PROJECT FROM stngetl.TWP_TaskChild TC INNER JOIN
						stngetl.TWP_Task PT ON PT.TASK_ID = TC.PARENTTASK
						WHERE (ABS(DATEDIFF(MONTH,GETDATE(), TC.CHILDTARGETENDDATE)) < 6 AND TC.COMPLETED = 0) OR (ABS(DATEDIFF(MONTH,GETDATE(), TC.CHILDTARGETSTARTDATE)) < 6 AND TC.COMPLETED = 0)
						
					)
					
					SELECT N.*,CASE WHEN (twpa.ActTot) > 0 THEN 1 ELSE 0 END AS HasParentTasks, CASE WHEN (twp.FlagTot) > 0 THEN 1 ELSE 0 END AS HasFlag, CASE WHEN (twpb.NotCompTot) > 0 THEN 1 ELSE 0 END AS HasIncompActivities  FROM stng.VV_MPL_PMC N INNER JOIN
					(Select M.PROJECT , SUM(M.FlaggedCount) as FlagTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twp ON
					twp.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.ActivityCount) as ActTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpa ON
					twpa.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.NotCompletedCount) as NotCompTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpb ON
					twpb.PROJECT = N.ProjectID
					WHERE N.ProjectID IN (SELECT distinct Project FROM Activity)
					ORDER by N.ProjectID
				END
			IF @SubOp = 3
				BEGIN
					With Activity AS(
						SELECT TC.PARENTTASK, TC.TASK_ID, TC.CHILDACTIVITYID, PT.PROJECT FROM stngetl.TWP_TaskChild TC INNER JOIN
						stngetl.TWP_Task PT ON PT.TASK_ID = TC.PARENTTASK
						WHERE (ABS(DATEDIFF(YEAR,GETDATE(), TC.CHILDTARGETENDDATE)) < 1 AND TC.COMPLETED = 0) OR (ABS(DATEDIFF(YEAR,GETDATE(), TC.CHILDTARGETSTARTDATE)) < 1 AND TC.COMPLETED = 0)
						
					)
					
					SELECT N.*,CASE WHEN (twpa.ActTot) > 0 THEN 1 ELSE 0 END AS HasParentTasks, CASE WHEN (twp.FlagTot) > 0 THEN 1 ELSE 0 END AS HasFlag, CASE WHEN (twpb.NotCompTot) > 0 THEN 1 ELSE 0 END AS HasIncompActivities  FROM stng.VV_MPL_PMC N INNER JOIN
					(Select M.PROJECT , SUM(M.FlaggedCount) as FlagTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twp ON
					twp.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.ActivityCount) as ActTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpa ON
					twpa.PROJECT = N.ProjectID LEFT JOIN
					(Select M.PROJECT , SUM(M.NotCompletedCount) as NotCompTot FROM stng.VV_TWP_Main M GROUP BY M.PROJECT) twpb ON
					twpb.PROJECT = N.ProjectID
					WHERE N.ProjectID IN (SELECT distinct Project FROM Activity)
					ORDER by N.ProjectID
				END
            END

		/*Parent Tasks for each Project*/
	    IF (@Operation = 4)
            BEGIN

			IF @SubOp = 0
				BEGIN
					SELECT * FROM stng.VV_TWP_Main N WHERE N.PROJECT = @ProjectID

				END

				IF @SubOp = 1
				BEGIN
				    SELECT * FROM stng.VV_TWP_Main N WHERE N.PROJECT = @ProjectID AND ((ABS(DATEDIFF(DAY,GETDATE(), N.TARGETENDDATE)) < 14 AND N.COMPLETED = 0) OR (ABS(DATEDIFF(DAY,GETDATE(), N.TARGETSTARTDATE)) < 14 AND N.COMPLETED = 0))
				END

				IF @SubOp = 2
				BEGIN
					SELECT * FROM stng.VV_TWP_Main N WHERE N.PROJECT = @ProjectID AND ((ABS(DATEDIFF(MONTH,GETDATE(), N.TARGETENDDATE)) < 6 AND N.COMPLETED = 0) OR (ABS(DATEDIFF(MONTH,GETDATE(), N.TARGETSTARTDATE)) < 6 AND N.COMPLETED = 0))
				END

				IF @SubOp = 3
				BEGIN
					SELECT * FROM stng.VV_TWP_Main N WHERE N.PROJECT = @ProjectID AND ((ABS(DATEDIFF(YEAR,GETDATE(), N.TARGETENDDATE)) < 1 AND N.COMPLETED = 0) OR (ABS(DATEDIFF(YEAR,GETDATE(), N.TARGETSTARTDATE)) < 1 AND N.COMPLETED = 0))
				END

            END

		/*Flagging Child Tasks*/
		IF (@Operation = 5)
            BEGIN

			if @PK_ID is null or @Parent_ID is null or @Flagged is null
						begin

							select 'PKID, ParentID, Flagged are required' as ReturnMessage;
							return;

						end

				UPDATE stngetl.TWP_TaskChildFlags SET Flagged = @Flagged where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

				Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
                values(Concat(@PK_ID, '-',@Parent_ID), 'Flagged', 'TWP_TaskChildFlags', @Flagged, @EmployeeID, GETDATE())

            END

		/*Updating user defined fields for Child Tasks*/
		IF (@Operation = 6)
            BEGIN
				IF(@SubOp = 1)
					BEGIN
					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end

						UPDATE stngetl.TWP_TaskChildUpdate SET AssignedResource = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'AssignedResource', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =2)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Num1 is null
						begin

							select 'PKID, ParentID, Num1 are required' as ReturnMessage;
							return;

						end

						UPDATE stngetl.TWP_TaskChildUpdate SET StatusID = @Num1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID,'-',@Parent_ID), 'StatusID', 'TWP_TaskChildUpdate', @Num1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =3)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @IsTrue1 is null
						begin

							select 'PKID, ParentID, isTrue1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET HardCopyReceived = @IsTrue1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'HardCopyReceived', 'TWP_TaskChildUpdate', @IsTrue1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =4)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET Labour = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'Labour', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =5)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET [Type] = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'Type', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =6)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET NumITPs = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'NumITPs', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =7)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET ECNum = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'ECNum', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =8)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET ITPNum = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'ITPNum', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =9)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET Discipline = @Value1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'Discipline', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =10)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value3 is null
						begin

							select 'PKID, ParentID, Value3 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET ReceivedDate = @Value3 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'ReceivedDate', 'TWP_TaskChildUpdate', @Value3, @EmployeeID, GETDATE())
					END
				IF(@SubOp =11)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @IsTrue1 is null
						begin

							select 'PKID, ParentID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET AssessingComp = @IsTrue1 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'AssessingComp', 'TWP_TaskChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =12)
					BEGIN

					if @PK_ID is null or @Parent_ID is null or @Value3 is null
						begin

							select 'PKID, ParentID, Value3 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskChildUpdate SET TCD = @Value3 where TASK_ID = @PK_ID and PARENTTASK = @Parent_ID

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'TCD', 'TWP_TaskChildUpdate', @Value3, @EmployeeID, GETDATE())
					END
				
            END

			IF (@Operation = 7)
            BEGIN
				EXEC [stng].[SP_Common_CRUD] @Operation=1,@Value1='TWP',@Value2='TWP',@Value3='Status',@Endpoints=@Endpoints
            END

			/*Get all Grandchild Activities*/
			IF (@Operation = 8)
            BEGIN
				Select * from stng.VV_TWP_GCDetails where Deleted != 1 and (PARENTCHILDTASKID = @PK_ID and PARENTTASKID = @Parent_ID)
            END

			/*Add New GC Activity*/
			IF (@Operation = 9)
            BEGIN
				INSERT INTO stngetl.TWP_TaskGrandChildUpdate(PK_ID, PARENTCHILDTASKID, PARENTTASKID, ActivityName, AssignedResource, StatusID, HardCopyReceived, Labour,Type,
				NumITPs,RAB, RAD, Deleted, DeletedBy, DeletedDate, ITPNum, Discipline, AssessingComp, ReceivedDate)
				Select G.PK_ID, G.PARENTCHILDTASKID, G.PARENTTASKID, G.ActivityName, G.AssignedResource, G.StatusID, G.HardCopyReceived, G.Labour,G.[Type],
				G.NumITPs,G.RAB, G.RAD, G.Deleted, G.DeletedBy, G.DeletedDate, G.ITPNum, G.Discipline, G.AssessingComp, G.ReceivedDate from @GCActivity G
            END

			/*Delete new GC Activity*/
			IF (@Operation = 10)
            BEGIN
				UPDATE stngetl.TWP_TaskGrandChildUpdate
				SET Deleted = 1, DeletedBy = @EmployeeID,DeletedDate = getDate()
				WHERE PARENTCHILDTASKID = @PK_ID and PARENTTASKID = @Parent_ID
            END

			/*Fetch Options for Dropdown*/
			IF (@Operation = 11)
            BEGIN
				EXEC [stng].[SP_Common_CRUD] @Operation=1,@Value1='TWP',@Value2='TWP',@Value3='ActivityNames',@Endpoints=@Endpoints
            END

			IF (@Operation = 12)
            BEGIN
				IF(@SubOp = 1)
					BEGIN
					if @Value2 is null or @Value1 is null
						begin

							select 'PKID are required' as ReturnMessage;
							return;

						end

						UPDATE stngetl.TWP_TaskGrandChildUpdate SET AssignedResource = @Value1 where PK_ID= @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(@Value2, 'AssignedResource', 'TWP_TaskGrandChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =2)
					BEGIN

					if @Value2 is null or @Num1 is null
						begin

							select 'PKID, ParentID, Num1 are required' as ReturnMessage;
							return;

						end

						UPDATE stngetl.TWP_TaskGrandChildUpdate SET StatusID = @Num1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(@Value2, 'StatusID', 'TWP_TaskGrandChildUpdate', @Num1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =3)
					BEGIN

					if @Value2 is null or @IsTrue1 is null
						begin

							select 'PKID, isTrue1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET HardCopyReceived = @IsTrue1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(@Value2, 'HardCopyReceived', 'TWP_TaskGrandChildUpdate', @IsTrue1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =4)
					BEGIN

					if @Value2 is null or @Value1 is null
						begin

							select 'PKID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET Labour = @Value1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(@Value2, 'Labour', 'TWP_TaskGrandChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =5)
					BEGIN

					if @Value2 is null or @Value1 is null
						begin

							select 'PKID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET [Type] = @Value1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(@Value2, 'Type', 'TWP_TaskGrandChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =6)
					BEGIN

					if @Value2 is null or @Value1 is null
						begin

							select 'PKID, Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET NumITPs = @Value1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(@Value2, 'NumITPs', 'TWP_TaskGrandChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =7)
					BEGIN

					if @Value2 is null or @Value1 is null
						begin

							select 'Value2 and Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET ITPNum = @Value1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'ITPNum', 'TWP_TaskGrandChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =8)
					BEGIN

					if @Value2 is null or @Value1 is null
						begin

							select 'Value2 and Value1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET Discipline = @Value1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'Discipline', 'TWP_TaskGrandChildUpdate', @Value1, @EmployeeID, GETDATE())
					END
				IF(@SubOp =9)
					BEGIN

					if @Value3 is null or @Value2 is null
						begin

							select 'Value3 and Value2 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET ReceivedDate = @Value3 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'ReceivedDate', 'TWP_TaskGrandChildUpdate', @Value3, @EmployeeID, GETDATE())
					END
				IF(@SubOp =10)
					BEGIN

					if @IsTrue1 is null or @Value2 is null
						begin

							select 'Value2 and IsTrue1 are required' as ReturnMessage;
							return;

						end
						UPDATE stngetl.TWP_TaskGrandChildUpdate SET AssessingComp = @IsTrue1 where PK_ID = @Value2

						Insert into stng.Common_ChangeLog(ParentID, AffectedField, AffectedTable, NewValue, CreatedBy, CreatedDate)
						values(Concat(@PK_ID, '-',@Parent_ID), 'AssessingComp', 'TWP_TaskGrandChildUpdate', @IsTrue1, @EmployeeID, GETDATE())
					END
				
            END

		IF(@Operation = 13)
		BEGIN
		select distinct EC, [DESCRIPTION], [STATUS], JPNUM, SITEID
				
					from stngetl.General_AllEC
					where 
					(EC like '%' + @EC + '%' or @EC is null)
					and
					([DESCRIPTION] like '%' + @Description + '%' or @Description is null)
					and
					([Status] like '%' + @Status + '%' or @Status is null)
					and
					(SITEID like '%' + @Site + '%' or @Site is null)
					and
					(JPNUM like '%' + @JPNum + '%' or @JPNum is null)
					
		END

	IF(@Operation = 15)
		BEGIN
		select * from stng.VV_TWP_FullExport			
		END

    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],Operation) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     CONCAT(ERROR_MESSAGE(),'PK_ActivityID: ',@PK_ID),
					 @Operation
              );
			  THROW
	END CATCH
	
END
