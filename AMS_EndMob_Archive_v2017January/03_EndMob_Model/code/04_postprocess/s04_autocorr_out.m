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
parpool(10);
addpath ../../postprocess;
load('samplesIndex.mat');
load('samplesIndex.mat');
load('runInfo.csv');
T = runInfo(4); 
L=runInfo(5); 
M=runInfo(6); 
Q=runInfo(7);
Xnum = runInfo(8);

    %WAGE PARAMETER POSTPROCESSING%
load('autocorr.mat');


MCSE = zeros(1,T-2);
parfor i = 1:T-2
    output = initSeq(autocorr(:,i),samplesIndex(:,1));
    MCSE(i) = sqrt(output.H1hat/output.threadLength);
end

autocorr_Out = [mean(autocorr);MCSE];
save('autocorr_Out.mat','autocorr_Out');

clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
