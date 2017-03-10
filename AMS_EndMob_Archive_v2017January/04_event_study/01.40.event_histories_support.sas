************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* Count unique PIKS and SEINS for each cellid
-------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/01.40.event_histories_support.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

proc sort data=INTERWRK.event_sample(keep=pik cellid) out=INTERWRK.event_piks nodupkey;
  by pik;
run;

proc freq data=INTERWRK.event_piks;
  tables cellid;
  title "Number of unique PIKS contributing to each CELLID (mobility pattern)";
run;


proc sort data=INTERWRK.event_sample(keep=sein cellid) out=INTERWRK.event_seins nodupkey;
  by sein;
run;

proc freq data=INTERWRK.event_seins;
  tables cellid;
  title "Number of unique SEINS contributing to each CELLID (mobility pattern)";
run;

