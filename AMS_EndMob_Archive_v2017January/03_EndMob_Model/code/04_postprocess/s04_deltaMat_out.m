%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_deltaMat_out.m
%Author: Ian M. Schmutte
%Date:   August 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares data for disclosure avoidance review
%
%nohup matlab -nodisplay -nosplash -singleCompThread -r s04_deltaMat_out > s04_deltaMat_out.log &
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
load('Delta.mat');
MCSE = zeros(1,L*(M+1)*Q*(M+1));
parfor i =1:L*(M+1)*Q*(M+1)
    [a b c d] = ind2sub([L,M+1,Q,M+1],i);
    if (b==M+1 & (c~=1 | d>=M))  %exits from non-employment only have match class 1 and can only be transitions to employment 
        MCSE(i) = -9999;
    elseif (b~=M+1 & d==M+1)
        MCSE(i) = -9999;
    else
        output = initSeq(Delta(:,i),samplesIndex(:,1));
        MCSE(i) = sqrt(output.H1hat/output.threadLength);
    end
end

deltaMean = reshape(mean(Delta),L,M+1,Q,M+1);
deltaMCSE = reshape(MCSE,L,M+1,Q,M+1);

save('deltaOut.mat','deltaMean','deltaMCSE');

matlabpool close;
clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
