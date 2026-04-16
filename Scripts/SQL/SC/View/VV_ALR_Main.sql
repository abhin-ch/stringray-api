CREATE OR ALTER VIEW [stng].[VV_ALR_Main]
AS
SELECT 
	  'ITEM' AS Type,
	  'I-' + RIGHT('000000' +  CAST(ISSIDC AS VARCHAR(50)),6) AS SMSIDC,
	   ISSIDC AS SMSID,
	   ItemNum AS Number,
	   Description,
	   MaximoStatus,	  
	   IStatus AS SMSStatus,
	   ItemID AS LinkToMaximo,
	   IRAD AS RAD,
	   IRABC AS RABC,	  
	   ILUD AS LUD,
	   SiteID,
	   OutageC,
	   OutageC2,
	   Crew,
	   TWeek,
	   CommodityGroup,	
	   CricSparesC,
	   NULL AS SubType, /*Subtype*/
	   NULL AS Activity, /*Activity*/
	   DEC,
	   DeliverableC,
	   UserID,
	   AStatus,
	   CMS05,
	   CMS18,
	   NULL AS CMS16,
	   Comment,
	   PartStatus,
	   LocationCat,
	   WONUMCat,
	   TWeekCat,
	   PartStatusWithT,
	   ProjectID,
	   WOA,
	   BPScheduleBacklog


FROM stng.VV_ALR_ISSMain
UNION
SELECT 
	  'CR' AS Type,
	  'C-' + RIGHT('000000' +  CAST(CRIDC AS VARCHAR(50)),6) AS SMSIDC,
	   CRIDC AS SMSID,
	   CRNum AS Number,
	   Description,
	   MaximoStatus,
	   CRStatus AS CRStatus,
	   TicketUID AS LinkToMaximo,
	   CRAD AS RAD,
	   CRABC AS RABC,
	   CLUD AS LUD,
	   SiteID,
	   OutageC,
	   OutageC2,
	   Crew,
	   TWeek,
	   CommodityGroup, 
	   NULL, /*Critical Spares*/
	   CRType AS SubType,	  
	   Activity,	 
	   DEC,
	   DeliverableC,
	   UserID,
	   AStatus,
	   NULL,
	   NULL,
	   CMS16,
	   Comment,
	   NULL /*Part Status*/,
	   LocationCat,
	   WONUMCat,
	   TWeekCat,
	   NULL,
	   ProjectID,
	   WOA,
	   BPScheduleBacklog
	   
FROM stng.VV_ALR_CRSSMain
GO