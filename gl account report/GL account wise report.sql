select sum(nvl(jel.accounted_dr,0)) - sum(nvl(jel.accounted_cr,0)) accounted_balance,
sum(nvl(jel.entered_dr,0)) - sum(nvl(jel.entered_cr,0)) entered_balance
,jel.code_combination_id,
gcc.SEGMENT4,
jeh.je_source
from 
fusion.gl_je_batches jeb, 
fusion.gl_je_headers jeh,
fusion.gl_je_lines jel,
gl_code_combinations gcc
 where 1=1
 and jeh.PERIOD_NAME = :P_PERIOD
AND to_number(gcc.SEGMENT4) between  nvl(:P_FROM_ACCT,gcc.SEGMENT4) AND
nvl(:P_TO_ACCT,gcc.SEGMENT4)
--and jeb.actual_flag='A'
--and jeb.status='P'
and jeh.je_source <> 'Cost Accounting'
and jeh.je_batch_id= jeb.je_batch_id
and jeh.je_header_id = jel.je_header_id
and gcc.code_combination_id=jel.code_combination_id
and jeb.name='Cost Accounting A 690085000002 690098 N 07-JUN-2022 17:54:58 | Corrected APR-22'
group by jel.code_combination_id,gcc.SEGMENT4,jeh.je_source