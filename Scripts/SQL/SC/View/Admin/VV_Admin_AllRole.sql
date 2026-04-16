/****** Object:  View [stng].[VV_Admin_AllRole]    Script Date: 10/21/2024 12:22:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE view [stng].[VV_Admin_AllRole] as
select r.Deleted, r.DeletedBy, r.DeletedOn, r.LUB, r.LUD, r.RAB, r.RAD, r.Role, r.RoleDescription, r.UniqueID
--, att.Attribute, att.AttributeType
from stng.Admin_Role r
--left join stng.VV_Admin_RoleAttribute att on att.RoleID = r.UniqueID
where r.Deleted = 0

GO


