%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_regParms_out.m
%Author: Ian M. Schmutte
%Date:   2013-05-15
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares data for disclosure avoidance review
%
%nohup matlab -nodisplay -nosplash -singleCompThread -r s04_regParms_out > s04_regParms_out.log &
%%%%%%%%%%%%%%%%%%%%%%%%%


try;
ver
license checkout Statistics_Toolbox;
license checkout Distrib_Computing_Toolbox;
matlabpool open;
load('samplesIndex.mat');
addpath /rdcprojects/co2/co00538/programs/schmu005/EndMob/source/code/gibbs_sampler/v20120522/postprocess;

    %CORRECTION FACTOR POSTPROCESSING%
load('betaMat.mat');
MCSE = zeros(1,30);
parfor i =1:30
        output = initSeq(betaMat(:,i),samplesIndex(:,1));
        MCSE(i) = sqrt(output.H1hat/output.threadLength);
end

betaMean = reshape(mean(betaMat),6,5);
betaMCSE = reshape(MCSE,6,5);

save('betaOut.mat','betaMean','betaMCSE');

matlabpool close;
clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
