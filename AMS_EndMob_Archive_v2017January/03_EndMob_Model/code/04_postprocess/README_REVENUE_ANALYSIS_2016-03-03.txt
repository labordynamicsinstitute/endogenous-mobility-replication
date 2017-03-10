Notes on Combining Revenue Measures with Endogenous Mobility Output
Ian M. Schmutte
2016 March 4
(only slight changes relative to version of 2014 December 9)
================

Linking the revenue measures to Endogenous Mobility output follows several steps:

1. Produce list of SEINs used in analysis:
	code: 
		$P/programs/projects/networks/08.01.sein_list.sas
	
	description:
		Use piksein_strip_mcmc_half.sas7bdat. This file is conformable with the input dataset for the gibbs sampler, but records PIK, SEIN, and components of AKM for all observations. This is the file we use to compare AKM and Gibbs estimates in our standard postprocessing.
                [NOTE: NOT UPDATED FOR JBES REVISION SINCE DATA UNIVERSE IDENTICAL]


2. Get BR variables, aggregate to SEIN level, and construct percentiles/deciles
	code:
		/rdcprojects/co/co00538/programs/projects/networks/br_qrl/
			01.01. builds percentiles
			01.02. merges BR variables to SEIN list
			01.03. constructs employment weighted mean of all BR variables (within implicate) and matches percentiles
				*** DATASETS ***;
				OUTPUTS: $TEMP/interwork/abowd001/networks/br_qrl/br_qrl_sein_pctls.sas7bdat
				{*** CHECK HERE TO SEE IF LINKAGES ARE VALID ***}



3. Compute posterior mean of worker, firm, and match effects, as well as Xbeta and residual from Gibbs sampler output
	code (MATLAB):
		$P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/runs/post_20160302/export_mean_gibbs.m

	output:
		$P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/runs/post_20160302/gibbs_model_out.txt 
			(Tab-delimited. Converted to sas7bdat in 07.01.import_gibbs_model.sas)

	description:
		compute posterior mean for each worker's worker effect, each firm's firm effect, each match effect
		build output dataset conformable with the input dataset that links each observation to the corresponding posterior mean effects.
		export dataset


4. Merge Gibbs and BR variables to the original input dataset {SEE OUTPUTS OF THESE FILES}
	code:
		 $P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/runs/post_20140818/
			07.01. import gibbs sampler data (from step 3)
			07.02  merge BR variables to the original input dataset using AKM_strip_JBES_ids.sas7bdat.(as in step 1)
				we get AKM components here as well
			07.03  process a (basic) SEIN-level file

	outputs:
		$TEMP/interwork/abowd001/networks/interwrk/br_qrl_gibbs.sas7bdat
			contains all identifiers, AKM component, Gibbs components, and output measures (levels, percentiles, and deciles for each implicate). This file is exactly conformable with the (0.5 percent input sample)

		$TEMP/interwork/abowd001/networks/interwrk/br_gibbs_sein_agg.sas7bdat
			contains within-sein means of input and output measures.

5. Run the regression of ln R/L on SEIN averags of theta, psi, mu, exper (GIBBS and AKM)
	07.04.ln_revenue_per_worker.sas (need to loop over implicates and do Rubin standard errors.
	