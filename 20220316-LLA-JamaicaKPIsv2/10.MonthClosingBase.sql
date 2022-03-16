WITH MONTHLASTDAY AS(
 SELECT DATE_TRUNC (LOAD_DT, MONTH) AS MES, MAX(LOAD_DT) AS LASTDAY
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" 
 GROUP BY MES
),
CLOSINGBASE AS(
SELECT DISTINCT MES, LASTDAY, act_acct_cd
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` t
INNER JOIN MONTHLASTDAY l ON l.LASTDAY = t.load_dt AND DATE_TRUNC (t.LOAD_DT, MONTH) = l.MES
WHERE org_cntry = "Jamaica" AND (fi_outst_age < 90 OR fi_outst_age IS NULL) AND
ACT_CUST_TYP_NM IN ('Browse & Talk HFONE', 'Residence', 'Standard') AND ACT_ACCT_STAT IN ('B','D','P','SN','SR','T','W')
GROUP BY MES, act_acct_cd, LASTDAY
)
SELECT MES, LASTDAY, COUNT (DISTINCT act_acct_cd) AS CLOSINGBASECUSTOMERS
FROM CLOSINGBASE
GROUP BY MES,LASTDAY
ORDER BY MES, LASTDAY
