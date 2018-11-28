SELECT
     header.country_id
    ,header.business_unit_id
    ,header.sales_return_type_cd
    ,header.sales_return_dt
    ,header.location_id
        
    ,header.business_area_sales_flg
    ,CASE WHEN header.business_area_sales_flg = 'VE' THEN 'Venta Empresa'
          WHEN header.business_area_sales_flg = 'VR' THEN 'Venta Retail'
     END AS business_area_sales_desc
    ,COUNT(distinct header.sales_return_document_num) as agg_business_area_sales_cnt
    ,SUM(header.st_document_total_net_amt) AS st_document_total_net_amt
    ,SUM(header.st_document_total_amt) AS st_document_total_amt
    ,$JOBID AS job_id    --Usar variable JOBID del proceso

FROM 
(select distinct 
	country_id,
	business_unit_id,
	sales_return_type_cd,
	sales_return_dt,
	location_id,
	Sales_Return_Document_Num,
	business_area_sales_flg,
	st_document_total_net_amt,
	st_document_total_amt
FROM sales_return_fact 
where country_id= 'CL' 
and business_unit_id = 'SOD'
and Sales_Return_Dt in $CONDICION_FECHA) header 
group by country_id
    ,sales_return_type_cd
    ,business_unit_id
    ,sales_return_dt
    ,location_id
    ,business_area_sales_flg
