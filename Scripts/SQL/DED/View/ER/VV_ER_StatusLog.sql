CREATE view [stng].[VV_ER_StatusLog] as
select a.UniqueID, a.ERID, 
a.Comment,
a.StatusID, b.StatusShort, b.[Status],
a.RAD as StatusDate,
concat(c.FirstName, ' ', c.LastName) as StatusAddedBy
from stng.ER_StatusLog as a
inner join stng.ER_Status as b on a.StatusID = b.UniqueID
inner join stng.Admin_User as c on a.RAB = c.EmployeeID