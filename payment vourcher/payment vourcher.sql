SELECT aca.check_id, 
        aca.check_number
      ,aca.VENDOR_NAME
      ,TO_CHAR(aca.CHECK_DATE,'YYYY-MM-DD') CHECK_DATE
      ,aca.DOC_SEQUENCE_VALUE  DOC_NO
      ,aca.DESCRIPTION
      ,aca.CHECK_VOUCHER_NUM  EXT_VOCH_NO
     -- ,	aip.INVOICE_ID
      ,aca.AMOUNT AMOUNT 
      ,null  W_VAT_AMOUNT 
      , null WHT_AMOUNT	  
FROM AP_CHECKS_ALL aca
   -- ,AP_INVOICE_PAYMENTS_ALL aip
WHERE 1=1
--and ACA.CHECK_ID = AIP.CHECK_ID
--AND NVL(AIP.REVERSAL_FLAG,'N') = 'N'
and aca.check_number = nvl( :DOC_NUMBER,aca.check_number)
AND trunc(ACA.CREATION_DATE) >=:P_FROM_DATE
AND trunc(ACA.CREATION_DATE) <= :P_TO_DATE
******************************************************8

SELECT aia.INVOICE_NUM
       ,'Invoice' DOC_TYPE
	   ,TO_CHAR(aia.INVOICE_DATE,'YYYY-MM-DD') INVOICE_DATE
	   ,aia.DESCRIPTION
	   ,aia.TOTAL_TAX_AMOUNT W_VAT_AMOUNT
	   ,aia.INVOICE_AMOUNT
	   ,(select sum(aida.amount) from ap_invoice_distributions_all aida
	         where aida.invoice_id = aia.invoice_id
             and aida.line_type_lookup_code = 'AWT'
	        group by aida.invoice_id) WHT_AMOUNT
	   ,aia.invoice_id
,aca.check_id
FROM AP_INVOICES_ALL aia
	,AP_CHECKS_ALL aca
    ,AP_INVOICE_PAYMENTS_ALL aip
where 1=1
and aia.invoice_id = aip.invoice_id
and ACA.CHECK_ID = AIP.CHECK_ID
**********************************************
select  
to_char(sysdate,'MM/DD/YY') rundate,
to_char(sysdate,'HH24:MI:SS')  runtime,
:xdo_user_name username,
(Select PPF.DISPLAY_NAME
From
PER_PERSON_NAMES_F PPF,
PER_USERS PU
WHERE
PU.PERSON_ID = PPF.PERSON_ID
AND UPPER(USERNAME) = UPPER(:xdo_user_name)
AND ROWNUM < 2 ) AS name
from dual