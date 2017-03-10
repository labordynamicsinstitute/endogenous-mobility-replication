%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_latentProb_out.m
%Author: Ian M. Schmutte
%Date:   August 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares data for disclosure avoidance review
%
%nohup matlab -nodisplay -nosplash -singleCompThread -r s04_latentProb_out > s04_latentProb_out.log &
%%%%%%%%%%%%%%%%%%%%%%%%%

try;
ver
license checkout Statistics_Toolbox;
license checkout Distrib_Computing_Toolbox;
matlabpool open;
addpath /rdcprojects/co/co00538/programs/schmu005/EndMob/source/code/gibbs_sampler/current/postprocess;
load('samplesIndex.mat');
load('runInfo.csv');
L=runInfo(5); 
M=runInfo(6); 
Q=runInfo(7);

    %LATENT CLASS PROBABILITIES POSTPROCESSING%
load('piA.mat');
load('piB.mat');
load('piK.mat');
MCSE = zeros(1,L);
parfor i =1:L
    output = initSeq(piA(:,i),samplesIndex(:,1));
    MCSE(i) = sqrt(output.H1hat/output.threadLength);
end

piA_Out = [mean(piA);MCSE];

MCSE = zeros(1,M);
parfor i =1:M
    output = initSeq(piB(:,i),samplesIndex(:,1));
    MCSE(i) = sqrt(output.H1hat/output.threadLength);
end

piB_Out = [mean(piB);MCSE];

MCSE = zeros(1,L*M*Q);
parfor i =1:L*M*Q
    output = initSeq(piK(:,i),samplesIndex(:,1));
    MCSE(i) = sqrt(output.H1hat/output.threadLength);
end

piKmean = reshape(mean(piK),L,M,Q);
piKMCSE = reshape(MCSE,L,M,Q);


save('latentProbOut.mat','piA_Out','piB_Out','piKmean','piKMCSE');
matlabpool close;
clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
