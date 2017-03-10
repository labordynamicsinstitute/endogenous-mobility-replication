* 06.04.prepare_mcmc_vars.sas;
* I.M. Schmutte 20160201;
* This revision to restrict analysis to the original 3-state/5-year population from v2012September paper
* 06.04.prepare_mcmc_vars.sas;
* J. Abowd 20130127;

%include "config.sas";

options obs=max fullstimer;


options obs=max;

data sample_dominant_job_AKM;
  set INTERWRK.sample_dominant_job_AKM(where=(sample_half=1 and year ge 1999 and year le 2004));
  if sein="999999999999" then sein="000000000000";
  state = substr(sein,1,2);
  if (state not in ("17","18","55")) then sein="000000000000"; *We need to eliminate out-of-state observations while preserving the balanced panel.;
run;

data activepiks(keep=pik);
  set sample_dominant_job_AKM;
  by pik year;
  retain everactive;
  if first.pik then everactive=0;
  if sein not in ("000000000000","999999999999") and year < 2004 then everactive=1; *eliminate piks that are not employed in our three states between 1999-2003;
  if last.pik and everactive=1 then output;
run;

proc contents data=activepiks;
run;

data sample_dominant_job_AKM;
  merge sample_dominant_job_AKM (in=a)
        activepiks (in=b);
  by pik;
  if a and b then output;
run;

data INTERWRK.pik_histories_new_JBES(drop=last_sein);
  set sample_dominant_job_AKM;
  by pik year;
  if _n_=1 then do;
    set interwrk.psi_mean;
    set interwrk.theta_mean;
    set interwrk.mu_mean;
  end;
  length last_sein $12;
  retain pik_count (0) last_sein ("999999999999");
  if first.pik then do;
    last_sein="999999999999"; *blanks for missing causes problems, zero filled;
    pik_count+1;
  end;
  if sein^="000000000000" & psi=. then psi=psi_mean;
  if theta=. then do; *this does happen, dont know why;
    theta=theta_mean; 
    cons=akm_cons;
  end;
  if sein="000000000000" then do;
    mu=0;
    psi=0;
  end;
  t=year-1998;
  cons=akm_cons;
  if year=2004 and mu=. then mu=0; *don't use 2004 data;
  output; 
  last_sein=sein;
run;

proc print data=INTERWRK.pik_histories_new_JBES (obs=200);
  id pik sein pik_count year;
  var theta psi mu;
  title2 "After creation of pik_count";
run;

proc sort data=INTERWRK.pik_histories_new_JBES out=pik_histories_new;
  by pik descending year;
run;

data INTERWRK.pik_histories_new_JBES;
  set pik_histories_new;
  by pik descending year;
  length next_sein $12;
  retain next_sein ("") separation (0);
  if first.pik then do; *this should always be 2004;
    next_sein="999999999999";  *blank for missing causes a problem, zero filled;
    separation=-99.; *this value should never appear in 1999-2003 data;
  end;
  else do;
    if sein^=next_sein then separation=1;
    else separation=0;
  end;      
  output; 
  next_sein=sein;
run;

* This SORT and PRINT can be eliminated in production;
* The sort is just to make the print be in the correct order;
proc sort data=INTERWRK.pik_histories_new_JBES out=pik_histories_new;
  by pik year;
run;

proc print data=pik_histories_new (obs=200);
  id pik sein next_sein year;
  var theta psi mu pik_count separation;
  title2 "After creation of next_sein and separation";
run;
* LINES to comment above not needed in production;

proc sort data=pik_histories_new;
  by sein year;
run;

data INTERWRK.pik_histories_new_JBES interwrk.sein_to_seincount_xwalk_JBES(keep=sein sein_count);
  set pik_histories_new;
  by sein year;
  retain sein_count (-1) sein_hold; 
  if first.sein then do;
      if 1999<=year<=2003 then do;
          sein_count+1;
          output interwrk.sein_to_seincount_xwalk_JBES;
      end;
  end;
  sein_hold = sein_count;
  if year = 2004 and first.sein then sein_count = .;
  output INTERWRK.pik_histories_new_JBES;
  sein_count = sein_hold;
  format pik_count sein_count 9. separation 4. t 3.;
run;

proc print data=INTERWRK.sein_to_seincount_xwalk_JBES(obs=200);
  id sein sein_count;
  title2 "Checking SEIN count list: nonemployment SEIN 000000000000 sein_count 0";
run;

proc sort data=INTERWRK.pik_histories_new_JBES;
  by next_sein;
run;

data pik_histories_new;
  merge INTERWRK.pik_histories_new_JBES(in=_a_)
        INTERWRK.sein_to_seincount_xwalk_JBES
        (rename=(sein=next_sein sein_count=next_sein_count));
  by next_sein;
  if _a_;
run;

proc print data=pik_histories_new (obs=200);
  id pik year sein next_sein sein_count next_sein_count pik_count;
  var ln_real_ann_earn separation;
  title2 "Checking sein_count next_sein";
  
data INTERWRK.matches_sample_half_JBES (keep=pik_count sein_count);
  set pik_histories_new;
  if sein^="000000000000" & sein^="999999999999" & year^=2004 then output;
  *do not generate a match_count when the pik sein combination only occurs in 2004;
run;

proc sort data=INTERWRK.matches_sample_half_JBES nodupkey;
  by pik_count sein_count;
run;

data INTERWRK.matches_sample_half_JBES;
  set INTERWRK.matches_sample_half_JBES;
  by pik_count sein_count;
  retain match_count (0);
  if first.sein_count then match_count+1;
run;

proc sort data=pik_histories_new out=INTERWRK.pik_histories_new_JBES;
  by pik_count sein_count;
run;

data INTERWRK.pik_histories_new_JBES;
  merge INTERWRK.matches_sample_half_JBES(in=_b_)
      INTERWRK.pik_histories_new_JBES (in=_a_);
  by pik_count sein_count;
  if _a_;
  if sein="000000000000" then match_count=0;
run;

proc print data=INTERWRK.pik_histories_new_JBES (obs=200);
  id pik sein;
  var pik_count sein_count year match_count ln_real_ann_earn separation;
  title2 "Check match_count";
run;

proc sort data=INTERWRK.pik_histories_new_JBES;
  by pik year;
run;

proc print data=INTERWRK.pik_histories_new_JBES (obs=200);
  id pik sein next_sein year t;
  var ln_real_ann_earn
      theta
      psi
      mu
      pik_count 
      sein_count
      match_count 
      separation 
      next_sein_count;
  title2 "All MCMC variables ready";
run;

proc freq data=INTERWRK.pik_histories_new_JBES;
  tables year;
run;

data OUTPUTS.to_mcmc_half_JBES
  (keep=ln_real_ann_earn  pik_count  t  sein_count  match_count 
         separation next_sein_count 
         age age_2 age_3 age_4 female_age female_age_2 female_age_3 female_age_4
         black_age black_age_2 black_age_3 black_age_4
         hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4 
         six_q_2 six_q_3 six_q_4 six_q_5 six_q_6 six_q_left
         six_q_right six_q_4th six_q_inter 
         year2000-year2003 );
  length ln_real_ann_earn 8 pik_count 8 t 8 sein_count 8 match_count 8
         separation next_sein_count 8
         age age_2 age_3 age_4 female_age female_age_2 female_age_3 female_age_4
         black_age black_age_2 black_age_3 black_age_4
         hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4 8
         six_q_2 six_q_3 six_q_4 six_q_5 six_q_6 six_q_left
         six_q_right six_q_4th six_q_inter 3
         year2000-year2003 3;
  set INTERWRK.pik_histories_new_JBES;
  where (1999<=year<=2003);
  if ln_real_ann_earn=. then ln_real_ann_earn=-99;
  if separation=. then separation=-99;
  if next_sein_count=. then next_sein_count=-99;
  if match_count=. then match_count=-99;
run;

proc print data=OUTPUTS.to_mcmc_half_JBES (obs=200);
  var ln_real_ann_earn
      pik_count 
      t
      sein_count
      match_count 
      separation 
      next_sein_count;
  title2 "Variables in CSV file except X vars";
run;

proc means data=OUTPUTS.to_mcmc_half_JBES;
  var ln_real_ann_earn  pik_count  t  sein_count  match_count 
         separation next_sein_count 
         age age_2 age_3 age_4 female_age female_age_2 female_age_3 female_age_4
         black_age black_age_2 black_age_3 black_age_4
         hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4 
         six_q_2 six_q_3 six_q_4 six_q_5 six_q_6 six_q_left
         six_q_right six_q_4th six_q_inter 
         year2000-year2003;
  title2 "Analysis data all observations 1999-2003";
run;

proc means data=OUTPUTS.to_mcmc_half_JBES;
  where(sein_count>0);
  var ln_real_ann_earn  pik_count  t  sein_count  match_count 
         separation next_sein_count 
         age age_2 age_3 age_4 female_age female_age_2 female_age_3 female_age_4
         black_age black_age_2 black_age_3 black_age_4
         hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4 
         six_q_2 six_q_3 six_q_4 six_q_5 six_q_6 six_q_left
         six_q_right six_q_4th six_q_inter 
         year2000-year2003;
  title2 "Analysis data when employed 1999-2003";
run;

proc export data=OUTPUTS.to_mcmc_half_JBES
  outfile="$TEMP/interwork/abowd001/networks/outputs/to_mcmc_half_JBES.csv"
  dbms=csv
  replace;
run;
