SELECT chk.check_number " NO."
      ,bnk.bank_name " NAME"
	  ,bnkacc.bank_account_num "DEBIT_FROM_ACCOUNT"
	  ,chk.vendor_name "BENEFICIARY_NAME"
	  ,chk.amount "AMOUNT"
	  ,chk.check_date "CHECK_DATE"
	  ,chk.amount "NET_PAY"
	  ,supp_bank.bank_name "SUPPLIER_BNAME"
	  ,supp_bank.bank_account_num "SUPP BANK ACCOUNT ."
	  ,'KAREN' PHYSICAL_ADDRESS
	  ,'SUPPLIER_PAYMENT' MY_REFERENCE 
	  ,cbbv.eft_swift_code YOUR_BRANCH_BIC_CODE
    ----------  ,cbbvs.eft_swift_code SUP_BANK_bic_code
,TRANSLATE(REPLACE(lower(cbbvs.eft_swift_code),'(0) -',' '),'abcdefghijklmnopqrstuvwxyz()- +/,.#',' ') SUP_BANK_bic_code
      ,cbbvs.bank_branch_name SUP_bank_branch_name
	  ,:p_branch_bic_code
  FROM ap_checks_all chk
      ,ce_bank_acct_uses_all cbaua
      ,ce_bank_accounts bnkacc
      ,ce_banks_v bnk
      ,ce_bank_branches_v cbbv
      ,ce_bank_branches_v cbbvs
      ,(SELECT aps.vendor_id,
               hop_bank.organization_name bank_name,
               ieba.bank_account_num
               ,ieba.branch_id
               ,ieba.bank_id
          FROM poz_suppliers             aps,
               iby_external_payees_all  hepa,
               iby_pmt_instr_uses_all   ipiua,
               iby_ext_bank_accounts    ieba,
               hz_parties               hzp_bank,
               hz_organization_profiles hop_bank
        WHERE 1=1--HZP.PARTY_ID = APS.PARTY_ID
           --AND HZP.PARTY_ID = HEPA.PAYEE_PARTY_ID
          AND APS.PARTY_ID = HEPA.PAYEE_PARTY_ID
          AND HEPA.EXT_PAYEE_ID = IPIUA.EXT_PMT_PARTY_ID --(+)
          AND IPIUA.INSTRUMENT_ID = IEBA.EXT_BANK_ACCOUNT_ID --(+)
          AND IEBA.BANK_ID = HZP_BANK.PARTY_ID --(+)
          AND HZP_BANK.PARTY_ID = HOP_BANK.PARTY_ID   ---(+)
        AND HEPA.SUPPLIER_SITE_ID IS  NOT NULL
) SUPP_BANK
WHERE 1=1
   AND CHK.STATUS_LOOKUP_CODE <> 'VOIDED'
   AND cbaua.bank_acct_use_id = chk.ce_bank_acct_use_id
   AND cbaua.bank_account_id = BNKACC.bank_account_id
   AND BNK.BANK_PARTY_ID = BNKACC.BANK_ID   
   AND BNKACC.bank_branch_id = cbbv.branch_party_id
   and BNK.bank_party_id = cbbv.bank_party_id
   AND CHK.VENDOR_ID = SUPP_BANK.VENDOR_ID(+)
   and SUPP_BANK.branch_id = cbbvs.branch_party_id(+)
   and SUPP_BANK.bank_id = cbbvs.bank_party_id(+)
   and chk.check_number = '1234'
   and trunc(chk.check_date) >= :p_from_date
   and trunc(chk.check_date) <= :p_to_date
   and chk.org_id = '82'