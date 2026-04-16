CREATE OR ALTER   PROCEDURE [stng].[SP_TOQ]
(
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID NVARCHAR(20) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Value7 NVARCHAR(255) = NULL
	,@Value8 NVARCHAR(255) = NULL
)
AS
BEGIN
	-- Get IsEBS
	IF(@Operation=1)
		BEGIN 
			SELECT CAST(IIF(COUNT(*)>0,1,0) AS BIT) AS IsEBS FROM [stng].[VV_Admin_UserAttribute] U 
			WHERE U.AttributeType = 'BPRole' AND U.Attribute='EBS' AND EmployeeID = @EmployeeID
		END


	-- Get Roles on user
	ELSE IF(@Operation = 2)
	BEGIN
		SELECT B.BPRole,EmployeeID,B.Vendor
			,SUM(B.IsTOQAdmin) IsTOQAdmin
			,SUM(B.IsSysAdmin) IsSysAdmin
			,SUM(B.IsVendor) IsVendor 
		FROM (
			SELECT DISTINCT U.EmployeeID
			,IIF(S.Permission = 'TOQAdmin',1,0) IsTOQAdmin
			,IIF(S.Permission = 'SysAdmin',1,0) IsSysAdmin
			,IIF(A.AttributeType = 'Vendor',1,0) IsVendor
			,IIF(A.AttributeType = 'Vendor',A.Attribute,NULL) Vendor
			,IIF(A.AttributeType = 'BPRole',A.Attribute,NULL) BPRole
			FROM stng.VV_Admin_Users U
			LEFT JOIN [stng].VV_Admin_ActualUserPermission S ON S.EmployeeID = U.EmployeeID 
				AND (S.Permission = 'SysAdmin' OR S.Permission = 'TOQAdmin' OR S.Permission IS NULL)
			LEFT JOIN stng.[VV_Admin_UserAttribute] A ON A.EmployeeID = U.EmployeeID AND (A.AttributeType = 'BPRole' OR A.AttributeType = 'Vendor')
			WHERE U.EmployeeID = @EmployeeID
		) B
		GROUP BY B.BPRole,B.EmployeeID,B.Vendor
		ORDER BY IsVendor DESC
	END

	ELSE IF (@Operation = 3)
	BEGIN
		select * FROM stng.Admin_UserRole
		where RoleID = '66F4911F-469F-4AE9-8F4D-7FFAD0DF584C'
	END

	ELSE IF (@Operation = 4)
	BEGIN
		
		--EBS
		SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '336E4F3B-6D67-4D80-8E8F-3BEC1ABC309B' 
		AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		--EBS SM
		SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = 'DAE6F225-D07E-4228-A3C3-8E149AF2ACCD'
		AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		--Vendor PM
		SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '598D8A17-B2FA-4BC8-9540-86C3B93E3415'
		AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
	END

	ELSE IF (@Operation = 5)
	BEGIN
		--BP PROJECT CONTROLS TEAM		
		SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '040D83C1-57E1-4601-9E40-16A02E9D9105'
		AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
	END
END

select distinct Origin from stng.VV_Admin_ActualUserPermission