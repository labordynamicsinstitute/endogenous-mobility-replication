************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* This program aggregates residuals within dominant job
*-----------------------------------------------------------
* REVISION LIST
* 
*-----------------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/03.mean_resid_trans_analysis1.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;




data interwrk.domjob_cats2;
	set interwrk.domjob_cats2;
	rh_cat=put(theta_dec-1,1.)||put(last_psi_dec-1,1.)||put(psi_dec-1,1.);
	t_p0 = theta*last_psi;
	t_r0 = theta*last_resid;
	p0_r0 = last_psi*last_resid;
	t_p0_r0 = theta*last_psi*last_resid;
run;

/*proc reg data=interwrk.domjob_cats2;
	model psi = last_psi theta last_resid;
	model psi = last_psi theta last_resid t_p0 t_r0 p0_r0;
	model psi = last_psi theta last_resid t_p0 t_r0 p0_r0 t_p0_r0;
run;*/
	
proc freq data=interwrk.domjob_cats2;
	tables last_resid_dec*rh_cat/noprint chisq;
run;