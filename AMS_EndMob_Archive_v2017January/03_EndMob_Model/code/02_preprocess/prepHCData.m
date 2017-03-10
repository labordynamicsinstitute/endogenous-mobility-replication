%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   prepHCData.m
%Author: Ian M. Schmutte
%Date:   February 2012
%Today 2013-02-27
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
% Script to read HC files prepared for Gibbs sampler and associated postprocessing. 
%%%%%%%%%%%%%%%%%%%%%%%%%

try;

Y = csvread('$P/programs/schmu005/EndMob/source/data/to_mcmc_half_JBES.csv',1,0); %generated from 06.04.prepare_mcmc_vars_JBES.sas
save('$P/programs/schmu005/EndMob/source/data/pik_sample_half_percent_JBES.mat','Y');

clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end


exit;
