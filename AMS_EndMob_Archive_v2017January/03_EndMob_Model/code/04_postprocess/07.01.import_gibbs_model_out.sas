* Ian M. Schmutte
* 07.01.import_gibbs_model_out.sas
* 2014-December-09
* import posterior mean wage effects produced by export_mean_gibbs.m;


	libname br_qrl   "/temporary/interwork/abowd001/networks/br_qrl";
	libname datain   "/temporary/interwork/abowd001/networks/outputs";
	libname outputs  "/temporary/interwork/abowd001/networks/outputs";
    libname interwrk "/temporary/interwork/abowd001/networks/interwrk";

options nocenter ls=130 ps=32000 fullstimer;

             data INTERWRK.GIBBS_MODEL_OUT    ;
             %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
             infile './gibbs_model_out.txt' delimiter='09'x MISSOVER DSD lrecl=32767 ;
                informat VAR1 best32. ;
                informat VAR2 $23. ;
                informat VAR3 $23. ;
                informat VAR4 $23. ;
                informat VAR5 $23. ;
                informat VAR6 $23. ;
                informat VAR7 best32. ;
                informat VAR8 $1. ;
                format VAR1 best32. ;
                format VAR2 $23. ;
                format VAR3 $23. ;
                format VAR4 $23. ;
                format VAR5 $23. ;
                format VAR6 $23. ;
                format VAR7 best32. ;
                format VAR8 $1. ;
             input
                         VAR1
                         VAR2
                         VAR3
                         VAR4
                         VAR5
                         VAR6 $
                         VAR7
                         VAR8 $
             ;
             if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
             run;

/*
proc import  datafile="./gibbs_model_out.txt" out=interwrk.gibbs_model_out DBMS=TAB replace;
	getnames=no;
run;
*/

proc print data=interwrk.gibbs_model_out(obs=10);
run;

data interwrk.gibbs_model_out(drop=var2 var3 var4 var5 var6);
	set interwrk.gibbs_model_out(rename=
	(var1 = orig_index
	var7 = employed)
	drop = var8);
	
	if employed=0 then var6="";
	XBeta_Gibbs = input(var2,best32.);
	Theta_Gibbs = input(var3,best32.);
	Psi_Gibbs   = input(var4,best32.);
	Mu_Gibbs    = input(var5,best32.);
        Resid_Gibbs = input(var6,best32.);
run;	


proc contents data=interwrk.gibbs_model_out;
run;

proc corr data=interwrk.gibbs_model_out(where=(employed=1));
var _numeric_;
run;
