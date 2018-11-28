SELECT
     detalle.country_id
    ,detalle.sales_return_dt
    ,detalle.sales_return_type_cd
    ,detalle.business_unit_id
    ,detalle.location_id
        
    ,detalle.business_area_sales_flg
    ,detalle.business_area_sales_desc
    ,lvl1.agg_business_area_sales_cnt
       
    ,detalle.channel_sales_flg
    ,detalle.channel_sales_desc  
    ,lvl2.agg_channel_sales_cnt
    
    ,detalle.sub_channel_level1_sales_flg
    ,detalle.sub_channel_level1_sales_desc
    ,lvl3.agg_sub_channel_level1_cnt
    
    ,detalle.sub_channel_level2_sales_flg
    ,detalle.sub_channel_level2_sales_desc
    ,lvl4.agg_sub_channel_level2_cnt
        
    ,detalle.sub_channel_level3_sales_flg
    ,detalle.sub_channel_level3_sales_desc
    ,detalle.agg_sub_channel_level3_cnt
    ,detalle.st_extended_net_amt
    ,detalle.st_extended_amt
    ,$JOBID AS job_id    --Usar variable JOBID del proceso

FROM
(
select
     country_id
    ,sales_return_type_cd
    ,sales_return_dt
    ,business_unit_id
    ,location_id
        
    ,business_area_sales_flg
    ,CASE WHEN business_area_sales_flg = 'VE' THEN 'Venta Empresa'
          WHEN business_area_sales_flg = 'VR' THEN 'Venta Retail'
     END AS business_area_sales_desc
   
    ,channel_sales_flg
    ,CASE WHEN channel_sales_flg = 'VE'  THEN 'Venta Empresa'
          WHEN channel_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN channel_sales_flg = 'NSR' THEN 'Venta Non Store Retail'
     END AS channel_sales_desc  
   
    ,sub_channel_level1_sales_flg
    ,CASE WHEN sub_channel_level1_sales_flg = 'VE'  THEN 'Venta Empresa'
          WHEN sub_channel_level1_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN sub_channel_level1_sales_flg = 'KIOSKO' THEN 'Venta Kiosko'
          WHEN sub_channel_level1_sales_flg = 'DVD' THEN 'Venta DVD'
     END AS sub_channel_level1_sales_desc
     
    ,sub_channel_level2_sales_flg
    ,CASE WHEN sub_channel_level2_sales_flg = 'VE'  THEN 'Venta Empresa'
          WHEN sub_channel_level2_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN sub_channel_level2_sales_flg = 'VAT' THEN 'VAT'
          WHEN sub_channel_level2_sales_flg = 'RESTO' THEN 'Resto'
          WHEN sub_channel_level2_sales_flg = 'APP' THEN 'Mobile'
          WHEN sub_channel_level2_sales_flg = 'CALL' THEN 'Call'
          WHEN sub_channel_level2_sales_flg = 'WEB' THEN 'Web'
     END AS sub_channel_level2_sales_desc
    
    ,sub_channel_level3_sales_flg
    ,CASE WHEN sub_channel_level3_sales_flg = 'VEC'  THEN 'Venta Empresa Clientes'
	      WHEN sub_channel_level3_sales_flg = 'VES'  THEN 'Venta Empresa Subcanal'
          WHEN sub_channel_level3_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN sub_channel_level3_sales_flg = 'VATT' THEN 'VAT Tienda'
          WHEN sub_channel_level3_sales_flg = 'VATI' THEN 'VAT Internet'
          WHEN sub_channel_level3_sales_flg = 'UX+' THEN 'UXPOS+'
          WHEN sub_channel_level3_sales_flg = 'UXC' THEN 'UXPOS Cotizaciones'
          WHEN sub_channel_level3_sales_flg = 'SSEE' THEN 'Servicios Especiales'
          WHEN sub_channel_level3_sales_flg = 'APPMOB' THEN 'App Mobile'
          WHEN sub_channel_level3_sales_flg = 'FCOMP' THEN 'Fono Compra'
          WHEN sub_channel_level3_sales_flg = 'SOD' THEN 'Sodimac'
          WHEN sub_channel_level3_sales_flg = 'HOMY' THEN 'Homy'
          WHEN sub_channel_level3_sales_flg = 'CWEB' THEN 'Canje Web'
          WHEN sub_channel_level3_sales_flg = 'NCKIOSKO' THEN 'No Clasificado Kiosko'
          WHEN sub_channel_level3_sales_flg = 'NCDVD' THEN 'No Clasificado DVD'
     END AS sub_channel_level3_sales_desc
    ,COUNT(distinct sales_return_document_num) as agg_sub_channel_level3_cnt
    ,SUM(st_extended_net_amt) AS st_extended_net_amt
    ,SUM(st_extended_amt) AS st_extended_amt
FROM sales_return_fact
WHERE country_id = 'CL'
and business_unit_id = 'SOD'
and sales_return_Dt in $CONDICION_FECHA

group by country_id
    ,sales_return_type_cd
    ,sales_return_dt
    ,business_unit_id
    ,location_id
        
    ,business_area_sales_flg
    ,CASE WHEN business_area_sales_flg = 'VE' THEN 'Venta Empresa'
          WHEN business_area_sales_flg = 'VR' THEN 'Venta Retail'
     END
    ,channel_sales_flg
    ,CASE WHEN channel_sales_flg = 'VE'  THEN 'Venta Empresa'
          WHEN channel_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN channel_sales_flg = 'NSR' THEN 'Venta Non Store Retail'
     END    

    ,sub_channel_level1_sales_flg
    ,CASE WHEN sub_channel_level1_sales_flg = 'VE'  THEN 'Venta Empresa'
          WHEN sub_channel_level1_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN sub_channel_level1_sales_flg = 'KIOSKO' THEN 'Venta Kiosko'
          WHEN sub_channel_level1_sales_flg = 'DVD' THEN 'Venta DVD'
     END
     ,sub_channel_level2_sales_flg
    ,CASE WHEN sub_channel_level2_sales_flg = 'VE'  THEN 'Venta Empresa'
          WHEN sub_channel_level2_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN sub_channel_level2_sales_flg = 'VAT' THEN 'VAT'
          WHEN sub_channel_level2_sales_flg = 'RESTO' THEN 'Resto'
          WHEN sub_channel_level2_sales_flg = 'APP' THEN 'Mobile'
          WHEN sub_channel_level2_sales_flg = 'CALL' THEN 'Call'
          WHEN sub_channel_level2_sales_flg = 'WEB' THEN 'Web'
     END
   
    ,sub_channel_level3_sales_flg
    ,CASE WHEN sub_channel_level3_sales_flg = 'VEC'  THEN 'Venta Empresa Clientes'
	      WHEN sub_channel_level3_sales_flg = 'VES'  THEN 'Venta Empresa Subcanal'
          WHEN sub_channel_level3_sales_flg = 'SR'  THEN 'Venta Store Retail'
          WHEN sub_channel_level3_sales_flg = 'VATT' THEN 'VAT Tienda'
          WHEN sub_channel_level3_sales_flg = 'VATI' THEN 'VAT Internet'
          WHEN sub_channel_level3_sales_flg = 'UX+' THEN 'UXPOS+'
          WHEN sub_channel_level3_sales_flg = 'UXC' THEN 'UXPOS Cotizaciones'
          WHEN sub_channel_level3_sales_flg = 'SSEE' THEN 'Servicios Especiales'
          WHEN sub_channel_level3_sales_flg = 'APPMOB' THEN 'App Mobile'
          WHEN sub_channel_level3_sales_flg = 'FCOMP' THEN 'Fono Compra'
          WHEN sub_channel_level3_sales_flg = 'SOD' THEN 'Sodimac'
          WHEN sub_channel_level3_sales_flg = 'HOMY' THEN 'Homy'
          WHEN sub_channel_level3_sales_flg = 'CWEB' THEN 'Canje Web'
          WHEN sub_channel_level3_sales_flg = 'NCKIOSKO' THEN 'No Clasificado Kiosko'
          WHEN sub_channel_level3_sales_flg = 'NCDVD' THEN 'No Clasificado DVD'
     END
) detalle

LEFT JOIN (
    select 
    business_unit_id
    ,country_id
    ,sales_return_dt
    ,sales_return_type_cd
    ,business_area_sales_flg
    ,location_id
    ,count(distinct sales_return_document_num) AS agg_business_area_sales_cnt
from  sales_return_fact 
where country_id = 'CL'
and business_unit_id = 'SOD'
and sales_return_dt in $CONDICION_FECHA
group by business_unit_id,country_id,sales_return_type_cd,sales_return_dt,business_area_sales_flg,location_id
) lvl1
ON  lvl1.country_id = detalle.country_id
AND lvl1.sales_return_dt = detalle.sales_return_dt
AND lvl1.sales_return_type_cd = detalle.sales_return_type_cd
AND lvl1.business_area_sales_flg = detalle.business_area_sales_flg
AND lvl1.location_id = detalle.location_id

LEFT JOIN (
select
    business_unit_id
    ,country_id 
    ,sales_return_type_cd
    ,sales_return_dt
    ,channel_sales_flg
    ,location_id
    ,count(distinct sales_return_document_num) AS Agg_Channel_Sales_Cnt
from  sales_return_fact 
where country_id = 'CL'
and business_unit_id = 'SOD'
and sales_return_dt in $CONDICION_FECHA
group by business_unit_id,country_id,sales_return_type_cd,sales_return_dt,channel_sales_flg,location_id
) lvl2
ON  lvl2.country_id = detalle.country_id
AND lvl2.sales_return_dt = detalle.sales_return_dt
AND lvl2.sales_return_type_cd = detalle.sales_return_type_cd
AND lvl2.channel_sales_flg = detalle.channel_sales_flg
AND lvl2.location_id = detalle.location_id

LEFT JOIN (
select 
    business_unit_id
    ,country_id
    ,sales_return_type_cd
    ,sales_return_dt
    ,sub_channel_level1_sales_flg
    ,location_id
    ,count(distinct sales_return_document_num) AS Agg_Sub_Channel_Level1_Cnt
from  sales_return_fact 
where country_id = 'CL'
and business_unit_id = 'SOD'
and sales_return_dt in $CONDICION_FECHA 
group by business_unit_id,country_id,sales_return_type_cd,sales_return_dt,sub_channel_level1_sales_flg,location_id
) lvl3
ON  lvl3.country_id = detalle.country_id
AND lvl3.sales_return_dt = detalle.sales_return_dt
AND lvl3.sales_return_type_cd = detalle.sales_return_type_cd
AND lvl3.sub_channel_level1_sales_flg = detalle.sub_channel_level1_sales_flg
AND lvl3.location_id = detalle.location_id

LEFT JOIN (
select 
    business_unit_id
    ,country_id
    ,sales_return_type_cd
    ,sales_return_dt
    ,sub_channel_level2_sales_flg
    ,location_id
    ,count(distinct sales_return_document_num) AS agg_sub_channel_level2_cnt
from  sales_return_fact 
where country_id = 'CL'
and business_unit_id = 'SOD'
and sales_return_dt in $CONDICION_FECHA 
group by business_unit_id,country_id,sales_return_type_cd,sales_return_dt,sub_channel_level2_sales_flg,location_id
) lvl4
ON  lvl4.country_id = detalle.country_id
AND lvl4.sales_return_dt = detalle.sales_return_dt
AND lvl4.sales_return_type_cd = detalle.sales_return_type_cd
AND lvl4.sub_channel_level2_sales_flg = detalle.sub_channel_level2_sales_flg
AND lvl4.location_id = detalle.location_id
