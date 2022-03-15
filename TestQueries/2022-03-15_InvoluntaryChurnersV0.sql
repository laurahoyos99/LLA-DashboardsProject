SELECT DISTINCT DATE_TRUNC (LOAD_DT, MONTH) AS MES, act_acct_cd AS Churners, MAX(fi_outst_age) AS OVERDUEDAYS
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica"
 GROUP BY MES, act_acct_cd
)
SELECT MES, COUNT(DISTINCT Churners) as InvolChurners
FROM CHURNERSINVOLUNTARIOS
WHERE OVERDUEDAYS = 60
GROUP BY MES
ORDER BY MES
