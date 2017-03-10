************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* Locate worker records for event study and reconstruct log wage from components
-------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/01.30.analyze_event_histories.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

proc means data=INTERWRK.event_sample noprint;
  var log_wage net_log_wage;
  by cellid year;
  output out=INTERWRK.event_study(drop=_type_ _freq_ where=(_stat_="MEAN"));
run;

proc transpose data = INTERWRK.event_study OUT=INTERWRK.event_study;
  BY cellid;
  ID year;
  var log_wage net_log_wage;
run;

proc print data=INTERWRK.event_study;
run;

proc export data=INTERWRK.event_study(where=(_NAME_="log_wage")) outfile="./eventstudy_logwage.csv" DBMS=CSV replace;
run;

proc export data=INTERWRK.event_study(where=(_NAME_="net_log_wage")) outfile="./eventstudy_netlogwage.csv" DBMS=CSV replace;
run;