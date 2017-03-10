%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   AbilityUpdate.m
%Author: Ian M. Schmutte
%Date:   May 2010
%Updated May 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRIPITION
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%

function [AbilityType exitType] = AbilityUpdate(Data, Employed, B, BNext, K, queues, ...
    Sigma0, Alpha0, Theta0, Psi0, Mu0, gamma, delta, piA0,piK,L,M,Q,T)
		
	exitType=0;
		
%queues is vector with one entry per match that 'i' is involved in. Columns 
    %contain firm type and match type for that match.
	w        = Data(:,1);
	sep      = Data(:,2);
    tees     = Data(:,3);
	
	
%STEP 1: residual manipulations
    t1 = w(Employed) - Alpha0 - Psi0(B(Employed))' - Mu0(K(Employed))';
    residual = repmat(t1,1,L) - repmat(Theta0,sum(Employed),1);
	WageTweaks = prod(normpdf(residual,0,Sigma0));   %Returns 1xL row vector
			
%STEP 2: Mobility Manipulation (vectorization makes this terse)
	numobs = length(K);
	risk = (tees~=T);
	    %produce numobsXL matrix of gamma indices
	gamInd = repmat(((L*(M+1))*(K-1) + L*(B-1)),1,L) + repmat(1:L,numobs,1);
        %produce numobsXL matrix of delta indices
	delInd = repmat(((Q*(M+1)*L)*(BNext-1) + ((M+1)*L)*(K-1) + L*(B-1)),1,L) + repmat(1:L,numobs,1);
	
	stayTweaks = prod((1-gamma(gamInd(risk,:))).^repmat(1-sep(risk),1,L));
	
	sepTweaks = prod((gamma(gamInd(risk,:)).*delta(delInd(risk,:))).^repmat(sep(risk),1,L));

		
%STEP 3: Match Quality Manipulation
	NumMatches = length(queues(:,1));
	
	piKInd = repmat(((L*M)*(queues(:,2)-1) + L*(queues(:,1)-1)),1,L) + repmat(1:L,NumMatches,1);

	MatchQualTweaks = prod(piK(piKInd));
			
	tau = WageTweaks.*sepTweaks.*stayTweaks.*MatchQualTweaks.*piA0;
	tau = tau/(sum(tau));
	
    if (sum(isnan(tau)~=0))
        tau = ones(1,L)/L; %if sum(tau) = 0, not enough info in data to distinguish heterogeneity cases. This is a hack. Fix later
		exitType=1;
        %disp(sprintf('WORKER:In a bad place right now...'));
    end

	AbilityType = find(mnrnd(1,tau));
			
			
		
			