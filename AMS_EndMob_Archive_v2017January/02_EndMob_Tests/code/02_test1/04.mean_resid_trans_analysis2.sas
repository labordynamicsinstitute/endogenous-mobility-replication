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
*%let thisfile=%sysget(PWD)/04.mean_resid_trans_analysis2.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

proc sort data=interwrk.domjob_cats2(keep=last_resid_dec last_psi_dec psi_dec) out=interwrk.domjob_cats_strip;
	by last_resid_dec;
run;

proc freq data=interwrk.domjob_cats_strip noprint;
	tables last_psi_dec*psi_dec /list out=interwrk.endmob_dectrans(drop = percent);
	by last_resid_dec;
run;


%macro all_decs(dec);
	proc sort data = interwrk.endmob_dectrans(where=(last_resid_dec=&dec.)) out=interwrk.endmob_dectrans_dec&dec.;
		by last_psi_dec;
	run;

	proc transpose data=interwrk.endmob_dectrans_dec&dec. out=interwrk.endmob_dectrans_wide&dec. (drop=_name_ _label_) prefix = dest;
		by last_psi_dec;
		id psi_dec;
		var count;
	run;
	
	proc datasets library=interwrk;
		delete endmob_dectrans_dec&dec.
	run;


%mend;

%all_decs(1);
%all_decs(2);
%all_decs(3);
%all_decs(4);
%all_decs(5);
%all_decs(6);
%all_decs(7);
%all_decs(8);
%all_decs(9);
%all_decs(10);

data interwrk.endmob_dectrans_byresid;
	set interwrk.endmob_dectrans_wide1 (in=d1)
	interwrk.endmob_dectrans_wide2 (in=d2)
	interwrk.endmob_dectrans_wide3 (in=d3)
	interwrk.endmob_dectrans_wide4 (in=d4)
	interwrk.endmob_dectrans_wide5 (in=d5)
	interwrk.endmob_dectrans_wide6 (in=d6)
	interwrk.endmob_dectrans_wide7 (in=d7)
	interwrk.endmob_dectrans_wide8 (in=d8)
	interwrk.endmob_dectrans_wide9 (in=d9)
	interwrk.endmob_dectrans_wide10 (in=d10);

	if d1 then last_resid_dec = 1;
	else if d2 then last_resid_dec=2;
	else if d3 then last_resid_dec=3;
	else if d4 then last_resid_dec=4;
	else if d5 then last_resid_dec=5;
	else if d6 then last_resid_dec=6;
	else if d7 then last_resid_dec=7;
	else if d8 then last_resid_dec=8;
	else if d9 then last_resid_dec=9;
	else last_resid_dec=10;
run;


	proc export data=interwrk.endmob_dectrans_byresid outfile="&outpath./endmob_dectrans_byresid_JBES.csv" DBMS=CSV replace; run;