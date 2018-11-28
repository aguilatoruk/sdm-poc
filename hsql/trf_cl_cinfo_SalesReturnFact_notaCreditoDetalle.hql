SELECT
    ntcr.unor_codg AS location_id,
    ntcr.ntcr_corr AS sales_return_document_num,
    dnct.dnct_item AS retail_trans_line_item_seq_num,
    ntcr.ntcr_timestamp AS transaction_dttm,
    ntcr.ntcr_totl AS transaction_total_amt,
    ntcr.ntcr_csto AS transaction_total_cost_amt,
    ntcr.ntcr_valr AS transaction_total_net_amt,
    ntcr.ntcr_iva AS transaction_total_tax_amt,
    substring(ntcr.ntcr_nro_vtassstock, 4) AS reservation_num,
    ntcr.ntcr_n_pos AS till_id,
    ntcr.clnt_rut AS customer_id,
    substring(ntcr.ntcr_nro_vtassstock, 1, 2) AS channel_id,
    substring(ntcr.ntcr_nro_vtassstock, 3, 1) AS sub_channel_cd,
    ntcr.ntcr_tipo_beneficio AS benefit_type_cd,
    ntcr.ntcr_Tncr AS debit_credit_note_type_cd,
    ntcr.ntcr_tdct2 AS document_type_cd,
    ntcr.ntcr_corr AS origin_ballot_num,
    ntcr.fctr_corr AS origin_invoice_num,
    ntcr.ntcr_numero_pvt AS pvt_num,
    ntcr.ntcr_pvt_vpm AS vpm_type_cd,
    CASE
        WHEN ntcr.ntcr_docvta <> 'B' AND (ccld.rut IS NOT NULL OR substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('4'))
            THEN 'VE'
        ELSE 'VR'
    END business_area_sales_flg, -- NIVEL1
    CASE
        WHEN ntcr.ntcr_docvta <> 'B' AND (ccld.rut IS NOT NULL OR substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('4'))
            THEN 'VE'
        ELSE 
            CASE WHEN (substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) IN ('23', '25', '26', '27') AND dnct.ntcr_marca_lb = 'S')
                THEN 'NSR' 
                ELSE 'SR' 
            END
    END channel_sales_flg, --NIVEL 2
    CASE  WHEN ntcr.ntcr_docvta <> 'B' AND (ccld.rut IS NOT NULL OR substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('4'))
            THEN 'VE'
        ELSE 
            CASE WHEN (substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) IN ('23', '25', '26', '27') AND dnct.ntcr_marca_lb = 'S')
                THEN 
                    CASE WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' 
                        THEN 'DVD'
                        ELSE 'KIOSKO'
                    END
                ELSE 'SR'
            END
    END sub_channel_level1_sales_flg, --NIVEL 3
    CASE  WHEN ntcr.ntcr_docvta <> 'B' AND (ccld.rut IS NOT NULL OR substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('4'))
            THEN 'VE'
        ELSE 
            CASE WHEN (substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) IN ('23', '25', '26', '27') AND dnct.ntcr_marca_lb = 'S')
                THEN 
                    CASE WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('7', '8')
                        THEN 'VAT'
                        WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) IN('25','26') 
                        THEN 'RESTO'
                        WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('1', '5', '6')
                        THEN 'WEB'
                        WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='9'
                        THEN 'APP'
                        WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('2', '3')
                        THEN 'CALL'
                        ELSE CASE WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' THEN 'WEB' ELSE 'RESTO' END
                    END
                ELSE 'SR'
            END
    END sub_channel_level2_sales_flg, --NIVEL 4
    CASE  WHEN ccld.rut IS NOT NULL AND ntcr.ntcr_docvta <> 'B'
        THEN 
        CASE WHEN ntcr.ntcr_docvta IN ('F','P') AND ntcr.ntcr_tvta = 'S' AND ntcr.ntcr_pvt = 'PVT'
        THEN 'VENTCRS'
        WHEN ntcr.ntcr_docvta IN ('F','P') AND ntcr.ntcr_pvt <> 'PVT'
        THEN 'VENTCRM'
        WHEN ntcr.ntcr_docvta IN ('F','P') AND ntcr.ntcr_tvta = 'D'
        THEN 'VENTCRD'
        ELSE 
            'VEC'
        END
    ELSE 
        CASE WHEN (substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) IN ('23', '25', '26', '27') AND dnct.ntcr_marca_lb = 'S')
            THEN 
                CASE WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '26'
                    THEN 'UX+'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '25'
                    THEN 'SSEE'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='7'
                    THEN 'VATT'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='8'
                    THEN 'VATI'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='1'
                    THEN 'SOD'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='6'
                    THEN 'HOMY'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='9'
                    THEN 'APPMOB'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) ='2'
                    THEN 'FCOMP'
                    WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 3, 1) IN ('3')
                    THEN 'FCOMP-EMP'
                    ELSE CASE WHEN substring(trim(cast(ntcr.ntcr_nro_vtassstock as string)), 1, 2) = '23' THEN 'NCDVD' ELSE 'NCKIOSKO' END
                END
            ELSE 'SR'
        END
    END sub_channel_level3_sales_flg, --NIVEL5 
    dnct.item_codg AS item_id,
    -dnct.dnct_cntd AS unit_cnt,
    dnct.dnct_ctd_vendida_um_venta AS bulk_unit_cnt,
    dnct.dnct_precio_um_venta AS bulk_unit_uom_amt,
    dnct.dnct_precio_extendido AS extended_amt,
    dnct.dnct_ctun AS unit_cost_price_amt,
    dnct.dnct_prec AS transaction_unit_price_amt,
    dnct.dnct_cod_prom AS promotional_offer_id,
    dnct.dnct_um_venta AS transaction_item_uom_id,
    dnct.ntcr_marca_lb AS delivery_flg,
    dnct.dnct_tipo_prom AS promotion_type_cd,
    dnct.dnct_metodo_distribu AS distribution_method_type_cd,
    dnct.dnct_cod_metdistribu AS distribution_method_code_val,
    dnct.dnct_costoflete1 AS freight_cost_amt,
    dnct.dnct_costoflete2 AS last_mile_freight_cost_amt,
    dnct.dnct_costologistico AS logistic_cost_amt,
    dnct.dnct_precio_publico AS public_price_amt,
	ntcr.ntcr_docvta AS Origin_Document_Type_Cd,
	
	CASE WHEN ntcr.ntcr_docvta = 'B' THEN ntcr.ntcr_totl/1.19 ELSE ntcr.ntcr_valr END AS ST_Document_Total_NET_Amt,
	
	ntcr.ntcr_totl AS ST_Document_Total_Amt,
	
	-(dnct.dnct_cntd * dnct.dnct_prec) AS ST_Extended_NET_Amt,
	
	-((dnct.dnct_cntd * dnct.dnct_prec) * 1.19) AS ST_Extended_Amt,
    
    ntcr.ntcr_tvta AS Sales_Type_Cd,
    ntcr.ntcr_pvt AS PVT_Origin_Type_Cd,
    ntcr.ntcr_tvta_mesped AS Counter_Sales_Type_Cd,                                      
    ntcr.ntcr_tvta_voldet AS Volume_Sales_Type_Cd,

    ntcr.ntcr_cpgo  AS Payment_Method_Type_Cd,
    ntcr.ntcr_causal AS Return_Cause_Type_Cd,
    ntcr.ntcr_Cpago1 AS Transaction_Charge1_Type_Cd,
    ntcr.ntcr_Cpago2 AS Transaction_Charge2_Type_Cd,
    ntcr.ntcr_Cpago3 AS Transaction_Charge3_Type_Cd,
    ntcr.ntcr_tipo_devolucion AS Return_Type_Cd,
    ntcr.ntcr_motivo_dev      AS Return_Reason_Cd,

    $JOBID AS job_id,    --Usar variable JOBID del proceso
    'CL' AS country_id,    --Chile
    'SOD' AS Business_Unit_Id,   --Sodimac
    'ntcr' AS sales_return_type_cd,  --Nota Credito
    ntcr.highwatermark AS sales_return_dt  --Usar HighWaterMark para la busqueda de las fechas, esto ya que este es creado en base a los 3 campos origen (CONCAT('20', lpad(ntcr_ano, 2, "0"), '-', lpad(ntcr_mes, 2, "0"), '-', lpad(ntcr_dia, 2, "0")))

FROM nota_credito ntcr

LEFT OUTER JOIN detalle_nota_crdto dnct
    ON  ntcr.highwatermark = dnct.highwatermark
    AND ntcr.unor_codg= dnct.unor_codg
    AND ntcr.ntcr_corr= dnct.ntcr_corr
	
LEFT OUTER JOIN cartera_clientes_dia ccld
    ON ntcr.clnt_rut = ccld.rut
	AND ntcr.highwatermark = ccld.highwatermark
    
WHERE ((dnct.dnct_monto_tcc = 0 AND ntcr_docvta = 'B') OR ntcr_docvta <> 'B')
AND ntcr.highwatermark in $CONDICION_FECHA
