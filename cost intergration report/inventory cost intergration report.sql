select imt.inventory_item_id                      ,
        d.cost_organization_id AS cost_org_id      ,
        iop.organization_code  AS inv_org_code     ,
        iop.organization_name  AS inv_org_name     ,
        --inv.cost_org_code                          ,
		(select inv.cost_org_code from cst_cost_orgs_v inv where inv.cost_org_id= d.cost_organization_id ) cost_org_code,
		(select inv.cost_org_name from cst_cost_orgs_v inv where inv.cost_org_id= d.cost_organization_id ) cost_org_name,
        --inv.cost_org_name                          ,
        imt.subinventory_code                       AS subinventory      ,
        imt.transaction_reference                   AS insta_bill_number ,
       -- imt.external_sys_txn_reference              AS insta_charge_id   ,
	   (select imt1.external_sys_txn_reference  from inv_material_txns imt1 where imt1.transaction_id =imt.transaction_id ) as insta_charge_id,
        --to_char(imt.transaction_date, 'DD-MM-YYYY') AS transaction_date  ,
		imt.transaction_date transaction_date,
        e.txn_source_ref_doc_number                 AS reference_document,
        --esi.item_number 
        --esi.description 		,
		(select item_number from egp_system_items egp where egp.inventory_item_id=imt.inventory_item_id and rownum=1 ) item_number,
		(select description from egp_system_items egp  where egp.inventory_item_id=imt.inventory_item_id and rownum=1 ) description,		
        --ecs.catalog_code AS catalog                                      ,
		(select ecs.catalog_code from egp_category_sets_b ecs,egp_item_categories eic  where 1=1
		AND     ecs.category_set_id     = eic.category_set_id
AND     UPPER(ecs.catalog_code) ='COSTING'
and eic.inventory_item_id = imt.inventory_item_id
AND  eic.organization_id          = iop.organization_id 
		) as catalog,
			(select ec.category_name from egp_category_sets_b ecs,egp_item_categories eic,egp_categories_vl ec
			where 1=1
		AND     ecs.category_set_id     = eic.category_set_id
		and     eic.CATEGORY_ID             =ec.CATEGORY_ID
AND     UPPER(ecs.catalog_code) ='COSTING'
and eic.inventory_item_id = imt.inventory_item_id
AND  eic.organization_id          = iop.organization_id 
		) as category,
        --ec.category_name AS category                                     ,
        imt.transaction_quantity                                         ,
        uom.unit_of_measure                                              ,
        round(cst.unit_cost, 2) AS unit_cost                             ,
        c.currency_code                                                  ,
        r.transaction_type_name                                          ,
        imt.transaction_id                                               ,
		--SUM(nvl(c.accounted_dr,0)) - SUM(nvl(c.accounted_cr,0))                                                                                                                  AS accounted_amount    ,
        ( gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 ) AS code_combination    ,
        gcc.segment4                                                                                                                                               AS account   ,
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment1
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '%KAREN HOSPTIAL'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT1' ))||'-'||
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment2
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '% xxx'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT2' ))||'-'||
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment3
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '%xxx'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT3' ))||'-'||
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment4
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '%xxxxx'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT4' ))||'-'||
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment5
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '%xxxxx'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT5' ))||'-'||
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment6
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '%xxxxx'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT6' ))||'-'||
        (
                select distinct
                        al.DESCRIPTION
                from
                        fnd_flex_values_vl al
                where
                        al.flex_value     =gcc.segment7
                and     al.ENABLED_FLAG   ='Y'
                and     al.VALUE_CATEGORY like '%Kxxxxx'
                AND     al.FLEX_VALUE_SET_ID IN
                        (
                                SELECT
                                        FLEX_VALUE_SET_ID
                                FROM
                                        FND_ID_FLEX_SEGMENTS
                                WHERE
                                        application_id         = 101
                                AND     id_flex_code           = 'GL#'
                                AND     enabled_flag           = 'Y'
                                AND     application_column_name='SEGMENT7' ))  as cc_description,
								--to_char(c.accounting_date, 'MM/DD/YYYY') accounting_date,
								c.accounting_date,
								(select max(period_name) from  gl_periods where c.accounting_date between trunc(START_DATE) and trunc(END_DATE)) period_name,
SUM(nvl(c.accounted_dr,0)) - SUM(nvl(c.accounted_cr,0))                                                                                                                  AS accounted_amount    ,
SUM(nvl(c.accounted_dr,0)) - SUM(nvl(c.accounted_cr,0))    AS accounted_amount1								
from 	cst_cost_distribution_lines a,
	xla_distribution_links b,
	xla_ae_lines c,
	cst_cost_distributions d,
	cst_transactions e,
	cst_inv_transactions f,
	inv_material_txns imt,
	--egp_system_items_b esi,
	inv_organization_definitions_v iop ,
	inv_transaction_types r  ,
	inv_units_of_measure_vl uom,
	 cst_layer_costs  cst,
	 gl_code_combinations gcc           	
where 	1 = 1 --imt.transaction_type_id = tt.transaction_type_id
--and	imt.inventory_item_id = esi.inventory_item_id
--and	imt.organization_id = esi.organization_id
and	imt.organization_id = iop.organization_id
and imt.source_code ='INSTA'
and imt.transaction_date BETWEEN :P_TRX_FROM_DATE AND :P_TRX_TO_DATE
AND iop.organization_code       =NVL(:P_INV_ORG,iop.organization_code)
and	 b.application_id = 707
and 	a.distribution_line_id = b.source_distribution_id_num_1
and 	b.ae_header_id = c.ae_header_id
and 	b.ae_line_num = c.ae_line_num
and 	a.distribution_id = d.distribution_id
and 	d.transaction_id = e.transaction_id
and 	e.cst_inv_transaction_id = f.cst_inv_transaction_id
and 	f.external_system_ref_id  = imt.transaction_id
and f.external_system_reference = 'FUSION'
AND     a.accounting_line_type      ='OFFSET'
and     imt.transaction_type_id     = r.transaction_type_id
and     imt.transaction_uom     =uom.uom_code
and     d.distribution_id       =cst.distribution_id
and     c.code_combination_id   =gcc.code_combination_id
--AND     d.cost_organization_id      =inv.cost_org_id
and     c.accounting_date between nvl(
        (
                select
                        min(start_date)
                from
                        gl_periods
                where
                        period_name = :P_PERIOD_NAME ) , c.accounting_date)
and     nvl(
        (
                select
                        max(end_date)
                from
                        gl_periods
                where
                        period_name = :P_PERIOD_NAME ) , c.accounting_date)
						
group by
        imt.inventory_item_id                       ,
        d.cost_organization_id                      ,
        iop.organization_code                       ,
        iop.organization_name                       ,
        --inv.cost_org_code                           ,
        --inv.cost_org_name                           ,
        imt.subinventory_code                       ,
        imt.transaction_reference                   ,
        --imt.external_sys_txn_reference              ,
        --to_char(imt.transaction_date, 'DD-MM-YYYY') ,
		imt.transaction_date,
        e.txn_source_ref_doc_number                 ,
        --esi.item_number                             ,
        --esi.description                             ,
        --ecs.catalog_code                            ,
        --ec.category_name                            ,
        imt.transaction_quantity                    ,
        uom.unit_of_measure                         ,
        round(cst.unit_cost, 2)                     ,
        c.currency_code                             ,
        r.transaction_type_name                     ,
        imt.transaction_id                          ,
        -- gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7,
        gcc.segment1 ,
        gcc.segment2 ,
        gcc.segment3 ,
        gcc.segment4 ,
        gcc.segment5 ,
        gcc.segment6 ,
        gcc.segment7,
		c.accounting_date,iop.organization_id