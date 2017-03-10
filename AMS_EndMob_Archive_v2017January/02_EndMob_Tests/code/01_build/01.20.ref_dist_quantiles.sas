************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* This program stacks annwage for selected states and pulls selected
*variables that are relevant to the analysis. Imposes sample selection criteria.
*-----------------------------------------------------------
* REVISION LIST
* 
*-----------------------------------------------------------
* FILE INFORMATION;
%let thisfile=%sysget(PWD)/01.20.ref_dist_quantiles.sas;
%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;
proc sort data=OUTPUTS.HC_estimates_JBES(keep = pik theta year where=(year=2002)) nodupkey out=INTERWRK.pik_refsamp_JBES;
	by pik;
run;

proc sort data=OUTPUTS.HC_estimates_JBES(keep = sein psi year where=(year=2002)) nodupkey out=INTERWRK.sein_refsamp_JBES;
	by sein;
run;

proc sort data=OUTPUTS.HC_estimates_JBES(keep=pik sein year resid) out=HC_temp;
  by pik sein;
run;

/*make average residual and then get it's distribution in reference year*/
proc means data=HC_temp noprint;
  var resid;
  by pik sein;
  output out=muakm(drop = _type_ _freq_) mean(resid)=mu_akm;
run;

data INTERWRK.mu_refsamp_JBES(keep=pik sein mu_akm);
  merge HC_temp(where=(year=2002)) muakm;
  by pik sein;
run;

proc univariate data=INTERWRK.sein_refsamp_JBES noprint;
	var psi;
	output out=outputs.centiles_psi
		pctlpre=p_ pctlpts = 0 to 100 by 1;
run;

proc univariate data=INTERWRK.pik_refsamp_JBES noprint;
	var theta;
	output out=outputs.centiles_theta
		pctlpre=p_ pctlpts = 0 to 100 by 1;
run;

proc univariate data=INTERWRK.mu_refsamp_JBES noprint;
	var mu_akm;
	output out=outputs.centiles_mu
		pctlpre=p_ pctlpts = 0 to 100 by 1;
run;

proc corr data=OUTPUTS.HC_estimates_JBES(where=(year=2002));
	var theta psi;
run;

proc univariate data=OUTPUTS.HC_estimates_JBES(where=(year=2002)) noprint;
	var resid;
	output out=outputs.centiles_resid
		pctlpre=p_ pctlpts = 0 to 100 by 1;
run;