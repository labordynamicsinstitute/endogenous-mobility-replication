%runall_half_percent_AKMStart_10classes.m
%Ian Schmutte
%20120522
%John Abowd 20120620
%Ian Schmutte 2013-03-05 for v20130227 code version 
%Ian Schmutte 2013-04-06 for v20130406 code version
% nohup matlab -nodisplay -nosplash -singleCompThread -r runall_half_percent_AKMStart_10classes > run01_01.log &
try;
    ver
    license checkout Statistics_Toolbox
    license checkout Distrib_Computing_Toolbox

    matlabpool open 12;

L=10; M=10; Q=10;
NumSamples=1000;

addpath $P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/preprocess
addpath $P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/postprocess
addpath $P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/sampler;

load('$P/programs/schmu005/EndMob/source/data/pik_sample_half_percent_JBES.mat'); %loads input data matrix Y

[I T J NumMatches AbilityClasses0 ProdClasses0 MatchClasses0 ...
    Theta0 Psi0 Mu0 Alpha0 Beta0 Sigma0 Gamma0 Delta0 piA0 piB0 piK0 essPrior ...
    nuPrior] = prepInits(Y,L,M,Q);

clear AbilityClasses0 ProdClasses0 MatchClasses0 Sigma0;

imp = ...
    csvread('$P/programs/schmu005/EndMob/source/data/AC0_half_10C_JBES.csv',1,0);
    AbilityClasses0 = imp(:,2)';

imp = ...
    csvread('$P/programs/schmu005/EndMob/source/data/PC0_half_10C_JBES.csv',1,0);
    ProdClasses0 = imp(:,2)';

imp = ... 
    csvread('$P/programs/schmu005/EndMob/source/data/MC0_half_10C_JBES.csv',1,0);
    MatchClasses0 = imp(:,2)';

load('$P/programs/schmu005/EndMob/source/code/gibbs_sampler/current/preprocess/coloring/data/output/fp_color.mat'); %loads fp_color

Sigma0 = 0.1; % low guess
clear imp;

%reporting, etc.
tracking = 0; %tracking functionality is deprecated in this version of the code.
samples = RunSampler(NumSamples,tracking,Y,fp_color.color_mat,AbilityClasses0, ...
    ProdClasses0,MatchClasses0,Theta0,Psi0,Mu0,Alpha0,Beta0,Sigma0,Gamma0, ...
    Delta0,piA0,piB0,piK0,essPrior,nuPrior);

matlabpool close;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
exit;