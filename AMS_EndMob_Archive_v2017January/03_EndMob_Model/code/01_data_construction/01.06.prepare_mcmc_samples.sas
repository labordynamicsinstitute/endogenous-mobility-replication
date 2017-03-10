* 01.06.prepare_mcmc_samples.sas;
* J. Abowd 20120202;

%include "config.sas";
%let max_n=max;
%let test_file=;
%let sample_rate=0.005;
%let sample_name=half_percent;

options obs=&max_n.;

data pik_sample_&sample_name.(drop=pik_count match_count sein_count
     match_count_last match_count_next sein_count_last sein_count_next);
  set INTERWRK.pik_histories&test_file.(where=(random_unique<&sample_rate.));
run;

options obs=max;

proc sort data=pik_sample_&sample_name.;
  by pik year;
run;

data INTERWRK.pik_sample_&sample_name.;
  set pik_sample_&sample_name.;
  by pik year;
  retain pik_count (0);
  if first.pik then pik_count+1;
run;

proc print data=INTERWRK.pik_sample_&sample_name. (obs=100);
  id pik sein year;
  var theta psi pik_count;
run;

proc summary data=INTERWRK.pik_sample_&sample_name.;
  by pik;
  var year;
  output out=INTERWRK.balanced_check_&sample_name.
    n=year_count;
run;

proc freq data=INTERWRK.balanced_check_&sample_name.;
  tables year_count;
run;

data INTERWRK.pik_sample_&sample_name.;
  set INTERWRK.pik_sample_&sample_name.;
  by pik year;
  retain match_count (0);
  if first.pik then do;
    match_count+1;
  end;
  else do;
    if sein^=last_sein then match_count+1;
  end;      
run;

proc print data=INTERWRK.pik_sample_&sample_name. (obs=100);
  id pik sein last_sein year;
  var theta psi pik_count match_count;
run;

proc sort data=INTERWRK.pik_sample_&sample_name.;
  by sein pik year;
run;

data INTERWRK.pik_sample_&sample_name.;
  set INTERWRK.pik_sample_&sample_name.;
  by sein pik year;
  retain sein_count (0);
  if first.sein then sein_count+1;
run;

proc sort data=INTERWRK.pik_sample_&sample_name.;
  by pik year;
run;

proc print data=INTERWRK.pik_sample_&sample_name. (obs=100);
  id pik sein last_sein next_sein year;
  var theta psi pik_count match_count separation sein_count;
run;
  
data INTERWRK.pik_sample_&sample_name.;
  set INTERWRK.pik_sample_&sample_name.;
  by pik year;
  sein_count_last=lag(sein_count);
  match_count_last=lag(match_count);
  if first.pik then do;
    sein_count_last=.;
    match_count_last=.;
  end;
run;

proc print data=INTERWRK.pik_sample_&sample_name. (obs=100);
  id pik sein last_sein next_sein year t;
  var theta psi pik_count 
      match_count match_count_last
      separation separation_last
      sein_count sein_count_last;
run;

proc sort data=INTERWRK.pik_sample_&sample_name.;
  by pik descending year;
run;
 
data INTERWRK.pik_sample_&sample_name.;
  set INTERWRK.pik_sample_&sample_name.;
  by pik descending year;
  sein_count_next=lag(sein_count);
  match_count_next=lag(match_count);
  if first.pik then do;
    sein_count_next=.;
    match_count_next=.;
  end;
run;

proc sort data=INTERWRK.pik_sample_&sample_name.;
  by pik year;
run;

proc print data=INTERWRK.pik_sample_&sample_name. (obs=100);
  id pik sein last_sein next_sein year t;
  var theta psi pik_count 
      match_count match_count_last match_count_next
      separation separation_last separation_next 
      sein_count sein_count_last sein_count_next;
run;

data INTERWRK.pik_sample_&sample_name.;
  set INTERWRK.pik_sample_&sample_name.;
  by pik year;
  * values below should be replaced by averages from population;
  alpha0=XXX;
  theta0_1=XXX;
  theta0_2=XXX;
  psi0_1=XXX;
  psi0_2=XXX;
  mu0_1=XXX;
  mu0_2=XXX;
  if adj_earn_log_real>. then do;
    w0=alpha0 + (1-(theta_class-1))*(theta0_1-theta0_2)
            + (1-(psi_class-1))*(psi0_1-psi0_2)
            + (1-(mu_class-1))*(mu0_1-mu0_2);
  end;
run;

proc print data=INTERWRK.pik_sample_&sample_name. (obs=100);
  id pik sein last_sein next_sein year t;
  var theta theta_class
      psi psi_class 
      mu mu_class
      pik_count 
      match_count match_count_last match_count_next
      separation separation_last separation_next 
      sein_count sein_count_last sein_count_next
      adj_earn_log_real w0;
run;

proc means data=INTERWRK.pik_sample_&sample_name.;
run;

proc means data=INTERWRK.pik_sample_&sample_name.;
  where (year=2001);
  class theta_class psi_class mu_class;
  types theta_class psi_class mu_class theta_class*psi_class*mu_class;
  var adj_earn_log_real w0 theta psi mu;
run;
