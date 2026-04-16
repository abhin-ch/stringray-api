ALTER VIEW [stng].[VV_PR_APTItem]
AS
SELECT DISTINCT 
a.Item, b.APCount, c.MANUFACTURER, c.MODEL, c.ITEMDESC, d.MaxStage, h.[Status] as MaxStageC
--, e.CATID_STATUS
, f.HasDescription, f.HasJustification
--, g.Score as OVRScore
FROM            stng.PR_APR_Item AS a LEFT OUTER JOIN
(SELECT        Item, COUNT(APID) AS APCount
FROM            stng.PR_APT_Main
GROUP BY Item) AS b ON a.Item = b.Item LEFT OUTER JOIN
stngetl.General_Item AS c ON a.Item = c.Item LEFT OUTER JOIN
(SELECT        Item, MAX(CurrentBPStatus) AS MaxStage
FROM            stng.PR_APT_Main
GROUP BY Item) AS d ON a.Item = d.Item LEFT OUTER JOIN
--dems.VV_0348_ObsolDBCATID AS e ON a.CATID = e.CATID LEFT OUTER JOIN
(SELECT        Item, CAST(MAX(CASE WHEN description IS NULL OR description = '' THEN 0 ELSE 1 END) AS bit) AS HasDescription, CAST(MAX(CASE WHEN justification IS NULL OR justification = '' 
                            THEN 0 ELSE 1 END) AS bit) AS HasJustification
FROM            stng.PR_APT_Main
GROUP BY Item) AS f ON a.Item = f.Item
--left join dems.VV_0579_OVRScores as g on a.CATID = g.Item
LEFT OUTER JOIN stng.PR_APT_Status AS h ON d.MaxStage = h.UniqueID 
GO


