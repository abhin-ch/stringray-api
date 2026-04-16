ALTER PROCEDURE [stng].[SP_IQT_CRUD] (
									@Operation TINYINT,
									@CurrentUser VARCHAR(50) = null,

									@Wildcard bit = 0,
									@AnyWords bit = 0,
									@GetDistinctItems bit = 0,

									@ITEMNUM varchar(15) = null,
									@TopItem varchar(15) = null,
									@Location varchar(150) = null,
									@SiteID varchar(10) = null,
									@ITEMDESC varchar(max) = null,
									@WONUM varchar(50) = null,

									@ItemList stng.TYPE_IQT_ItemList READONLY,

									@PassportDocs bit = 0,
									@CSType varchar(50) = null,

									@UID int = null,
									@WorkModuleRole varchar(50) = null,

									@Error int = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN
	    BEGIN TRY

		if @Operation = 1 --Search by Item
			begin

				select distinct a.item as itemnum, a.ItemDesc as ItemDesc,
				a.model, a.PARTNUMBER, a.MANUFACTURER, a.STATUS as MaximoStatus, b.*,
				stng.FN_General_MaximoLink('Item',a.ITEMID) as MaximoLink
				from stngetl.General_Item as a
				left join stngetl.General_CatalogMain as b on a.Item = b.Item
				inner join @ItemList as c on a.Item = c.ITEMNUM
				order by a.Item asc;

			end
		
		else if @Operation = 2 --Search by Location
			begin

				if @Wildcard = 1
					begin

						select distinct
						--concat(a.location, '-', a.SITEID) as [site-location],
						--a.LOCATION, a.SITEID as siteid,
						a.ParentItem as itemnum, b.ItemDesc,
						b.MODEL, b.PARTNUMBER, b.MANUFACTURER, b.STATUS as MaximoStatus, c.*,
						stng.FN_General_MaximoLink('Item',b.ITEMID) as MaximoLink
						from stng.VV_IQT_MEL as a
						inner join stngetl.General_Item as b on a.ParentItem = b.Item
						left join stngetl.General_CatalogMain as c on a.ParentItem = c.Item
						where a.location like '%' + @Location + '%' and (a.siteid = @SiteID or @SiteID is null)
						option(optimize for (@Location unknown, @SiteID unknown));

					end

				else
					begin

						select distinct
						--concat(a.location, '-', a.SITEID) as [site-location],
						--a.LOCATION, a.SITEID as siteid, 
						a.ParentItem as itemnum, b.ItemDesc,
						b.MODEL, b.PARTNUMBER, b.MANUFACTURER, b.STATUS as MaximoStatus, c.*,
						stng.FN_General_MaximoLink('Item',b.ITEMID) as MaximoLink
						from stng.VV_IQT_MEL as a
						inner join stngetl.General_Item as b on a.ParentItem = b.Item
						left join stngetl.General_CatalogMain as c on a.ParentItem = c.Item
						where a.location = @Location and (a.siteid = @SiteID or @SiteID is null)
						option(optimize for (@Location unknown, @SiteID unknown));

					end		


			end

		else if @Operation = 3 --Docs
			begin

				if @CSType = 'SDAR'
					begin 

						select *
						from stng.FN_IQT_Doc_SDAR(@ITEMNUM);

					end

				else
					begin

						select *
						from stng.FN_IQT_Doc(@ITEMNUM,@CSType);

					end
							
			end

		else if @Operation = 4 --ECs
			begin
						
				select *
				from stng.VV_IQT_EC
				where Itemnum = @ITEMNUM
				order by STATUSDATE desc, ec asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 5 --JPs
			begin

				select a.*
				,stng.FN_General_MaximoLink('JP', a.JOBPLANID) as linkToMaximo
				from stng.VV_IQT_JPView as a
				where ITEMNUM = @ITEMNUM
				order by jobplan asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 6 --PP POs
			begin 

				with initialquery as
				(
					select distinct PURCHASINGOBJECT, PURCHASINGOBJECTSTATUS, PURCHASINGOBJECTSTATUSDATE, PURCHASINGOBJECTBUYER, 'Maximo' as Origin
					from stng.VV_General_PurchasingObject as a
					where itemnum = @ITEMNUM and PURCHASINGOBJECTTYPE = N'PO'
				)

				select *
				from
				(
					select PURCHASINGOBJECT, PURCHASINGOBJECTSTATUS, PURCHASINGOBJECTSTATUSDATE, PURCHASINGOBJECTBUYER, Origin
					from initialquery
					union
					select distinct a.PURCHASE_ORDER_NBR as PurchasingObject, a.PO_STATUS as PurchasingObjectStatus,
					a.PO_STATUS_DATE as PurchasingObjectStatusDate, a.POBUYER as PurchasingObjectBuyer, 'Passport' as Origin
					from stngetl.General_PassportPO as a
					left join initialquery as b on a.PURCHASE_ORDER_NBR = b.PURCHASINGOBJECT
					where a.CATALOG_ID = @ITEMNUM and b.PURCHASINGOBJECT is null
				) as x
				order by x.PURCHASINGOBJECTSTATUSDATE desc, x.PURCHASINGOBJECT asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 7 --PRs
			begin

				select *
				from
				(

					select distinct PURCHASINGOBJECT, PURCHASINGOBJECTSTATUS, PURCHASINGOBJECTSTATUSDATE, PURCHASINGOBJECTBUYER, 'Maximo' as Origin
					from stng.VV_General_PurchasingObject as a
					where Itemnum = @ITEMNUM and PURCHASINGOBJECTTYPE = N'PR'
					union
					select distinct PR as PurchasingObject, PRSTATUS as PurchasingObjectStatus,
					PR_STATUS_DATE as PurchasingObjectStatusDate, REQUESTEDBY as PurchasingObjectBuyer, 'Passport' as Origin
					from stngetl.General_PassportPR
					where CATALOG_ID = @ITEMNUM
				) as x
				order by x.PURCHASINGOBJECTSTATUSDATE desc, x.PURCHASINGOBJECT asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 8 --RFQs
			begin
						
				select *
				from
				(
					select distinct PURCHASINGOBJECT, PURCHASINGOBJECTSTATUS, PURCHASINGOBJECTSTATUSDATE, PURCHASINGOBJECTBUYER, 'Maximo' as Origin
					from stng.VV_General_PurchasingObject as a
					where Itemnum = @ITEMNUM and PURCHASINGOBJECTTYPE = N'RFQ'
					union
					select distinct RFQ_NUMBER as PurchasingObject, RFQ_STATUS as PurchasingObjectStatus,
					RFQ_STATUS_DATE as PurchasingObjectStatusDate, RFQBUYER as PurchasingObjectBuyer, 'Passport' as Origin
					from stngetl.General_PassportRFQ
					where CATALOG_ID = @ITEMNUM
				) as x
				order by x.PURCHASINGOBJECTSTATUSDATE desc, x.PURCHASINGOBJECT asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 9 --CRs
			begin

				select Origin, CR, CRCLASS, CRDESC, CRSTATUS, CRSTATUSDATE, MaximoLink
				from stng.VV_IQT_CRView
				where itemnum = @ITEMNUM
				order by CRSTATUSDATE desc, CR asc 
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 10 --BOM Dropdown
			begin

				select distinct TopItem
				from stngetl.General_ItemHierarchy
				where ITEMNUM = @ITEMNUM
				order by TopItem asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 11 --PP Docs
			begin

				select *
				from stng.VV_IQT_PassportCATIDDoc
				where catalog_id = @ITEMNUM
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 12 --IQT MEL
			begin

				select distinct SITEID, LOCATION, status, type, EQUIPMENT_NAME, SPV, CRIT_CAT, REPAIR_STRAT, SafetyClass, EQ, Seismic, MaximoLink
				from stng.VV_IQT_MEL
				where item = @ITEMNUM
				order by location asc, siteid asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 13 --PP AAAs
			begin

				select *
				from stngetl.General_PassportItemAAA
				where CATALOG_ID = @ITEMNUM
				order by Q_LEVEL asc, SUBMISSION_NBR asc, LAST_UPDATED_DATE asc
				option(optimize for (@ITEMNUM unknown));

			end

		else if @Operation = 14 --Search by Item Description
			begin

				if @GetDistinctItems = 1
					begin

						if exists(select 1 from @ItemList)
							begin
				
								select distinct a.item as ITEMNUM
								from stngetl.General_Item as a
								left join stngetl.General_CatalogMain as b on a.item = b.Item
								inner join @ItemList as c on a.item = c.ITEMNUM
								where a.ItemDesc like '%' + @ITEMDESC + '%'
								option(optimize for (@ITEMDESC unknown));

							end

						else
							begin

								select distinct a.item as ITEMNUM
								from stngetl.General_Item as a
								left join stngetl.General_CatalogMain as b on a.item = b.Item
								where a.ItemDesc like '%' + @ITEMDESC + '%' and a.Item is not null
								option(optimize for (@ITEMDESC unknown));

							end


					end

				else 
					begin

						select distinct a.item as itemnum, a.ItemDesc,
						a.model, a.PARTNUMBER, a.MANUFACTURER, a.STATUS as MaximoStatus, b.*,
						stng.FN_General_MaximoLink('Item',a.itemid) as MaximoLink
						from stngetl.General_Item as a
						inner join @ItemList as c on a.item = c.ITEMNUM
						left join stngetl.General_CatalogMain as b on a.item = b.item;

					end

				end 

			else if @Operation = 15 --Historical WOs
				begin

					select *
					from stng.VV_IQT_WO
					where ITEM = @ITEMNUM and (WOSTATUS in ('COMP','CLOSE','CAN') or Origin = 'Passport')
					order by LOCATION asc, SITEID asc
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 16 --Future WOs
				begin

					select *
					from stng.VV_IQT_WO
					where ITEM = @ITEMNUM and WOSTATUS not in ('COMP','CLOSE','CAN') and WOHeaderStatus not in ('COMP','CLOSE','CAN') and Origin <> 'Passport'
					order by LOCATION asc, SITEID asc
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 17 --Usage
				begin
						
					select x.*,
					y.location, y.siteid as locationsiteid,
					case when y.workorderid is not null 
					then stng.FN_General_MaximoLink('WO',y.WORKORDERID) end as MaximoLink
					from
					(
						select distinct 'Maximo' as Origin, [SITEID],[REFWO],[ITEMNUM],[TRANSDATE],[QUANTITYUSED],[Period],[StockoutEvent],[WOTYPE],[SchedulingType]
						from stng.VV_General_WOUsage
						where ITEMNUM = @ITEMNUM 
						union
						select distinct 'Passport' as Origin, a.[SITEID], a.WO as REFWO, a.CATALOG_ID as ITEMNUM,a.TRANSACTIONDATE as TRANSDATE,a.[QTY_ACTUAL] as QUANTITYUSED,
						year(a.TRANSACTIONDATE)*100 + month(a.TRANSACTIONDATE) as Period,
						0 as StockoutEvent, a.WORK_ORDER_TYPE as WOTYPE, a.OUTAGE as SchedulingType
						from stngetl.General_PassportUsage as a
						--left join dems.VV_0527_CSUsage as b on a.CATALOG_ID = b.ITEMNUM and a.WO = b.REFWO
						--where b.REFWO is null
					) as x
					left join stngetl.General_AllWOTask as y on x.REFWO = y.TASK
					where x.itemnum = @ITEMNUM
					order by x.TRANSDATE asc
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 18 --Demand
				begin

						select distinct a.*,
						b.location, b.siteid as locationsiteid,
						case when b.WORKORDERID is not null then stng.FN_General_MaximoLink('WO',b.WORKORDERID) end as MaximoLink
						from stng.VV_General_WODemand as a
						left join stngetl.General_AllWOTask as b on a.WO = b.TASK
						where a.itemnum = @ITEMNUM 
						order by a.StockAfterWO desc
						option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 19 --Search by WO
				begin

					with passport as
					(
						select distinct a.WOHEADER, a.WO as WONUM, b.WOSTATUS, b.WOSTATUSDATE, a.CATALOG_ID as itemnum
						from stngetl.General_PassportUsage  as a
						left join stngetl.General_PassportWO as b on a.WO = b.WO
					),
					unioned as
					(
						select WOHEADER, WONUM, WOSTATUS, WOSTATUSDATE, itemnum
						from passport
						union
						select distinct d.WONUM as WOHEADER, d.TASK as WONUM, d.TASKSTATUS as WOSTATUS, d.TASKSTATUSDATE as WOSTATUSDATE, b.itemnum
						from stng.VV_General_WODemand as b
						inner join stngetl.General_AllWOTask as d on b.WO = d.TASK
					)

					select distinct a.*, b.ItemDesc, b.MODEL, b.PARTNUMBER, b.MANUFACTURER, b.STATUS as MaximoStatus, c.*,
					stng.FN_General_MaximoLink('Item',b.itemid) as MaximoLink
					from unioned as a
					inner join stngetl.General_Item as b on a.itemnum = b.Item
					left join stngetl.General_CatalogMain  as c on a.itemnum = c.Item
					where a.WOHEADER = @WONUM or a.WONUM = @WONUM
					order by a.WOHEADER asc, a.WONUM asc, a.itemnum asc
					option(optimize for (@WONUM unknown));

				end

			else if @Operation = 20 --Passport OLE
				begin

					select eval, DocName, URLName as MaximoLink, DATAID, OLEID
					from stngetl.General_PassportItemOLE
					where itemnum = @ITEMNUM
					order by eval asc, DocName asc
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 21 --Projects
				begin

					select a.*, b.PROJECTNAME, b.[STATUS]
					from stng.VV_IQT_RelatedProjects as a 
					left join stng.mpl as b on a.PROJECTID = b.PROJECTID
					where Itemnum = @ITEMNUM
					order by b.status desc, b.PROJECTNAME desc
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 22 --BOM Children
				begin

					SELECT distinct ITEMPATH as [TopItem-Item], a.*
					FROM [stng].[VV_General_BOMHierarchy] as a
					WHERE TopItem = @ITEMNUM order by ITEMPATH asc
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 23 --Manufactuer Info
				begin

					select distinct * 
					from stngetl.General_CatalogMFR 
					where ITEMNUM = @ITEMNUM
					order by MANUF_STATUS, MANUFACTURERNAME
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 24 --Comments
				begin

					select distinct * 
					from stngetl.General_CatalogComment
					where ITEMNUM = @ITEMNUM
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 25 --CSA
				begin

					SELECT *
					FROM [stng].[VV_CSA_CSP]
					WHERE ITEMNUM = @ITEMNUM
					option(optimize for (@ITEMNUM unknown));

				end

			else if @Operation = 26 --COGNOS 362
				begin


					SELECT distinct a.ITEMNUM,a.SITEID, a.LOCATION, a.VERIFIED, a.MANUFACTURER_CODE as Manufacturer, a.MODEL_NUMBER as Model, a.CRIT_CAT as Criticality, a.SPV, a.SAFETYCLASS, a.REPAIR_STRAT, a.EQ, a.SEISMIC, a.QGROUP
					,stng.FN_General_MaximoLink('Location',c.LOCATIONSID) as LocationMaximoLink
					,stng.FN_General_MaximoLink('Item',d.ITEMID) as ItemMaximoLink 
					from stngetl.IQT_MEL as a
					inner join 
						(	
							select SITEID, LOCATION 
							from stngetl.IQT_MEL
							where ITEMNUM = @ITEMNUM
						) as b on a.SITEID = b.SITEID and a.LOCATION = b.LOCATION
					left join stngetl.General_LocationMapping as c on a.LOCATION = c.LOCATION and a.SITEID = c.SITEID
					left join stngetl.General_Item as d on a.ITEMNUM = d.ITEM
					order by a.LOCATION asc, a.SITEID asc, a.ITEMNUM asc
					option(optimize for (@ITEMNUM unknown))

				end

			else if @Operation = 27 --Demand Forcast
				begin

					select *
					from stng.VV_General_WODemandForecast
					where itemnum = @ITEMNUM

				end

			else if @Operation = 28 --PMs
				begin

					select distinct a.PMNUM, a.ORIGIN, a.PMDESC, a.PMSTATUS,
					a.MaximoLink as linkToMaximo
					from stng.VV_IQT_PM as a
					where Item = @ITEMNUM
					order by PMNUM asc
					option(optimize for (@ITEMNUM unknown));

				end

				

	    END TRY
			
	    BEGIN CATCH
			    SET @Error = ERROR_NUMBER()
			    SET @ErrorDescription = ERROR_MESSAGE()
	    END CATCH
    END
