* 05.07.create_real_ann_earn.sas;
* J. Abowd 20130323;

%include "config.sas";
%include "/rdcprojects/co/co00538/programs/projects/auxiliary/macro_cpi.sas";
%let test_file=;
*options ls=170 obs=1000;

*create bounds for Windsorization in new;
*use 0.1 and 99.9 percentiles for this;

data interwrk.sample_dominant_job_analysis(drop=ann_earn earn_q1 earn_q2 earn_q3 earn_q4 yy);
  merge interwrk.sample_dominant_job_balanced(in=_a_)
        interwrk.sample_icf;
  by pik;
  if _a_;
  length female black hispanic six_q_1-six_q_6 six_q_left six_q_right six_q_count six_q_4th
         six_q_inter yy year1990-year2011 3;
  %xcpi;
  *reference year is 2000;
  real_ann_earn=ann_earn*(xcpi{2000}/xcpi{year});
  *hard-coded Windsorization;
  if ann_earn>0 then do;
    if real_ann_earn<XXX then real_ann_earn=XXX;
    if real_ann_earn>XXX then real_ann_earn=XXX;
  end;
  if real_ann_earn>0 then ln_real_ann_earn=log(real_ann_earn);
  else ln_real_ann_earn=.;
  age=year-yob1;
  age_2=age*age/10;
  age_3=age*age*age/100;
  age_4=age*age*age*age/1000;
  if sex1="F" then female=1;
  else female=0;
  if race1="2" then black=1;
  else black=0;
  if ethnicity1="H" then hispanic=1;
  else hispanic=0;
  array age_vars age age_2 age_3 age_4;
  array female_vars female_age female_age_2 female_age_3 female_age_4;
  array black_vars black_age black_age_2 black_age_3 black_age_4;
  array hispanic_vars hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4;
  do over age_vars;
    female_vars=female*age_vars;
    black_vars=black*age_vars;
    hispanic_vars=hispanic*age_vars;
  end;
  if (age<18 | age>70) then do;
    ln_real_ann_earn=.;
    real_ann_earn=.;
    sein="999999999999";
  end;
  six_q_count=substr(six_q,1,1)+substr(six_q,2,1)+substr(six_q,3,1)+substr(six_q,4,1)+
              substr(six_q,5,1)+substr(six_q,6,1);
  if six_q_count=6 then six_q_6=1;
  else six_q_6=0;
  if six_q_count=5 then six_q_5=1;
  else six_q_5=0;
  if six_q_count=4 then six_q_4=1;
  else six_q_4=0;
  if six_q_count=3 then six_q_3=1;
  else six_q_3=0;
  if six_q_count=2 then six_q_2=1;
  else six_q_2=0;
  if six_q_count=1 then six_q_1=1;
  else six_q_1=0;
  if substr(six_q,5,1)="1" then six_q_4th=1;
  else six_q_4th=0;
  if six_q in ("100000","110000","111000","111100","111110","111111") then six_q_left=1;
  else six_q_left=0;
  if six_q in ("000001","000011","000111","001111","011111","111111") then six_q_right=1;
  else six_q_right=0;
  if six_q in ("101111","110111","111011","111101","100111","110011","111001","100011","110001")
    then six_q_inter=1;
  else six_q_inter=0;
  array year_ind(1990:2011) year1990-year2011;
  do yy=1990 to 2011;
    if yy=year then year_ind{yy}=1;
    else year_ind{yy}=0;
  end;
  label
    real_ann_earn="Real Annual Earnings CPI base 2000"
    ln_real_ann_earn="Ln real_ann_earn"
    age="Age, beginning of year"
    age_2="Age squared/10"
    age_3="Age cubed/100"
    age_4="Age quartic/1000"
  ;
run;

*checks the Windsorization;
*verify that upper and lower bounds on real_ann_earn are as expected;
proc univariate data=interwrk.sample_dominant_job_analysis;
  where(1990<=year<=2010 & real_ann_earn>0); *analysis years;
  var real_ann_earn;
  output out=interwrk.sample_earn_percentiles
    pctlpre=p_ pctlpts = 0 to 4.9 by .1, 5 to 95 by 5, 95.1 to 100 by .1;
run;

proc print data=interwrk.sample_earn_percentiles;
  title2 "Percentiles of real annual earnings";
run;

*can be removed
proc means data=interwrk.sample_dominant_job_analysis;
  where(1990<=year<=2010 & real_ann_earn>0);
  title2 "Sample statistics 10 percent IN IL WI 1990-2010";
run;

*do not run on population; *one-percent sample is fine;
proc glm data=interwrk.sample_dominant_job_analysis;
  absorb pik;
  where(1990<=year<=2010 & real_ann_earn>0);
  model ln_real_ann_earn = age age_2 age_3 age_4
                           female_age female_age_2 female_age_3 female_age_4
                           black_age black_age_2 black_age_3 black_age_4
                           hispanic_age hispanic_age_2 hispanic_age_3 hispanic_age_4
                           six_q_2-six_q_6 six_q_4th six_q_left six_q_right six_q_inter
                           year1992-year2010 
                           /solution ss3;
  title2 "GLM for ln real earnings w/person effects";
run;
