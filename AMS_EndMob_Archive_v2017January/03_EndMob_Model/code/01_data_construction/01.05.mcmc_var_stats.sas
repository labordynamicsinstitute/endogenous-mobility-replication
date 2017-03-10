* 01.05.mcmc_vars_stats.sas;
* J. Abowd 20120201;

%include "config.sas";
%let test_file=;

proc means data=INTERWRK.pik_histories&test_file.;
  where (year=2001);
  class theta_class psi_class mu_class;
  types theta_class psi_class mu_class theta_class*psi_class*mu_class;
  var adj_earn_log_real theta psi mu;
run;
