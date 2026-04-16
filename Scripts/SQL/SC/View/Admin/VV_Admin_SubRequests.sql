/****** Object:  View [stng].[VV_Admin_SubRequests]    Script Date: 10/21/2024 12:35:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [stng].[VV_Admin_SubRequests] AS
SELECT req.RequestID, sub.SubRequestID, typ.TypeName, typ.ShortName, 
req.RequestorEID, 
usr.EmpName, req.MimicOfEID, req.ReasonGiven, 
req.RAB, req.RAD, sub.Comment, sub.ReviewedBy, sub.ReviewedOn, stat.ActionStatus,
sub.RoleID, role.Role, role.RoleDescription, 
sub.ModuleAttributeID, att.Attribute as Module,
attdep.Attribute as Department
FROM stng.Admin_Request req
INNER JOIN stng.Admin_Request_Type typ ON req.AccessTypeID = typ.AccessTypeID 
LEFT JOIN stng.VV_Admin_Users usr ON usr.EmployeeID = req.RequestorEID
LEFT JOIN stng.Admin_SubRequest sub ON req.RequestID = sub.RequestID
LEFT JOIN stng.Admin_SubRequestStatus stat ON sub.StatusID = stat.StatusID
LEFT JOIN stng.Admin_Role role ON sub.RoleID = role.UniqueID
LEFT JOIN stng.Admin_Attribute att ON sub.ModuleAttributeID = att.UniqueID
LEFT JOIN stng.Admin_DepartmentModule depmod ON depmod.AttributeModID = sub.ModuleAttributeID
LEFT JOIN stng.Admin_Attribute attdep ON depmod.AttributeDeptID = attdep.UniqueID

GO


