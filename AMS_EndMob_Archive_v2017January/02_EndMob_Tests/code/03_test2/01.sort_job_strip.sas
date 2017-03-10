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
*%let thisfile=%sysget(PWD)/end_mob_test.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

%let indata = OUTPUTS.HC_estimates_JBES;

proc sort data=&indata.(keep = pik sein year resid theta psi) out=interwrk.job_strip_test2;
	by pik year sein;
run;


proc sort data=interwrk.job_strip_test2(where=(theta~=. and psi~=. and resid~=.)) out=interwrk.job_strip2;
	by sein year pik;
run;

proc contents;
proc means;
proc print data=interwrk.job_strip2(obs=1000);
run;
