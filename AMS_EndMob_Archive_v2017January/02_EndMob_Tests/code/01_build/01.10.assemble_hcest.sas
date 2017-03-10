************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* Read in human capital estimates output by MATLAB. Combine with worker, firm, and year identifiers.
-------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/01.10.assemble_hcest.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

proc import datafile="&outpath./HC_estimates_mfxsplit.txt" /*Should point to text file generated in ../../CG_Code/s02_CG_est_JBES*/
			out=OUTPUTS.HC_estimates_mfxsplit DBMS=TAB 
			replace;
run;

proc sort data=OUTPUTS.HC_estimates_mfxsplit;
	by obsnum;
run;

proc sort data=interwrk.AKM_Universe_mfxsplit_ids;
	by obsnum;
run;

data OUTPUTS.HC_estimates_mfxsplit(drop=seincount pikcount
								rename=(thetaAKM=theta
									    psiAKM = psi
									    XbAKM = Xb
									    ResidAKM = Resid));
  if _n_=1 then do;
    if 0 then
    set interwrk.AKM_Universe_piklist
        interwrk.AKM_Universe_seinlist;
    declare hash pikid(dataset: 'interwrk.AKM_Universe_piklist',
               ordered: 'ascending');
    pikid.definekey ("pikcount");
    pikid.definedata("pik");
    pikid.definedone();

    declare hash seinid(dataset: 'interwrk.AKM_Universe_seinlist',
               ordered: 'ascending');
    seinid.definekey ("seincount");
    seinid.definedata("sein");
    seinid.definedone();
  end;
  merge OUTPUTS.HC_estimates_mfxsplit
	interwrk.AKM_Universe_mfxsplit_ids;
  by obsnum;
  pikid.find();
  seinid.find();
run;

proc contents data=OUTPUTS.HC_estimates_mfxsplit;
run;

proc print data=OUTPUTS.HC_estimates_mfxsplit (obs=20);
run;