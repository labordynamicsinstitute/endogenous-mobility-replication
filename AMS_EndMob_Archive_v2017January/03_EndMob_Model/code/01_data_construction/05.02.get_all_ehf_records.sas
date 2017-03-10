* 05.02.get_all_ehf_records.sas;
* J. Abowd 20130323;

%include "config.sas";
%let test_file=;
*options ls=170;

data interwrk.sample_ehf;
  merge nicfstag.nicf_stage_ui_ehf(in=_a_)
        interwrk.pik_sample_ids(in=_b_);
  by pik;
  length state_fips $2;
  if _a_ & _b_;
  state_fips=substr(sein,1,2);
run;

proc means data=interwrk.sample_ehf;
  class state_fips year;
  var earn;
  title2 "summary data from raw extract";
run;
