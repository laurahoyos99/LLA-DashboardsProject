WITH FIRSTLASTDAYMONTH AS(
 SELECT DATE_TRUNC (LOAD_DT, MONTH) AS Month,MIN(LOAD_DT) AS FIRSTDAY, MAX(LOAD_DT) AS LASTDAY
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" AND (fi_outst_age < 90 OR fi_outst_age IS NULL) AND
 ACT_CUST_TYP_NM IN ('Browse & Talk HFONE', 'Residence', 'Standard') AND ACT_ACCT_STAT IN ('B','D','P','SN','SR','T','W') 
 GROUP BY Month
),
RGUSFirstDay AS(
SELECT DISTINCT DATE_TRUNC(load_dt, MONTH) as Month, act_acct_cd, 
CASE WHEN pd_mix_cd = "1P" THEN 1
WHEN pd_mix_cd = "2P"  THEN 2
WHEN pd_mix_cd = "3P"  THEN 3
ELSE NULL END AS RGUsFirst
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` t INNER JOIN 
FIRSTLASTDAYMONTH d on d.FIRSTDAY = t.LOAD_DT
WHERE org_cntry = "Jamaica" AND (fi_outst_age < 90 OR fi_outst_age IS NULL) AND
 ACT_CUST_TYP_NM IN ('Browse & Talk HFONE', 'Residence', 'Standard') AND ACT_ACCT_STAT IN ('B','D','P','SN','SR','T','W')
GROUP BY act_acct_cd, Month, RGUSFirst
),
RGUSLastDay AS(
SELECT DISTINCT DATE_TRUNC(load_dt, MONTH) as Month, act_acct_cd, 
CASE WHEN pd_mix_cd = "1P" THEN 1
WHEN pd_mix_cd = "2P"  THEN 2
WHEN pd_mix_cd = "3P" THEN 3
ELSE NULL END AS RGUSLast
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` t INNER JOIN 
FIRSTLASTDAYMONTH d on d.LASTDAY = t.LOAD_DT
WHERE org_cntry = "Jamaica" AND (fi_outst_age < 90 OR fi_outst_age IS NULL) AND
 ACT_CUST_TYP_NM IN ('Browse & Talk HFONE', 'Residence', 'Standard') AND ACT_ACCT_STAT IN ('B','D','P','SN','SR','T','W')
GROUP BY act_acct_cd, Month, RGUSLast
),
CAMBIORGUS AS
(
    SELECT DISTINCT 
    f.act_acct_cd, f.Month, 
    --l.act_acct_cd, l.Month,
    CASE WHEN (RGUSLast - RGUSFirst) > 0 THEN "Gain"
    WHEN (RGUSLast - RGUSFirst) < 0 THEN "Loss"
    WHEN (RGUSLast - RGUSFirst) = 0 THEN "Maintain"
    WHEN (RGUSFirst > 0 AND RGUSLast IS NULL) THEN "Churner"
    WHEN (RGUSFirst IS NULL AND RGUSLast > 0) THEN "New Customer"
    WHEN RGUsFirst IS NULL AND RGUSLAST IS NULL THEN "Null"
    END AS CAMBIORGUSMONTH
    FROM RGUSFirstDay f 
    LEFT JOIN RGUSLastDay l ON f.act_acct_cd = l.act_acct_cd and f.Month = l.Month
    --RIGHT JOIN RGUSLastDay l ON f.act_acct_cd = l.act_acct_cd and f.Month = l.Month
)
SELECT MONTH, CAMBIORGUSMONTH, COUNT(DISTINCT act_acct_cd) AS users
FROM CAMBIORGUS
GROUP BY CAMBIORGUSMONTH, MONTH
