SELECT
    blta.unor_codg AS location_id,
    blta.blta_corr AS sales_return_document_num,
    dtbl.dtbl_item AS retail_trans_line_item_seq_num,
    blta.blta_timestamp AS transaction_dttm,
    CASE
        WHEN trim(blta.blta_rut_especialista) = '' or COALESCE(blta.blta_rut_especialista, 'null') = 'null' THEN 'N'
        ELSE 'S'
    END AS specialist_circle_flg,
    CAST(SUBSTR(blta.blta_rut_especialista,1,LENGTH(TRIM(blta.blta_rut_especialista))-1) AS INT) as Specialist_Customer_Id,
    CONCAT(blta.highwatermark, ' ', coalesce(CONCAT(substring(blta.blta_hora_inicio, 1, 2), ':', substring(blta.blta_hora_inicio, 3, 2), ':', substring(blta.blta_hora_inicio, 5, 2)), '00:00:00')) AS document_start_dttm,    --La hora no está hh:mm:ss sino hhmmss en los datos de prueba
    blta.blta_tot AS transaction_total_amt,
    blta.blta_csto AS transaction_total_cost_amt,
    blta.blta_efectivo_ingresado AS transaction_cash_amt,
    blta.blta_monto_ncr AS credit_note_amt,
    substring(blta.blta_nro_vtassstock, 4) AS reservation_num,
    blta.blta_uems AS till_id,
    blta.clnt_rut AS customer_id,
    substring(blta.blta_nro_vtassstock, 1, 2) AS channel_id,
    substring(blta.blta_nro_vtassstock, 3, 1) AS sub_channel_cd,
    blta.blta_operador AS operator_id,
    blta.blta_tipo_beneficio AS benefit_type_cd,
    blta.blta_tdct2 AS document_type_cd,
    blta.blta_tdct AS document_use_type_cd,
    dtbl.dtbl_marca_vpm AS vpm_type_cd,
    'VR' business_area_sales_flg, -- NIVEL1
    CASE WHEN (substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtbl.blta_marca_lb = 'S') OR dtbl.dtbl_marca_vpm = '3' OR (dtbl.dtbl_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
        THEN 'NSR' 
        ELSE 'SR' 
    END channel_sales_flg, --NIVEL 2
    CASE WHEN (substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtbl.blta_marca_lb = 'S') OR dtbl.dtbl_marca_vpm = '3' OR (dtbl.dtbl_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
        THEN 
            CASE WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' 
                THEN 'DVD'
                ELSE 'KIOSKO'
            END
        ELSE 'SR'
    END sub_channel_level1_sales_flg, --NIVEL 3
    CASE WHEN (substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtbl.blta_marca_lb = 'S') OR dtbl.dtbl_marca_vpm = '3' OR (dtbl.dtbl_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
        THEN 
            CASE WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) IN ('7', '8')
                THEN 'VAT'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN('0','20','25','26') 
                THEN 'RESTO'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) IN ('1', '5', '6')
                THEN 'WEB'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='9'
                THEN 'APP'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='2'
                THEN 'CALL'
                ELSE CASE WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' then 'WEB' ELSE 'RESTO' END
            END
        ELSE 'SR'
    END sub_channel_level2_sales_flg, --NIVEL 4
    CASE WHEN (substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtbl.blta_marca_lb = 'S') OR dtbl.dtbl_marca_vpm = '3' OR (dtbl.dtbl_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
        THEN 
            CASE WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '26'
                THEN 'UX+'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN('0','20') and dtbl.dtbl_marca_vpm = '3'
                THEN 'UXCDAD'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) IN('0','20') and dtbl.dtbl_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105')
                THEN 'UXCRT'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '25'
                THEN 'SSEE'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='7'
                THEN 'VATT'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='8'
                THEN 'VATI'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='1'
                THEN 'SOD'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='6'
                THEN 'HOMY'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='9'
                THEN 'APPMOB'
                WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(blta.blta_nro_vtassstock as string)), 3, 1) ='2'
                THEN 'FCOMP'
                ELSE CASE WHEN substring(trim(cast(blta.blta_nro_vtassstock as string)), 1, 2) = '23' then 'NCDVD' ELSE 'NCKIOSKO' END
            END
        ELSE 'SR'
    END sub_channel_level3_sales_flg, --NIVEL5
    dtbl.item_codg AS item_id,
    dtbl.dtbl_cntd AS unit_cnt,
    dtbl.dtbl_prec_original AS regular_unit_price_amt,
    dtbl.dtbl_ctd_vendida_um_venta AS bulk_unit_cnt,
    dtbl.dtbl_precio_um_venta AS bulk_unit_uom_amt,
    dtbl.dtbl_precio_extendido AS extended_amt,
    dtbl.dtbl_val_desc_unitario AS unit_discount_amt,
    dtbl.dtbl_ctun AS unit_cost_price_amt,
    dtbl.dtbl_prec AS transaction_unit_price_amt,
    dtbl.dtbl_cod_prom AS promotional_offer_id,
    dtbl.dtbl_um_venta AS transaction_item_uom_id,
    dtbl.blta_marca_lb AS delivery_flg,
    dtbl.dtbl_tipo_prom AS promotion_type_cd,
    dtbl.dtbl_ctd_regalada AS transaction_gifted_qty,
    dtbl.dtbl_metodo_distribu AS distribution_method_type_cd,
    dtbl.dtbl_cod_metdistribu AS distribution_method_code_val,
    dtbl.dtbl_costoflete1 AS freight_cost_amt,
    dtbl.dtbl_costoflete2 AS last_mile_freight_cost_amt,
    dtbl.dtbl_costologistico AS logistic_cost_amt,
    dtbl.dtbl_precio_publico AS public_price_amt,
    blta.blta_tot/1.19 AS ST_Document_Total_NET_Amt,
    blta.blta_tot AS ST_Document_Total_Amt,
    (dtbl.dtbl_cntd * dtbl.dtbl_prec)/1.19 AS ST_Extended_NET_Amt,
    dtbl.dtbl_cntd * dtbl.dtbl_prec AS ST_Extended_Amt,

    PAGPRIN.cpgo_codg as Main_Payment_Type_Cd,
    MEDPAG.desmedio as Main_Payment_Type_Desc,
    CASE WHEN PAGCMR.cpgo_codg ='TF'
        THEN 1 
        ELSE 0 
    END AS Company_Card_Payment_Flg,

    CASE WHEN trim(coalesce(blta.blta_rut_especialista, '')) = '' or not trim(blta.blta_rut_especialista) rlike '^[0-9]+.$'
        THEN CASE WHEN CLIPRIN.pgbl_rut = 0 or CLIPRIN.pgbl_rut is null
                    THEN trim(cast(blta.clnt_rut as string))
                    ELSE trim(cast(CLIPRIN.pgbl_rut as string))
                END
        ELSE regexp_replace(substr(trim(blta.blta_rut_especialista), 1 , length(trim(blta.blta_rut_especialista)) - 1), '^0+(?!$)', '')
    END  Main_Customer_Id,

    $JOBID AS job_id,    --Usar variable JOBID del proceso

    'CL' AS country_id,    --Chile
    'SOD' AS Business_Unit_Id,   --Sodimac
    'blta' AS sales_return_type_cd,    --boleta
    blta.highwatermark AS sales_return_dt  -- Usar HighWaterMark para la busqueda de las fechas, esto ya que este es creado en base a los 3 campos origen (CONCAT('20', lpad(blta_ano, 2, "0"), '-', lpad(blta_mes, 2, "0"), '-', lpad(blta_dia, 2, "0")))

FROM $PUBLISH_ZONE_DB.boleta blta

LEFT OUTER JOIN $PUBLISH_ZONE_DB.detalle_boleta dtbl
    ON  blta.highwatermark = dtbl.highwatermark
    AND blta.unor_codg= dtbl.unor_codg
    AND blta.blta_corr= dtbl.blta_corr

LEFT OUTER JOIN (
    SELECT
        highwatermark
        ,unor_codg
        ,blta_corr
        ,cpgo_codg
        ,pgbl_rut
        ,sum_pgbl_valr
        ,Payment_Priority_Val
        from (
            SELECT 
                highwatermark
                ,unor_codg
                ,blta_corr
                ,cpgo_codg
                ,pgbl_rut
                ,sum_pgbl_valr
                ,Payment_Priority_Val
                ,ROW_NUMBER() OVER(PARTITION BY blta_corr, unor_codg order by sum_pgbl_valr desc, Payment_Priority_Val asc) unique_col
                from (
                SELECT
                    highwatermark
                    ,unor_codg
                    ,blta_corr
                    ,cpgo_codg
                    ,pgbl_rut 
                    ,COALESCE (PMTD.Payment_Priority_Val, 9999) as Payment_Priority_Val
                    ,sum(pgbl_valr) as sum_pgbl_valr
                    FROM $PUBLISH_ZONE_DB.pago_boleta 
                    LEFT JOIN $TARGET_ZONE_DB.payment_method_type_dim PMTD
                        on cpgo_codg = PMTD.Payment_Method_type_cd
                        and country_id = 'CL'
                        and business_unit_id = 'SOD'
                    where highwatermark in $CONDICION_FECHA
                    group by highwatermark
                    ,unor_codg
                    ,blta_corr
                    ,cpgo_codg
                    ,pgbl_rut
                    ,COALESCE (PMTD.Payment_Priority_Val, 9999)
                    ) AGG1
                group by 
                highwatermark
                ,unor_codg
                ,blta_corr
                ,cpgo_codg
                ,pgbl_rut
                ,sum_pgbl_valr
                ,Payment_Priority_Val
            ) AGG2
        where unique_col = 1
    ) PAGPRIN
    ON  blta.highwatermark = PAGPRIN.highwatermark
    AND blta.unor_codg= PAGPRIN.unor_codg
    AND blta.blta_corr= PAGPRIN.blta_corr

LEFT OUTER JOIN (
        SELECT
        highwatermark
        ,unor_codg
        ,blta_corr
        ,cpgo_codg
        ,pgbl_rut
        FROM $PUBLISH_ZONE_DB.pago_boleta 
        where cpgo_codg= 'TF'
        and highwatermark in $CONDICION_FECHA
        group by highwatermark
        ,unor_codg
        ,blta_corr
        ,cpgo_codg
        ,pgbl_rut
    ) PAGCMR
    ON  blta.highwatermark = PAGCMR.highwatermark
    AND blta.unor_codg= PAGCMR.unor_codg
    AND blta.blta_corr= PAGCMR.blta_corr

LEFT OUTER JOIN (
        SELECT 
            highwatermark
            ,unor_codg
            ,blta_corr
            ,cpgo_codg
            ,pgbl_rut
            ,unique_col
            from (
            SELECT
                highwatermark
                ,unor_codg
                ,blta_corr
                ,cpgo_codg
                ,pgbl_rut 
                ,COALESCE (PMTD.Payment_Priority_Val, 9999) as Payment_Priority_Val
                ,ROW_NUMBER() OVER(PARTITION BY blta_corr, unor_codg order by COALESCE (PMTD.Payment_Priority_Val, 9999) asc) unique_col
                FROM sod_cinfo_cl.pago_boleta 
                LEFT JOIN $TARGET_ZONE_DB.payment_method_type_dim PMTD
                    on cpgo_codg = PMTD.Payment_Method_type_cd
                    and country_id = 'CL'
                    and business_unit_id = 'SOD'
                where highwatermark in $CONDICION_FECHA
                and (pgbl_rut <> 0 or pgbl_rut is not null) 
                group by highwatermark
                ,unor_codg
                ,blta_corr
                ,cpgo_codg
                ,pgbl_rut
                ,COALESCE (PMTD.Payment_Priority_Val, 9999)
                ) AGG1
            where unique_col = 1
            group by 
            highwatermark
            ,unor_codg
            ,blta_corr
            ,cpgo_codg
            ,pgbl_rut
            ,unique_col
    ) CLIPRIN
    ON  blta.highwatermark = CLIPRIN.highwatermark
    AND blta.unor_codg= CLIPRIN.unor_codg
    AND blta.blta_corr= CLIPRIN.blta_corr

LEFT JOIN $PUBLISH_ZONE_DB.med_pago MEDPAG
on PAGPRIN.cpgo_codg = MEDPAG.codmedio

LEFT JOIN $TARGET_ZONE_DB.ITEM_DIM ITMD
ON cast(dtbl.item_codg as int) = cast(ITMD.item_id as int)
and country_id = 'CL'
and business_unit_id = 'SOD'

WHERE dtbl.blta_monto_tcc = 0
AND blta.highwatermark in $CONDICION_FECHA

