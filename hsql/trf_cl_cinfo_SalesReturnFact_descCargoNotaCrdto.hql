SELECT

      dcnc.unor_codg AS Location_ID
    , dcnc.ntcr_corr AS Sales_Return_Document_Num
    , dcnc.dcnc_nmro AS Retail_Trans_Line_Item_Seq_Num
    , dcnc.tdcg_codg AS Charge_Discount_Type_Cd
    , dcnc.dcnc_mnto AS Charge_Discount_Amt
    , dcnc.dcnc_dccg AS Charge_Discount_Flg
    , dcnc.dcnc_sku AS Item_ID
    , dcnc.dcnc_precio_extendido AS Extended_Amt
    , dcnc.dcnc_um_venta AS Transaction_Item_UOM_Id
    , dcnc.dcnc_desc_prod AS Charge_Discount_Type_Desc
	, CASE WHEN ntcr.ntcr_docvta = 'B' THEN CASE WHEN dcnc.dcnc_dccg = 'D' THEN -dcnc.dcnc_mnto/1.19 ELSE dcnc.dcnc_mnto/1.19 END ELSE CASE WHEN dcnc.dcnc_dccg = 'D' THEN -dcnc.dcnc_mnto ELSE dcnc.dcnc_mnto END END AS st_extended_net_amt
	, CASE WHEN ntcr.ntcr_docvta = 'B' THEN CASE WHEN dcnc.dcnc_dccg = 'D' THEN -dcnc.dcnc_mnto ELSE dcnc.dcnc_mnto END ELSE CASE WHEN dcnc.dcnc_dccg = 'D' THEN -dcnc.dcnc_mnto * 1.19 ELSE dcnc.dcnc_mnto * 1.19 END END AS st_extended_amt
    , $JOBID AS job_Id
    
    , 'CL' AS Country_Id    --Chile
    , 'SOD' AS Business_Unit_Id   --Sodimac
    , 'cdnc' AS Sales_Return_Type_Cd
    , dcnc.highwatermark AS Sales_Return_Dt

FROM desc_cargo_nota_crdto dcnc
LEFT JOIN nota_credito ntcr
ON dcnc.highwatermark = ntcr.highwatermark
AND dcnc.unor_codg = ntcr.unor_codg
AND dcnc.ntcr_corr = ntcr.ntcr_corr
WHERE dcnc.highwatermark in $CONDICION_FECHA
