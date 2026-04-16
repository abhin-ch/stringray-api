CREATE view [stng].[VV_ER_StandardDeliverableActivity] as
with deltotal as 
(
	select b.DeliverableID, case when sum(b.StandardHours) is null then 0 else sum(b.StandardHours) end as DeliverableHoursTotal
	from stng.ER_StandardDeliverable as a
	left join stng.ER_StandardDeliverableActivity as b on a.UniqueID= b.DeliverableID
	where a.Active = 1  and b.Active = 1
	group by b.DeliverableID
),
initialquery as 
(
	select b.UniqueID, a.DeliverableID, a.DeliverableHoursTotal, b.Activity, b.StandardHours, b.SortOrder, b.ActivityType
	from deltotal as a
	left join stng.ER_StandardDeliverableActivity as b on a.DeliverableID = b.DeliverableID
	where b.Active = 1
)

select *,
case when DeliverableHoursTotal = 0 then 0 else StandardHours/DeliverableHoursTotal end as HoursSpread
from initialquery
GO


