* Ian M. Schmutte
* 07.03.br_gibbs_sein_level.sas
* 2014 December 9
* sein-level analysis;


	libname br_qrl   "$TEMP/interwork/abowd001/networks/br_qrl";
	libname datain   "$TEMP/interwork/abowd001/networks/outputs";
	libname outputs  "$TEMP/interwork/abowd001/networks/outputs";
    libname interwrk "$TEMP/interwork/abowd001/networks/interwrk";

options nocenter ls=130 ps=32000 fullstimer;

proc sort data=interwrk.br_qrl_gibbs;
	by sein;
run;

data interwrk.br_gibbs_sein;
	set interwrk.br_qrl_gibbs;
	exp_Xbeta_g = exp(Xbeta_gibbs);
	exp_theta_g = exp(theta_gibbs);
	exp_mu_g = exp(mu_gibbs);
	exp_Xbeta = exp(Xbeta_AKM);
	exp_theta = exp(theta_AKM);
	exp_mu = exp(mu_AKM);
run;

proc means data=interwrk.br_gibbs_sein(where=(employed=1)) noprint;
	var exp_xbeta_g exp_theta_g exp_mu_g exp_Xbeta exp_theta exp_mu psi_akm psi_gibbs qrl_c_imp1_Mean qrl_nok_c_imp1_Mean rl_ems_c_imp1_Mean;
	by sein;
	output out=interwrk.br_gibbs_sein_agg(drop=_type_ _freq_) mean= /autoname;
run;

data interwrk.br_gibbs_sein_agg;
	set interwrk.br_gibbs_sein_agg;
	ln_aggmatch_g = log(exp_xbeta_g_mean+exp_theta_g_mean+exp_mu_g_mean);
	ln_aggmatch = log(exp_Xbeta_mean + exp_theta_mean + exp_mu_mean);
run;
	

proc corr data=interwrk.br_gibbs_sein_agg;
    var qrl_c_imp1_Mean_mean qrl_nok_c_imp1_Mean_mean rl_ems_c_imp1_Mean_mean ln_aggmatch_g psi_gibbs_mean ln_aggmatch psi_akm_mean ;
run;
