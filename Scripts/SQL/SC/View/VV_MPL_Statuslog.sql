

Create or ALTER VIEW [stng].[VV_MPL_StatusLog]
AS
SELECT
    A.UniqueID,
	A.ProjectUpdateID,
    A.RAD,
    A.ActionStatus,
	B.ProjectNo,
	case when B.field='Owners Engineering' then 'Owners Engineering Lead' else B.Field end as Field,
	B.ChangeFrom,
	B.ChangeTo,
	CASE 
		WHEN A.RAB = 'SYSTEM' THEN A.RAB
		ELSE C.EmpName
	END AS ActionBy,D.Body as Comment
FROM stng.MPL_StatusLog A
LEFT JOIN stng.VV_MPL_ChangeRequest B ON A.ProjectUpdateID = B.UniqueID
LEFT JOIN stng.VV_Admin_Users C ON A.RAB = C.EmployeeID
left join [stng].[Common_Comment] D on cast(a.UniqueID as nvarchar(max) )=d.ParentID




