Create or Alter view [stng].[VV_CARLA_ItemWO] as
(
	
				SELECT   [WONUM], [ITEM],[STATION]  ,[ITEMDESC] ,[STATUS] ,[MANUFACTURER], [PROJECTID], concat( b.UniqueID,Concat('_' ,a.UniqueID)) as UniqueID,PROCUREMENTCLASS
					 FROM [stngetl].[General_WODemand] a
						  left join [stngetl].[General_Item] b on
						  a.itemnum=b.item 
)