* 05.08.cleanup_theta_psi.sas;
* J. Abowd 20130324;

%include "config.sas";
%let test_file=;
*options ls=170 obs=1000;

data psi(keep=sein psi) theta (keep=pik theta cons);
  set interwrk.sample_hcep;
  by pik year;
  if sein^="000000000000" & psi>.Z then output psi;
  if theta>.Z then output theta;
run;

proc means data=psi;
  title2 "All psi values in sample";
run;

proc means data=theta;
  title2 "All theta values in sample";
run;

proc sort data=psi out=interwrk.psi nodupkey;
  by sein;
run;

proc sort data=theta out=interwrk.theta nodupkey;
  by pik;
run;

*this step is necessary to make sure all the PIKs get thetas;
data sample_hcep;
  merge interwrk.sample_dominant_job_balanced(in=_a_ keep=pik sein year ann_earn)
        interwrk.sample_hcep;
  by pik year;
  if _a_;
run;

proc sort data=sample_hcep out=sample_hcep;
  by sein year;
run;

data sample_hcep;
  merge sample_hcep(in=_a_ drop=psi) interwrk.psi;
  by sein;
  if _a_;
run;

proc sort data=sample_hcep;
  by pik year;
run;

data interwrk.sample_hcep_updated;
  merge sample_hcep(in=_a_ drop=theta cons) interwrk.theta;
  by pik;
  if _a_;
run;

proc sort data=interwrk.sample_hcep_updated;
  by pik year;
run;

proc means data=interwrk.sample_hcep_updated;
  var ann_earn cons theta psi;
run;
