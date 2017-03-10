%s01_reviewSamplerOutput.m
%Ian Schmutte
%20120203

%Code to generate summary plots of the sampler output. Should be run from the RUN DIR.
%Assumes the existence of samples.csv and runInfo.csv

% nohup matlab -nodisplay -nosplash -singleCompThread -r s01_reviewSamplerOutput > s01_reviewSamplerOutput.log &
try;
    load('runInfo.csv');
    I = runInfo(1);
    J = runInfo(2);
    NumMatch = runInfo(3);
    L = runInfo(5);
    M = runInfo(6);
    Q = runInfo(7);
    Xnum = runInfo(8);
    samplesParms = load('./run01/samplesParms.csv');
    plot_samplesParms(samplesParms(:,1:end-1),I,J,NumMatch,L,M,Q,Xnum,1,'graphs_run01');
    samplesParms = load('./run02/samplesParms.csv');
    plot_samplesParms(samplesParms(:,1:end-1),I,J,NumMatch,L,M,Q,Xnum,1,'graphs_run02');
    samplesParms = load('./run03/samplesParms.csv');
    plot_samplesParms(samplesParms(:,1:end-1),I,J,NumMatch,L,M,Q,Xnum,1,'graphs_run03');

clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
