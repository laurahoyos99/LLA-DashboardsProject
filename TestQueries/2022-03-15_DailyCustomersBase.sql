WITH MONTHLASTDAY AS(
 SELECT DATE_TRUNC (LOAD_DT, MONTH) AS MES, LOAD_DT AS MONTHDATE
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" 
 GROUP BY MES, load_dt
),
CLOSINGBASE AS(
SELECT DISTINCT MES, MONTHDATE, act_acct_cd
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` t
INNER JOIN MONTHLASTDAY l ON l.MONTHDATE = t.load_dt AND DATE_TRUNC (t.LOAD_DT, MONTH) = l.MES
WHERE org_cntry = "Jamaica" AND (fi_outst_age < 90 OR fi_outst_age IS NULL)
GROUP BY MES, act_acct_cd, MONTHDATE
)
SELECT MES, MONTHDATE, COUNT (DISTINCT act_acct_cd) AS CLOSINGBASECUSTOMERS
FROM CLOSINGBASE
GROUP BY MES,MONTHDATE
ORDER BY MES, MONTHDATE
