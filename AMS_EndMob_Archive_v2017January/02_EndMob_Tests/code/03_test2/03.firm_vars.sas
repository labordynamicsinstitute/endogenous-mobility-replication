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
*%let thisfile=%sysget(PWD)/03.firm_vars.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;

*** Calculate the mean residuals at every point in time ***;

data temp1(keep=sein year mean_resid counter);
   set interwrk.job_strip2(keep=sein year resid);
      by sein year;

   retain mean_resid counter;

   if first.year then do;
      mean_resid=0;
      counter=0;
   end;

   mean_resid=mean_resid+resid;
   counter=counter+1;

   if last.year then do;
      mean_resid=mean_resid/counter;
      output;
   end;
run;

proc means;
run;

*** Merge on the mean residual  ***;

data interwrk.firm_data(keep=sein year psi mean_resid theta1-theta10 counter merge
                        resid_dec psi_dec theta_cat_sum theta_cat_check);
   merge interwrk.job_strip2(in=a) temp1(in=b);
      by sein year;

   length merge 3;
   merge=a+2*b;

   *** Load the centiles into arrays ***;
   array residcents {100} _temporary_;
   array psicents {100} _temporary_;
   array thetacents {100} _temporary_;
   if _n_=1 then do;
           *load the array of quantile cutoffs;
           b = 0;
           do until (b=1);
           set outputs.centiles_resid_firm end=lastobs;
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

   *** Calculate theta counts in each decile ***;
   retain theta1-theta10;
   array tht {10} theta1-theta10;

   if first.year then do;
      do i=1 to 10;
         tht{i}=0;
      end;
   end;

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

   tht{theta_dec}=tht{theta_dec}+1;

   if last.year then do;
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

      *** Check that every worker is assigned a theta decile ***;
      theta_cat_sum=0;
      do i=1 to 10;
         theta_cat_sum=theta_cat_sum+tht{i};
      end;
      theta_cat_check=theta_cat_sum=counter;
      output;
   end;
run;

proc contents;
proc freq;
   tables year psi_dec resid_dec;
run;

proc means;
run;

proc means;
   class psi_dec;
   var psi;
run;

proc means;
   class resid_dec;
   var mean_resid;
run;

proc print data=interwrk.firm_data(obs=1000);
run;
