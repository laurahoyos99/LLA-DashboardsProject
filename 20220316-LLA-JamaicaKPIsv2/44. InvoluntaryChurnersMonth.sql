WITH  CHURNERSINVOLUNTARIOS AS(
 SELECT DISTINCT DATE_TRUNC (LOAD_DT, MONTH) AS MES, act_acct_cd AS Churners, load_dt as FECHACHURN
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" 
 --AND fi_outst_age = 90 
 AND fi_outst_age = 120
 AND ACT_CUST_TYP_NM IN ('Browse & Talk HFONE', 'Residence', 'Standard') AND ACT_ACCT_STAT IN ('B','D','P','SN','SR','T','W') 
 GROUP BY MES, act_acct_cd, fechachurn
),
PAYMENTS AS(
 SELECT DISTINCT DATE_TRUNC (LOAD_DT, MONTH) AS MES, act_acct_cd AS User, load_dt as Fechacomp
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" 
 --AND  fi_outst_age <90
 AND  fi_outst_age <120
 AND ACT_CUST_TYP_NM IN ('Browse & Talk HFONE', 'Residence', 'Standard') AND ACT_ACCT_STAT IN ('B','D','P','SN','SR','T','W') 
 GROUP BY MES, User, FechaComp
),
REALCHURNERS AS(
 SELECT c.MES, c.Churners
 FROM CHURNERSINVOLUNTARIOS c LEFT JOIN PAYMENTS p ON c.Churners = p.User AND c.FechaChurn < p.Fechacomp
 WHERE p.User is null

)
SELECT MES, COUNT(DISTINCT Churners) as InvolChurners
FROM REALCHURNERS
GROUP BY MES
ORDER BY MES
