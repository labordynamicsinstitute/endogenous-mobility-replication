/********************
	05.mobdiag.sas
	Ian M. Schmutte

	2014-June

	DESCRIPTION: 
	We are going to make some diagnostic plots in the spirit of CHK and Abowd, McKinney, and Schmutte
*********************/
%include "../lib/config.sas";

%let indata=interwrk.domjob_cats2;

proc contents data=&indata.;
run;

proc means data=&indata.;
var _numeric_;
run;


%macro plotmaker(dataset,o_var,d_var,sum_var,tab_name);

	proc means data=&dataset. noprint;
		var &sum_var.;
		class &o_var. &d_var.;
		output out=interwrk.tmp_table(drop=_type_ _freq_) mean(&sum_var.) = &sum_var._mean;
	run;


	proc sort data=interwrk.tmp_table;
		by &o_var. &d_var.;
	run;


	data interwrk.&tab_name. (keep=orig &d_var._00--&d_var._10);
		retain &d_var._00 &d_var._01 &d_var._02 &d_var._03 &d_var._04 &d_var._05 &d_var._06 &d_var._07 &d_var._08 &d_var._09 &d_var._10 j (0);
		set interwrk.tmp_table(where=(&o_var. ne . and &d_var. ne .));
		by &o_var. &d_var.;
		array dest{0:10} &d_var._00--&d_var._10;
	    if first.&o_var. then do;
	    	do i = 0 to 10;
	    	    dest{i}=.;
	    	end;
	    end;
	    dest{&d_var.} = &sum_var._mean;
	    if last.&o_var. then do;
                j = sum(j,1);
	    	jstr = strip(put(j,z2.));
	    	orig = "&o_var."||jstr;
	    	output;
	    	
	    end;
	run;


    /*reorder variables for output*/
	data interwrk.&tab_name.;
		retain orig &d_var._00 &d_var._01 &d_var._02 &d_var._03 &d_var._04 &d_var._05 &d_var._06 &d_var._07 &d_var._08 &d_var._09 &d_var._10;
		set interwrk.&tab_name.;		
	run;

	proc print data=interwrk.&tab_name.;
	run;

    proc export data=interwrk.&tab_name. outfile = "./&tab_name..csv" DBMS = CSV replace;
    run;

%mend;

%plotmaker(&indata.,theta_dec,psi_dec,mean_resid,theta_psi_resid_all);
%plotmaker(&indata.,last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_all);
%plotmaker(&indata.(where=(theta_dec=1)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec1);
%plotmaker(&indata.(where=(theta_dec=2)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec2);
%plotmaker(&indata.(where=(theta_dec=3)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec3);
%plotmaker(&indata.(where=(theta_dec=4)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec4);
%plotmaker(&indata.(where=(theta_dec=5)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec5);
%plotmaker(&indata.(where=(theta_dec=6)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec6);
%plotmaker(&indata.(where=(theta_dec=7)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec7);
%plotmaker(&indata.(where=(theta_dec=8)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec8);
%plotmaker(&indata.(where=(theta_dec=9)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec9);
%plotmaker(&indata.(where=(theta_dec=10)),last_psi_dec,psi_dec,last_resid,prevpsi_psi_prevresid_thetadec10);

