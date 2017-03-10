%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_gammaMat_out.m
%Author: Ian M. Schmutte
%Date:   August 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares data for disclosure avoidance review
%
%nohup matlab -nodisplay -nosplash -singleCompThread -r s04_gammaMat_out > s04_gammaMat_out.log &
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
load('Gamma.mat');
MCSE = zeros(1,L*(M+1)*Q);
parfor i =1:L*(M+1)*Q
    [a b c] = ind2sub([L,M+1,Q],i);
    if b==M+1 & c~=1
        MCSE(i) = -9999;
    else
        output = initSeq(Gamma(:,i),samplesIndex(:,1));
        MCSE(i) = sqrt(output.H1hat/output.threadLength);
    end
end

gammaMean = reshape(mean(Gamma),L,M+1,Q);
gammaMCSE = reshape(MCSE,L,M+1,Q);

save('gammaOut.mat','gammaMean','gammaMCSE');

matlabpool close;
clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
