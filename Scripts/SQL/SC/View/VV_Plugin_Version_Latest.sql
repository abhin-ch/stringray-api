--create view stng.VV_Plugin_Version_Latest as
with latestversion as 
(
	select a.VersionID, a.BLOBName, a.RAD as VersionDate
	from stng.Plugin_Version as a
	inner join
	(
		select max(RAD) as latestDate
		from stng.Plugin_Version
		group by VersionID 
	) as b on a.RAD = b.latestDate
)

select *
from latestversion