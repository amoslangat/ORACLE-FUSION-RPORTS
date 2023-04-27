
select distinct 
invoice_num,
--nvl(substr(invoice_num,1,instr(invoice_num,'-')-1),invoice_num) bill_number,
invoice_amount,
amount_paid,

(
(select 
rcta.trx_number
from ra_customer_trx_all rcta
,ar_payment_schedules_all aps

where 1=1 
and rcta.customer_trx_id = aps.customer_trx_id
and rcta.trx_number LIKE nvl(substr(invoice_num,1,instr(invoice_num,'-')-1),invoice_num)||'%'
and rownum<2
)
)  bill_number,
(
(select 
--sum(aps.amount_due_original) orig_amount
sum(aps.amount_due_remaining)
from ra_customer_trx_all rcta
,ar_payment_schedules_all aps
where 1=1 
and rcta.customer_trx_id = aps.customer_trx_id
and rcta.trx_number LIKE nvl(substr(invoice_num,1,instr(invoice_num,'-')-1),invoice_num)||'%'
)
) AR_Amount_Due,
(
(select 
sum(aps.amount_due_original) orig_amount
--sum(aps.amount_due_remaining)
from ra_customer_trx_all rcta
,ar_payment_schedules_all aps
where 1=1 
and rcta.customer_trx_id = aps.customer_trx_id
and rcta.trx_number like nvl(substr(invoice_num,1,instr(invoice_num,'-')-1),invoice_num)||'%'
)
) AR_Invoice_Amount,

vendor_name  Supplier_name,
invoice_date
from ap_invoices_all aia,POZ_SUPPLIERS_V ps
where 1=1
and aia.vendor_id = ps.vendor_id
and ps.vendor_name = nvl(:P_VENDOR_ID,ps.vendor_name)
--and invoice_num like 'BL1190508%'
and invoice_num like 'BL%'
--and invoice_date < '01-APR-2022'
and nvl(amount_paid,0) < invoice_amount
order by 7;