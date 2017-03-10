* 01.04.prepare_mcmc_vars.sas;
* J. Abowd 20120203;

%include "config.sas";
%let max_n=max;
%let max_n2=max;
%let max_piks=200000000;
%let random_seed=0;

data randomids(keep=randomid random_unique);
  length random_unique 8;
  do randomid=1 to &max_piks.;
    seed=&random_seed.;
    call ranuni(seed,random_unique);
    output;
  end;
run;

proc sort data=randomids out=randomids nodupkey;
  by random_unique;
run;

proc sort data=randomids out=INTERWRK.randomids(keep=random_unique);
  by randomid;
run;

options obs=&max_n.;

data INTERWRK.pik_histories (keep=pik theta);
  set INTERWRK.three_state_sample_clean;
  by pik;
  if first.pik then output;
run;

options obs=max;

data INTERWRK.pik_histories (keep=pik theta random_unique);
  merge INTERWRK.pik_histories(in=left)
        INTERWRK.randomids (in=right);
  format random_unique 18.14;
  if left & right;
run;

proc univariate data=INTERWRK.pik_histories;
  var random_unique;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik random_unique;
run;

data INTERWRK.pik_histories;
  set INTERWRK.pik_histories;
  do year=1999 to 2003;
    output;
  end;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik year theta;
run;

proc sort data=INTERWRK.pik_histories;
  by pik year;
run;

options obs=&max_n2.;

proc sort data=INTERWRK.three_state_sample_clean
  out=three_state_sample_clean (drop=theta); *theta is saved above so all obs have one;
  by pik year sein;
run;

options obs=max;

data INTERWRK.pik_histories;
  merge INTERWRK.pik_histories (in=left)
        three_state_sample_clean (in=right);
  by pik year;
  retain pik_count (0);
  if first.pik then pik_count+1;
  if left & ^right then do;
    sein="999999999999";
    output;
  end;
  else if left & right then output;
  *else put "ERROR in inputs:" pik= sein= year=; *uncomment for production;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein year;
  var theta psi pik_count;
run;

proc summary data=INTERWRK.pik_histories;
  by pik;
  var year;
  output out=INTERWRK.balanced_check
    n=year_count;
run;

proc freq data=INTERWRK.balanced_check;
  tables year_count;
run;

proc sort data=INTERWRK.pik_histories;
  by pik year;
run;

data INTERWRK.pik_histories;
  set INTERWRK.pik_histories;
  by pik year;
  length last_sein $12;
  retain match_count (0) last_sein ("");
  if first.pik then do;
    last_sein="";
    match_count+1;
  end;
  else do;
    if sein^=last_sein then match_count+1;
  end;      
  output; 
  last_sein=sein;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein last_sein year;
  var theta psi pik_count match_count;
run;

proc sort data=INTERWRK.pik_histories;
  by pik descending year;
run;

data INTERWRK.pik_histories;
  set INTERWRK.pik_histories;
  by pik descending year;
  length next_sein $12;
  retain next_sein ("") separation (0);
  if first.pik then do;
    next_sein="";
    separation=.;
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

proc sort data=INTERWRK.pik_histories;
  by pik year;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein last_sein next_sein year;
  var theta psi pik_count match_count separation;
run;
* LINES to comment above not needed in production;

proc sort data=INTERWRK.pik_histories;
  by sein pik year;
run;

data INTERWRK.pik_histories;
  set INTERWRK.pik_histories;
  by sein pik year;
  retain sein_count (0);
  if first.sein then sein_count+1;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein last_sein next_sein year;
  var theta psi pik_count match_count separation sein_count;
run;

proc sort data=INTERWRK.pik_histories;
  by pik year;
run;
  
data INTERWRK.pik_histories;
  set INTERWRK.pik_histories;
  by pik year;
  t=year-1998;
  separation_last=lag(separation);
  sein_count_last=lag(sein_count);
  match_count_last=lag(match_count);
  if first.pik then do;
    separation_last=.;
    sein_count_last=.;
    match_count_last=.;
  end;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein last_sein next_sein year t;
  var theta psi pik_count 
      match_count match_count_last
      separation separation_last
      sein_count sein_count_last;
run;

proc sort data=INTERWRK.pik_histories;
  by pik descending year;
run;
 
data INTERWRK.pik_histories;
  set INTERWRK.pik_histories;
  by pik descending year;
  separation_next=lag(separation);
  sein_count_next=lag(sein_count);
  match_count_next=lag(match_count);
  psi_next=lag(psi);
  if first.pik then do;
    separation_next=.;
    sein_count_next=.;
    match_count_next=.;
    psi_next=.;
  end;
run;

* This SORT and PRINT can be eliminated in production;

proc sort data=INTERWRK.pik_histories;
  by pik year;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein last_sein next_sein year t;
  var theta psi pik_count 
      match_count match_count_last match_count_next
      separation separation_last separation_next 
      sein_count sein_count_last sein_count_next;
run;

* Lines to comment above can be eliminated in production;

proc sort data=INTERWRK.pik_histories;
  by pik sein year;
run;

data INTERWRK.pik_histories;
  merge INTERWRK.pik_histories (in=left)
        INTERWRK.input_mu (in=right drop=_type_ _freq_);
  by pik sein;
  if left;
  if theta<REDACTED then theta_class=1;
  else theta_class=2;
  if psi=. then psi_class=3;
  else if psi<REDACTED then psi_class=1;
  else psi_class=2;
  if psi_next=. then psi_class_next=3;
  else if psi_next<REDACTED then psi_class_next=1;
  else psi_class_next=2;  
  if mu=. then mu_class=1;
  else if mu<REDACTED then mu_class=1;
  else mu_class=2;
  if (h>. & psi>. & resid>.) then adj_earn_log_real=h + psi + resid;
  format pik_count match_count match_count_last match_count_next
         sein_count sein_count_last sein_count_next 9.
	 separation separation_last separation_next
	 t theta_class psi_class mu_class 2.;
  label
    random_unique="Unique uniform random number"
    psi="Firm effect (AKM)"
    theta="Person effect (AKM)"
    cons="AKM constant"
    match_count="Unique sequential id for match"
    sein_count="Unique sequential id for firm"
    pik_count="Unique sequential id for person"
    separation="Indicator for separation at end of period"
    mu="Average resid in employment spell"
    theta_class="MCMC person type"
    psi_class="MCMC firm type"
    mu_class="MCMC match type"
    adj_earn_log_real="Ln real earn FT/FY exper/LF attach adj"
run;

proc sort data=INTERWRK.pik_histories;
  by pik year;
run;

proc print data=INTERWRK.pik_histories (obs=100);
  id pik sein last_sein next_sein year t;
  var theta theta_class
      psi psi_class 
      mu mu_class
      pik_count 
      match_count match_count_last match_count_next
      separation separation_last separation_next 
      sein_count sein_count_last sein_count_next;
run;

proc freq data=INTERWRK.pik_histories;
  tables year;
run;

proc means data=INTERWRK.pik_histories;
run;

proc means data=INTERWRK.pik_histories;
  where (year=2001);
  class theta_class psi_class mu_class;
  types theta_class psi_class mu_class theta_class*psi_class*mu_class;
  var adj_earn_log_real theta psi mu;
run;
