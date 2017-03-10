* 05.04.balance_dominant_job_sample.sas;
* J. Abowd 20130323;

%include "config.sas";
%let test_file=;
*options ls=170 obs=1000;

data balanced (keep=pik year sample_half);
  set interwrk.pik_sample_ids; *list of piks that were processed in 05.02;
  by pik;
  length year 3;
  do year=1990 to 2011;
    output;
  end;
run;

proc sort data=balanced;
  by pik year;
run;

* fills in balanced data file;
data interwrk.sample_dominant_job_balanced;
  merge interwrk.sample_dominant_job(in=_a_)
        work.balanced(in=_b_);
  by pik year;
  if _b_;
  if ann_earn=. then ann_earn=0;
  if earn_q1=. then earn_q1=0;
  if earn_q2=. then earn_q2=0;
  if earn_q3=. then earn_q3=0;
  if earn_q4=. then earn_q4=0;
  if sein="" then sein="000000000000";
run;

*creates quarterly work array;
data interwrk.work_array(keep=pik work_array compress=yes);
  set interwrk.sample_dominant_job_balanced;
  by pik year;
  length work_array $88; *macroize this length and start, end years in config;
  retain work_array;
  if first.pik then do yy=1 to 88;
    substr(work_array,yy,1)="0";
  end;
  if earn_q1>0 then substr(work_array,(year-1990)*4+1,1)="1";
  if earn_q2>0 then substr(work_array,(year-1990)*4+2,1)="1";
  if earn_q3>0 then substr(work_array,(year-1990)*4+3,1)="1";
  if earn_q4>0 then substr(work_array,(year-1990)*4+4,1)="1";
  if last.pik then output;
run;

*creates the six_q window;
data interwrk.sample_dominant_job_balanced(drop=work_array);
  merge interwrk.sample_dominant_job_balanced(in=_a_)
        interwrk.work_array(in=_b_);
  by pik;
  if _a_ & _b_;
  length six_q $6;
  if year=1990 then do;
    six_q="0"||substr(work_array,1,5);
  end;
  else if year=2011 then do;
    six_q=substr(work_array,84,5)||"0";
  end;
  else do;
    six_q=substr(work_array,(year-1990)*4,6);
  end;
run;

proc freq data=interwrk.sample_dominant_job_balanced;
  tables six_q year*six_q/list;
  title2 "labor force attachement summary";
run;
