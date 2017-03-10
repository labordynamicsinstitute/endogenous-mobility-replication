* 05.09.sample_reassembled.sas;
* J. Abowd 20130324;

%include "config.sas";
%let test_file=;
*options ls=170 obs=1000;

data sample_dominant_job_hcep2;
  merge interwrk.sample_dominant_job_analysis(in=_a_ drop=sample_half)
        interwrk.sample_hcep_updated(keep=pik year cons theta psi raw_earn_real_log age sixqwindow
                                     rename=(age=age_hcep sixqwindow=six_q_hcep cons=cons_hcep));
  by pik year;
  if _a_;
  if (ln_real_ann_earn>.Z & raw_earn_real_log>.Z) then earn_diff=ln_real_ann_earn-raw_earn_real_log;
  label
    year="Year"
    raw_earn_real_log="Ln real_ann_earn HCEP"
    earn_diff="Ln real_ann_earn new-old";
    ;
run;

proc means data=sample_dominant_job_hcep2;
  where (1990<=year<=2010 & real_ann_earn>0);
  title2 "Check completeness of input data";
run;

*NOTE: NAME CHANGE WHEN DOING REPAIR--FIX DOWNSTREAM JOBS SHOULD BE FILE NAMES FROM 05.06;
data interwrk.sample_dominant_job_hcep2;
  merge sample_dominant_job_hcep2(in=_a_)
        interwrk.pik_sample_ids;
  by pik;
  if _a_;
run;

options ls=150;

proc means data=interwrk.sample_dominant_job_hcep2 n nmiss mean std min max;
  where (sample_half=1 & 1990<=year<=2010 & real_ann_earn>0);
  class year;
  var ln_real_ann_earn raw_earn_real_log earn_diff age age_hcep cons_hcep theta psi;
  title2 "with HCEF 2.4 variables included";
run;

proc corr data=interwrk.sample_dominant_job_hcep2;
  where (sample_half=1 & 1990<=year<=2003);
  var ln_real_ann_earn raw_earn_real_log earn_diff age age_hcep;
  title2 "correlation between original and new log real annual earnings, 1990-2003";
run;
