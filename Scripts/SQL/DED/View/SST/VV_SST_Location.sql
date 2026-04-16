CREATE OR ALTER view [stng].[VV_SST_Location] as
with Ranked as
(
select c.UniqueID, a.UniqueID as SSTID, b.LOCATION, b.SITEID, b.LOCATIONDESCRIPTION as LocationDesc, b.USI, c.CRIT_CAT, b.SPVFLAG as SPV,
b.RSE, b.RCE, b.RDE, c.SYSTEMDESC as USIDesc, b.STRATEGY_OWNER, d.JPNUM,
ROW_NUMBER() OVER ( PARTITION BY a.UniqueID, b.LOCATION ORDER BY c.UniqueID ) AS rn
from stng.SST_Main as a
inner join stngetl.General_PM d on d.PMNUM = a.PM
inner join stngetl.General_JobPlanWorkAsset as b on b.JOBPLAN = d.JPNUM
inner join stngetl.IQT_MEL as c on b.LOCATION = c.LOCATION and b.SITEID = c.SITEID
--where b.USI <> '20000A' and b.USI <> '20000B'--excluding 'Bruce A' and 'Bruce B' general locations
)
select * from Ranked where rn = 1



GO


