CREATE OR ALTER view [stng].[VV_General_Organization_Section] as
select G.UniqueID,Section, SM, SMName,G.MPLDiscipline PrimaryDiscipline
from stng.VV_General_OrganizationView G
where Section is not null