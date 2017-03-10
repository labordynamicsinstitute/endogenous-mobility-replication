* 05.06.get_hcep24_characteristics.sas;
* J. Abowd 20130323;

%include "config.sas";
%let test_file=;
*options ls=170 obs=1000;

data sample_hcep(keep=pik year sein);
  set interwrk.sample_dominant_job_balanced;
  by pik year;
  if sein^="000000000000" then output;
run;

proc sort data=sample_hcep;
  by sein year pik;
run;

data interwrk.sample_hcep;
  merge sample_hcep(in=_a_)
        hc24.al_hc_by_sein
        hc24.ca_hc_by_sein
        hc24.de_hc_by_sein
        hc24.fl_hc_by_sein
        hc24.ia_hc_by_sein
        hc24.id_hc_by_sein
        hc24.il_hc_by_sein
        hc24.in_hc_by_sein
        hc24.ks_hc_by_sein
        hc24.ky_hc_by_sein
        hc24.md_hc_by_sein
        hc24.me_hc_by_sein
        hc24.mn_hc_by_sein
        hc24.mo_hc_by_sein
        hc24.mt_hc_by_sein
        hc24.nc_hc_by_sein
        hc24.nd_hc_by_sein
        hc24.nj_hc_by_sein
        hc24.nm_hc_by_sein
        hc24.ok_hc_by_sein
        hc24.or_hc_by_sein
        hc24.pa_hc_by_sein
        hc24.sc_hc_by_sein
        hc24.tx_hc_by_sein
        hc24.va_hc_by_sein
        hc24.vt_hc_by_sein
        hc24.wa_hc_by_sein
        hc24.wi_hc_by_sein
        hc24.wv_hc_by_sein
        ;
  by sein year pik;
  if _a_;
run;

proc means data=interwrk.sample_hcep;
  title2 "AKM characteristics for sample";
run;

proc sort data=interwrk.sample_hcep;
  by pik year;
run;
