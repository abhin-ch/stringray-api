CREATE OR ALTER function [stng].[FN_Budgeting_SDQ_PDFSignature]
(
	@SDQUID bigint
)
returns @tbl table
(
	SignatureType varchar(100),
	[Role] varchar(100),
	Signatory varchar(150),
	SignatureDate datetime
)
begin
	declare @AllStatus table
	(
		SDQStatus varchar(50),
		StatusDate datetime,
		EmpName varchar(250),
		RN INT
	);

	declare @Legacy bit;	
	IF EXISTS (
		select Legacy,StatusValue
		from stng.VV_Budgeting_SDQMain A
		where A.RecordTypeUniqueID = @SDQUID AND A.StatusValue IN ('AFRE','APRE') AND Legacy = 1
	)
	SET @Legacy = 1;

	WITH allstatus AS
	(
		SELECT 
			b.SDQStatus, 
			a.CreatedDate AS StatusDate, 
			c.EmpName
		FROM stng.Budgeting_StatusLog AS a
		INNER JOIN stng.Budgeting_SDQ_Status AS b ON a.StatusID = b.SDQStatusID
		INNER JOIN stng.VV_Admin_UserView AS c ON a.CreatedBy = c.EmployeeID
		WHERE a.[Type] = 'SDQ' 
		  AND a.RecordTypeUID = @SDQUID
		  AND SDQStatus != 'MIGR'
	),
	orderedStatus AS (
		SELECT *,
			ROW_NUMBER() OVER (ORDER BY StatusDate DESC) AS RN
		FROM allstatus
	)
	INSERT INTO @AllStatus(SDQStatus,StatusDate,EmpName,RN)
	SELECT 
		SDQStatus,
		StatusDate,
		EmpName 
		,RN
	FROM orderedStatus
	ORDER BY StatusDate DESC;

	--PCS 
	--Legacy accounts for the fact that AOEA now proceeds INIT/CORR, not AVER
	if @Legacy = 1
		begin

			insert into @tbl
			(Signatory, SignatureDate, SignatureType, Role)
			SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
				select
				CASE WHEN a.EmpName <> S.PCS THEN CONCAT(a.EmpName,' (',S.PCS,')')
				ELSE a.EmpName END AS Signatory, 
				a.StatusDate SignatureDate, 'Project Controls Specialist' SignatureType, 'PCS' Role
				,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
				from @AllStatus a
				LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.PCS, S.PCSID FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
				JOIN @AllStatus b ON a.RN + 1 = b.RN
				WHERE a.SDQStatus = 'APWCP'
				AND b.SDQStatus = 'INIT'
			) A WHERE A.RN = 1

		end

	else
		begin
			insert into @tbl
			(Signatory, SignatureDate, SignatureType, Role)
			SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
				select
				CASE WHEN a.EmpName <> S.PCS THEN CONCAT(a.EmpName,' (',S.PCS,')')
				ELSE a.EmpName END AS Signatory, 
				a.StatusDate SignatureDate, 'Project Controls Specialist' SignatureType, 'PCS' Role
				,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
				from @AllStatus a
				LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.PCS, S.PCSID FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
				JOIN @AllStatus b ON a.RN + 1 = b.RN
				WHERE (a.SDQStatus = 'AOEA' AND b.SDQStatus = 'INIT') OR (a.SDQStatus = 'AOEA' AND b.SDQStatus = 'CORR')
			) A WHERE A.RN = 1
		end


	--OE
	--Legacy accounts for the fact that AOEA now proceeds INIT/CORR, not AVER
	if @Legacy = 1
		begin

			insert into @tbl
			(Signatory, SignatureDate, SignatureType,Role)
			SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
				select
				CASE WHEN a.EmpName <> S.OE THEN CONCAT(a.EmpName,' (',S.OE,')')
				ELSE a.EmpName END AS Signatory, 
				a.StatusDate SignatureDate, 'Owner''s Engineer Lead (OE)' SignatureType, 'OE' Role
				,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
				from @AllStatus a
				LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.OE, S.OEID FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
				JOIN @AllStatus b ON a.RN + 1 = b.RN
				WHERE a.SDQStatus = 'ASMA'
				AND b.SDQStatus = 'AOEA'
			) A WHERE A.RN = 1
		end

	else
		begin
			insert into @tbl
			(Signatory, SignatureDate, SignatureType,Role)
			SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
				select
				CASE WHEN a.EmpName <> S.OE THEN CONCAT(a.EmpName,' (',S.OE,')')
				ELSE a.EmpName END AS Signatory, 
				a.StatusDate SignatureDate, 'Owner''s Engineer Lead (OE)' SignatureType, 'OE' Role
				,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
				from @AllStatus a
				LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.OE, S.OEID FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
				JOIN @AllStatus b ON a.RN + 1 = b.RN
				WHERE a.SDQStatus = 'AVER'
				AND b.SDQStatus = 'AOEA'
			) A WHERE A.RN = 1
		end


	--SMs, Verifier, and Lead Planner
	insert into @tbl
	(Signatory, SignatureDate, SignatureType,Role)
	select DISTINCT
	CASE WHEN ApprovedByC IS NULL THEN ApproverC
		WHEN ApprovedByC <> ApproverC THEN CONCAT(ApprovedByC, ' (', ApproverC,')')
		ELSE ApproverC END
	,ApprovalDate, 
	case when SDQApprovalType = 'SectionManager' then concat('Section Manager, ', PersonGroupC) else SDQApprovalType end,
	'SM'
	from stng.VV_Budgeting_SDQ_Approval A
	where A.SDQUID = @SDQUID and Approved = 1;

	--Legacy Verifier
	if @Legacy = 1 and not exists
	(
		select *
		from @tbl 
		where SignatureType = 'Verifier'
	)
		begin

			insert into @tbl(Signatory, SignatureDate, SignatureType,Role)
			SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
				select
				CASE WHEN a.EmpName <> S.Verifier THEN CONCAT(a.EmpName,' (',S.Verifier,')')
				ELSE a.EmpName END AS Signatory, 
				a.StatusDate SignatureDate, 'Verifier' SignatureType, 'Verifier' Role
				,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
				from @AllStatus a
				LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.Verifier FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
				JOIN @AllStatus b ON a.RN + 1 = b.RN
				WHERE a.SDQStatus = 'AOEA'
				AND b.SDQStatus = 'AVER'
			) A WHERE A.RN = 1			
		end;

	--DM DPTEP
	insert into @tbl
	(Signatory, SignatureDate, SignatureType, Role)
	SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
		select
		CASE WHEN a.EmpName <> S.DMEP THEN CONCAT(a.EmpName,' (',S.DMEP,')')
		ELSE a.EmpName END AS Signatory, 
		a.StatusDate SignatureDate, 'Department Manager, Engineering Projects' SignatureType, 'DMEP' Role
		,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
		from @AllStatus a
		LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.DMEP FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
		JOIN @AllStatus b ON a.RN + 1 = b.RN
		WHERE a.SDQStatus = 'APJMA'
		AND b.SDQStatus = 'ADPA'
	) A WHERE A.RN = 1

	--PM
	insert into @tbl(Signatory, SignatureDate, SignatureType, Role)
	SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
		select
		CASE WHEN a.EmpName <> S.ProjM THEN CONCAT(a.EmpName,' (',S.ProjM,')')
		ELSE a.EmpName END AS Signatory, 
		a.StatusDate SignatureDate, 'Project Manager' SignatureType, 'PM' Role
		,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN
		from @AllStatus a
		LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.ProjM FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
		JOIN @AllStatus b ON a.RN + 1 = b.RN
		WHERE a.SDQStatus = 'APGMA'
		AND b.SDQStatus = 'APJMA'
	) A WHERE A.RN = 1

	--ProgM
	declare @ProgMRouteDate datetime;
	select @ProgMRouteDate = StatusDate
	from @AllStatus
	where SDQStatus = 'APGMA';

	insert into @tbl(Signatory, SignatureDate, SignatureType, Role)
	SELECT A.Signatory,A.SignatureDate,A.SignatureType,A.Role FROM (
		select
		CASE WHEN a.EmpName <> S.ProgM THEN CONCAT(a.EmpName,' (',S.ProgM,')')
		ELSE a.EmpName END AS Signatory, 
		a.StatusDate SignatureDate, 'Program Manager' SignatureType, 'ProgM' Role
		,ROW_NUMBER() OVER (ORDER BY a.StatusDate DESC) AS RN,A.SDQStatus,A.StatusDate
		from @AllStatus a
		LEFT JOIN (SELECT RecordTypeUniqueID SDQUID, S.ProgM FROM stng.VV_Budgeting_SDQMain S) S ON S.SDQUID = @SDQUID
		JOIN @AllStatus b ON a.RN + 1 = b.RN
		WHERE a.SDQStatus IN ('AOERC','APCSC','AOEFR','AFRE')
		AND b.SDQStatus = 'APGMA'
	) A 
	--inner join
	--(
	--	select min(StatusDate) as StatusDate
	--	from @AllStatus
	--	where SDQStatus in ('AOERC','APCSC','AOEFR','AFRE') and StatusDate >= @ProgMRouteDate
	--) as b on a.StatusDate = b.StatusDate
	--where a.SDQStatus in ('AOERC','APCSC','AOEFR','AFRE')
	WHERE A.RN = 1

return;

end
GO


