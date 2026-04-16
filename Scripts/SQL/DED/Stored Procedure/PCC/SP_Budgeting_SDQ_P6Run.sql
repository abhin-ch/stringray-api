CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_SDQ_P6Run](
 @SDQID BIGINT,
 @P6RunID VARCHAR(255),
 @SubOp INT,
 @EmployeeID VARCHAR(20),
 @P6PostProcess stng.TYPE_Budgeting_P6PostProcess readonly,
 @DeliverableTypeVersion INT = NULL
)
AS
BEGIN 
	DECLARE @WorkingProjectID varchar(50);
	DECLARE @ReturnTbl table
	(
		NextStatus varchar(20),
		NextStatusLong varchar(200),
		ReturnMessage varchar(200),
		ReturnMessageUnauthorized varchar(200)
	);
				--Do RSS for write operations
				IF @SubOp >= 2 and @SubOp <=4
					BEGIN 

						INSERT INTO @ReturnTbl
						(NextStatus, ReturnMessage, ReturnMessageUnauthorized)
						SELECT NextStatus, ReturnMessage, ReturnMessageUnauthorized
						FROM stng.FN_Budgeting_Routing_RSSCheck_SDQ(@SDQID,@EmployeeID,null);

						IF exists
						(
							SELECT top 1 ReturnMessage
							FROM @ReturnTbl
							WHERE ReturnMessage is not null
						)
							BEGIN

								SELECT top 1 ReturnMessage
								FROM @ReturnTbl
								WHERE ReturnMessage is not null;
								return;

							END

						ELSE IF exists
						(
							SELECT top 1 ReturnMessageUnauthorized
							FROM @ReturnTbl
							WHERE ReturnMessageUnauthorized is not null
						)
							BEGIN

								SELECT top 1 ReturnMessageUnauthorized
								FROM @ReturnTbl
								WHERE ReturnMessageUnauthorized is not null;
								return;

							END

						ELSE IF not exists
						(
							SELECT *
							FROM stng.VV_Budgeting_SDQMain
							WHERE RecordTypeUniqueID = @SDQID and StatusValue in ('INIT','CORR')
						)
							BEGIN

								SELECT 'SDQ P6 schedule is not linkable at the current status' AS ReturnMessage;
								return;

							END

					END

				--Get all P6 schedules for a SDQ
				IF @SubOp = 1
					BEGIN 
						
						--Null and existence check
						IF @SDQID is null
							BEGIN

								SELECT 'SDQID required' AS ReturnMessage;
								return;

							END

						ELSE IF not exists
						(
							SELECT *
							FROM stng.Budgeting_SDQMain
							WHERE SDQUID = @SDQID
						)
							BEGIN

								SELECT 'SDQ does not exist' AS ReturnMessage;
								return;

							END

						SELECT a.RunID, a.RunSubID, a.PipelineCompleteTime, b.Active AS Linked, a.RABC, 
						CONCAT(a.RunSubID,' - ',FORMAT(a.PipelineCompleteTime,'dd-MMM-yyyy'),' - ',a.RABC) AS [label]
						FROM stngetl.VV_Budgeting_SDQ_P6_Run AS a
						INNER JOIN stng.Budgeting_SDQP6Link AS b on a.RunID = b.RunID
						WHERE a.SDQUID = @SDQID
						order by a.PipelineCompleteTime desc;

					END 

				--Link P6 Schedule
				ELSE IF @SubOp = 2
					BEGIN

						--Null and existence checks
						IF @SDQID is null
							BEGIN

								SELECT 'SDQID required' AS ReturnMessage;
								return;

							END

						ELSE IF not exists
						(
							SELECT *
							FROM stng.Budgeting_SDQMain
							WHERE SDQUID = @SDQID
						)
							BEGIN

								SELECT 'SDQ does not exist' AS ReturnMessage;
								return;

							END

						IF @P6RunID is null
							BEGIN

								SELECT 'P6RunID is required' AS ReturnMessage;
								return;

							END

						ELSE IF not exists
						(
							SELECT *
							FROM stngetl.Budgeting_SDQ_Run
							WHERE RunID = @P6RunID and PipelineCompleteTime is not null
						)
							BEGIN

								SELECT 'P6Run does not exist' AS ReturnMessage;
								return;

							END

						--First, deactivate any linked schedules
						UPDATE stng.Budgeting_SDQP6Link
						SET Active = 0
						WHERE SDQUID = @SDQID;

						--If RunID is inactive, reactivate
						IF exists
						(
							SELECT *
							FROM stng.Budgeting_SDQP6Link
							WHERE SDQUID = @SDQID and RunID = @P6RunID
						)
							BEGIN

								UPDATE stng.Budgeting_SDQP6Link
								SET Active = 1
								WHERE SDQUID = @SDQID and RunID = @P6RunID

								UPDATE S SET S.RequestedScope = A.CurrentRequest
								FROM stng.Budgeting_SDQMain S
								CROSS APPLY (SELECT * FROM stng.FN_Budgeting_SDQ_HeaderCost(@SDQID)) A
								WHERE S.SDQUID = @SDQID

							END

						--Otherwise, add new record
						else
							BEGIN

								INSERT INTO stng.Budgeting_SDQP6Link
								(RunID, SDQUID, Active, CreatedBy, CreatedDate)
								values
								(@P6RunID, @SDQID, 1, @EmployeeID, stng.GetDate());

							END

						-- Update materialized CIIDeliverabletable table 
						EXEC stngetl.SP_Budgeting_SDQ_P6_CIIDeliverable_RefreshMaterialized @P6RunID, @SDQID;
						-- Update materialized P6_CIIOrg table 
						EXEC stngetl.SP_Budgeting_SDQ_P6_CIIOrg_RefreshMaterialized @P6RunID, @SDQID;
						-- Update materialized CVWBS table for the 
						EXEC stngetl.SP_Budgeting_SDQ_P6_CVWBS_RefreshMaterialized @P6RunID, @SDQID;

						SELECT a.RunID, a.RunSubID, a.PipelineCompleteTime, b.Active AS Linked, a.RABC, 
						CONCAT(a.RunSubID,' - ',FORMAT(a.PipelineCompleteTime,'dd-MMM-yyyy'),' - ',a.RABC) AS [label]
						FROM stngetl.VV_Budgeting_SDQ_P6_Run AS a
						INNER JOIN stng.Budgeting_SDQP6Link AS b on a.RunID = b.RunID
						WHERE a.SDQUID = @SDQID and b.Active = 1
						order by a.PipelineCompleteTime desc;

					END

				--SubOp 3 is used to add a P6 run
				ELSE IF @SubOp = 3
					BEGIN

						--Null and existence check
						IF @SDQID is null
							BEGIN

								SELECT 'SDQID required' AS ReturnMessage;
								return;

							END

						ELSE IF not exists
						(
							SELECT *
							FROM stng.Budgeting_SDQMain
							WHERE SDQUID = @SDQID
						)
							BEGIN

								SELECT 'SDQ does not exist' AS ReturnMessage;
								return;

							END

						SELECT @WorkingProjectID = case when left(ProjectNo,3) <> 'ENG' then concat('ENG-',ProjectNo) else ProjectNo END
						FROM stng.Budgeting_SDQMain
						WHERE SDQUID = @SDQID;

						IF @WorkingProjectID is null or not exists
						(
							SELECT *
							FROM stng.MPL
							WHERE PROJECTID = @WorkingProjectID
						)
							BEGIN

								SELECT 'Project ID linked to SDQ does not exist in MPL' AS ReturnMessage;
								return;

							END

						declare @RunSubID int;
						SELECT @RunSubID = max(RunSubID)
						FROM stngetl.Budgeting_SDQ_Run
						WHERE SDQUID = @SDQID;

						IF @RunSubID is null SET @RunSubID = 1
						else SET @RunSubID = @RunSubID + 1;

						INSERT INTO stngetl.Budgeting_SDQ_Run
						(SDQUID, RunSubID, RAB, DeliverableTypeVersion)
						values
						(@SDQID,@RunSubID,@EmployeeID, 2);

						SELECT @P6RunID = RunID
						FROM stngetl.Budgeting_SDQ_Run
						WHERE SDQUID = @SDQID and RunSubID = @RunSubID;

						SELECT @WorkingProjectID AS ProjectNo, @P6RunID AS RunID
						FROM stng.Budgeting_SDQMain
						WHERE SDQUID = @SDQID;

					END

				--SubOp 4 is used to fetch P6 run info 
				ELSE IF @SubOp = 4
					BEGIN

						SELECT *
						FROM stngetl.Budgeting_SDQ_P6
						WHERE RunID = @P6RunID
						OPTION(optimize for(@P6RunID unknown));

					END

				--SubOp 5 is used to alter PhaseCode/DisciplineCode for a given P6RunID and add it to stng.Budgeting_SDQP6Link 
				ELSE IF @SubOp = 5
					BEGIN

						--Null checks
						IF @P6RunID is null or @SDQID is null
							BEGIN

								SELECT 'P6RunID and SDQID are required' AS ReturnMessage;
								return;

							END

						ELSE IF not exists
						(
							SELECT top 1 *
							FROM stngetl.Budgeting_SDQ_P6
							WHERE RunID = @P6RunID 
						)
							BEGIN

								SELECT 'P6RunID does not exist' AS ReturnMessage;
								return;

							END

						ELSE IF not exists
						(
							SELECT *
							FROM stng.Budgeting_SDQMain
							WHERE SDQUID = @SDQID
						)
							BEGIN

								SELECT 'SDQID does not exist' AS ReturnMessage;
								return;

							END

					UPDATE a
					SET a.PhaseCode = b.PhaseCode,
						a.DisciplineCode = b.DisciplineCode
					FROM stngetl.Budgeting_SDQ_P6 AS a
					INNER JOIN @P6PostProcess AS b
						ON (a.Task_ID = b.Task_ID OR a.UniqueID = b.UniqueID)
					WHERE a.RunID = @P6RunID;
							
					END 

				--P6 Project View
				ELSE IF @SubOp = 6
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_ProjectView
						WHERE SDQUID = @SDQID
						order by ActivityID asc
						OPTION(RECOMPILE)

					END 

				--P6 Deliverable Summary
				ELSE IF @SubOp = 7
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_DeliverablesSummary
						WHERE SDQUID = @SDQID
						order by RevisedCommitment asc
						OPTION(RECOMPILE)

					END 

				--CII Deliverable Summary
				ELSE IF @SubOp = 8
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_CIIDeliverable_MatView
						WHERE SDQUID = @SDQID
						OPTION(optimize for (@SDQID unknown))
						


					END

				--CII by Org
				ELSE IF @SubOp = 9
					BEGIN

						SELECT *
						FROM stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized
						WHERE SDQUID = @SDQID
						order by RespOrg asc 
						OPTION(RECOMPILE)

					END

				--CII SDS
				ELSE IF @SubOp = 10
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_CIISDS
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)


					END

				--CII Summary by Phase
				ELSE IF @SubOp = 11
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_CIISummaryPhase
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)
						
					END

				--CV by WBS
				ELSE IF @SubOp = 12
					BEGIN

						SELECT *
						FROM stngetl.Budgeting_SDQ_P6_CVWBS_Materialized
						WHERE SDQUID = @SDQID
						order by DeliverableType asc
						--OPTION(RECOMPILE)

					END

				--CV by Phase
				ELSE IF @SubOp = 13
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_CVPhase
						WHERE SDQUID = @SDQID
						order by PhaseCode asc
						OPTION(RECOMPILE)

					END 

				--CV SDS
				ELSE IF @SubOp = 14
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_CVSDS
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END 

				--CV Summary by Phase
				ELSE IF @SubOp = 15
					BEGIN

						SELECT *
						FROM [stngetl].[VV_Budgeting_SDQ_P6_CVSummaryPhase] 
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END

				--CV Summary by Phase Summary
				ELSE IF @SubOp = 16
					BEGIN

						SELECT *
						FROM [stngetl].[VV_Budgeting_SDQ_P6_CVSummaryPhaseSummary]
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END

				--CII SDS Summary
				ELSE IF @SubOp = 17
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_SDSSummary_CII
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END 

				--CV SDS Summary
				ELSE IF @SubOp = 18
					BEGIN

						SELECT *
						FROM [stngetl].[VV_Budgeting_SDQ_P6_SDSSummary_CV]
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END 

				--LAMP SDS Summary
				ELSE IF @SubOp = 19
					BEGIN

						SELECT *
						FROM stngetl.FN_Budgeting_SDQ_P6_LAMPSummary(@SDQID)
						order by Revision asc, CPVClass asc

					END

				--Forecast (Total)
				ELSE IF @SubOp = 20
					BEGIN

						SELECT FirstOfMonth AS [Date], Forecast AS Cost
						FROM stngetl.VV_Budgeting_SDQ_P6_TotalForecast
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END

				--Forecast (CII)
				ELSE IF @SubOp = 21
					BEGIN

						SELECT FirstofMonth AS [Date], Forecast AS Cost
						FROM [stngetl].[VV_Budgeting_SDQ_P6_TotalForecast_CII]
						WHERE SDQUID = @SDQID
						order by FirstofMonth
						OPTION(RECOMPILE)

					END


				--Forecast (CPV)
				ELSE IF @SubOp = 22
					BEGIN

						SELECT FirstofMonth AS [Date], Forecast AS Cost
						FROM [stngetl].[VV_Budgeting_SDQ_P6_TotalForecast_CPV] 
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END

				--Hours by Discipline
				ELSE IF @SubOp = 23
					BEGIN
						
						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_Discipline
						WHERE SDQUID = @SDQID
						order by PersonGroupDescription asc
						OPTION(RECOMPILE)

					END

				--CII Summary by Phase Summary
				ELSE IF @SubOp = 24
					BEGIN

						SELECT *
						FROM [stngetl].[VV_Budgeting_SDQ_P6_CIISummaryPhaseSummary]
						WHERE SDQUID = @SDQID
						OPTION(RECOMPILE)

					END

				--SubOp 25 is reserved for API use

				--P6 Validation Checks
				ELSE IF @SubOp = 26
					BEGIN

						INSERT INTO stngetl.Budgeting_SDQ_P6_Error
						(RunID, WBSCode, ActivityID, Error, General)
						SELECT RunID, WBSCode, ActivityID, Error, General
						FROM stng.FN_Budgeting_SDQ_P6_Validation(@P6RunID, @SDQID);

						IF  exists
						(
							SELECT * 
							FROM stngetl.Budgeting_SDQ_P6_Error 
							WHERE RunID = @P6RunID
						)
							BEGIN

								SELECT 1 AS HasP6Error;

							END

						else
							BEGIN
								INSERT INTO stng.Budgeting_SDQP6Link
									(SDQUID, RunID, Active, CreatedBy, CreatedDate)
								VALUES
									(@SDQID, @P6RunID,
									 CASE WHEN NOT EXISTS (
										  SELECT 1
										  FROM stng.Budgeting_SDQP6Link
										  WHERE SDQUID = @SDQID
									 ) THEN 1 ELSE 0 END,
									 @EmployeeID, stng.GetDate());
							END

					END

				--PMPC Pct
				ELSE IF @SubOp = 27
					BEGIN

						SELECT *
						FROM stngetl.VV_Budgeting_SDQ_P6_PMPC
						WHERE SDQUID = @SDQID;

					END

				--P6 Error
				ELSE IF @SubOp = 28
					BEGIN
							
						SELECT * 
						FROM stngetl.Budgeting_SDQ_P6_Error 
						WHERE RunID = @P6RunID;

					END

				ELSE IF (@SubOp = 29)
					SELECT A.*,A.PreviousRevisionEAC PriorSDQEAC,E.EcoSysEAC FROM stng.FN_PCC_FinancialSummary(@SDQID) A
					LEFT JOIN stng.VV_Budgeting_SDQ_EcoSysEAC E ON E.SDQUID = A.SDQUID


				-- Update Deliverable Type Version 
				ELSE IF(@SubOp = 30) UPDATE stngetl.Budgeting_SDQ_Run SET DeliverableTypeVersion = @DeliverableTypeVersion
					WHERE RunID = @P6RunID

				ELSE IF(@SubOp = 31) SELECT DeliverableTypeVersion FROM stngetl.Budgeting_SDQ_Run WHERE RunID = @P6RunID

			
			END
