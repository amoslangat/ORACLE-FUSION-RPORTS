select distinct hca.account_number customer_number
		,hp.party_name customer_name
		--,hca.account_name customer_name
		,hp.party_id
,hca.account_number
,hca.party_id hca_party_id
		,ACRA.RECEIPT_NUMBER
		,(select sum(araa2.amount_applied) 
						from ar_receivable_applications_all araa2
						where araa2.cash_receipt_id = acra.cash_receipt_id
						and araa2.status = 'APP'
						group by araa2.cash_receipt_id) amount_applied
		--ARAA.AMOUNT_APPLIED
		,ARAA.APPLIED_CUSTOMER_TRX_ID
		,ARAA.CASH_RECEIPT_ID
		,a.original_amount Invoice_amount
		,a.trx_number invoice_number
		,rcta.invoice_currency_code currency
		,to_char(rcta.trx_date, 'DD-MM-YYYY')  trx_date
		,a.original_amount - (
						select sum(araa1.amount_applied) 
						from ar_receivable_applications_all araa1
						where araa1.cash_receipt_id = acra.cash_receipt_id
						and araa1.status = 'APP'
						group by araa1.cash_receipt_id
						) remaining_amount
		,to_char(acra.receipt_date, 'DD-MM-YYYY') payment_date
		,trunc(acra.receipt_date)-trunc(rcta.trx_date)  Aging_Days
from hz_cust_accounts hca
	,ra_customer_trx_all rcta
	,hz_parties hp
	,AR_RECEIVABLE_APPLICATIONS_ALL ARAA 
	,AR_CASH_RECEIPTS_ALL ACRA
	,(select rcta1.customer_trx_id, rcta1.trx_number,
		sum(rctla1.extended_amount) ORIGINAL_AMOUNT
		from 
			ra_customer_trx_lines_all rctla1,
			ra_customer_trx_all rcta1
		where 
			rcta1.customer_trx_id = rctla1.customer_trx_id
			and rctla1.line_type = 'LINE'
			--and rcta1.trx_number = 'Test001'
group by rcta1.trx_number,rcta1.customer_trx_id) a
where 1=1
--and rcta.sold_to_party_id = hca.party_id
and rcta.bill_to_customer_id = hca.cust_account_id
and hca.party_id = hp.party_id(+)
and ARAA.CASH_RECEIPT_ID=ACRA.CASH_RECEIPT_ID
AND ARAA.APPLIED_CUSTOMER_TRX_ID=RCTA.CUSTOMER_TRX_ID
and a.customer_trx_id = rcta.customer_trx_id
-- parameters
--and hp.party_name = nvl(:p_customer_name, hp.party_name)
and trunc(rcta.trx_date) ='01-APR-2023'
and trunc(rcta.trx_date)='01-APR-2023'--- between :p_from_date and :p_to_date