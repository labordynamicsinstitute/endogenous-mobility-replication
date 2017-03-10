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
*%let thisfile=%sysget(PWD)/01.mean_resids.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;
%let indata = OUTPUTS.HC_estimates_JBES;

proc sort data=&indata.(keep = pik sein year resid theta psi) out=interwrk.job_strip;
	by pik year sein;
run;

/* now compute the within job mean residual*/


data interwrk.domjob_cats(keep=pik sein start_year end_year mean_resid theta psi obs_tenure
	first_job last_job);
	set interwrk.job_strip;
		by pik year sein;
		retain sum_resid obs_tenure last_sein last_psi end_year start_year first_job last_job;

		
/* 		Initialize on first pik */

		if first.pik then do;
			first_job=1;
			last_sein = sein;
			start_year = year;
			end_year = year;
			last_psi = psi;
			obs_tenure = 1;
			sum_resid = resid;
			last_job=0;

		end;

		if not first.pik and sein = last_sein then do;
			sum_resid = sum(resid,sum_reid);
			obs_tenure = sum(obs_tenure,1);
			end_year = year;
			if last.pik then do;
				mean_resid = sum_resid/obs_tenure;
				last_job = 1;
				output;
			end;	
		end;
		if not first.pik and sein ne last_sein then do;
		/*output for job spell that just finished*/
			mean_resid = sum_resid/obs_tenure;
			next_sein = sein;
			sein = last_sein;
			next_psi = psi;
			psi=last_psi;
			output;
			first_job=0;
			sein = next_sein;
			psi = next_psi;	
			sum_resid = resid;
			obs_tenure = 1;
			start_year=year;
			end_year = year;
			last_sein = sein;
			last_psi = psi;
			if last.pik then do;
				mean_resid = sum_resid/obs_tenure;
				last_job = 1;
				end_year = year;
				output;
			end;
		end;
		if first.pik and last.pik then do;
			mean_resid = resid;
			start_year = year;
			end_year=year;
			obs_tenure=1;
			last_job = 1;
			output;
		end;
run;


proc contents data=interwrk.domjob_cats; run;

proc print data=interwrk.domjob_cats(obs=50); run;



