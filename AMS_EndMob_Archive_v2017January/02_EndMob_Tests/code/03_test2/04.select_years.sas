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
*%let thisfile=%sysget(PWD)/04.select_years.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;
*** Select the data for two years ***;

data tmps(drop=year) /view=tmps;
   set interwrk.firm_data(keep=sein year counter psi_dec resid_dec theta1-theta10
                          rename=(counter=counter_s
                                  psi_dec=psi_dec_s
                                  resid_dec=resid_dec_s
                                  theta1=theta1_s
                                  theta2=theta2_s
                                  theta3=theta3_s
                                  theta4=theta4_s
                                  theta5=theta5_s
                                  theta6=theta6_s
                                  theta7=theta7_s
                                  theta8=theta8_s
                                  theta9=theta9_s
                                  theta10=theta10_s)
                                  where=(year=2001));
run;
    
data tmpt(drop=year) /view=tmpt;
   set interwrk.firm_data(keep=sein year counter psi_dec resid_dec theta1-theta10
                          rename=(counter=counter_t
                                  psi_dec=psi_dec_t
                                  resid_dec=resid_dec_t
                                  theta1=theta1_t
                                  theta2=theta2_t
                                  theta3=theta3_t
                                  theta4=theta4_t
                                  theta5=theta5_t
                                  theta6=theta6_t
                                  theta7=theta7_t
                                  theta8=theta8_t
                                  theta9=theta9_t
                                  theta10=theta10_t)
                                  where=(year=2003));
run;

*** Merge the two datasets together ***;

data temp1(keep=sein counter_s x_j1-x_j10 psi_dec_s resid_dec_s);
   merge tmps(in=a) tmpt(in=b);
      by sein;

   array tht{10} theta1_t theta2_t theta3_t theta4_t theta5_t theta6_t theta7_t theta8_t theta9_t theta10_t;
   array ths{10} theta1_s theta2_s theta3_s theta4_s theta5_s theta6_s theta7_s theta8_s theta9_s theta10_s;

   if a=1 and b=0 then do;
       counter_t=0;
       do i=1 to 10;
          tht{i}=0;
       end;
    end; 

    array x_j{10} x_j1-x_j10;

    do i=1 to 10;
       if counter_t>0 then x_j{i}=(tht{i}/counter_t) - (ths{i}/counter_s);
       if counter_t=0 then x_j{i}=0 - (ths{i}/counter_s);
    end; 

   if a=1 then output;
run;

proc sort data=temp1 out=temp2;
   by psi_dec_s resid_dec_s;
run;

proc means;
proc print data=temp1(obs=100);
run;

*** Calculate the number of workers in the firm ***;

data emp1 (keep=psi_dec_s resid_dec_s sum_s);
   set temp2;
      by psi_dec_s resid_dec_s;

   retain sum_s;

   if first.resid_dec_s=1 then do;
      sum_s=0;
   end;

   sum_s=sum_s+counter_s;

   if last.resid_dec_s=1 then do;
      output;
   end;
run;

*** Compute the weighted means by ac and a ***;

proc means data=temp2 noprint;
   by psi_dec_s resid_dec_s;
   weight counter_s;
   output out=test2_ac
      mean(x_j1 x_j2 x_j3 x_j4 x_j5 x_j6 x_j7 x_j8 x_j9 x_j10)=
      ac_x_j1 ac_x_j2 ac_x_j3 ac_x_j4 ac_x_j5 ac_x_j6 ac_x_j7 ac_x_j8 ac_x_j9 ac_x_j10
      N(counter_s)=N_j SUMWGT(counter_s)=sum_test;
run;

proc print data=test2_ac;
run;

proc means data=temp2 noprint;
   by psi_dec_s;
   weight counter_s;
   output out=test2_a
      mean(x_j1 x_j2 x_j3 x_j4 x_j5 x_j6 x_j7 x_j8 x_j9 x_j10)=
      a_x_j1 a_x_j2 a_x_j3 a_x_j4 a_x_j5 a_x_j6 a_x_j7 a_x_j8 a_x_j9 a_x_j10;
run;

proc print data=test2_a;
run;

data test2_ac;
   merge test2_ac(drop=_TYPE_ _FREQ_) test2_a(drop=_TYPE_ _FREQ_);
      by psi_dec_s;
run;

data outputs.test2_ac;
   merge test2_ac emp1;
      by psi_dec_s resid_dec_s;
run;

proc means;
proc print data=outputs.test2_ac;
run;

*** Add Variance Variables ***;

data outputs.firm_s_t_sort_ac(drop=i ac_x_j1-ac_x_j10 a_x_j1-a_x_j10);
   merge temp2 outputs.test2_ac;
      by psi_dec_s resid_dec_s;

   array vx{10} vx1-vx10;
   array xj{10} x_j1-x_j10;
   array ac{10} ac_x_j1-ac_x_j10;

   do i=1 to 10;
      vx{i}=(sqrt(counter_s)*(xj{i}-ac{i}));
   end;
run;

proc means;
proc print data=outputs.firm_s_t_sort_ac(obs=100);
run;
