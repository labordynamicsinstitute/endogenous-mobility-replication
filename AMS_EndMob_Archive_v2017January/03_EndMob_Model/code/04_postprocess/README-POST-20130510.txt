README
Ian M. Schmutte
2013-05-10
===============
Post Processing 

TO DO:
   -put temporary and output datasets into separate folders to keep the file structure clean
   -edit the code that writes output to a text file for easy disclosure avoidance review.
   -edit code that produces the summary of starting values.
   -decide whether we compute transition matrix in RDC and get its MCSE or continue as we have been.


Step 1: Visual diagnostic check
    1. run s01_reviewSamplerOutput.m
    2. review plots and choose starting point for keeping output from Gibbs sampler

Step 2: Assemble sampler output
    1. if needed, edit s02_stack_samples.m, replacing starting values and changing number/location of raw samples
    2. run s02_stack_samples.m

Step 3: Assemble the summary statistics of interest for each draw for output processing
    1. run s03_make_stats.m

The Following can be run in any order (and in particular, can be run in parallel)
    NOTE that each of these should be run with as many processors as possible. The MCSE computations are time-consuming,
        s04_autocorr_out.m
        s04_corrMat_out.m
        s04_deltaMat_out.m
        s04_gammaMat_out.m
        s04_latentProb_out.m
        s04_wageParms_out.m
