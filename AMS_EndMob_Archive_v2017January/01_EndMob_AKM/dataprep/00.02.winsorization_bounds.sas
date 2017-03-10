*00.02.winsorization_bounds.sas;
*N. Zhao 20131216;
*Last modified: 20160217;
*Run after 00.01.annearn_ilinwi.sas;
/* Compute bounds for winsorizing the annual earnings data */

*** DATASETS ***;
/*
INPUTS:  annearn.annearn_s2013_ilinwi
OUTPUTS: dot.winsorization_bounds
*/

%include "config.sas";
libname dot ".";

*** AKM analysis dataset ***;
data interwrk.AKM_Universe_s2013_ilinwi;
	set annearn.annearn_s2013_ilinwi(where=((dominant="1") and (age ge 18 and age le 70) and (year ge 1999 and year le 2003))
			keep= age 
			      dominant
			      ethnicity
			      pik
			      race
			      real_ann_earn
			      sein
			      sex
			      sixq
			      year
			      );
run;

*** Winsorization bounds ***;
proc univariate data=interwrk.AKM_Universe_s2013_ilinwi(keep=real_ann_earn) noprint;
	var real_ann_earn;

	** lower bound: 0.01 percentile **;
	** upper bound: 99.99 percentile **;
	output out=dot.winsorization_bounds 
	       pctlpts  = 0 0.01 99.99 100
	       pctlpre  = winsor;
run;

data dot.winsorization_bounds;
	set dot.winsorization_bounds;

	label winsor0_01  = "lower bound for Winsorization"
	      winsor99_99 = "upper bound for Winsorization";
run;

title2 "##### WINSORIZATION BOUNDS: dominant jobs, 18-70 year olds, 1999-2003, IL-IN-WI #####";
proc print data=dot.winsorization_bounds;
run;
