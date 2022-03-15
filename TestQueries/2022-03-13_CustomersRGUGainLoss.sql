WITH RGUSPRIMERDIA AS(
SELECT DISTINCT act_acct_cd, 
CASE WHEN pd_mix_cd = "1P" THEN 1
WHEN pd_mix_cd = "2P" THEN 2
WHEN pd_mix_cd = "3P" THEN 3
ELSE NULL END AS NUMRGUS1
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
WHERE org_cntry = "Jamaica" AND load_dt = '2022-02-01' AND (fi_outst_age < 90 OR fi_outst_age IS NULL)
GROUP BY act_acct_cd, NUMRGUS1
),
RGUSULTIMODIA AS(
SELECT DISTINCT act_acct_cd, 
CASE WHEN pd_mix_cd = "1P" THEN 1
WHEN pd_mix_cd = "2P" THEN 2
WHEN pd_mix_cd = "3P" THEN 3
ELSE NULL END AS NUMRGUS28
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.cwc_jam_dna_fullmonth_202202` 
WHERE org_cntry = "Jamaica" AND load_dt = '2022-02-28' --AND (fi_outst_age < 90 OR fi_outst_age IS NULL)
GROUP BY act_acct_cd, NUMRGUS28
),
CAMBIORGUS AS
(
    SELECT DISTINCT p.act_acct_cd,
    CASE WHEN (NUMRGUS28 - NUMRGUS1) > 0 THEN "Gain"
    WHEN (NUMRGUS28 - NUMRGUS1) < 0 THEN "Loss"
    WHEN (NUMRGUS28 - NUMRGUS1) = 0 THEN "Maintain"
    ELSE NULL END AS CAMBIORGUSMES
    FROM RGUSPRIMERDIA p LEFT JOIN RGUSULTIMODIA u ON p.act_acct_cd = u.act_acct_cd
)
SELECT CAMBIORGUSMES, COUNT (DISTINCT act_acct_cd) as NumUsers
FROM CAMBIORGUS
GROUP BY CAMBIORGUSMES
