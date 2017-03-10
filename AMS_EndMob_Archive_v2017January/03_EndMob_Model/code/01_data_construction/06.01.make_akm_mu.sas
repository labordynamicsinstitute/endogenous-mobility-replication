* 06.01.make_akm_mu.sas;
* J. Abowd 20130125;

%include "config.sas";

options obs=max;

proc summary data=interwrk.psi;
  var psi;
  output out=interwrk.psi_mean(drop=_type_ _freq_) mean(psi)=psi_mean;
run;

proc print data=interwrk.psi_mean;
  title2 "Mean of all psi over SEIN";
run;

proc summary data=interwrk.theta;
  var theta cons;
  output out=interwrk.theta_mean(drop=_type_ _freq_) 
  mean(theta)=theta_mean mean(cons)=akm_cons;
run;

proc print data=interwrk.theta_mean;
  title2 "Mean of all theta over PIK";
run;

options obs=max;

data sample_dominant_job_hcep(drop=psi_mean theta_mean);
  set interwrk.sample_dominant_job_hcep2; *CHANGED TO BYPASS UNREPAIRED LOCKED FILE;
  if _n_=1 then do;
    set interwrk.psi_mean;
    set interwrk.theta_mean;
  end;  
  if sein^="999999999999" & psi=. then psi=psi_mean;
  if theta=. then do; *this does happen, dont know why;
    theta=theta_mean; 
    cons=akm_cons;
  end;
  if real_ann_earn>0 then depvar=ln_real_ann_earn-theta-psi;
run;

proc means data=sample_dominant_job_hcep;
  where(1990<=year<=2010 & real_ann_earn>0);
  var ln_real_ann_earn depvar theta psi cons;
  title2 "Check inputs for AKM decomposition based on HCEP 2.4";
run;

proc reg data=sample_dominant_job_hcep;
  where(1990<=year<=2010 & real_ann_earn>0);
  model depvar = age age_2 age_3 age_4
                 female_age female_age_2 female_age_3 female_age_4
                 black_age black_age_2 black_age_3 black_age_4
                 hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4
                 six_q_2-six_q_6 six_q_4th six_q_left six_q_right six_q_inter
                 year1992-year2010;
  output out=interwrk.sample_akm(keep=pik year sein depvar real_ann_earn 
                                      pred_akm resid_akm)
    predicted=pred_akm residual=resid_akm;
  title2 "Regression for ln real earnings w/person and firm effects removed";
run;

proc summary data=interwrk.sample_akm;
  where(1990<=year<=2010 & real_ann_earn>0);
  class pik sein;
  types pik*sein;
  var resid_akm;
  output out=interwrk.mu(drop=_type_ _freq_)
    mean(resid_akm)=mu;
run;

proc sort data=interwrk.sample_akm out=sample_akm;
  by pik sein;
run;

data sample_akm;
  merge sample_akm(in=_a_)
        interwrk.mu;
  by pik sein;
  if _a_;
  residual=depvar-pred_akm-mu;
run;

proc sort data=sample_akm out=interwrk.sample_akm;
  by pik year;
run;

data interwrk.sample_dominant_job_AKM;
  merge sample_dominant_job_hcep(in=_a_)
        interwrk.sample_akm(drop=sein real_ann_earn);
  by pik year;
  if _a_;
  label
    depvar="Ln_real_ann_earn-theta-psi"
    theta= "Person effect (AKM)"
    psi=   "Firm effect (AKM)"
    mu    ="Match effect (AKM)"
    resid_akm="AKM residual y-xb-theta-psi"
    residual ="full residual y-xb-theta-psi-mu"
    pred_akm ="AKM xb"
  ;
run;

proc means data=interwrk.sample_dominant_job_AKM;
  where(1990<=year<=2010 & real_ann_earn>0);
  var ln_real_ann_earn depvar theta psi mu pred_akm resid_akm residual;
  title2 "AKM decomposition based on HCEP 2.4";
run;

