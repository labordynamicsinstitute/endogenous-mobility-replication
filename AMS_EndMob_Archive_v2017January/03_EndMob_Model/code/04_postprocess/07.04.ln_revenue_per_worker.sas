* 07.04.ln_revenue_per_worker.sas
* Ian M. Schmutte J. Abowd;
* 2014 December 31;
* sein-level analysis;

  libname br_qrl   "$TEMP/interwork/abowd001/networks/br_qrl";
  libname datain   "$TEMP/interwork/abowd001/networks/outputs";
  libname outputs  "$TEMP/interwork/abowd001/networks/outputs";
  libname interwrk "$TEMP/interwork/abowd001/networks/interwrk";

options nocenter ls=130 ps=32000 fullstimer;

%macro rubin(implicates);

%do i = 1 %to &implicates.;
  data br_qrl_gibbs;
    set interwrk.br_qrl_gibbs;
    if rl_ems_c_imp&i._Mean > 0 then ln_rl_ems_c_imp&i._Mean = log(rl_ems_c_imp&i._Mean);
  run;

  proc means data=br_qrl_gibbs(where=(employed=1 & year=2002 & (substr(sein,1,2) in ("17","18","55")))) noprint;
	var theta_gibbs psi_gibbs mu_gibbs xbeta_gibbs xbeta_akm theta_akm mu_akm psi_akm rl_ems_c_imp&i._Mean ln_rl_ems_c_imp&i._Mean;
	by sein;
	output out=outputs.br_qrl_gibbs_sein_imp&i.(drop=_type_ _freq_) mean= /autoname;
  run;

  proc reg data=outputs.br_qrl_gibbs_sein_imp&i. outest=outputs.br_qrl_sein_reg_imp&i. covout;
    gibbs: model ln_rl_ems_c_imp&i._Mean_Mean = theta_gibbs_mean psi_gibbs_mean mu_gibbs_mean xbeta_gibbs_mean;
    akm: model ln_rl_ems_c_imp&i._Mean_Mean = theta_akm_mean psi_akm_mean mu_akm_mean xbeta_akm_mean;
  run;
  data outputs.br_qrl_sein_reg_imp&i.;
    set outputs.br_qrl_sein_reg_imp&i.;
    length implicate 3;
    implicate=symget('i');
  run;
  %if &i. = 1 %then %do;
    proc print data=outputs.br_qrl_sein_reg_imp&i.;
    run;
  %end;

%end;
%mend rubin;

%rubin(10);
run;

data stacked;
  set outputs.br_qrl_sein_reg_imp1
      outputs.br_qrl_sein_reg_imp2
      outputs.br_qrl_sein_reg_imp3
      outputs.br_qrl_sein_reg_imp4
      outputs.br_qrl_sein_reg_imp5
      outputs.br_qrl_sein_reg_imp6
      outputs.br_qrl_sein_reg_imp7
      outputs.br_qrl_sein_reg_imp8
      outputs.br_qrl_sein_reg_imp9
      outputs.br_qrl_sein_reg_imp10;
run;

proc sort data=stacked out=br_qrl_sein_reg_implicates;
  by implicate _model_;
run;

data outputs.br_qrl_sein_reg_implicates(
     keep=implicate _model_ 
                    b0_gibbs b_theta_gibbs b_psi_gibbs b_xbeta_gibbs b_mu_gibbs 
                    v_b0_gibbs v_theta_gibbs v_psi_gibbs v_xbeta_gibbs v_mu_gibbs
                    b0_akm b_theta_akm b_psi_akm b_exper_akm b_mu_akm
                    v_b0_akm v_theta_akm v_psi_akm v_exper_akm v_mu_akm);
  set br_qrl_sein_reg_implicates;
  retain            b0_gibbs b_theta_gibbs b_psi_gibbs b_xbeta_gibbs b_mu_gibbs 
                    v_b0_gibbs v_theta_gibbs v_psi_gibbs v_xbeta_gibbs v_mu_gibbs
                    b0_akm b_theta_akm b_psi_akm b_exper_akm b_mu_akm
                    v_b0_akm v_theta_akm v_psi_akm v_exper_akm v_mu_akm;
  by implicate _model_;
  if first.implicate then do;
    b0_gibbs=.;
    b_theta_gibbs=.; 
    b_psi_gibbs=.; 
    b_xbeta_gibbs=.;
    b_mu_gibbs=.; 
    v_b0_gibbs=.; 
    v_theta_gibbs=.; 
    v_psi_gibbs=.; 
    v_xbeta_gibbs=.;
    v_mu_gibbs=.;
    b0_akm=.; 
    b_theta_akm=.; 
    b_psi_akm=.; 
    b_exper_akm=.; 
    b_mu_akm=.;
    v_b0_akm=.;
    v_theta_akm=.; 
    v_psi_akm=.; 
    v_exper_akm=.; 
    v_mu_akm=.;
  end;
  if _model_="gibbs" then do;
    if _type_="PARMS" then do;
      b0_gibbs=intercept;
      b_theta_gibbs=theta_gibbs_mean; 
      b_psi_gibbs=psi_gibbs_mean; 
      b_xbeta_gibbs=xbeta_gibbs_mean; 
      b_mu_gibbs=mu_gibbs_mean;
    end;
    else if _type_="COV" then do;
      if _name_="Intercept" then v_b0_gibbs=intercept;
      if _name_="Theta_Gibbs_Mean" then v_theta_gibbs=theta_gibbs_mean;
      if _name_="Psi_Gibbs_Mean" then v_psi_gibbs=psi_gibbs_mean;
      if _name_="XBeta_Gibbs_Mean" then v_xbeta_gibbs=xbeta_gibbs_mean;
      if _name_="Mu_Gibbs_Mean" then v_mu_gibbs=mu_gibbs_mean;
    end;
  end;
  else if _model_="akm" then do;
    if _type_="PARMS" then do;
      b0_akm=intercept;
      b_theta_akm=theta_akm_mean; 
      b_psi_akm=psi_akm_mean; 
      b_exper_akm=xbeta_akm_mean; 
      b_mu_akm=mu_akm_mean;
    end;
    else if _type_="COV" then do;
      if _name_="Intercept" then v_b0_akm=intercept;
      if _name_="Theta_AKM_Mean" then v_theta_akm=theta_akm_mean;
      if _name_="Psi_AKM_Mean" then v_psi_akm=psi_akm_mean;
      if _name_="Xbeta_AKM_Mean" then v_exper_akm=xbeta_akm_mean;
      if _name_="mu_akm_Mean" then v_mu_akm=mu_akm_mean;
    end;
  end;
  if last.implicate then output;
run;

proc print data=outputs.br_qrl_sein_reg_implicates;
 id implicate;
run;

proc summary data=outputs.br_qrl_sein_reg_implicates;
  var b0_gibbs b_theta_gibbs b_psi_gibbs b_xbeta_gibbs b_mu_gibbs 
      v_b0_gibbs v_theta_gibbs v_psi_gibbs v_xbeta_gibbs v_mu_gibbs
      b0_akm b_theta_akm b_psi_akm b_mu_akm
      v_b0_akm v_theta_akm v_psi_akm b_mu_akm;
  output out=outputs.br_qrl_sein_reg_rubin
    mean(b0_gibbs b_theta_gibbs b_psi_gibbs b_xbeta_gibbs b_mu_gibbs 
      v_b0_gibbs v_theta_gibbs v_psi_gibbs v_xbeta_gibbs v_mu_gibbs
      b0_akm b_theta_akm b_psi_akm b_exper_akm b_mu_akm
      v_b0_akm v_theta_akm v_psi_akm v_exper_akm v_mu_akm)=
      est_b0_gibbs est_theta_gibbs est_psi_gibbs est_xbeta_gibbs est_mu_gibbs 
      win_b0_gibbs win_theta_gibbs win_psi_gibbs win_xbeta_gibbs win_mu_gibbs
      est_b0_akm est_theta_akm est_psi_akm est_exper_akm est_mu_akm
      win_b0_akm win_theta_akm win_psi_akm win_exper_akm win_mu_akm
    var(b0_gibbs b_theta_gibbs b_psi_gibbs b_xbeta_gibbs b_mu_gibbs 
        b0_akm b_theta_akm b_psi_akm b_exper_akm b_mu_akm)=
        bet_b0_gibbs bet_theta_gibbs bet_psi_gibbs bet_xbeta_gibbs bet_mu_gibbs 
        bet_b0_akm bet_theta_akm bet_psi_akm bet_exper_akm bet_mu_akm
  ;
run;

proc print data=outputs.br_qrl_sein_reg_rubin;
run;

data outputs.br_qrl_sein_reg_rubin;
  set outputs.br_qrl_sein_reg_rubin;
  array within win_b0_gibbs win_theta_gibbs win_psi_gibbs win_xbeta_gibbs win_mu_gibbs
               win_b0_akm win_theta_akm win_psi_akm win_exper_akm win_mu_akm;
  array between bet_b0_gibbs bet_theta_gibbs bet_psi_gibbs bet_xbeta_gibbs bet_mu_gibbs 
                bet_b0_akm bet_theta_akm bet_psi_akm bet_exper_akm bet_mu_akm;
  array total tot_b0_gibbs tot_theta_gibbs tot_psi_gibbs tot_xbeta_gibbs tot_mu_gibbs
              tot_b0_akm tot_theta_akm tot_psi_akm tot_exper_akm tot_mu_akm;
  array missingness miss_b0_gibbs miss_theta_gibbs miss_psi_gibbs miss_xbeta_gibbs miss_mu_gibbs
               miss_b0_akm miss_theta_akm miss_psi_akm miss_exper_akm miss_mu_akm;
  array df df_b0_gibbs df_theta_gibbs df_psi_gibbs df_xbeta_gibbs df_mu_gibbs
               df_b0_akm df_theta_akm df_psi_akm df_exper_akm df_mu_akm;
  array ste ste_b0_gibbs ste_theta_gibbs ste_psi_gibbs ste_xbeta_gibbs ste_mu_gibbs
               ste_b0_akm ste_theta_akm ste_psi_akm ste_exper_akm ste_mu_akm;
  do over within;
    total = within + (11/10)*between;
    ste = sqrt(total);
    missingness = ((11/10)*between)/total;
    df = 9*(1+(10/11)*(within/between));
  end;
run;

data outputs.br_qrl_sein_reg_rubin_final(keep=
    est_b0_gibbs ste_b0_gibbs miss_b0_gibbs df_b0_gibbs
    est_theta_gibbs ste_theta_gibbs miss_theta_gibbs df_theta_gibbs
    est_psi_gibbs ste_psi_gibbs miss_psi_gibbs df_psi_gibbs
    est_xbeta_gibbs ste_xbeta_gibbs miss_xbeta_gibbs df_xbeta_gibbs
    est_mu_gibbs ste_mu_gibbs miss_mu_gibbs df_mu_gibbs
    est_b0_akm ste_b0_akm miss_b0_akm df_b0_akm
    est_theta_akm ste_theta_akm miss_theta_akm df_theta_akm
    est_psi_akm ste_psi_akm miss_psi_akm df_psi_akm
    est_exper_akm ste_exper_akm miss_exper_akm df_exper_akm
    est_mu_akm ste_mu_akm miss_mu_akm df_mu_akm
    );
  length 
    est_b0_gibbs ste_b0_gibbs miss_b0_gibbs df_b0_gibbs
    est_theta_gibbs ste_theta_gibbs miss_theta_gibbs df_theta_gibbs
    est_psi_gibbs ste_psi_gibbs miss_psi_gibbs df_psi_gibbs
    est_xbeta_gibbs ste_xbeta_gibbs miss_xbeta_gibbs df_xbeta_gibbs
    est_mu_gibbs ste_mu_gibbs miss_mu_gibbs df_mu_gibbs
    est_b0_akm ste_b0_akm miss_b0_akm df_b0_akm
    est_theta_akm ste_theta_akm miss_theta_akm df_theta_akm
    est_psi_akm ste_psi_akm miss_psi_akm df_psi_akm
    est_exper_akm ste_exper_akm miss_exper_akm df_exper_akm
    est_mu_akm ste_mu_akm miss_mu_akm df_mu_akm
    8;
  set outputs.br_qrl_sein_reg_rubin;
run;

proc export data=outputs.br_qrl_sein_reg_rubin_final
  outfile="$TEMP/interwork/abowd001/networks/outputs/br_qrl_sein_reg_rubin_final.csv"
  dbms=csv
  replace;
run;
