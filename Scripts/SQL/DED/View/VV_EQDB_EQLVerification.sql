CREATE view [stng].[VV_EQDB_EQLVerification] as
select case when a.location is not null then a.location else b.location end as location
,case when a.FACILITY is not null then a.FACILITY else b.SITEID end as siteid
,case when a.Unit is not null then a.Unit else b.UnitStation end as unit
,a.LOCATIONSTATUS
,case when a.location is not NULL then 'Yes' else 'No' end as inMaximo
	  ,case when b.LOCATION is not NULL then 'Yes' else 'No' end as inEQIS
	  ,case when b.EQLINDICATOR = 'Y' then 'Yes' else 'No' end as eqlIndicator
 from stngetl.EQDB_IndexInfo as a
 full outer join (SELECT [LOCATION]
      ,[SITEID]
      ,[UNIT]
      ,[EQLINDICATOR]
      ,[UniqueID]
	  ,case when unit = 0 then concat(unit,SUBSTRING(SITEID,2,2)) else unit end as UnitStation
  FROM [stngetl].[EQDB_EQISMain]
  where [COMPONENTTYPE] != 'CABL'
  ) as b on a.location = b.location and a.FACILITY = b.SITEID and a.Unit = b.UnitStation