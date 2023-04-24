
-- select count(*) from(

SELECT
    "Customer_Number",
   -- party_site_number,
    party_name,
  --  invoice_currency_code,
    --"Credit Limit",
    SUM("Not Due Amount") AS not_due_amount,
    -SUM("CM Amount") AS cm_amount,
    -SUM("CASH Amount") AS cash_amount,
    SUM("0 to 365") AS "0 to 365",
    SUM("366 to 730") AS "366 to 730",
    SUM("731 to 1095") AS "731 to 1095",
    SUM("1096 to 1460") AS "1096 to 1460",
    SUM("More than 1461") AS "More than 1461",
    SUM("1462 to 1825") AS "1462 to 1825",
    SUM("More than 1826") AS "More than 1826",
    SUM(amount_due_original) AS "amount_due_original",
    SUM(amount_adjusted) AS "amount_adjusted",
    SUM("Open_amount_adjusted") AS "Open_amount_adjusted",
    SUM("amount_due_adjusted") AS "amount_due_adjusted",
    SUM(amt_due_remaining) AS "amt_due_remaining",
    SUM(amt_due_remaining_USD) AS "amt_due_remaining_USD"
	,nvl((select sum(TRX_CREDIT_LIMIT) from HZ_CUST_PROFILE_AMTS_F a
where a.CUST_ACCOUNT_ID = CUST_ACCOUNT_ID),0) "Credit Limit"
FROM
(
select "Transaction Type Name",
party_name,
"Customer_Number",
 CUST_ACCOUNT_ID ,
PARTY_SITE_NUMBER,
"SALESREP_ID",
Rep,
Sales,
Email_SM,
Milestone1,
Milestone2,
Milestone3,
Milestone4,
Milestone5,
"Payment Terms",
purchase_order,
gl_date ,
due_date,
total_days,
case when total_days < 1 then amt_due_remaining*exchange_rate end "Not Due Amount",
-1*"CM Amount"*exchange_rate "CM Amount",
-1*"CASH Amount"*exchange_rate "CASH Amount",
case when total_days between 1 and  365 then amt_due_remaining*exchange_rate end "0 to 365",
case when total_days between 366 and  730 then amt_due_remaining*exchange_rate end "366 to 730",
case when total_days between 731 and  1095 then amt_due_remaining*exchange_rate end "731 to 1095",
case when total_days between 1096 and  1460 then amt_due_remaining*exchange_rate end "1096 to 1460",
case when total_days > to_number('1461') then amt_due_remaining*exchange_rate end  "More than 1461",
case when total_days between 1462 and  1825 then amt_due_remaining*exchange_rate end "1462 to 1825",
case when total_days > to_number('1826') then amt_due_remaining*exchange_rate end "More than 1826",
"Transaction Date",
"Transaction Number",
invoice_currency_code,
exchange_rate,
amount_due_original,
amount_adjusted,
(nvl(amount_due_original,'0')+nvl(amount_adjusted,'0')) "Open_amount_adjusted",
(nvl(amount_due_original,'0')+nvl(amount_adjusted,'0'))*exchange_rate "amount_due_adjusted",
nvl(amt_due_remaining,'0') amt_due_remaining,
nvl(amt_due_remaining,'0')*nvl(exchange_rate,1) amt_due_remaining_USD 
from (
Select
RT.NAME "Transaction Type Name",
hp.party_name,
--hc.account_number "Customer_Number",
hp.PARTY_NUMBER "Customer_Number",
hc.CUST_ACCOUNT_ID,
TRUNC(TO_DATE(aps.due_date,'YYYY-MM-DD')) due_date,
hps_bill.PARTY_SITE_NUMBER,
nvl(ra.PRIMARY_RESOURCE_SALESREP_ID,null) "SALESREP_ID",
nvl((Select heb11.Attribute_char1 from
ra_customer_trx_lines_all rl11,
doo_headers_all ha11,
doo_headers_eff_b heb11
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl11.customer_trx_id
AND rl11.interface_line_attribute1 = TO_CHAR(ha11.order_number)
--AND ha2.order_type_code = 'SO'
AND heb11.header_id = ha11.header_id
AND heb11.CONTEXT_CODE = 'Sales'),null)
 Rep,
nvl( (Select 
 LISTAGG(T2.SALES_ORDER, ';') 
 WITHIN GROUP (ORDER BY T2.CUSTOMER_TRX_ID,T2.SALES_ORDER) "Sales"
FROM
(Select DISTINCT RAL.CUSTOMER_TRX_ID, RAL.SALES_ORDER
 FROM RA_CUSTOMER_TRX_LINES_ALL RAL
 WHERE RAL.CUSTOMER_TRX_ID = ra.customer_trx_id)T2 ),null)  Sales,

nvl( (Select heb9.Attribute_char3 from
ra_customer_trx_lines_all rl9,
doo_headers_all ha9,
doo_headers_eff_b heb9
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl9.customer_trx_id
AND rl9.interface_line_attribute1 = TO_CHAR(ha9.order_number)
--AND ha2.order_type_code = 'SO'
AND heb9.header_id = ha9.header_id
AND heb9.CONTEXT_CODE = 'Sales'),null) Email_SM,

nvl( (Select heb1.ATTRIBUTE_NUMBER1 || '% at ' || heb1.ATTRIBUTE_CHAR1 || ', within ' || ATTRIBUTE_CHAR2 from
ra_customer_trx_lines_all rl1,
doo_headers_all ha1,
doo_headers_eff_b heb1 
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl1.customer_trx_id
AND rl1.interface_line_attribute1 = TO_CHAR(ha1.order_number)
--AND ha2.order_type_code = 'SO'
AND heb1.header_id = ha1.header_id
AND heb1.CONTEXT_CODE = 'Billing Stage 1' ),null) Milestone1, 

nvl( (Select heb2.ATTRIBUTE_NUMBER1 || '% at ' || heb2.ATTRIBUTE_CHAR1 || ', within ' || heb2.ATTRIBUTE_CHAR2 from
ra_customer_trx_lines_all rl2,
doo_headers_all ha2,
doo_headers_eff_b heb2 
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl2.customer_trx_id
AND rl2.interface_line_attribute1 = TO_CHAR(ha2.order_number)
--AND ha2.order_type_code = 'SO'
AND heb2.header_id = ha2.header_id
AND heb2.CONTEXT_CODE = 'Billing Stage 2' ),null) Milestone2, 

nvl( (Select heb3.ATTRIBUTE_NUMBER1 || '% at ' || heb3.ATTRIBUTE_CHAR1 || ', within ' || heb3.ATTRIBUTE_CHAR2 from
ra_customer_trx_lines_all rl3,
doo_headers_all ha3,
doo_headers_eff_b heb3 
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl3.customer_trx_id
AND rl3.interface_line_attribute1 = TO_CHAR(ha3.order_number)
--AND ha2.order_type_code = 'SO'
AND heb3.header_id = ha3.header_id
AND heb3.CONTEXT_CODE = 'Billing Stage 3' ),null) Milestone3, 

nvl( (Select heb4.ATTRIBUTE_NUMBER1 || '% at ' || heb4.ATTRIBUTE_CHAR1 || ', within ' || heb4.ATTRIBUTE_CHAR2 from
ra_customer_trx_lines_all rl4,
doo_headers_all ha4,
doo_headers_eff_b heb4 
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl4.customer_trx_id
AND rl4.interface_line_attribute1 = TO_CHAR(ha4.order_number)
--AND ha2.order_type_code = 'SO'
AND heb4.header_id = ha4.header_id
AND heb4.CONTEXT_CODE = 'Billing Stage 4' ),null) Milestone4, 

nvl( (Select heb5.ATTRIBUTE_NUMBER1 || '% at ' || heb5.ATTRIBUTE_CHAR1 || ', within ' || heb5.ATTRIBUTE_CHAR2 from
ra_customer_trx_lines_all rl5,
doo_headers_all ha5,
doo_headers_eff_b heb5 
Where 1=1
AND ROWNUM = 1
AND ra.customer_trx_id = rl5.customer_trx_id
AND rl5.interface_line_attribute1 = TO_CHAR(ha5.order_number)
--AND ha2.order_type_code = 'SO'
AND heb5.header_id = ha5.header_id
AND heb5.CONTEXT_CODE = 'Billing Stage 5' ),null) Milestone5, 
nvl(pt.name,null) "Payment Terms",
TRUNC(TO_DATE(aps.gl_date,'YYYY-MM-DD')) gl_date ,
to_date(trunc(:p_as_of_date)) - aps.due_date total_days, 
nvl(TRUNC(ra.trx_date),null) "Transaction Date",
ra.trx_number "Transaction Number",
nvl(ra.purchase_order,null) purchase_order,
aps.invoice_currency_code,
nvl(aps.exchange_rate,1) exchange_rate,
aps.amount_due_original,
aps.amount_adjusted,
nvl( (
SELECT
SUM(app1.amount_applied)
FROM ar_receivable_applications_all app1,
ra_customer_trx_all rct1,
ar_payment_schedules_all ps_cm1
where
app1.application_type = 'CM'
and app1.applied_customer_trx_id = rct1.customer_trx_id
and app1.payment_schedule_id = ps_cm1.payment_schedule_id
and TRUNC (app1.gl_date) <= :p_as_of_date
and rct1.trx_number = ra.trx_number
and ps_cm1.org_id = ra.org_id
),null) "CM Amount",
nvl((
SELECT
SUM(app2.amount_applied) 
FROM ar_receivable_applications_all app2,
ar_cash_receipts_all rcpt2,
ar_payment_schedules_all ps_rcpt2,
ra_customer_trx_all inv2
where
app2.application_type = 'CASH'
and app2.applied_customer_trx_id     = inv2.customer_trx_id	
and app2.cash_receipt_id             = rcpt2.cash_receipt_id
and app2.payment_schedule_id         = ps_rcpt2.payment_schedule_id
and app2.applied_payment_schedule_id = aps.payment_schedule_id
and TRUNC (app2.gl_date) <= :p_as_of_date
and inv2.trx_number = aps.trx_number
and ps_rcpt2.org_id = aps.org_id
),null) "CASH Amount",
(Case RT.NAME 
When  'Credit Memo' Then
(aps.amount_due_original + nvl((SELECT SUM (NVL (ara.amount_applied, 0))
                          FROM ar_receivable_applications_all ara
                         WHERE 1=1 
--                               AND ara.applied_customer_trx_id = aps.customer_trx_id
--                               AND ara.applied_payment_schedule_id = aps.payment_schedule_id
                               AND ara.customer_trx_id = aps.customer_trx_id
                               AND ara.payment_schedule_id = aps.payment_schedule_id
                           AND ((ara.REVERSAL_GL_DATE is Null) OR TRUNC(ara.reversal_GL_DATE) > :p_as_of_date)
                           AND TRUNC (ara.gl_date) <= :p_as_of_date ),0)
                   + NVL(( SELECT sum(nvl(aaa.amount,0))
                           FROM ar_adjustments_all aaa
                          WHERE aaa.payment_schedule_id = aps.payment_schedule_id
                            AND aaa.postable = 'Y' AND aaa.gl_date <= :p_as_of_date ),0)
                  ) 
else
(aps.amount_due_original - nvl((SELECT SUM (NVL (ara.amount_applied, 0))
                          FROM ar_receivable_applications_all ara
                         WHERE 1=1 
                               AND ara.applied_customer_trx_id = aps.customer_trx_id
                              AND ara.applied_payment_schedule_id = aps.payment_schedule_id
--                               AND ara.customer_trx_id = aps.customer_trx_id
--                               AND ara.payment_schedule_id = aps.payment_schedule_id
                           AND ((ara.REVERSAL_GL_DATE is Null) OR TRUNC(ara.reversal_GL_DATE) > :p_as_of_date)
                           AND TRUNC (ara.gl_date) <= :p_as_of_date ),0)
                   + NVL(( SELECT sum(nvl(aaa.amount,0))
                           FROM ar_adjustments_all aaa
                          WHERE aaa.payment_schedule_id = aps.payment_schedule_id
                            AND aaa.postable = 'Y' AND aaa.gl_date <= :p_as_of_date ),0)
                  ) end )
amt_due_remaining ,

hc.ORIG_SYSTEM_REFERENCE "Orig_Sys_Bill_To_Cust_Ref",
nvl(hcasa_bill.ORIG_SYSTEM_REFERENCE,null) "Orig_Sys_Bill_to_Cus_Add_Ref",
hc.ORIG_SYSTEM_REFERENCE "Orig_Sys_Ship_to_Cus_Acc_Ref", 
nvl(hcasa_bill.ORIG_SYSTEM_REFERENCE,null) "Orig_Ship_Cus_Acc_Add_Ref"
FROM 
ra_customer_trx_all ra,
ar_payment_schedules_all aps,
ra_cust_trx_types_all rt,
hz_cust_accounts hc,
hz_parties hp,
hz_cust_acct_sites_all hcasa_bill,
hz_cust_site_uses_all hcsua_bill,
hz_party_sites hps_bill,
ra_terms pt
WHERE 1 = 1
AND ra.TERM_ID = pt.TERM_ID(+)
AND ra.customer_trx_id = aps.customer_trx_id
AND ra.org_id = aps.org_id
AND ra.complete_flag = 'Y'
AND ra.cust_trx_type_seq_id = rt.cust_trx_type_seq_id
AND ra.bill_to_customer_id = hc.cust_account_id
AND hc.status = 'A'
AND hp.party_id = hc.party_id
AND hcasa_bill.cust_account_id = ra.bill_to_customer_id
AND hcasa_bill.cust_acct_site_id = hcsua_bill.cust_acct_site_id
AND hcsua_bill.site_use_code = 'BILL_TO'
AND hcsua_bill.site_use_id = ra.bill_to_site_use_id
AND hps_bill.party_site_id = hcasa_bill.party_site_id
AND hcasa_bill.status = 'A'
AND hcsua_bill.status = 'A'
--AND aps.amount_due_remaining <> 0
AND aps.status IN ('OP','CL')
AND aps.class != 'PMT'
AND aps.gl_date  <= :p_as_of_date
AND aps.gl_date_closed  > :p_as_of_date
AND (( :P_CUST_NUM = 'All' AND hc.account_number LIKE '%' ) OR
 (:P_CUST_NUM <> 'All' AND hc.account_number = :P_CUST_NUM))
AND ra.SET_OF_BOOKS_ID = (:P_LEDGER)

 UNION ALL

Select
'' "Transaction Type Name",
hp.party_name,
--hc.account_number "Customer_Number",
hp.PARTY_NUMBER  "Customer_Number",
hc.CUST_ACCOUNT_ID,
TRUNC(TO_DATE(aps.due_date,'YYYY-MM-DD')) due_date,
'' PARTY_SITE_NUMBER,
null SALESREP_ID,
null Rep,
null Sales,
null Email_SM,
null Milestone1,
null Milestone2,
null Milestone3,
null Milestone4,
null Milestone5,
null "Payment Terms",
TRUNC(TO_DATE(aps.gl_date,'YYYY-MM-DD')) gl_date ,
to_date(trunc(:p_as_of_date)) - aps.due_date total_days, 
nvl(TRUNC(acr.RECEIPT_DATE),null)  "Transaction Date",
acr.receipt_number "Transaction Number",
'' purchase_order,
aps.invoice_currency_code,
nvl(aps.exchange_rate,1) exchange_rate,
aps.amount_due_original,
aps.amount_adjusted,
null "CM Amount",
null "CASH Amount",
  (
-nvl((select sum(ara.amount_applied) from 
ar_cash_receipts_all acr1,
AR_RECEIVABLE_APPLICATIONS_ALL ara
where 1=1
AND 
acr1.CASH_RECEIPT_ID = ara.CASH_RECEIPT_ID
AND acr1.CASH_RECEIPT_ID = acr.cash_receipt_id
AND ara.status IN (
        'ACC',
        'UNAPP' )
AND ((ara.REVERSAL_GL_DATE is Null) OR TRUNC(ara.reversal_GL_DATE) > :p_as_of_date)
AND ara.gl_date  <= :p_as_of_date
 ),0) )amt_due_remaining, 
hc.ORIG_SYSTEM_REFERENCE "Orig_Sys_Bill_To_Cust_Ref",
null "Orig_Sys_Bill_to_Cus_Add_Ref",
hc.ORIG_SYSTEM_REFERENCE "Orig_Sys_Ship_to_Cus_Acc_Ref",
null "Orig_Ship_Cus_Acc_Add_Ref"
FROM 
ar_cash_receipts_all acr,
ar_payment_schedules_all aps,
hz_cust_accounts hc,
hz_parties hp
where 1=1
and acr.set_of_books_id = (:P_LEDGER)
and acr.cash_receipt_id = aps.cash_receipt_id
AND acr.status IN ('UNAPP','APP')
AND aps.gl_date  <= :p_as_of_date
AND aps.gl_date_closed  > :p_as_of_date
AND acr.pay_from_customer = hc.cust_account_id
AND hc.status = 'A'
AND (( :P_CUST_NUM = 'All' AND hc.account_number LIKE '%' ) OR
 (:P_CUST_NUM <> 'All' AND hc.account_number = :P_CUST_NUM))
AND hp.party_id = hc.party_id) a1
) GROUP by "Customer_Number",
      --  party_site_number,
        party_name
	--	,"Credit Limit"
       --, invoice_currency_code
ORDER by  "Customer_Number" 
-- )