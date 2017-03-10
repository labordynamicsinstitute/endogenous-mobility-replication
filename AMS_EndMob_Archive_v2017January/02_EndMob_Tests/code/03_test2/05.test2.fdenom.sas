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
*%let thisfile=%sysget(PWD)/end_mob_test.sas;
*%put ===========&thisfile;

*-----------------------------------------------------------;
%include "../lib/config.sas";
*************************************************************;


proc corr data=outputs.firm_s_t_sort_ac cov vardef=n out=outputs.m_v_ac noprint;
  by psi_dec_s resid_dec_s;
  weight counter_s;
  var x_j1-x_j10;
run;

proc iml;
df=0;
x_2=0;
results=shape(0,10*10,4+2*10);
resids=shape(0,10*10,2+10);
do psi=1 to 10;
  do res=1 to 10;

    use outputs.test2_ac;
      read all var{ac_x_j1 ac_x_j2 ac_x_j3 ac_x_j4 ac_x_j5 ac_x_j6 ac_x_j7 ac_x_j8 ac_x_j9 ac_x_j10} into x_ac where(psi_dec_s=psi & resid_dec_s=res);
      read all var {a_x_j1 a_x_j2 a_x_j3 a_x_j4 a_x_j5 a_x_j6 a_x_j7 a_x_j8 a_x_j9 a_x_j10} into x_a where(psi_dec_s=psi & resid_dec_s=res);
      read all var {N_j} into n_j where(psi_dec_s=psi & resid_dec_s=res);
    print x_ac;
    print x_a;
    print n_j;

    use outputs.m_v_ac;
      read all var {x_j1 x_j2 x_j3 x_j4 x_j5 x_j6 x_j7 x_j8 x_j9 x_j10} into v_ac where(psi_dec_s=psi & resid_dec_s=res & _TYPE_='COV');
      read all var {x_j1 x_j2 x_j3 x_j4 x_j5 x_j6 x_j7 x_j8 x_j9 x_j10} into x_bar_ac where(psi_dec_s=psi & resid_dec_s=res & _TYPE_='MEAN');
    print x_bar_ac;
    print v_ac;

    *call eigen(e_val, e_vec, v_ac);
    *print e_val;
    *print e_vec;
    x_2_contrib= n_j*(x_bar_ac - x_a)*inv(v_ac)*t(x_bar_ac - x_a);
    print x_2_contrib;
    x_2=x_2 + x_2_contrib;
    df=df+ncol(x_bar_ac)-1;
    ii=(psi-1)*10+res;
    results[ii,]=psi||res||n_j||x_2_contrib||x_bar_ac||x_a;
    resids[ii,]=psi||res||(x_bar_ac-x_a);

    end;
  end;

print x_2;
print df;
prob=1-probchi(x_2,df);
print prob;
print results;
print resids;
col_names={'psi_dec' 'res_dec' 'n_j' 'x_2_contrib' 
    'ac_x_j1' 'ac_x_j2' 'ac_x_j3' 'ac_x_j4' 'ac_x_j5' 'ac_x_j6' 'ac_x_j7' 'ac_x_j8' 'ac_x_j9' 'ac_x_j10'
    'a_x_j1' 'a_x_j2' 'a_x_j3' 'a_x_j4' 'a_x_j5' 'a_x_j6' 'a_x_j7' 'a_x_j8' 'a_x_j9' 'a_x_j10'};
print col_names;
create outputs.test2_results_fdenom from results [colname=col_names];
append from results;
close outputs.test2_results;
col_names={'psi_dec' 'res_dec'
    'tht_j1'  'tht_j2'  'tht_j3'  'tht_j4'  'tht_j5'  'tht_j6'  'tht_j7'  'tht_j8'  'tht_j9'  'tht_j10'};
print col_names;
create outputs.residuals_fdenom from resids [colname=col_names]; 
append from resids;
close outputs.residuals;

quit;

proc export data=outputs.test2_results_fdenom outfile="&wrkpath./test2_results_fdenom.csv" DBMS=CSV replace; run;
proc export data=outputs.residuals_fdenom outfile="&wrkpath./residuals_fdenom.csv" DBMS=CSV replace; run;
