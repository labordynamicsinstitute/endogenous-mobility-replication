************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* Locate worker records for event study and reconstruct log wage from components
-------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/01.10.build_event_data.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

/*Find workers employer in all five years that have only two jobs and who change in 2001*/
proc sort data=OUTPUTS.HC_estimates_JBES;
  by pik year;
run;

data INTERWRK.event_piks(keep=pik);
  set OUTPUTS.HC_estimates_JBES;
  by pik;
  retain yearcount seincount last_sein change_year;
  if first.pik then do;
    yearcount=0;
    seincount=1;
    last_sein = sein;
    change_year = 1999;
  end;
  yearcount=yearcount+1;
  if sein ne last_sein then do;
    seincount = seincount+1;
    last_sein = sein;
    change_year = year;
  end;
  if last.pik and yearcount=5 and seincount=2 and change_year=2001 then output;
run;

data INTERWRK.event_sample;
  merge OUTPUTS.HC_estimates_JBES(in=a) INTERWRK.event_piks (in=b);
  by pik;
  log_wage = constAKM+theta+psi+Xb+resid;
  net_log_wage = constAKM+theta+psi+resid;
  if a and b then output;
run;

proc print data=INTERWRK.event_sample(obs=100);
run;

proc means data=INTERWRK.event_sample;
  var _numeric_;
run;

proc contents data=INTERWRK.event_sample;
run;



