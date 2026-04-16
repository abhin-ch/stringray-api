/****** Object:  View [stng].[VV_Admin_Request_Status]    Script Date: 10/21/2024 12:48:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [stng].[VV_Admin_Request_Status]
AS

WITH RequestStatuses AS
(SELECT
    ar.RequestID as UniqueID,
	--COUNT(*) as NumSubRequests,
    CASE
        WHEN COUNT(*) = SUM(CASE WHEN s.ActionStatus = 'Approved' THEN 1 ELSE 0 END) THEN 'Approved'
        WHEN SUM(CASE WHEN s.ActionStatus = 'Approved' THEN 1 ELSE 0 END) > 0 THEN 'Partially Approved'
        WHEN COUNT(*) = SUM(CASE WHEN s.ActionStatus = 'Rejected' THEN 1 ELSE 0 END) THEN 'Rejected'
        ELSE 'In Review'
    END AS [Status]
FROM stng.Admin_Request ar
JOIN
    stng.Admin_SubRequest sar ON ar.RequestID = sar.RequestID
JOIN
    stng.Admin_SubRequestStatus s ON sar.StatusID = s.StatusID
GROUP BY
	ar.RequestID)
SELECT 
	rs.UniqueID, 
	rs.[Status],
	--NumSubRequests,
	ar.RequestorEID as EmployeeID,
	ar.RAD as CreatedDate,
	u.EmpName as EmpName,
	rt.TypeName as RequestType,
	u2.EmpName as MimicOf,
	ar.ReasonGiven as [Description],
	aa.Attribute as OriginalModule
from RequestStatuses rs
LEFT JOIN stng.Admin_Request ar on ar.RequestID = rs.UniqueID
LEFT JOIN stng.VV_Admin_Users u on u.EmployeeID = ar.RequestorEID
LEFT JOIN stng.Admin_Request_Type rt on rt.AccessTypeID = ar.AccessTypeID
LEFT JOIN stng.VV_Admin_Users u2 on u2.EmployeeID = ar.MimicOfEID
LEFT JOIN stng.Admin_Attribute aa on ar.OriginalModuleID = aa.UniqueID

GO


