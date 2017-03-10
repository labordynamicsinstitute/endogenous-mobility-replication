%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   prepInits.m
%Author: Ian M. Schmutte
%Date:   January 2012
%Today:  2013-02-27
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
% Program that generates starting values for the Gibbs Sampler
% Requires data have been prepared through prepData.m
% Assumes that data arrive as a matrix with the following structure
    % dataIn = [w i t j MatchIdx s jNext Xvars].
	% --there is an entry for each i for t=1,...,T. 
        % missing values for wages and separations are coded as -99
	% --If wages are missing, j=0. 
	% --MatchIdx is a unique integer identifying the ixj pair. It must run from 1
	% --to NumMatch where NumMatch is the number of pairings observed in the data.
	% --s is a separation indicator. s=1 during the *last* period of a given job
	% (worker-employed match)
	% L is the number of latent worker types
	% M is the number of latent employer types
	% Q is the number of latent match types
% Returns a data matrix ready for the Gibbs Sampler
	% dataOut =  
%%%%%%%%%%%%%%%%%%%%%%%%%

function [I T J NumMatches AbilityClasses0 ProdClasses0 MatchClasses0 ... 
     Theta0 Psi0 Mu0 Alpha0 Beta0 Sigma0 Gamma0 Delta0 piA0 piB0 piK0 essPrior ... 
	 nuPrior] = prepInits(dataIn,L,M,Q)

%basic facts from the data
	I = max(dataIn(:,2));
	T = max(dataIn(:,3));
	J = max(dataIn(:,4)); %by convention, 0 indicates non-employment
	NumMatches = max(dataIn(:,5)); %by convention, MatchIdx = 0 in non-employment
	Xnum = length(dataIn(1,8:end)); %number of xvars is unknown ahead of time

%make up random vectors of starting classes
	AbilityClasses0 = randi(L,1,I); %randi might not be available everywhere.
	ProdClasses0 = randi(M,1,J); %by convention J+1 has class M+1
	MatchClasses0 = randi(Q,1,NumMatches);
	
%starting values for wage components
	Theta0 = zeros(1,L);
	Psi0 = zeros(1,M);
	Mu0 = zeros(1,Q);
	Alpha0 = 0;
        Beta0 = zeros(1,Xnum);
	
%starting values for population heterogeneity distributions
    piA0 = (1/L)*ones(1,L);
	piB0 = (1/M)*ones(1,M);
	piK0 = repmat((1/Q)*ones(1,Q),1,L*M); %row-major listing of cond. dist
	
%separation and transition probabilities
    Gamma0 = 0.5*ones(1,L*(M+1)*Q);
	Delta0 = repmat((1/(M+1))*ones(1,M+1),1,L*(M+1)*Q);

%starting values for variance of wage residual and its prior
    essPrior = 1;
	nuPrior = 1;
	Sigma0 = 1;
	
