************************************************************
* AUTHOR
* Ian M. Schmutte
*-----------------------------------------------------------
* DESCRIPTION
* Locate worker records for event study and reconstruct log wage from components
-------------------------------------------------
* FILE INFORMATION;
*%let thisfile=%sysget(PWD)/01.20.collapse_event_histories.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

proc sort data=INTERWRK.event_sample;
  by pik year;
run;

/*collapse worker wage histories*/
data INTERWRK.cellids(keep=pik cellid);
  array psicents {100} _temporary_;
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
  end; *_n_=1 do-loop;
  set INTERWRK.event_sample;
  retain first_psi_quart;
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
  if psi_cat lt 25 then psi_quart = 1;
  else if psi_cat lt 50 then psi_quart = 2;
  else if psi_cat lt 75 then psi_quart = 3;
  else psi_quart = 4;

  if year=1999 then first_psi_quart=psi_quart;
  if year=2003 then do;
    cellid = trim(left(put(first_psi_quart,1.)))||trim(left(put(psi_quart,1.)));
    output;
    first_psi_quart=0;
  end;
run;

proc freq data=INTERWRK.cellids;
  tables cellid;
run;

data INTERWRK.event_sample;
  merge INTERWRK.event_sample INTERWRK.cellids;
  by pik;
run;

proc sort data=INTERWRK.event_sample;
  by cellid year;
run;



