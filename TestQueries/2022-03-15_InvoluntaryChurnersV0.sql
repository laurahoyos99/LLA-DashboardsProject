WITH  CHURNERSINVOLUNTARIOS AS(
 SELECT DISTINCT DATE_TRUNC (LOAD_DT, MONTH) AS MES, act_acct_cd AS Churners, load_dt as FECHACHURN
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" and fi_outst_age =90
 GROUP BY MES, act_acct_cd, fechachurn
),
PAYMENTS AS(
 SELECT DISTINCT DATE_TRUNC (LOAD_DT, MONTH) AS MES, act_acct_cd AS User, load_dt as Fechacomp
 FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
 WHERE org_cntry = "Jamaica" and fi_outst_age <90 
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
