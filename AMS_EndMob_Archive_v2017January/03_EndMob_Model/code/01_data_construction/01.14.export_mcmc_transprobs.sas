* 01.14.export_mcmc_transprobs.sas;
*Ian Schmutte 20120202;

%include "config.sas";

proc export data=INTERWRK.gamma dbms=CSV replace
    OUTFILE="/temporary/saswork2/abowd001/networks/outputs/gamma_forMatlab.csv";
run;

proc export data=INTERWRK.delta dbms=CSV replace
    OUTFILE="/temporary/saswork2/abowd001/networks/outputs/delta_forMatlab.csv";
run;
