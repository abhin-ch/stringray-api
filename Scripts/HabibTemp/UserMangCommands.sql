--create endpoint,authenticate endpoint,point,link to attribute (module)
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/status', @HTTPVerb = 'GET', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/status', @HTTPVerb = 'GET', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/status', @HTTPVerb = 'GET',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';

-- Create Attribute
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='PCS',@AttributeType='BPRole',@EmployeeID = '619704'

-- Create permission, link to attribute (module)
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQDeleteTDSAttachment',@Description='Enable download button for TDS Attachment in TDS Header',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQDeleteTDSAttachment',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';

SELECT Permission FROM stng.VV_Admin_AllPermission WHERE Permission LIKE '%TOQ%' AND Permission NOT LIKE '%TOQLite%' GROUP BY Permission 

--Assign BPRole to User
exec stng.SP_Admin_UserManagement @Operation = 42, @Attribute = 'SM', @AttributeType = 'BPRole', @EmployeeID = '619704';


--If permission is for vendors, permission needs to be linked to an attribute of 'Vendor' Type

--link endpoint to permission
EXEC stng.SP_Admin_UserManagement @Operation = 45, @Endpoint = 'admin/user/me/attribute', @HTTPVerb = 'GET', @Permission = 'test', @EmployeeID = '619704';

