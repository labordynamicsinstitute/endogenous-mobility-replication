* 05.05.get_individual_characteristics.sas;
* J. Abowd 20130323;

%include "config.sas";
%let test_file=;
*options ls=170 obs=1000;

data interwrk.sample_icf;
  merge interwrk.pik_sample_ids(in=_a_ keep=pik)
        icffinal.icf_us_wide(keep=pik dob1 sex1 race1 ethnicity1 educ_c1
                                  dob_imputed sex_imputed race_imputed
                                  ethnicity_imputed educ_c_imputed);
  by pik;
  if _a_;
  length yob1 3;
  yob1=year(dob1);
  label yob1="Year of birth from ICF DOB1";
run;

proc freq data=interwrk.sample_icf;
  tables sex1*sex_imputed
         yob1*dob_imputed
         race1*race_imputed
         ethnicity1*ethnicity_imputed
         educ_c1*educ_c_imputed;
  title2 "demographic characteristics for sample";
run;
