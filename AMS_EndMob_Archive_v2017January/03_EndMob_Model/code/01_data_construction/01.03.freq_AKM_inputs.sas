* 01.03.freq_AKM_inputs.sas;
* J. Abowd 20120130;

%include "config.sas";
options obs=max;

data INTERWRK.three_state_sample_clean;
  set INTERWRK.three_state_sample;
  if resid>. & h>. & theta>.;
run;

proc means data=INTERWRK.three_state_sample_clean;
run;

proc summary data=INTERWRK.three_state_sample_clean;
  by pik sein;
  var resid;
  output out=INTERWRK.input_mu
    mean=mu;
run;

proc univariate data=INTERWRK.input_mu noprint;
  var mu;
  output out=INTERWRK.input_mu_distribution
  pctlpre=mu_p_ pctlpts = 0 to 100 by 1;
run;

data input_theta(keep=pik theta) input_psi(keep=sein psi);
  set INTERWRK.three_state_sample_clean;
  output input_theta;
  output input_psi;
run;

proc sort data=input_theta out=INTERWRK.input_theta nodupkey;
  by pik;
run;

proc sort data=input_psi out=INTERWRK.input_psi nodupkey;
  by sein;
run;

proc univariate data=INTERWRK.input_theta noprint;
  var theta;
  output out=INTERWRK.input_theta_distribution
  pctlpre=theta_p_ pctlpts = 0 to 100 by 1;
run;

proc univariate data=INTERWRK.input_psi noprint;
  var psi;
  output out=INTERWRK.input_psi_distribution
  pctlpre=psi_p_ pctlpts = 0 to 100 by 1;
run;
