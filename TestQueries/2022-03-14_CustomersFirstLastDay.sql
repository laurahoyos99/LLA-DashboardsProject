WITH CUSTOMERSPRIMERDIA AS(
SELECT DATE_TRUNC(LOAD_DT, MONTH ) AS MES, count(distinct cst_cust_cd) AS NUMCUSTOMERS1
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
WHERE org_cntry = "Jamaica" AND load_dt = '2022-02-01'
GROUP BY MES
),
CUSTOMERSULTIMODIA AS
(
SELECT DATE_TRUNC (LOAD_DT, MONTH) AS MES, count(distinct cst_cust_cd) AS NUMCUSTOMERS28
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
WHERE org_cntry = "Jamaica" AND load_dt = '2022-02-28'  
GROUP BY MES
)
SELECT t.MES, NumCustomers1, NumCustomers28
FROM CUSTOMERSPRIMERDIA t INNER JOIN CUSTOMERSULTIMODIA u ON t.MES = u.MES
GROUP BY t.MES, NumCustomers1, NumCustomers28
