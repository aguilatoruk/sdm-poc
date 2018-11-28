SELECT

      dcbl.unor_codg AS Location_ID
    , dcbl.blta_corr AS Sales_Return_Document_Num
    , dcbl.dcbl_nmro AS Retail_Trans_Line_Item_Seq_Num
    , dcbl.tdcg_codg AS Charge_Discount_Type_Cd
    , dcbl.dcbl_mnto AS Charge_Discount_Amt
    , dcbl.dcbl_dccg AS Charge_Discount_Flg
    , dcbl.dcbl_sku AS Item_ID
    , dcbl.dcbl_precio_extendido AS Extended_Amt
    , dcbl.dcbl_um_venta AS Transaction_Item_UOM_Id
    , dcbl.dcbl_desc_prod AS Charge_Discount_Type_Desc
	, case when dcbl.dcbl_dccg = 'D' THEN -dcbl.dcbl_mnto/1.19 ELSE dcbl.dcbl_mnto/1.19 END AS st_extended_net_amt
	, case when dcbl.dcbl_dccg = 'D' THEN -dcbl.dcbl_mnto ELSE dcbl.dcbl_mnto END AS st_extended_amt
	
    , $JOBID AS job_Id
    
    , 'CL' AS Country_Id    --Chile
    , 'SOD' AS Business_Unit_Id   --Sodimac
    , 'cdbo' AS Sales_Return_Type_Cd
    , dcbl.highwatermark AS Sales_Return_Dt

FROM desc_cargo_boleta dcbl
WHERE dcbl.highwatermark in $CONDICION_FECHA

