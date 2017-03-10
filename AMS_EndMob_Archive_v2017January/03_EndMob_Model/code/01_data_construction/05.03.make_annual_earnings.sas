* 05.03.make_annual_earnings.sas;
* J. Abowd 20130322;

%include "config.sas";
%let test_file=;
*options ls=170 obs=1000;

proc summary data=interwrk.sample_ehf nway;
  by pik sein;
  class year quarter;
  var earn;
  output out=sample_ehf(drop=_type_ _freq_)
    sum(earn)=earn;
run;

data interwrk.sample_annual_earnings (drop=earn quarter);
  set sample_ehf;
  by pik sein year quarter;
  retain ann_earn earn_q1 earn_q2 earn_q3 earn_q4;
  if year>=1990;
  if first.year then do;
    ann_earn=0;
    earn_q1=0;
    earn_q2=0;
    earn_q3=0;
    earn_q4=0;
  end;
  ann_earn=ann_earn+earn;
  if quarter=1 then earn_q1=earn;
  if quarter=2 then earn_q2=earn;
  if quarter=3 then earn_q3=earn;
  if quarter=4 then earn_q4=earn;
  if last.year then output;
run;

proc means data=interwrk.sample_annual_earnings;
  class year;
  var _numeric_;
  title2 "annual earnings before dominant job selection";
run;

proc sort data=interwrk.sample_annual_earnings
          out=sample_dominant_job;
  by pik year descending ann_earn;
run;

data interwrk.sample_dominant_job;
  set sample_dominant_job;
  by pik year;
  if first.year then output;
run;

proc means data=interwrk.sample_dominant_job;
  class year;
  var _numeric_;
  title2 "annual earnings after dominant job selection";
run;
