SELECT

      dcnd.unor_codg AS Location_ID
    , dcnd.ntdb_corr AS Sales_Return_Document_Num
    , dcnd.dcnd_nmro AS Retail_Trans_Line_Item_Seq_Num
    , dcnd.tdcg_codg AS Charge_Discount_Type_Cd
    , dcnd.dcnd_mnto AS Charge_Discount_Amt
    , dcnd.dcnd_dccg AS Charge_Discount_Flg
    , dcnd.dcnd_sku AS Item_ID
    , dcnd.dcnd_precio_extendido AS Extended_Amt
    , dcnd.dcnd_um_venta AS Transaction_Item_UOM_Id
    , dcnd.dcnd_desc_prod AS Charge_Discount_Type_Desc
	, CASE WHEN ntdb.ntdb_tipo_doc_vta_org = 'BLT' THEN CASE WHEN dcnd.dcnd_dccg = 'D' THEN -dcnd.dcnd_mnto/1.19 ELSE dcnd.dcnd_mnto/1.19 END ELSE CASE WHEN dcnd.dcnd_dccg = 'D' THEN -dcnd.dcnd_mnto ELSE dcnd.dcnd_mnto END END AS st_extended_net_amt
	, CASE WHEN ntdb.ntdb_tipo_doc_vta_org = 'BLT' THEN CASE WHEN dcnd.dcnd_dccg = 'D' THEN -dcnd.dcnd_mnto ELSE dcnd.dcnd_mnto END ELSE CASE WHEN dcnd.dcnd_dccg = 'D' THEN -dcnd.dcnd_mnto * 1.19 ELSE dcnd.dcnd_mnto * 1.19 END END AS st_extended_amt
    , $JOBID AS job_Id
    
    , 'CL' AS Country_Id    --Chile
    , 'SOD' AS Business_Unit_Id   --Sodimac
    , 'cdnd' AS Sales_Return_Type_Cd
    , dcnd.highwatermark AS Sales_Return_Dt

FROM desc_cargo_nota_debito dcnd
LEFT JOIN nota_debito ntdb
ON ntdb.highwatermark = dcnd.highwatermark
AND ntdb.unor_codg= dcnd.unor_codg
AND ntdb.ntdb_corr = dcnd.ntdb_corr

WHERE dcnd.highwatermark in $CONDICION_FECHA
