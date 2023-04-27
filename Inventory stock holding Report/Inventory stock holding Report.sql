SELECT 
distinct 
inv.ITEM_NUMBER,
inv.ORGANIZATION_NAME,
inv.ORGANIZATION_CODE,
inv.DESCRIPTION,inv.TRX_QTY  quantity_onhand,
ECT.CATEGORY_NAME,
inv.SUBINVENTORY_CODE,
(select TO_CHAR(EXPIRATION_DATE, 'MM-DD-YYYY')  from INV_LOT_NUMBERS where 1=1
AND inventory_item_id = ITEMCATS.inventory_item_id
AND ITEMS.inventory_item_id = inventory_item_id
AND inventory_item_id = inv.inventory_item_id
and rownum<2)expiration_date,
(select UNIT_COST_NEW  from cst_perpavg_cost where 1=1
AND inventory_item_id = ITEMCATS.inventory_item_id
AND ITEMS.inventory_item_id = inventory_item_id
AND inventory_item_id = inv.inventory_item_id
and rownum<2)unit_cost_onhand
FROM egp_item_cat_assignments ITEMCATS,
egp_category_sets_b CATSETS,
egp_system_items_b ITEMS,
inv_org_parameters ORG,
EGP_CATEGORIES_TL ECT,
(select ESI.ITEM_NUMBER ,
  IODV.ORGANIZATION_NAME,
  ESI.DESCRIPTION ,
  IOP.ORGANIZATION_CODE ,
  SUM(IOQD.TRANSACTION_QUANTITY) TRX_QTY,
  IOQD.SUBINVENTORY_CODE 
  ,IOQD.INVENTORY_ITEM_ID
  ,ESI.ORGANIZATION_ID   
from INV_ONHAND_QUANTITIES_DETAIL IOQD ,
  EGP_SYSTEM_ITEMS ESI ,
  INV_ORG_PARAMETERS IOP ,
  INV_ORGANIZATION_DEFINITIONS_V IODV,
  INV_UNITS_OF_MEASURE_TL UOMT ,
  INV_UNITS_OF_MEASURE_B UOMB,
  INV_ITEM_LOCATIONS IIL
where 1                     = 1
and IODV.ORGANIZATION_ID    =IOP.ORGANIZATION_ID
and IOQD.INVENTORY_ITEM_ID  = ESI.INVENTORY_ITEM_ID
and IOQD.ORGANIZATION_ID    = ESI.ORGANIZATION_ID
and ESI.ORGANIZATION_ID     = IOP.ORGANIZATION_ID
and UOMT.UNIT_OF_MEASURE_ID = UOMB.UNIT_OF_MEASURE_ID
and UOMB.UOM_CODE           = IOQD.TRANSACTION_UOM_CODE
and IOQD.ORGANIZATION_ID    = IIL.ORGANIZATION_ID(+)
and IOQD.SUBINVENTORY_CODE  = IIL.SUBINVENTORY_CODE(+)
and IOQD.LOCATOR_ID         =IIL.INVENTORY_LOCATION_ID(+)
---AND IODV.organization_name=('Main Store')
group by ESI.ITEM_NUMBER ,
  IODV.ORGANIZATION_NAME,
  ESI.DESCRIPTION ,
  IOP.ORGANIZATION_CODE ,
  IOQD.SUBINVENTORY_CODE
  ,IOQD.INVENTORY_ITEM_ID
  ,ESI.ORGANIZATION_ID 
order by 1,2) inv
WHERE CATSETS.category_set_id = ITEMCATS.category_set_id
AND ITEMS.inventory_item_id = ITEMCATS.inventory_item_id
AND ITEMS.inventory_item_id = inv.inventory_item_id
AND ORG.organization_id = ITEMS.organization_id
and inv.inventory_item_id=ITEMS.inventory_item_id
AND ITEMCATS.category_id=ECT.category_id
and ECT.CATEGORY_NAME  NOT LIKE '%Cost%'
---and inv.ORGANIZATION_NAME=nvl(:p_organization_name,inv.ORGANIZATION_NAME)
 --- and  inv.SUBINVENTORY_CODE=nvl(:p_SUBINVENTORY_CODE,inv.SUBINVENTORY_CODE)
AND ( ( CATSETS.control_level = 1 AND ITEMCATS.organization_id = ORG.master_organization_id )
OR ( CATSETS.control_level = 2 AND ITEMCATS.organization_id = ORG.organization_id ) )