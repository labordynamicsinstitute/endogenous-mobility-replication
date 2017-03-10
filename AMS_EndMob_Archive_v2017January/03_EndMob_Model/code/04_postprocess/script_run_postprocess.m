%script_run_postprocess.m
%Ian Schmutte
%20130515

%runs all of the postprocessing scripts 

% nohup matlab -nodisplay -nosplash -singleCompThread -r script_run_postprocess > script_run_postprocess.log &

try;
    !cp ../run01/samplesParms.csv ./run01/;
    !cp ../run01/samplesClasses.csv ./run01/;
    !cp ../run02/samplesParms.csv ./run02/;
    !cp ../run02/samplesClasses.csv ./run02/;
    !cp ../run03/samplesParms.csv ./run03/;
    !cp ../run03/samplesClasses.csv ./run03/;

    s01_reviewSamplerOutput;
    s02_stack_samples;
    s03_make_stats;
    s04_corrMat_out;
    s04_autocorr_out;
    s04_regParms_out;
    s04_wageParms_out;
    s04_latentProb_out;
    s04_gammaMat_out;
    s04_deltaMat_out;


clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end

exit;

