CREATE OR ALTER VIEW stng.VV_TOQ_VendorStatusLog
AS 
SELECT A.*,C.Label Status,U.EmpName,B.TOQMainID FROM stng.TOQ_VendorStatusLog A
INNER JOIN stng.TOQ_VendorAssigned B ON B.UniqueID = A.VendorAssignedID
INNER JOIN stng.VV_TOQ_VendorSubmissionStatus C ON C.StatusID = A.StatusID
INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = A.CreatedBy