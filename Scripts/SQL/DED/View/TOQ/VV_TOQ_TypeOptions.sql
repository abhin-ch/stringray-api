CREATE OR ALTER view [stng].[VV_TOQ_TypeOptions] 
as
select a.TypeID TOQTypeID, a.Type TOQType, a.TypeLong TOQTypeLong, a.Description TOQTypeDescription, a.ParentType, 
c.TypeID as ChildTOQTypeID, c.Type as ChildTOQType, 
c.TypeLong  as ChildTOQTypeLong, c.Description as ChildTOQTypeDescription
from stng.VV_TOQ_Types as a
left join stng.TOQ_Type_ValidChildren as b on a.TypeID = b.TOQTypeID
left join stng.VV_TOQ_Types as c on b.TOQTypeChildrenID = c.TypeID