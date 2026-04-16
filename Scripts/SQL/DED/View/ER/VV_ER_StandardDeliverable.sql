CREATE view [stng].[VV_ER_StandardDeliverable] as 
with blendedrate as
(
	select max(ConstantNum) as BlendedRate
	from stng.ER_Constant
	where ConstantName = 'BlendedRate'
)

select x.*, y.BlendedRate*cast(x.StandardHours as float) as StandardCost
from
(
	select a.UniqueID, a.Deliverable, case when sum(b.StandardHours) is null then 0 else sum(b.StandardHours) end as StandardHours, b.ActivityType
	from stng.ER_StandardDeliverable as a
	left join stng.ER_StandardDeliverableActivity as b on a.UniqueID = b.DeliverableID and b.Active = 1
	where a.Active = 1
	group by a.UniqueID, a.Deliverable, b.ActivityType
) as x, blendedrate as y
GO


