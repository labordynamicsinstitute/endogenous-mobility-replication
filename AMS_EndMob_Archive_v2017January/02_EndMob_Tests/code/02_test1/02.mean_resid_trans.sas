************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
*-----------------------------------------------------------
* REVISION LIST
* 
*-----------------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/02.mean_resid_trans.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

data interwrk.domjob_cats2(keep=pik sein start_year end_year 
				mean_resid resid_cat resid_dec 
				theta theta_cat theta_dec psi obs_tenure
				psi psi_cat psi_dec
				first_job last_job 
				last_sein last_end_year last_resid last_resid_cat last_resid_dec last_psi last_psi_cat last_psi_dec );
	array residcents {100} _temporary_;
	array psicents {100} _temporary_;
	array thetacents {100} _temporary_;	
	if _n_=1 then do;
		*load the array of quantile cutoffs;
		b = 0;
		do until (b=1);
		set outputs.centiles_resid end=lastobs;
			array centls {100} p_1--p_100;
			do i = 1 to 100;
				residcents{i} = centls{i};
			end;
			b=1;
		end;
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
	end; *_n_=1 do-loop;
	
	set interwrk.domjob_cats;
	by pik;
	retain last_sein last_resid last_resid_cat last_resid_dec last_psi last_psi_cat last_psi_dec theta_cat theta_dec last_end_year;
	if first.pik and not last.pik then do;
		j=0; h=100;
		b=0;
		do until (b=1);
			m = floor(0.5*(j+h));
			if h = j+1 then do;
				b=1;
				theta_cat = h;
			end;
			else do;
				if theta lt thetacents{m} then h = m;
				else if theta gt thetacents{m} then j = m;
				else if theta = thetacents{m} then do;
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
		last_psi = .;
		last_psi_cat = .;
		last_psi_dec = .;
		last_resid = .;
		last_resid_cat = .;
		last_resid_dec = .;
		last_sein = .;
		last_end_year = .;
	end;		
/* 		from here to bottom is just assignment to quantiles */
			j=0; h=100;
			b=0;
			do until (b=1);
				m = floor(0.5*(j+h));
				if h = j+1 then do;
					b=1;
					resid_cat = h;
				end;
				else do;
					if mean_resid lt residcents{m} then h = m;
					else if mean_resid gt residcents{m} then j = m;
					else if mean_resid = residcents{m} then do;
						b=1;
						resid_cat=m;
					end;
				end;
			end;
			j=0; h=100;
			b=0;
			do until (b=1);
				m = floor(0.5*(j+h));
				if h = j+1 then do;
					b=1;
					psi_cat = h;
				end;
				else do;
					if psi lt psicents{m} then h = m;
					else if psi gt psicents{m} then j = m;
					else if psi = psicents{m} then do;
						b=1;
						psi_cat=m;
					end;
				end;
			end;

			if resid_cat lt 10 then resid_dec = 1;
			else if resid_cat lt 20 then resid_dec = 2;
			else if resid_cat lt 30 then resid_dec = 3;
			else if resid_cat lt 40 then resid_dec = 4;
			else if resid_cat lt 50 then resid_dec = 5;
			else if resid_cat lt 60 then resid_dec = 6;
			else if resid_cat lt 70 then resid_dec = 7;
			else if resid_cat lt 80 then resid_dec = 8;
			else if resid_cat lt 90 then resid_dec = 9;
			else if resid_cat le 100 then resid_dec = 10;
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

	if not first.pik then output;
	if not last.pik then do;
		last_psi = psi;
		last_psi_cat = psi_cat;
		last_psi_dec = psi_dec;
		last_resid = mean_resid;
		last_resid_cat = resid_cat;
		last_resid_dec = resid_dec;
		last_sein = sein;
		last_end_year = end_year;
	end;
run;

proc contents data=interwrk.domjob_cats2; run;

proc print data=interwrk.domjob_cats2 (obs=50); run;
	
