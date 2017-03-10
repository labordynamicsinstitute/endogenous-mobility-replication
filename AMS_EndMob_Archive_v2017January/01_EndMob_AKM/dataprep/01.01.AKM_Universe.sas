* 01.01.AKM_Universe.sas;
* I. Schmutte 2016 Feb 11;
* after 01.00.annearn_ilinwi.sas;

%include "config.sas";
options obs=max;

libname dot ".";

*** Winsorization bounds ***;
data work.winsor_bounds;
	set dot.winsorization_bounds(keep=winsor0_01 winsor99_99);

	call symput('winsor0001', put(winsor0_01,best12.));
	call symput('winsor9999', put(winsor99_99,best12.));
run;

/*extract realized mobility network strip and variables to be used in the AKM model*/
data interwrk.AKM_Universe_variables(
				keep=log_earn
				     age
				     black
				     hispanic
				     female
				     sixq1 sixq2 sixq3 sixq4 sixq5 sixq6
				     sixqleft sixqright sixqinter sixq4th
				     year
				     obsnum
				)
    interwrk.AKM_Universe_ids(keep=pik sein year obsnum)
    work.winsorized_earn(keep=real_ann_earn log_earn);
    retain log_earn year age black hispanic female 
           sixq1 sixq2 sixq3 sixq4 sixq5 sixq6 sixqleft sixqright sixqinter sixq4th
		   obsnum;
	set interwrk.AKM_Universe_s2013_ilinwi;
	array sixqw {6} (6*0);
	obsnum = _n_;
	hispanic = ethnicity = "H";
	black = race = "2";
	female = sex = "F";
	
	if real_ann_earn > 0 then do;
		if real_ann_earn < &winsor0001. then real_ann_earn = &winsor0001.;
		if real_ann_earn > &winsor9999. then real_ann_earn = &winsor9999.;
	end;
	log_earn = log(real_ann_earn);

	sixqw{1} = input(substr(sixq,1,1),1.);
	sixqw{2} = input(substr(sixq,2,1),1.);
	sixqw{3} = input(substr(sixq,3,1),1.);
	sixqw{4} = input(substr(sixq,4,1),1.);
	sixqw{5} = input(substr(sixq,5,1),1.);
	sixqw{6} = input(substr(sixq,6,1),1.);
	sixq1 = sum(of sixqw(*)) = 1;
	sixq2 = sum(of sixqw(*)) = 2;
	sixq3 = sum(of sixqw(*)) = 3;
	sixq4 = sum(of sixqw(*)) = 4;
	sixq5 = sum(of sixqw(*)) = 5;
	sixq6 = sum(of sixqw(*)) = 6;
	sixqleft = sixq  in ("100000", "110000", "111000","111100","111110","111111");
	sixqright = sixq in ("111111", "011111", "001111", "000111", "000011", "000001");
	sixqinter = sixq in ("10111", "110111", "111011", "111101", "100111", "110011", "111001", "100011","110001");
	sixq4th = substr(sixq,4,1) = "1";
run;

title2 "#### CONTENTS OF OUTPUT DATASETS ####";
proc contents data=interwrk.AKM_Universe_variables;
run;

proc contents data=interwrk.AKM_Universe_ids;
run;

/* Check winsorization */
proc univariate data=work.winsorized_earn noprint;
	var real_ann_earn log_earn;

	output out=work.winsorization_check
	       pctlpts  = 0 0.01 99.99 100
	       pctlpre  = w_earn w_ln_earn;
run;

title2 "##### WINSORIZATION CHECK: min=0.01 pctl and max=99.99 pctl #####";
proc print data=work.winsorization_check;
	var w_earn0 w_earn0_01 w_earn99_99 w_earn100;
run;
proc print data=work.winsorization_check;
	var w_ln_earn0 w_ln_earn0_01 w_ln_earn99_99 w_ln_earn100;
run;

/* Check for missing or wrong values. All variables should be observed */
title2 "#### INPUT FILE CHECK: check for missings or wrong values ####";
proc means data=interwrk.AKM_Universe_variables nolabels n nmiss mean std min p50 max;
	var _numeric_;
run;

