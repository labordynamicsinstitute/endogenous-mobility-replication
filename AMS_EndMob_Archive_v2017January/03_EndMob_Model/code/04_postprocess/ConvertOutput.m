%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   ConvertOutput.m
%Author: Ian M. Schmutte
%Date:   April 2010
%%%%%%%%%%%%%%%%%%%%%%%%%
function [AbilityClasses0, ProdClasses0, MatchClasses0, Theta0, Psi0, Mu0, ... 
    Alpha0, sigma0, Gamma0, Delta0, piA0, piB0, piK0, Beta0] = ...
    ConvertOutput(input,I,J,NumMatch,L,M,Q,Xnum)
%%%%%%%%%%%%%%%%%%%%%%%%%
%Parse output from the Gibbs Sampler into a useful format.
%%%%%%%%%%%%%%%%%%%%%%%%%

first = 1;
length = L;
Theta0 = input(:,first:length);

first = length+1;
length = length+M;
Psi0 = input(:,first:length);

first = length+1;
length = length+Q;
Mu0 = input(:,first:length);

first = length+1;
length = length+1;
Alpha0 = input(:,first:length);

first = length+1;
length = length+1;
sigma0 = input(:,first:length);

first = length+1;
length = length+L*(M+1)*Q;
Gamma0 = input(:,first:length);

first = length+1;
length = length+L*(M+1)*Q*(M+1);
Delta0 = input(:,first:length);

first = length+1;
length = length+L;
piA0 = input(:,first:length);

first = length+1;
length = length+M;
piB0 = input(:,first:length);

first = length+1;
length = length+L*M*Q;
piK0 = input(:,first:length);

first = length+1;
length = length+Xnum;
Beta0 = input(:,first:length);

first = length+1;
length = length+I;
AbilityClasses0 = input(:,first:length);

first = length+1;
length = length+J;
ProdClasses0 = input(:,first:length);

first = length+1;
length = length+NumMatch;
MatchClasses0 = input(:,first:length);





