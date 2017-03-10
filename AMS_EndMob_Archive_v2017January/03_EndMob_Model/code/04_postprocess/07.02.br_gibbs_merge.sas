* Ian M. Schmutte
* 07.02.br_gibbs_merge.sas
* 2014 December 9
* merge input data with posterior mean wage effects and revenue data;


    libname br_qrl   "$TEMP/interwork/abowd001/networks/br_qrl";
    libname datain   "$TEMP/interwork/abowd001/networks/outputs";
    libname outputs  "$TEMP/interwork/abowd001/networks/outputs";
    libname interwrk "$TEMP/interwork/abowd001/networks/interwrk";

options nocenter ls=130 ps=32000 fullstimer;

proc contents data=INTERWRK.AKM_strip_JBES_ids; /*from xx.xx.sample_w_AKM.sas*/
run;

/*horizontal join of gibbs mean wage components and the piksein strip*/
data interwrk.piksein_strip_w_gibbs;
	merge INTERWRK.AKM_strip_JBES_ids
		interwrk.gibbs_model_out;
run;


/*Combine sein-level revenue data using piksein_strip from 06.04b.prepare_pik_sein_strip.sas*/
proc sort data=interwrk.piksein_strip_w_gibbs out=interwrk.tmp;
    by sein;
run;

proc sort data=br_qrl.br_qrl_sein_pctls;
    by sein;
run;

data interwrk.br_qrl_gibbs;
    merge interwrk.tmp(in=a)
        br_qrl.br_qrl_sein_pctls(in=b);
    by sein;
    if a then output;
run;


proc contents data=interwrk.br_qrl_gibbs;
run;

/*
proc corr data=interwrk.br_qrl_gibbs(where=(employed=1));
    var _numeric_;
run;
*/

proc datasets library=interwrk;
delete tmp;
run;