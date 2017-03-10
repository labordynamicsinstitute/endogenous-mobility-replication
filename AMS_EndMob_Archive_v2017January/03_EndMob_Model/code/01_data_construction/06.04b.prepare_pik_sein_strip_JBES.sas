* 06.04b.prepare_pik_sein_strip_JBES.sas;
* Ian Schmutte 20160201;
* Extract pik-sein strip for use downstream in 07.05c.make_mcmc_inits_JBES.sas;


%include "config.sas";

options obs=max fullstimer;

    data OUTPUTS.piksein_strip_mcmc_half_JBES;
        set INTERWRK.pik_histories_new_JBES(keep=pik sein theta psi mu year);
        where (1999<=year<=2003);
    run;
    
    proc contents data=OUTPUTS.piksein_strip_mcmc_half_JBES;
    run;
    
    proc print data=OUTPUTS.piksein_strip_mcmc_half_JBES (obs=50);
    run;
