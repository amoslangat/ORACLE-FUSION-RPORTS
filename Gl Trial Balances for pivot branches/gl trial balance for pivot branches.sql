SELECT acc_name
	,acc_desc
	,SUM(NVL(C_000, 0)) AS "000 D"
	,SUM(NVL(C_100, 0)) AS "100 M"
	,SUM(NVL(C_110, 0)) AS "110 N"
	,SUM(NVL(C_120, 0)) AS "120 T"
	,SUM(NVL(C_130, 0)) AS "130 Nk"
	,SUM(NVL(C_140, 0)) AS "140 Mr"
	,SUM(NVL(C_150, 0)) AS "150 Kru"
	,SUM(NVL(C_160, 0)) AS "160 Tk"
	,SUM(NVL(C_170, 0)) AS "170 Rg"
	,SUM(NVL(C_180, 0)) AS "180 Nv"
	,SUM(NVL(C_190, 0)) AS "190 U"
	,SUM(NVL(C_200, 0)) AS "200 Tc"
	,SUM(NVL(C_210, 0)) AS "210 Kt"
	,SUM(NVL(C_220, 0)) AS "220 Ng"
	,SUM(NVL(C_230, 0)) AS "230 Wt"
	,SUM(NVL(C_240, 0)) AS "240 Cps"
	,SUM(NVL(C_000, 0) + NVL(C_100, 0) + NVL(C_110, 0) + NVL(C_120, 0) + NVL(C_130, 0) + NVL(C_140, 0) + NVL(C_150, 0) + NVL(C_160, 0) + NVL(C_170, 0) + NVL(C_180, 0) + NVL(C_190, 0) + NVL(C_200, 0) + NVL(C_210, 0) + NVL(C_220, 0) + NVL(C_230, 0) + NVL(C_240, 0)) TOTAL
	,SUM(NVL(begining_balance,0)) begining_balance
	
	,SUM(NVL(ending_balance,0)) ending_balance
FROM (
	SELECT br.branch_name || '-' || br.branch_desc branch
		,acc.acc_name
		,acc.acc_desc
		,SUM(BEGIN_BALANCE_DR - BEGIN_BALANCE_CR) begining_balance
		
		,SUM(PERIOD_NET_DR - PERIOD_NET_CR) Period_total
		,SUM((BEGIN_BALANCE_DR - BEGIN_BALANCE_CR) + (PERIOD_NET_DR - PERIOD_NET_CR)) ending_balance
	FROM gl_balances gb
		,gl_code_combinations gcc
		,(
			SELECT br.flex_value branch_name
				,br.DESCRIPTION branch_desc
			FROM fnd_flex_values_vl br
				,fnd_id_flex_segments bfifs
			WHERE br.flex_value_set_id = bfifs.flex_value_set_id
				AND bfifs.ID_FLEX_CODE = 'GL#'
				AND bfifs.SEGMENT_NAME = 'xxx'
				AND br.flex_value IN (
					'000'
					,'100'
					,'110'
					,'120'
					,'130'
					,'140'
					,'150'
					,'160'
					,'170'
					,'180'
					,'190'
					,'200'
					,'210'
					,'220'
					,'230'
					,'240'
					)
			) br
		,(
			SELECT distinct br.flex_value acc_name
				,br.DESCRIPTION acc_desc
			FROM fnd_flex_values_vl br
				,fnd_id_flex_segments bfifs
			WHERE br.flex_value_set_id = bfifs.flex_value_set_id
				AND bfifs.ID_FLEX_CODE = 'GL#'
				AND bfifs.SEGMENT_NAME = 'Natural Account'
			) acc,
			 (
        SELECT  distinct 
            gps.period_name,
            gps.ledger_id,
            gps.period_num
        FROM
            gl_period_statuses gps1,
            gl_period_statuses gps2,
            gl_period_statuses gps
        WHERE
                gps1.period_name =:P_TO_PERIOD
            AND gps1.application_id = 101
            AND gps2.period_name = :P_TO_PERIOD
            AND gps2.application_id = 101
            AND gps.effective_period_num >= gps1.effective_period_num
            AND gps.effective_period_num <= gps2.effective_period_num
            AND gps.application_id = 101
    )                    gl_period
	WHERE gb.code_combination_id(+) = gcc.code_combination_id
		AND gcc.segment2 = br.branch_name(+)
		AND gcc.segment4 = acc.acc_name(+)
		AND gb.actual_flag(+) = 'A'		
		 AND gb.period_name (+) = gl_period.period_name
	    AND gb.ledger_id (+) = gl_period.ledger_id
	GROUP BY br.branch_name
		,br.branch_desc
		,acc.acc_name
		,acc.acc_desc
	)
PIVOT(SUM(Period_total) FOR branch IN (
			'000-D' AS C_000
			,'100-M ' AS C_100
			,'110-N' AS C_110
			,'120-T' AS C_120
			,'130-Nk' AS C_130
			,'140-Mr' AS C_140
			,'150-Kru' AS C_150
			,'160-Tk' AS C_160
			,'170-Rn' AS C_170
			,'180-Nv' AS C_180
			,'190-U' AS C_190
			,'200-Tc' AS C_200
			,'210-Kt' AS C_210
			,'220-Ng' AS C_220
			,'230-Wt' AS C_230
			,'240-Cp' AS C_240
			))
GROUP BY acc_name
	,acc_desc
ORDER BY acc_name