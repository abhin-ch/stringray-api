CREATE OR ALTER VIEW [stng].[VV_TOQ_VendorSubmission]
AS
	Select * FROM stng.VV_TOQ_VendorSubmissionIncludeRemoved
	WHERE DeleteRecord = 0

GO