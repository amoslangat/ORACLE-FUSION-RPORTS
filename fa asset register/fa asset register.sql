with fr as (
select distinct fa_additions_b.asset_id from fa_retirements, fa_additions_b, fa_transaction_headers
where fa_additions_b.asset_id = fa_retirements.asset_id(+)
and fa_additions_b.asset_id = fa_transaction_headers.asset_id
--AND ( fa_transaction_headers.transaction_header_id = fa_retirements.transaction_header_id_in
--                  OR fa_transaction_headers.transaction_header_id = fa_retirements.transaction_header_id_out )
and (
((:p_retirement = 'ALL' )
and fa_transaction_headers.transaction_type_code =  fa_transaction_headers.transaction_type_code
--and fa_additions_b.asset_id = fa_retirements.asset_id(+)
)
)
UNION

select distinct fa_additions_b.asset_id from fa_retirements, fa_additions_b, fa_transaction_headers
where fa_additions_b.asset_id = fa_retirements.asset_id
and fa_additions_b.asset_id = fa_transaction_headers.asset_id
AND ( fa_transaction_headers.transaction_header_id = fa_retirements.transaction_header_id_in
                  OR fa_transaction_headers.transaction_header_id = fa_retirements.transaction_header_id_out )
and (
((:p_retirement = 'RETIRED' )
and fa_transaction_headers.transaction_type_code =  fa_transaction_headers.transaction_type_code
--and fa_additions_b.asset_id = fa_retirements.asset_id(+)
)
)
)
SELECT rownum SL_NO,
ASSET_NUMBER
  ,DESCRIPTION
  ,TAG_NUMBER
  ,Quantity
  ,SERIAL_NUMBER
  ,Major_Category
  ,Minor_Category
  ,Asset_Cost
  ,Deprication_Cost
  ,Net_book_value
           ,Date_Placed_Purchase_Date
            ,to_char(Disposal_Retirment_Date,'DD-MON-YYYY')
      ,Invoice_Number
              ,Invoice_Description
               ,Supplier
  ,Block_Building
, Wing
,Floor
,Room
,Department
from
(select distinct
fab.ASSET_NUMBER ASSET_NUMBER
  ,fat.DESCRIPTION DESCRIPTION
  ,fab.TAG_NUMBER  TAG_NUMBER
  ,fab.CURRENT_UNITS Quantity
  ,fab.SERIAL_NUMBER SERIAL_NUMBER
  ,fcb.SEGMENT1 Major_Category
  ,fcb.SEGMENT2 Minor_Category
  ,fb.ORIGINAL_COST Asset_Cost
  ,fdd.DEPRN_RESERVE Deprication_Cost
  ,(fb.ORIGINAL_COST- fdd.DEPRN_RESERVE)  Net_book_value
           ,to_char(fab.creation_Date, 'DD-MON-YYYY') Date_Placed_Purchase_Date
            ,(select DATE_RETIRED from  FA_RETIREMENTS
where  asset_id =fab.asset_id
             and rownum<2) Disposal_Retirment_Date
      ,(select aia.invoice_num
    from  fa_asset_invoices fai,ap_invoices_all aia
where  fai.invoice_id =aia.invoice_id
and fai.asset_id =fab.asset_id and rownum <2) Invoice_Number
,(select attribute1 from fa_transaction_headers
where 1=1
and transaction_header_id in
(select min(ft.transaction_header_id) from fa_transaction_headers ft
where ft.asset_id = fab.asset_id)) Invoice_Description
               ,(select hp.party_name
    from  fa_asset_invoices fai,poz_suppliers poz ,hz_parties hp
where  fai.PO_VENDOR_ID =poz.vendor_id and hp.party_id = poz.party_id
and fai.asset_id =fab.asset_id and rownum <2) Supplier
  ,(select ffvv.DESCRIPTION
from fnd_flex_value_sets ffvs
,fnd_flex_values_vl ffvv
where ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
and VALUE_CATEGORY = 'Building'
and rownum=1
) Block_Building
,(select ffvv.DESCRIPTION
from fnd_flex_value_sets ffvs
,fnd_flex_values_vl ffvv
where ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
and ffvs.FLEX_VALUE_SET_NAME = 'Wing'
and rownum=1
) Wing
,(select ffvv.DESCRIPTION
  from  fnd_flex_value_sets ffvs
,fnd_flex_values_vl ffvv
where ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
and VALUE_CATEGORY = 'Floor'
and rownum=1
) Floor
,(select ffvv.DESCRIPTION
  from  fnd_flex_value_sets ffvs
,fnd_flex_values_vl ffvv
where ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
and VALUE_CATEGORY = 'Room'
and rownum=1
) Room
,(select ffvv.DESCRIPTION
from fnd_flex_value_sets ffvs
,fnd_flex_values_vl ffvv
where ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
and VALUE_CATEGORY = 'Department'
and rownum=1
) Department
FROM FA_ADDITIONS_B FAB
,fa_categories_b fcb
,fa_additions_tl fat
,fa_books fb
,FA_DEPRN_DETAIL fdd
,fr fr
WHERE 1=1
and fab.ASSET_CATEGORY_ID = fcb.CATEGORY_ID
AND fab.asset_id = fat.asset_id
and fb.asset_id = fab.asset_id
and fdd.asset_id = fab.asset_id
and fb.DATE_INEFFECTIVE is  null
and fdd.creation_date in
(select max(creation_date) from FA_DEPRN_DETAIL
where asset_id = fab.asset_id)
and fb.book_type_code = :P_ASSET_BOOK_TYPE
and fab.creation_date >= :P_FROM_DATE 
and fab.creation_date <= :P_TO_DATE+1 
and fr.asset_id = fab.asset_id
)
order by SL_NO

