SELECT
	invaudee.audit_number AS inventory_transaction_id,
	invaudee.trans_date AS transaction_accounting_dt,
	invaudee.posted_date_time AS transaction_dttm,
	invaudee.trans_session AS transaction_session_num,
	invaudee.trans_sequence AS transaction_sequence_num,
	SUBSTRING(TRIM(prdmstee.prd_lvl_number),0, LENGTH(TRIM(prdmstee.prd_lvl_number))-1) AS item_id,
	orgmstee.org_lvl_number AS location_id,
	invaudee.inv_mrpt_code AS major_report_cd,
	invaudee.inv_drpt_code AS minor_report_cd,
	invaudee.trans_type_code AS inventory_type_cd,
	invaudee.trans_trn_code AS inventory_transaction_type_cd,
	invaudee.trans_curr_code AS currency_cd,
	invaudee.proc_source AS transaction_source_reference_desc,
	invaudee.trans_ref AS first_origin_document_num,
	invaudee.trans_ref2 AS second_origin_document_num,
	invaudee.trans_qty AS transaction_qty,
	invaudee.trans_retl AS transaction_amt,
	invaudee.trans_cost AS unit_cost_amt,
	invaudee.trans_vat AS total_unit_tax_amt,
	invaudee.trans_pos_ext_total AS total_pos_extended_amt,
	invaudee.trans_ext_retl AS extended_amt,
	invaudee.trans_ext_cost AS extended_cost_amt,
	invaudee.trans_ext_vat AS extended_tax_amt,
	invaudee.inv_trn_audit AS auditable_flg,
	invaudee.inv_avg_cost AS affects_cost_flg,
	invaudee.inv_eff_bal AS affects_ballance_cd,
	invaudee.inv_eff_qty AS ballance_effect_sign_qty_flg,
	invaudee.inv_eff_ret AS ballance_effect_sign_price_flg,
	invaudee.inv_eff_cst AS ballance_effect_sign_cost_flg,
	invaudee.inv_eff_vat AS ballance_effect_sign_tax_flg,
	invaudee.inv_mult AS ballance_multiplier_factor_flg,
	invaudee.reslt_oh_qty AS result_onhand_qty,
	invaudee.reslt_oh_retl AS result_onhand_amt,
	invaudee.reslt_oh_cost AS result_onhand_cost_amt,
	$JOBID AS job_id,
	invaudee.highwatermark AS transaction_dt,
	'CL' AS country_id,    --Chile
	'SOD' as Business_Unit_ID
FROM invaudee
LEFT OUTER JOIN orgmstee
	ON  invaudee.trans_org_child = orgmstee.org_lvl_child
	AND orgmstee.org_lvl_id =1
LEFT OUTER JOIN prdmstee
	ON invaudee.trans_prd_child = prdmstee.prd_lvl_child
	AND prdmstee.prd_lvl_id=1
WHERE to_date(invaudee.highwatermark) IN $CONDICION_FECHA
	