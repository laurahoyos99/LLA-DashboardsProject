WITH RGUSPRIMERDIA AS(
SELECT DISTINCT CST_CUST_CD, 
CASE WHEN pd_mix_cd = "1P" THEN 1
WHEN pd_mix_cd = "2P" THEN 2
WHEN pd_mix_cd = "3P" THEN 3
ELSE NULL END AS NUMRGUS1
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
WHERE org_cntry = "Jamaica" AND load_dt = '2022-02-01' 
GROUP BY cst_cust_cd, pd_mix_cd
),
RGUSULTIMODIA AS(
SELECT DISTINCT CST_CUST_CD, 
CASE WHEN pd_mix_cd = "1P" THEN 1
WHEN pd_mix_cd = "2P" THEN 2
WHEN pd_mix_cd = "3P" THEN 3
ELSE NULL END AS NUMRGUS28
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
WHERE org_cntry = "Jamaica" AND load_dt = '2022-02-28' 
),
CAMBIORGUS AS
(
    SELECT DISTINCT p.CST_CUST_CD,
    CASE WHEN (NUMRGUS28 - NUMRGUS1) > 0 THEN "Gain"
    WHEN (NUMRGUS28 - NUMRGUS1) < 0 THEN "Loss"
    WHEN (NUMRGUS28 - NUMRGUS1) = 0 THEN "Maintain"
    ELSE NULL END AS CAMBIORGUSMES
    FROM RGUSPRIMERDIA p LEFT JOIN RGUSULTIMODIA u ON p.cst_cust_cd = u.cst_cust_cd
)
SELECT CAMBIORGUSMES, COUNT (DISTINCT CST_CUST_CD)
FROM CAMBIORGUS
GROUP BY CAMBIORGUSMES
