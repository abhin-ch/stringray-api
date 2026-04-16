create view stng.VV_Plugin_DownloadManifest_Task as
with latestmanifest as
(
	select top 1 *
	from stng.Plugin_DownloadManifest
	order by RAD desc
)

select a.DownloadManifestID, c.TaskType, b.TaskOrder, b.ProgressWeight, b.Instruction, b.Context1, b.Context2, b.Context3
from latestmanifest as a
inner join stng.Plugin_DownloadManifest_Task as b on a.DownloadManifestID = b.DownloadManifestID
inner join stng.Plugin_DownloadManifest_TaskType as c on b.TaskTypeID = c.TaskTypeID;