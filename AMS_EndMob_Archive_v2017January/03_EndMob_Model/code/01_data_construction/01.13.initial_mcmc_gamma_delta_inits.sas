* 01.13.initial_mcmc_gamma_delta.sas;
* Ian Schmutte 20120202;

%include "config.sas";
%let max_n=max;
%let sample_name=;

proc freq data=INTERWRK.pik_histories&sample_name.;
  where(separation in (0,1));
  tables theta_class*psi_class*mu_class*separation/list out=INTERWRK.gamma;
  tables theta_class*psi_class*mu_class/list out=INTERWRK.gamma_margin;
run;

data INTERWRK.gamma(drop=count percent margin);
  merge INTERWRK.gamma(in=left)
        INTERWRK.gamma_margin(in=right drop=percent rename=(count=margin));
  by theta_class psi_class mu_class;
  if left & right;
  if margin>0 then gamma=count/margin;
run;

proc print data=INTERWRK.gamma;
  id theta_class psi_class mu_class separation;  
run;

proc freq data=INTERWRK.pik_histories&sample_name.;
 where(separation=1);
  tables theta_class*psi_class*mu_class*psi_class_next/list out=INTERWRK.delta;
  tables theta_class*psi_class*mu_class/list out=INTERWRK.delta_margin;
run;

data INTERWRK.delta(drop=count percent margin);
  merge INTERWRK.delta(in=left)
        INTERWRK.delta_margin(in=right drop=percent rename=(count=margin));
  by theta_class psi_class mu_class;
  if left & right;
  if margin>0 then delta=count/margin;
run;

proc print data=INTERWRK.delta;
  id theta_class psi_class mu_class psi_class_next;  
run;
