************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* This program aggregates residuals within dominant job
*-----------------------------------------------------------
* REVISION LIST
* 
*-----------------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/02.create_resid_deciles.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;


%let indata = OUTPUTS.HC_estimates_JBES;

data temp1(keep=sein resid) /view=temp1;
   set &indata.(keep=pik sein resid year where=(year=2002 and resid~=.));
run;

proc sort data=temp1 out=temp2;
  by sein;
run;

proc print data=temp2(obs=1000);
run;

*** Calculate the mean residual at the firm for the reference sample ***;

data temp3(keep=sein mean_resid counter);
   set temp2;
      by sein;

   retain mean_resid counter;
  
   if first.sein then do;
      mean_resid=0;
      counter=0;
   end;

   mean_resid=mean_resid+resid;
   counter=counter+1;

   if last.sein then do;
      mean_resid=mean_resid/counter;
      output;
   end;
run;

proc print data=temp3(obs=1000);
run;

*** Calculate the deciles ***;

proc univariate data=temp3;
        var mean_resid;
        output out=outputs.centiles_resid_firm
                pctlpre=p_ pctlpts = 0 to 100 by 1;
run;

proc univariate data=temp3;
        var mean_resid;
        weight counter;
        output out=outputs.centiles_resid_firm_weight
                pctlpre=p_ pctlpts = 0 to 100 by 1;
run;
