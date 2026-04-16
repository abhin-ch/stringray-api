/****** Object:  View [stng].[VV_TOQLite_Main]    Script Date: 11/19/2025 9:22:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [stng].[VV_TOQLite_Main]
AS
WITH currentstatusdates AS (
	SELECT a.TOQLiteID
	, MAX(a.RAD) AS currentstatusdate
	FROM stng.TOQLite_StatusLog AS a 
	INNER JOIN stng.TOQLite_Status AS b ON a.StatusID = b.UniqueID
	GROUP BY a.TOQLiteID
), 
ers AS (
	SELECT a.ERID as UniqueID
	, a.ER
	, b.ERTitle as ERDesc
	, b.Outage
	, c.Status AS ERStatus
      FROM stng.VV_ER_Main AS a 
	  LEFT JOIN stngetl.ER_SupportInfo AS b ON a.ER = b.ER 
	  INNER JOIN stng.ER_Status AS c ON a.CurrentStatusID = c.[UniqueID]
),
vendorSubmissionInitiator as (
	SELECT TOQLiteID, RABC
	FROM (
		SELECT TOQLiteID, RABC
		,ROW_NUMBER() OVER (PARTITION BY TOQLiteID ORDER BY b.RAD DESC) as rn
		FROM stng.TOQLite_Main as a
		LEFT JOIN stng.VV_TOQLite_Status as b on a.UniqueID = b.TOQLiteID
		LEFT JOIN stng.TOQLite_Status as c on a.CurrentStatus = c.UniqueID
		WHERE (b.StatusShort = 'AV' or b.StatusShort = 'RV') and c.StatusShort in ('AV', 'AA', 'AB', 'RV', 'RB')
	) as recentVendorSubmission
	WHERE rn = 1
),
estimateCost as (
	SELECT TOQLiteID, sum(DeliverableCost) as EstimateCost
	FROM [stng].[VV_TOQLite_BPDeliverable]
	group by TOQLiteID
),
vendorCost as (
	SELECT TOQLiteID, sum(DeliverableCost) as VendorCost
	FROM [stng].[VV_TOQLite_VendorDeliverable]
	group by TOQLiteID
)

SELECT 
a.UniqueID
, a.ERID
, a.CurrentStatus
, b.currentstatusdate
, h.Status AS CurrentStatusC
, h.StatusShort AS CurrentStatusShort
, a.ERInstance
, a.Section
, a.RAD
, f.Section AS SectionDescription
, f.SMName AS SectionManager
, c.ER
, c.ERDesc
, c.Outage
, c.ERStatus
, e.PROJECTID AS ProjectID
, e.PROJECTNAME AS ProjectTitle
, a.VendorResponseDate
, CASE WHEN a.ERLevelDates = 1 THEN a.PCT50Date END AS PCT50Date
, CASE WHEN a.ERLevelDates = 1 THEN a.PCT90Date END AS PCT90Date
, a.VendorNotes
, a.Scope
, i.AttributeID as VendorID
, i.Attribute as Vendor
, g.VendorTOQID
, g.Revision as TOQRevision
, a.ERLevelDates
, j.RABC as VendorSubmissionInitiator
, k.EstimateCost
, l.VendorCost
, a.Revision as TDSRevision

FROM stng.TOQLite_Main AS a 
INNER JOIN currentstatusdates AS b ON a.UniqueID = b.TOQLiteID 
INNER JOIN ers AS c ON a.ERID = c.UniqueID 
--LEFT OUTER JOIN stng.VV_Admin_AllAttribute AS d ON a.VendorID = d.AttributeID and AttributeType = 'Vendor'
left join stng.[VV_Admin_AllVendors] as i on a.VendorID = i.AttributeID
LEFT OUTER JOIN stng.MPL AS e ON a.ProjectNo = e.PROJECTID
LEFT OUTER JOIN stng.[VV_ER_SectionManger] AS f ON a.Section = f.UniqueID
LEFT OUTER JOIN stng.TOQLite_TOQ_Temp AS g ON a.TOQID = g.UniqueID 
INNER JOIN stng.TOQLite_Status AS h ON a.CurrentStatus = h.UniqueID
LEFT JOIN vendorSubmissionInitiator as j on a.UniqueID = j.TOQLiteID
LEFT JOIN estimateCost as k on a.UniqueID = k.TOQLiteID
LEFT JOIN vendorCost as l on a.UniqueID = l.TOQLiteID

GO


