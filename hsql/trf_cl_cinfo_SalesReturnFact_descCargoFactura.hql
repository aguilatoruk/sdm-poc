SELECT

      dcft.unor_codg AS Location_ID
    , dcft.fctr_corr AS Sales_Return_Document_Num
    , dcft.dcft_nmro AS Retail_Trans_Line_Item_Seq_Num
    , dcft.tdcg_codg AS Charge_Discount_Type_Cd
    , dcft.dcft_mnto AS Charge_Discount_Amt
    , dcft.dcft_dccg AS Charge_Discount_Flg
    , dcft.dcft_sku AS Item_ID
    , dcft.dcft_precio_extendido AS Extended_Amt
    , dcft.dcft_um_venta AS Transaction_Item_UOM_Id
    , dcft.dcft_desc_prod AS Charge_Discount_Type_Desc
    , CASE WHEN dcft.dcft_dccg='D' THEN -dcft.dcft_mnto ELSE dcft.dcft_mnto END AS st_extended_net_amt
	, CASE WHEN dcft.dcft_dccg='D' THEN -dcft.dcft_mnto * 1.19 ELSE dcft.dcft_mnto * 1.19 END AS st_extended_amt
	, $JOBID AS job_Id
    	
    , 'CL' AS Country_Id    --Chile
    , 'SOD' AS Business_Unit_Id   --Sodimac
    , 'cdft' AS Sales_Return_Type_Cd
    , dcft.highwatermark AS Sales_Return_Dt

FROM desc_cargo_factura dcft
WHERE dcft.highwatermark in $CONDICION_FECHA

