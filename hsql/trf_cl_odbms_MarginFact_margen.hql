SELECT 

  Item_ID as Item_Id
, Country_Id As Country_Id
, Business_Unit_ID as Business_Unit_ID
, Location_ID As Location_ID
, Accounting_Dt as Margin_Dt
, Transaction_Dt as Transaction_Dt
, Margin_Type_Cd as Margin_Type_Cd
, Major_Report_Cd 
, Minor_Report_Cd 
, Inventory_Transaction_Type_Cd
, Inventory_Transaction_Type_Desc
, SUM(Venta) as Sales_Amt
, SUM(Venta)-SUM(Tax) as ST_Sales_Amt
, SUM(Tax) as Tax_Amt
, SUM(Costo) as Cost_Amt
, SUM(Venta)-SUM(Tax)-SUM(Costo) as Contribution_Amt
, SUM(Cant) as Unit_Cnt
, CASE WHEN (SUM(Venta) - SUM (Tax))<>0
    THEN (SUM(Venta) - SUM(Tax) - SUM(Costo)) / (SUM(Venta) - SUM(Tax))
    ELSE 0
    END Margin_Pct
, '$JOBID' as job_id
    
FROM (
    SELECT 
    Item_ID
    , Country_Id
    , Business_Unit_ID
    , Location_ID
    , from_unixtime(unix_timestamp(Transaction_Accounting_Dt , 'yyyy-MM-dd'), 'yyyy-MM-dd') Accounting_Dt
    , Transaction_Dt
    , INV.Major_Report_Cd 
    , INV.inventory_transaction_type_cd
    , INV.Minor_Report_Cd 
    , BI2.inv_drpt_desc as Inventory_Transaction_Type_Desc

    , SUM (CASE WHEN trim(major_report_cd) <> 'AE'
        THEN CASE WHEN trim(ballance_effect_sign_price_flg) = '+'
             THEN -Extended_Amt
             ELSE Extended_Amt
             END
        ELSE 0
      END) Venta

    , SUM (CASE WHEN trim(major_report_cd) <> 'AE'
        THEN CASE WHEN trim(ballance_effect_sign_price_flg) = '+'
             THEN -Extended_Tax_Amt
             ELSE Extended_Tax_Amt
             END
        ELSE 0
      END) Tax

    , SUM (CASE WHEN trim (Ballance_Effect_Sign_Cost_Flg) <> 'null'
            THEN CASE WHEN trim(Ballance_Effect_Sign_Cost_Flg) = '+'
                THEN -Extended_Cost_Amt
                ELSE Extended_Cost_Amt
                END
            ELSE CASE WHEN trim(BI.ref_4_eff) <> 'null'
                THEN CASE WHEN trim(BI.ref_4_eff) = '-' 
                    THEN -Extended_Cost_Amt
                    ELSE Extended_Cost_Amt
                    END
                ELSE 0
            END
      END) Costo

    ,SUM (CASE WHEN trim(major_report_cd) <> 'AE'
        THEN CASE WHEN trim(ballance_effect_sign_price_flg) = '+'
             THEN -Transaction_Qty
             ELSE Transaction_Qty
             END
        ELSE 0
      END) Cant

    , CASE WHEN BI.inv_mrpt_code IS NOT null
        THEN 'Margen General'
        ELSE 'No Considerado en Margen'
      END as Margin_Type_Cd

    FROM $PUBLISH_ZONE_DB.Inventory_Transaction_Fact INV

        LEFT JOIN $WORK_ZONE_DB.invtrdbi BI
        ON INV.Major_Report_Cd = BI.inv_mrpt_code
        AND INV.inventory_transaction_type_cd = BI.inv_trn_code
        AND INV.Minor_Report_Cd = BI.inv_drpt_code
        AND TRIM(BI.ref_4_var) <> 'null'
        
        JOIN $WORK_ZONE_DB.invtrdbi BI2
        ON INV.Major_Report_Cd = BI2.inv_mrpt_code
        AND INV.inventory_transaction_type_cd = BI2.inv_trn_code
        AND INV.Minor_Report_Cd = BI2.inv_drpt_code

    WHERE country_id = 'CL'
    AND Business_Unit_ID = 'SOD'
    AND TO_DATE(transaction_dt) IN $CONDICION_FECHA 

    group by
    Item_ID
    , Country_Id
    , Business_Unit_ID
    , Transaction_Dt
    , Location_ID
    , from_unixtime(unix_timestamp(Transaction_Accounting_Dt , 'yyyy-MM-dd'), 'yyyy-MM-dd')
    , INV.Major_Report_Cd 
    , INV.inventory_transaction_type_cd
    , INV.Minor_Report_Cd 
    , BI2.inv_drpt_desc

    , CASE WHEN BI.inv_mrpt_code IS NOT null
        THEN 'Margen General'
        ELSE 'No Considerado en Margen'
      END
) AGG

GROUP BY
  Item_ID
, Country_Id
, Margin_Type_Cd
, Business_Unit_ID
, Location_ID
, Accounting_Dt
, Transaction_Dt
, Major_Report_Cd 
, Minor_Report_Cd 
, Inventory_Transaction_Type_Cd
, Inventory_Transaction_Type_Desc
, '$JOBID'