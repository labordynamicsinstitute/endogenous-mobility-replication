* 01.02.subset_sample.sas;
* J. Abowd 20120130;

%include "config.sas";
options obs=max;

data three_state_sample;
  set INPUTS.domjob_sample;
  where (state_work in ("17","18","55"));
run;

proc sort data=three_state_sample
  out=INTERWRK.three_state_sample;
  by pik sein year;
run;

proc freq data=INTERWRK.three_state_sample;
  tables year*state_work;
run;
