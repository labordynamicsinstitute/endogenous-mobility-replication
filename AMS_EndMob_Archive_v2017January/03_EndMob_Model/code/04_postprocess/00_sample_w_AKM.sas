* sample_w_AKM.sas;
* I.M. Schmutte 20160302;
* Attach the AKM estimates generated from code under ./akm and then converted to SAS in ./testing to the 0.5% sample used in estimating the structural model. We need this for postestimation in s03_make_stats.m The expected file is AKM_strip_JBES.csv;

%include "config.sas";

/*convert pik_count used in structural model back to pik. Same for sein*/
proc sort data=INTERWRK.pik_histories_new_JBES(keep=pik pik_count) nodupkey out=pik_xwalk;
  by pik_count;
run;

proc sort data=INTERWRK.pik_histories_new_JBES(keep=sein sein_count) nodupkey out=sein_xwalk;
  by sein_count;
run;

proc sort data=OUTPUTS.HC_estimates_JBES(keep=sein psi) nodupkey out=psi_data;
  by sein;
run;

data psi_data;
  set psi_data;
  next_sein = sein;
  next_psi = psi;
run;


proc sort data=psi_data(keep=next_sein next_psi);
  by next_sein;
run;

data AKM_strip(keep=pik sein year separation next_sein obsnum);
  set INTERWRK.pik_histories_new_JBES;
  where (1999<=year<=2003);
  obsnum = _n_;
run;

proc sort data=AKM_strip;
  by next_sein;
run;

data AKM_strip;
  merge AKM_strip(in=a) psi_data;
  by next_sein;
  if a;
run;

proc means data=AKM_strip;
var next_psi;
run;

proc print data=AKM_strip(obs=30);
title "AKM Strip";
run;

proc sort data=AKM_strip out=AKM_strip_x;
  by pik year;
run;

data AKM_strip_2(keep = pik sein year Xb theta psi resid);
    if _n_=1 then do;
    if 0 then
    set AKM_strip_x;
    declare hash obsid(dataset: 'AKM_strip_x',
               ordered: 'ascending');
    obsid.definekey ("pik","year","sein");
    obsid.definedone();

  end;
  set OUTPUTS.HC_estimates_JBES;
  rc = obsid.find();
  if rc=0 then output;
run;

proc sort data=AKM_strip_2;
  by pik sein;
run;

proc means data=AKM_strip_2 noprint;
  var resid;
  by pik sein;
  output out=muakm(drop = _type_ _freq_) mean(resid)=mu_akm;
run;

data AKM_strip_2;
  merge AKM_strip_2 muakm;
  by pik sein;
  resid_AKM = resid-mu_AKM;
run; 

proc sort data=AKM_strip_2;
  by pik year;
run;

proc sort data=AKM_strip;
  by pik year;
run;

data AKM_strip_3;
  merge AKM_strip(in=a) AKM_strip_2(in=b);
  by pik year;
  if a then output;
run;

proc sort data=AKM_strip_3 out=AKM_strip_JBES;
  by obsnum;
run;

proc means data=AKM_strip_JBES;
  var obsnum next_psi;
run;

proc print data=AKM_strip_JBES (obs=30);
run;

data INTERWRK.AKM_strip_JBES_ids(keep=pik sein year separation next_sein Xbeta_AKM Theta_AKM Psi_AKM next_psi_akm Mu_AKM Resid_AKM theta_dec psi_dec next_psi_dec mu_dec obsnum);
	array psicents {100} _temporary_;
	array thetacents {100} _temporary_;	
        array mucents {100} _temporary_;	
	if _n_=1 then do;
		*load the array of quantile cutoffs;
		b = 0;
		do until (b=1);
		set outputs.centiles_psi end=lastobs;
			array centls2 {100} p_1--p_100;
			do i = 1 to 100;
				psicents{i} = centls2{i};
			end;
			b=1;
		end;

		b = 0;
		do until (b=1);
		set outputs.centiles_theta end=lastobs2;
			array centls3 {100} p_1--p_100;
			do i = 1 to 100;
				thetacents{i} = centls3{i};
			end;
			b=1;
		end;

		b = 0;
		do until (b=1);
		set outputs.centiles_mu end=lastobs;
			array centls {100} p_1--p_100;
			do i = 1 to 100;
				mucents{i} = centls{i};
			end;
			b=1;
		end;

	end; *_n_=1 do-loop;
set AKM_strip_JBES(keep=pik sein year separation next_sein Xb theta psi next_psi mu_akm resid_akm obsnum);
  Xbeta_AKM = Xb;
  Theta_AKM = theta;
  Psi_AKM = psi;
  next_psi_akm = next_psi;
		j=0; h=100;
		b=0;
		do until (b=1);
			m = floor(0.5*(j+h));
			if h = j+1 then do;
				b=1;
				theta_cat = h;
			end;
			else do;
				if theta_AKM lt thetacents{m} then h = m;
				else if theta_AKM gt thetacents{m} then j = m;
				else if theta_AKM = thetacents{m} then do;
					b=1;
					theta_cat=m;
				end;
			end;
		end;
		if theta_cat lt 10 then theta_dec = 1;
		else if theta_cat lt 20 then theta_dec = 2;
		else if theta_cat lt 30 then theta_dec = 3;
		else if theta_cat lt 40 then theta_dec = 4;
		else if theta_cat lt 50 then theta_dec = 5;
		else if theta_cat lt 60 then theta_dec = 6;
		else if theta_cat lt 70 then theta_dec = 7;
		else if theta_cat lt 80 then theta_dec = 8;
		else if theta_cat lt 90 then theta_dec = 9;
		else if theta_cat le 100 then theta_dec = 10;
		
/* 		from here to bottom is just assignment to quantiles */
			j=0; h=100;
			b=0;
			do until (b=1);
				m = floor(0.5*(j+h));
				if h = j+1 then do;
					b=1;
					psi_cat = h;
				end;
				else do;
					if psi_AKM lt psicents{m} then h = m;
					else if psi_AKM gt psicents{m} then j = m;
					else if psi_AKM = psicents{m} then do;
						b=1;
						psi_cat=m;
					end;
				end;
			end;
                        psi_dec = .;
			if psi_cat lt 10 then psi_dec = 1;
			else if psi_cat lt 20 then psi_dec = 2;
			else if psi_cat lt 30 then psi_dec = 3;
			else if psi_cat lt 40 then psi_dec = 4;
			else if psi_cat lt 50 then psi_dec = 5;
			else if psi_cat lt 60 then psi_dec = 6;
			else if psi_cat lt 70 then psi_dec = 7;
			else if psi_cat lt 80 then psi_dec = 8;
			else if psi_cat lt 90 then psi_dec = 9;
			else if psi_cat le 100 then psi_dec = 10;
                        if sein = "999999999999" or sein = "000000000000" then psi_dec = 0;
			
                        j=0; h=100;
			b=0;
			do until (b=1);
				m = floor(0.5*(j+h));
				if h = j+1 then do;
					b=1;
					psi_cat = h;
				end;
				else do;
					if next_psi_AKM lt psicents{m} then h = m;
					else if next_psi_AKM gt psicents{m} then j = m;
					else if next_psi_AKM = psicents{m} then do;
						b=1;
						psi_cat=m;
					end;
				end;
			end;
                        next_psi_dec = .;
			if psi_cat lt 10 then next_psi_dec = 1;
			else if psi_cat lt 20 then next_psi_dec = 2;
			else if psi_cat lt 30 then next_psi_dec = 3;
			else if psi_cat lt 40 then next_psi_dec = 4;
			else if psi_cat lt 50 then next_psi_dec = 5;
			else if psi_cat lt 60 then next_psi_dec = 6;
			else if psi_cat lt 70 then next_psi_dec = 7;
			else if psi_cat lt 80 then next_psi_dec = 8;
			else if psi_cat lt 90 then next_psi_dec = 9;
			else if psi_cat le 100 then next_psi_dec = 10;
                        if next_sein = "999999999999" or next_sein = "000000000000" then next_psi_dec = 0;

                        j=0; h=100;
			b=0;
			do until (b=1);
				m = floor(0.5*(j+h));
				if h = j+1 then do;
					b=1;
					mu_cat = h;
				end;
				else do;
					if mu_AKM lt mucents{m} then h = m;
					else if mu_AKM gt mucents{m} then j = m;
					else if mu_AKM = mucents{m} then do;
						b=1;
						mu_cat=m;
					end;
				end;
			end;
                        mu_dec = .;
			if mu_cat lt 10 then mu_dec = 1;
			else if mu_cat lt 20 then mu_dec = 2;
			else if mu_cat lt 30 then mu_dec = 3;
			else if mu_cat lt 40 then mu_dec = 4;
			else if mu_cat lt 50 then mu_dec = 5;
			else if mu_cat lt 60 then mu_dec = 6;
			else if mu_cat lt 70 then mu_dec = 7;
			else if mu_cat lt 80 then mu_dec = 8;
			else if mu_cat lt 90 then mu_dec = 9;
			else if mu_cat le 100 then mu_dec = 10;
                        if sein = "999999999999" or sein = "000000000000" or psi_dec=0 then mu_dec = 1;



run;

data INTERWRK.AKM_strip_JBES(keep=Xbeta_AKM Theta_AKM Psi_AKM Mu_AKM Resid_AKM obsnum);
  length Xbeta_AKM 8 Theta_AKM 8 Psi_AKM 8 Mu_AKM 8 Resid_AKM 8 obsnum 8;
  set AKM_strip_JBES(keep=Xb theta psi mu_akm resid_akm obsnum);
  Xbeta_AKM = Xb;
  Theta_AKM = theta;
  Psi_AKM = psi;
run;
  

proc export data=INTERWRK.AKM_strip_JBES(drop=obsnum)
  outfile="$TEMP/interwork/abowd001/networks/outputs/AKM_strip_JBES.csv"
  dbms=csv
  replace;
run;

proc contents data=INTERWRK.AKM_strip_JBES;
run;

proc print data=INTERWRK.AKM_strip_JBES (obs=30);
run;

proc print data=OUTPUTS.to_mcmc_half_JBES (obs=30);
run;

proc corr data=INTERWRK.AKM_strip_JBES;
  var _numeric_;
run;

proc means data=INTERWRK.AKM_strip_JBES_ids;
  var separation Xbeta_AKM Theta_AKM Psi_AKM next_psi_akm Mu_AKM Resid_AKM theta_dec psi_dec next_psi_dec mu_dec;
run;