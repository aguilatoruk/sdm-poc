SELECT
	fctr.unor_codg AS location_id,
    fctr.fctr_corr AS sales_Return_document_num,
    dtfc.dtfc_item AS retail_trans_line_item_seq_num,
    fctr.fctr_timestamp AS transaction_dttm,
    CASE
        WHEN TRIM(fctr.fctr_rut_especialista) = '' or COALESCE(fctr.fctr_rut_especialista, 'null') = 'null' THEN 'N'
        ELSE 'S'
    END AS specialist_circle_flg,
    CAST(SUBSTR(fctr.fctr_rut_especialista,1,LENGTH(TRIM(fctr.fctr_rut_especialista))-1) AS INT) as Specialist_Customer_Id, 
    CONCAT(fctr.highwatermark, ' ', COALESCE(CONCAT(substring(fctr.fctr_hora_inicio, 1, 2), ':', substring(fctr.fctr_hora_inicio, 3, 2), ':', substring(fctr.fctr_hora_inicio, 5, 2)), '00:00:00')) AS document_start_dttm,
    fctr.fctr_totl AS transaction_total_amt,
    fctr.fctr_csto AS transaction_total_cost_amt,
    fctr.fctr_valr AS transaction_total_net_amt,
    fctr.fctr_efectivo_ingresado AS transaction_cash_amt,
    fctr.fctr_desc AS transaction_total_discount_amt,
    fctr.fctr_iva AS transaction_total_tax_amt,
    fctr.fctr_valfle AS transaction_total_freight_amt,
    fctr.fctr_cosfle AS transaction_total_freight_cost_amt,
    fctr.fctr_monto_ncr AS credit_note_amt,
    substring(fctr.fctr_nro_vtassstock, 4) AS reservation_num,
    fctr.fctr_n_pos AS till_id,
    fctr.clnt_rut AS customer_id,
    substring(fctr.fctr_nro_vtassstock, 1, 2) AS channel_id,
    substring(fctr.fctr_nro_vtassstock, 3, 1) AS sub_channel_cd,
    fctr.fctr_tdct2 AS document_type_cd,
    fctr.fctr_tipo_pvt AS pvt_num,
    fctr.fctr_nro_pvt AS pvt_type_cd,
    dtfc.dtfc_marca_vpm AS vpm_type_cd,
    CASE
        WHEN ccld.rut IS NOT NULL OR substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('4')
            THEN 'VE'
        ELSE 'VR'
    END business_area_sales_flg, -- NIVEL1
    CASE
        WHEN ccld.rut IS NOT NULL OR substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('4')
            THEN 'VE'
        ELSE 
            CASE WHEN (substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtfc.fctr_marca_lb = 'S') OR dtfc.dtfc_marca_vpm = '3' OR (dtfc.dtfc_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
                THEN 'NSR' 
                ELSE 'SR' 
            END
    END channel_sales_flg, --NIVEL 2
    CASE  WHEN ccld.rut IS NOT NULL OR substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('4')
            THEN 'VE'
        ELSE 
            CASE WHEN (substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtfc.fctr_marca_lb = 'S') OR dtfc.dtfc_marca_vpm = '3' OR (dtfc.dtfc_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
                THEN 
                    CASE WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' 
                        THEN 'DVD'
                        ELSE 'KIOSKO'
                    END
                ELSE 'SR'
            END
    END sub_channel_level1_sales_flg, --NIVEL 3
    CASE  WHEN ccld.rut IS NOT NULL OR substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('4')
            THEN 'VE'
        ELSE 
            CASE WHEN (substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtfc.fctr_marca_lb = 'S') OR dtfc.dtfc_marca_vpm = '3' OR (dtfc.dtfc_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
                THEN 
                    CASE WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('7', '8')
                        THEN 'VAT'
                        WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN('0','20','25','26') 
                        THEN 'RESTO'
                        WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('1', '5', '6')
                        THEN 'WEB'
                        WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='9'
                        THEN 'APP'
                        WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('2', '3')
                        THEN 'CALL'
                        ELSE CASE WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' then 'WEB' ELSE 'RESTO' END
                    END
                ELSE 'SR'
            END
    END sub_channel_level2_sales_flg, --NIVEL 4
    CASE  WHEN ccld.rut IS NOT NULL 
        THEN 
        CASE WHEN fctr.fctr_tvta IN ('S','B','O') AND fctr.fctr_tvta_mesped = 'P'
             THEN 'VEFS'
             WHEN fctr.fctr_tvta IN ('S','O') AND fctr.fctr_tvta_mesped = 'M'
             THEN 'VEFM'
             WHEN fctr.fctr_tvta = 'D' AND fctr.fctr_tvta_voldet = 'V'
             THEN 'VEFD'        
        ELSE 'VEC'
        END    
    ELSE 
        CASE WHEN (substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN ('0','20', '23', '25', '26', '27') AND dtfc.fctr_marca_lb = 'S') OR dtfc.dtfc_marca_vpm = '3' OR (dtfc.dtfc_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105'))
            THEN 
                CASE WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '26'
                    THEN 'UX+'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN('0','20') and dtfc.dtfc_marca_vpm = '3'
                    THEN 'UXCDAD'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) IN('0','20') and dtfc.dtfc_marca_vpm = '1' and trim(ITMD.hier_family_cd) not in ('0101','0103','0104','0105')
                    THEN 'UXCRT'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '25'
                    THEN 'SSEE'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='7'
                    THEN 'VATT'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '27' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='8'
                    THEN 'VATI'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='1'
                    THEN 'SOD'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='6'
                    THEN 'HOMY'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='9'
                    THEN 'APPMOB'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) ='2'
                    THEN 'FCOMP'
                    WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23' AND substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 3, 1) IN ('3')
                    THEN 'FCOMP-EMP'
                    ELSE CASE WHEN substring(trim(cast(fctr.fctr_nro_vtassstock as string)), 1, 2) = '23'  then 'NCDVD' ELSE 'NCKIOSKO' END
                END
            ELSE 'SR'
        END
    END sub_channel_level3_sales_flg, --NIVEL5
    dtfc.item_codg AS item_id,
    dtfc.dtfc_ctdd AS unit_cnt,
    dtfc.dtfc_prec_original AS regular_unit_price_amt,
    dtfc.dtfc_ctd_vendida_um_venta AS bulk_unit_cnt,
    dtfc.dtfc_precio_um_venta AS bulk_unit_uom_amt,
    dtfc.dtfc_precio_extendido AS extended_amt,
    dtfc.dtfc_val_desc_unitario AS unit_discount_amt,
    dtfc.dtfc_ctun AS unit_cost_price_amt,
    dtfc.dtfc_prec AS transaction_unit_price_amt,
    dtfc.dtfc_cod_prom AS promotional_offer_id,
    dtfc.dtfc_um_venta AS transaction_item_uom_id,
    dtfc.fctr_marca_lb AS delivery_flg,
    dtfc.dtfc_tipo_prom AS promotion_type_cd,
    dtfc.dtfc_ctd_regalada AS transaction_gifted_qty,
    dtfc.dtfc_metodo_distribu AS distribution_method_type_cd,
    dtfc.dtfc_cod_metdistribu AS distribution_method_code_val,
    dtfc.dtfc_costoflete1 AS freight_cost_amt,
    dtfc.dtfc_costoflete2 AS last_mile_freight_cost_amt,
    dtfc.dtfc_costologistico AS logistic_cost_amt,
    dtfc.dtfc_valfleun AS unit_freight_amt,
	fctr.fctr_valr AS ST_Document_Total_NET_Amt,
	fctr.fctr_totl AS ST_Document_Total_Amt,
	(dtfc.dtfc_ctdd * dtfc.dtfc_prec) AS ST_Extended_NET_Amt,
	(dtfc.dtfc_ctdd * dtfc.dtfc_prec) * 1.19 AS ST_Extended_Amt,
    fctr.fctr_tvta AS Sales_Type_Cd,
    fctr.fctr_tvta_mesped AS Counter_Sales_Type_Cd,
    fctr.fctr_tvta_voldet AS Volume_Sales_Type_Cd,                                      

    'CL' AS country_id,    --Chile
    'SOD' AS Business_Unit_Id,   --Sodimac
    'fctr' AS sales_return_type_cd,  -- factura
    fctr.highwatermark AS sales_return_dt,  -- Usar HighWaterMark para la busqueda de las fechas, esto ya que este es creado en base a los 3 campos origen (CONCAT('20', lpad(fctr_ano, 2, "0"), '-', lpad(fctr_mes, 2, "0"), '-', lpad(fctr_dia, 2, "0")))

    PAGPRIN.cpgo_codg as Main_Payment_Type_Cd,
    MEDPAG.desmedio as Main_Payment_Type_Desc,
    CASE WHEN PAGCMR.cpgo_codg ='TF' 
        THEN 1  
        ELSE 0
    END AS Company_Card_Payment_Flg,

    CASE WHEN trim(coalesce(fctr.fctr_rut_especialista, '')) = '' or not trim(fctr.fctr_rut_especialista) rlike '^[0-9]+.$'
        THEN CASE WHEN CLIPRIN.pgfc_rut = 0 or CLIPRIN.pgfc_rut is null
                    THEN trim(cast(fctr.clnt_rut as string))
                    ELSE trim(cast(CLIPRIN.pgfc_rut as string))
                END
        ELSE regexp_replace(substr(trim(fctr.fctr_rut_especialista), 1 , length(trim(fctr.fctr_rut_especialista)) - 1),'^0+(?!$)','')
    END  Main_Customer_Id,

    $JOBID AS job_Id

FROM $PUBLISH_ZONE_DB.factura fctr

LEFT OUTER JOIN $PUBLISH_ZONE_DB.detalle_factura dtfc
    ON  fctr.highwatermark = dtfc.highwatermark
    AND fctr.unor_codg= dtfc.uvta_codg
    AND fctr.fctr_corr= dtfc.fctr_corr

LEFT OUTER JOIN $PUBLISH_ZONE_DB.cartera_clientes_dia ccld
ON fctr.clnt_rut = ccld.rut
AND fctr.highwatermark = ccld.highwatermark

LEFT OUTER JOIN (
    SELECT
        highwatermark
        ,uvta_codg
        ,fctr_corr
        ,cpgo_codg
        ,pgfc_rut
        ,sum_pgfc_valr
        ,Payment_Priority_Val
        from (
            SELECT 
                highwatermark
                ,uvta_codg
                ,fctr_corr
                ,cpgo_codg
                ,pgfc_rut
                ,sum_pgfc_valr
                ,Payment_Priority_Val
                ,ROW_NUMBER() OVER(PARTITION BY fctr_corr, uvta_codg order by sum_pgfc_valr desc, Payment_Priority_Val asc) unique_col
                from (
                SELECT
                    highwatermark
                    ,uvta_codg
                    ,fctr_corr
                    ,cpgo_codg
                    ,pgfc_rut 
                    ,COALESCE (PMTD.Payment_Priority_Val, 9999) as Payment_Priority_Val
                    ,sum(pgfc_valr) as sum_pgfc_valr
                    FROM $PUBLISH_ZONE_DB.pago_factura 
                    LEFT JOIN $TARGET_ZONE_DB.payment_method_type_dim PMTD
                        on cpgo_codg = PMTD.Payment_Method_type_cd
                        and country_id = 'CL'
                        and business_unit_id = 'SOD'
                    where highwatermark in $CONDICION_FECHA
                    group by highwatermark
                    ,uvta_codg
                    ,fctr_corr
                    ,cpgo_codg
                    ,pgfc_rut
                    ,COALESCE (PMTD.Payment_Priority_Val, 9999)
                    ) AGG1
                group by 
                highwatermark
                ,uvta_codg
                ,fctr_corr
                ,cpgo_codg
                ,pgfc_rut

                ,sum_pgfc_valr
                ,Payment_Priority_Val
            ) AGG2
        where unique_col = 1
    ) PAGPRIN
    ON  fctr.highwatermark = PAGPRIN.highwatermark
    AND fctr.unor_codg= PAGPRIN.uvta_codg
    AND fctr.fctr_corr= PAGPRIN.fctr_corr

LEFT OUTER JOIN (
        SELECT
        highwatermark
        ,uvta_codg
        ,fctr_corr
        ,cpgo_codg
        ,pgfc_rut
        FROM $PUBLISH_ZONE_DB.pago_factura 
        where cpgo_codg= 'TF'
        and highwatermark in $CONDICION_FECHA
        group by highwatermark
        ,uvta_codg
        ,fctr_corr
        ,cpgo_codg
        ,pgfc_rut
    ) PAGCMR
    ON  fctr.highwatermark = PAGCMR.highwatermark
    AND fctr.unor_codg= PAGCMR.uvta_codg
    AND fctr.fctr_corr= PAGCMR.fctr_corr

LEFT OUTER JOIN (
        SELECT 
            highwatermark
            ,uvta_codg
            ,fctr_corr
            ,cpgo_codg
            ,pgfc_rut
            ,unique_col
            from (
            SELECT
                highwatermark
                ,uvta_codg
                ,fctr_corr
                ,cpgo_codg
                ,pgfc_rut 
                ,COALESCE (PMTD.Payment_Priority_Val, 9999) as Payment_Priority_Val
                ,ROW_NUMBER() OVER(PARTITION BY fctr_corr, uvta_codg order by COALESCE (PMTD.Payment_Priority_Val, 9999) asc) unique_col
                FROM sod_cinfo_cl.pago_factura 
                LEFT JOIN $TARGET_ZONE_DB.payment_method_type_dim PMTD
                    on cpgo_codg = PMTD.Payment_Method_type_cd
                    and country_id = 'CL'
                    and business_unit_id = 'SOD'
                where highwatermark in $CONDICION_FECHA
                and (pgfc_rut <> 0 or pgfc_rut is not null) 
                group by highwatermark
                ,uvta_codg
                ,fctr_corr
                ,cpgo_codg
                ,pgfc_rut
                ,COALESCE (PMTD.Payment_Priority_Val, 9999)
                ) AGG1
            where unique_col = 1
            group by 
            highwatermark
            ,uvta_codg
            ,fctr_corr
            ,cpgo_codg
            ,pgfc_rut
            ,unique_col
    ) CLIPRIN
    ON  fctr.highwatermark = CLIPRIN.highwatermark
    AND fctr.unor_codg= CLIPRIN.uvta_codg
    AND fctr.fctr_corr= CLIPRIN.fctr_corr

LEFT JOIN $PUBLISH_ZONE_DB.med_pago MEDPAG
on PAGPRIN.cpgo_codg = MEDPAG.codmedio

LEFT JOIN $TARGET_ZONE_DB.ITEM_DIM ITMD
ON cast(dtfc.item_codg as int) = cast(ITMD.item_id as int)
and country_id = 'CL'
and business_unit_id = 'SOD'

WHERE fctr.highwatermark in $CONDICION_FECHA
