* 07.05c.make_mcmc_inits_JBES.sas;
* Ian Schmutte 20160201;
* Produces vectors to initialize Gibbs sampler;
*based on ...;
* 07.05c.make_mcmc_inits.sas;

%include "config.sas";

libname cg_new "$P/programs/projects/networks/zhao0310/runcg/cg_interwrk";

%macro centilemaker(var);
    proc univariate data=&var._ref;
	var &var.;
	output out=INTERWRK.centiles_&var.
		pctlpre=p_ pctlpts = 0 to 100 by 1;
    run;
%mend;

%macro catmatch(var);
	j=0; h=100;
	b=0;
	do until (b=1);
		m = floor(0.5*(j+h));
		if (h = j+1) then do;
			b=1;
			&var._cat = h;
		end;
		else do;
			if &var. lt &var._cents{m} then h = m;
			else if &var. gt &var._cents{m} then j = m;
			else if &var. = &var._cents{m} then do;
				b=1;
				&var._cat=m;
			end;
		end;
	end;
	if &var._cat lt 10 then &var._dec = 1;
	else if &var._cat lt 20 then &var._dec = 2;
	else if &var._cat lt 30 then &var._dec = 3;
	else if &var._cat lt 40 then &var._dec = 4;
	else if &var._cat lt 50 then &var._dec = 5;
	else if &var._cat lt 60 then &var._dec = 6;
	else if &var._cat lt 70 then &var._dec = 7;
	else if &var._cat lt 80 then &var._dec = 8;
	else if &var._cat lt 90 then &var._dec = 9;
	else if &var._cat le 100 then &var._dec = 10;
%mend;

data thetaref;
    set outputs.piksein_strip_mcmc_half_JBES(where=(theta ne .));
run;

proc sort data=thetaref nodupkey out=tmp(keep=theta);
    by pik;
run;

proc univariate data=tmp;
    var theta;
run;

/*
proc sort data=cg_new.hcest2_ilinwi(keep=theta pik year where=(year=2001)) out=theta_ref(keep=theta) nodupkey;
    by pik;
run;


proc sort data=cg_new.hcest2_ilinwi(keep=sein psi year where=(year=2001)) out=psi_ref(keep=psi) nodupkey;
    by sein;
run;


proc sort data=cg_new.hcest2_ilinwi(keep=pik sein mu year where=(year=2001)) out=mu_ref(keep=mu) nodupkey;
    by pik sein;
run;

%centilemaker(theta);
%centilemaker(psi);
%centilemaker(mu);
*/


data akm_starting_values(keep=theta psi mu pik_count sein_count match_count theta_dec psi_dec mu_dec theta_cat psi_cat mu_cat);
	array theta_cents {100} _temporary_;
        array psi_cents {100} _temporary_;
        array mu_cents {100} _temporary_;
	if _n_=1 then do;
		*load the array of quantile cutoffs;
		b = 0;
		do until (b=1);
		set INTERWRK.centiles_theta;
			array centls {100} p_1--p_100;
			do i = 1 to 100;
				theta_cents{i} = centls{i};
			end;
			b=1;
		end;
                b = 0;
		do until (b=1);
		set INTERWRK.centiles_psi;
			array centls2 {100} p_1--p_100;
			do i = 1 to 100;
				psi_cents{i} = centls2{i};
			end;
			b=1;
		end;
                b = 0;
		do until (b=1);
		set INTERWRK.centiles_mu;
			array centls3 {100} p_1--p_100;
			do i = 1 to 100;
				mu_cents{i} = centls3{i};
			end;
			b=1;
		end;
	end; *_n_=1 do-loop;

        merge OUTPUTS.piksein_strip_mcmc_half_JBES(keep=theta psi mu)
            OUTPUTS.to_mcmc_half_JBES(keep=pik_count sein_count match_count);

        if sein_count ne 0 then do;
            %catmatch(theta);
            %catmatch(psi);
            if mu = . then mu = 0;
            %catmatch(mu);
        end;
        else if sein_count=0 then do;
            psi_dec = 11;
            mu_dec = 11;
        end;
run;

proc sort data=akm_starting_values;
    by pik_count descending sein_count;
run;

data akm_starting_values;
    set akm_starting_values;
    by pik_count;
    retain theta_dec_hold;
    if first.pik_count then do;
        if theta_dec = . then theta_dec = ceil(10*ranuni(-1));
        theta_dec_hold = theta_dec;
    end;
    theta_dec = theta_dec_hold;
run;



proc sort data=akm_starting_values(keep=pik_count theta_dec)
    out=INTERWRK.AC0_half_10C_JBES nodupkey;
    by pik_count;
run;

proc sort data=akm_starting_values(keep=sein_count psi_dec where=(psi_dec ne 11))
    out=INTERWRK.PC0_half_10C_JBES nodupkey;
    by sein_count;
run;

proc sort data=akm_starting_values(keep=match_count pik_count sein_count mu_dec psi_dec where=(psi_dec ne 11))
    out=INTERWRK.MC0_half_10C_JBES (keep=match_count mu_dec) nodupkey;
    by match_count; /*this deals with people who stop and start a job in same firm*/
run;

proc sort data=INTERWRK.MC0_half_10C_JBES;
    by match_count;
run;

data INTERWRK.neworder_retain;
    retain pik_count theta_dec;
    set INTERWRK.AC0_half_10C_JBES (keep=pik_count theta_dec);
run;

proc print data=INTERWRK.neworder_retain(obs=50); 
run;

proc freq data=INTERWRK.neworder_retain;
  tables theta_dec;
run;

proc export data=INTERWRK.neworder_retain dbms=CSV replace
    OUTFILE="$TEMP/interwork/abowd001/networks/outputs/AC0_half_10C_JBES.csv";
run;

data INTERWRK.neworder_retain;
    retain sein_count psi_dec;
    set INTERWRK.PC0_half_10C_JBES(keep=sein_count psi_dec);
run;

proc print data=INTERWRK.neworder_retain(obs=50); 
run;

proc freq data=INTERWRK.neworder_retain;
  tables psi_dec;
run;

proc export data=INTERWRK.neworder_retain dbms=CSV replace
    OUTFILE="$TEMP/interwork/abowd001/networks/outputs/PC0_half_10C_JBES.csv";
run;

data INTERWRK.neworder_retain(keep=match_count mu_dec);
    retain match_count mu_dec;
    set INTERWRK.MC0_half_10C_JBES(keep=match_count mu_dec);
run;

proc print data=INTERWRK.neworder_retain(obs=50); 
run;

proc freq data=INTERWRK.neworder_retain;
  tables mu_dec;
run;

proc export data=INTERWRK.neworder_retain dbms=CSV replace
    OUTFILE="$TEMP/interwork/abowd001/networks/outputs/MC0_half_10C_JBES.csv";
run;

proc datasets library=INTERWRK;
    delete neworder_retain;
run;
