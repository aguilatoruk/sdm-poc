SELECT
    ntdb.unor_codg as location_id,
    ntdb.ntdb_corr as sales_return_document_num,
    dtnd.dtnd_item as retail_trans_line_item_seq_num,
    ntdb.ntdb_timestamp as transaction_dttm,
    ntdb.ntdb_total as transaction_total_amt,
    ntdb.ntdb_neto as transaction_total_net_amt,
    ntdb.ntdb_iva as transaction_total_tax_amt,
    substring(trim(string(ntdb.ntdb_num_reser_sstock)),4) as reservation_num, --desde el 4to caracter corresponde al numero de reserva.
    ntdb.rut_clie as customer_id,
    substring(trim(string(ntdb.ntdb_num_reser_sstock)), 1, 2) as channel_id, --los 2 primero campos corresponden a los canales del documento.
    substring(trim(string(ntdb.ntdb_num_reser_sstock)), 3, 1) as sub_channel_cd, -- 3r caracter corresponde a subcanal.
    ntdb.ntdb_tipo_beneficio as benefit_type_cd, --codigo, 0,1,2 o 3.  ej: venta normal, venta personal, venta costo 0, venta costo 0 +5%.  tipifica la venta.  similar a tdct (asociado al documento origen)

    'VR' as business_area_sales_flg,
    'SR' as channel_sales_flg,
    'SR' as sub_channel_level1_sales_flg,
    'SR' as sub_channel_level2_sales_flg,
    'SR' as sub_channel_level3_sales_flg,

    dtnd.item_codg as item_id, -- sku del producto sin digito verificador
    dtnd.dtnd_cntd as unit_cnt, --cantidad de articulos
    dtnd.dtnd_ctd_vendida_um_venta as bulk_unit_cnt, --cantidad de unidad de medida de venta
    dtnd.dtnd_precio_um_venta as bulk_unit_uom_amt, --precio por unidad de medida
    dtnd.dtnd_precio_extendido as extended_amt, --pxq precio por cantidad
    dtnd.dtnd_costocero as unit_cost_price_amt, --costo del producto puesto en la tienda
    dtnd.dtnd_prec as transaction_unit_price_amt, --precio unitario neto
    dtnd.dtnd_um_venta as transaction_item_uom_id, --unidad de medida de la venta
    dtnd.dtnd_metodo_distribu as distribution_method_type_cd, --codigo de metodo de distribucion.  como se abastece el producto desde el origen del producto hasta llegar a la tienda
    dtnd.dtnd_cod_metdistribu as distribution_method_code_val, --codigo de metodo de distribucion.  si una bodega es la que distribuye, viene codigo de la bodega (codigo del local de la bodega),  puede tambien venir codigo de proveedor.
    dtnd.dtnd_costoflete1 as freight_cost_amt, --costo del flete.  costo del producto hasta la tienda
    dtnd.dtnd_costoflete2 as last_mile_freight_cost_amt, --costo del flete.  costo de la "ultima milla", desde la tienda hasta el cliente
    dtnd.dtnd_costologistico as logistic_cost_amt, --costo logistico.
	ntdb.ntdb_tipo_doc_vta_org AS Origin_Document_Type_Cd,
	
	
	CASE WHEN ntdb.ntdb_tipo_doc_vta_org = 'BLT' THEN ntdb.ntdb_total/1.19 ELSE ntdb.ntdb_neto END AS ST_Document_Total_NET_Amt,
	ntdb.ntdb_total AS ST_Document_Total_Amt,
	CASE WHEN ntdb.ntdb_tipo_doc_vta_org = 'BLT' THEN (dtnd.dtnd_cntd * dtnd.dtnd_prec)/1.19 ELSE (dtnd.dtnd_cntd * dtnd.dtnd_prec) END AS ST_Extended_NET_Amt,
	CASE WHEN ntdb.ntdb_tipo_doc_vta_org = 'BLT' THEN (dtnd.dtnd_cntd * dtnd.dtnd_prec) ELSE (dtnd.dtnd_cntd * dtnd.dtnd_prec)*1.19 END AS ST_Extended_Amt,
	
    $JOBID as job_id,
    'CL' as country_id,
    'SOD' AS Business_Unit_Id,   --Sodimac
    'ntdb' as sales_return_type_cd, --nota de debito
    ntdb.highwatermark as sales_return_dt
FROM nota_debito ntdb
LEFT OUTER JOIN detalle_nota_debito dtnd
ON ntdb.highwatermark = dtnd.highwatermark
AND ntdb.unor_codg= dtnd.unor_codg
AND ntdb.ntdb_corr = dtnd.ntdb_corr

WHERE ntdb.highwatermark in $CONDICION_FECHA

