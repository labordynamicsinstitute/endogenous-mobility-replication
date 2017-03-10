%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_wageParms_out.m
%Author: Ian M. Schmutte
%Date:   August 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares data for disclosure avoidance review
%
%nohup matlab -nodisplay -nosplash -singleCompThread -r s04_wageParms_out > s04_wageParms_out.log &
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
Xnum = runInfo(8);

    %WAGE PARAMETER POSTPROCESSING%
load('wageParms.mat');
for q = 1:99
    wageParms_quantiles_out(q,:) = quantile(wageParms,q/100);
end

MCSE = zeros(1,L+M+Q+Xnum+2);
parfor i = 1:L+M+Q+Xnum+2
    output = initSeq(wageParms(:,i),samplesIndex(:,1));
    MCSE(i) = sqrt(output.H1hat/output.threadLength);
end

wageParms_Out = [mean(wageParms);MCSE;wageParms_quantiles_out];
save('wageParms_Out.mat','wageParms_Out');

matlabpool close;
clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
