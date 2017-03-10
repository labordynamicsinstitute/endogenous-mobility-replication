* 01.12.export_mcmc_inits.sas;
* Ian Schmutte 20120202;

%include "config.sas";
%let max_n=max;
%let sample_rate=0.0025;
%let sample_name=quarter_percent;

proc sort data=INTERWRK.pik_sample_&sample_name.(keep=pik_count theta_class)
    out=INTERWRK.AbilityClasses0_&sample_name. nodupkey;
    by pik_count;
run;

proc sort data=INTERWRK.pik_sample_&sample_name.(keep=sein_count psi_class where=(psi_class ne 3))
    out=INTERWRK.ProdClasses0_&sample_name. nodupkey;
    by sein_count;
run;

proc sort data=INTERWRK.pik_sample_&sample_name.(keep=match_count pik_count sein_count mu_class psi_class where=(psi_class ne 3))
    out=INTERWRK.MatchClasses0_&sample_name.(keep=match_count mu_class) nodupkey;
    by pik_count sein_count; /*this deals with people who stop and start a job in same firm*/
run;


data INTERWRK.het_values_&sample_name.(keep=alpha0 theta0_1 psi0_1 mu0_1);
    retain alpha0 theta0_1 psi0_1 mu0_1;
    set INTERWRK.pik_sample_&sample_name.(keep=alpha0 theta0_1 theta0_2 psi0_1 psi0_2 mu0_1 mu0_2);
    if _n_ = 1 then do;
        theta0_1 = theta0_1 - theta0_2;
        psi0_1 = psi0_1 - psi0_2;
        mu0_1 = mu0_1 - mu0_2;
        output;
    end;
stop;
run;

data INTERWRK.neworder_retain;
    retain pik_count theta_class;
    set INTERWRK.AbilityClasses0_&sample_name.(keep=pik_count theta_class);
run;

proc print data=INTERWRK.neworder_retain(obs=50); run;

proc export data=INTERWRK.neworder_retain dbms=CSV replace
    OUTFILE="/temporary/saswork2/abowd001/networks/outputs/AbilityClasses0_&sample_name._forMatlab.csv";
run;

data INTERWRK.neworder_retain;
    retain sein_count psi_class;
    set INTERWRK.ProdClasses0_&sample_name.(keep=sein_count psi_class);
run;

proc print data=INTERWRK.neworder_retain(obs=50); run;

proc export data=INTERWRK.neworder_retain dbms=CSV replace
    OUTFILE="/temporary/saswork2/abowd001/networks/outputs/ProdClasses0_&sample_name._forMatlab.csv";
run;

data INTERWRK.neworder_retain(keep=match_count mu_class);
    retain match_count mu_class;
    set INTERWRK.MatchClasses0_&sample_name.(keep=match_count mu_class);
run;

proc print data=INTERWRK.neworder_retain(obs=50); run;

proc export data=INTERWRK.neworder_retain dbms=CSV replace
    OUTFILE="/temporary/saswork2/abowd001/networks/outputs/MatchClasses0_&sample_name._forMatlab.csv";
run;

proc export data=INTERWRK.het_values_&sample_name. dbms=CSV replace
    OUTFILE="/temporary/saswork2/abowd001/networks/outputs/het_values_&sample_name._forMatlab.csv";
run;

proc print data=INTERWRK.het_values_&sample_name.;
run;


proc datasets library=INTERWRK;
    delete neworder_retain;
run;
