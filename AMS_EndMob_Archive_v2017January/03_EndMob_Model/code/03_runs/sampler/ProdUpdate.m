%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   ProdUpdate.m
%Author: Ian M. Schmutte
%Date:   April 2010
%Updated: May 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%
%			
%%%%%%%%%%%%%%%%%%%%%%%%%

function [ProdType exitType] = ProdUpdate(Data, A, BNext, K, dest, ASource, BSource, KSource, ...
    queues, Sigma0, Alpha0, Theta0, Psi0, Mu0, gamma, delta, piB0,piK,L,M,Q,T)
	%The data rows were pruned to include all obs for single firm 'j'
	%w are wage observations
	%queues is vector with one entry per match that 'j' is involved in. 
	%Columns contain ability type and match type for that match.
	%remaining parameters as defined in RunSampler.m
	
	exitType=0;
	w        = Data(:,1);
	sep      = Data(:,2);
    tees     = Data(:,3);
			
%STEP 1: residual manipulations
    t1 = (w - Alpha0 - Theta0(A)'  - Mu0(K)');
    resid = kron(t1,ones(1,length(Psi0))) - kron(Psi0,ones(length(A),1));
	%Returns 1xM row vector; handles case with only one obs
	WageTweaks = prod([normpdf(resid,0,Sigma0);ones(1,M)]);    

%STEP 2: Mobility Manipulations

    risk = (tees~=T);
	%handle case where firm only exists in last period of the sample so provides
	%no information on separations
	
	if (sum(risk) == 0)
		sepTweaks = ones(1,M);
		stayTweaks = ones(1,M);
	else
	    NumObs = length(A);
        gamInd = repmat(((M+1)*L)*(K-1),1,M) + L*(repmat(1:M,NumObs,1)-1) + repmat(A,1,M);
		delInd = repmat(((Q*(M+1)*L)*(BNext-1) + ((M+1)*L)*(K-1)),1,M) + L*(repmat(1:M,NumObs,1)-1) + repmat(A,1,M);
		
		stayTweaks = prod((1-gamma(gamInd(risk,:))).^repmat(1-sep(risk),1,M));
		sepTweaks = prod((gamma(gamInd(risk,:)).*delta(delInd(risk,:))).^repmat(sep(risk),1,M));
		

    end
	
	
	%handle cases where j is the destination firm for a mobility event
	
	if (dest==0)
	    sepDestTweaks = ones(1,M);
	else
	    NumObs = length(ASource);
	    delInd = Q*(M+1)*L*(repmat(1:M,NumObs,1)-1) + repmat((((M+1)*L)*(KSource-1) + L*(BSource-1) + ASource),1,M);
		sepDestTweaks = prod(delta(delInd));
	end

		
		
%STEP 3: Match Quality Tweaks
	NumMatches = length(queues(:,1));
	piKInd = repmat((M*L)*(queues(:,2)-1),1,M) + L*(repmat(1:M,NumMatches,1)-1) + repmat(queues(:,1),1,M);
	MatchQualTweaks = prod(piK(piKInd));

	%STEP 4: Generate Probabilities and Sample
		tau = WageTweaks.*sepTweaks.*stayTweaks.*sepDestTweaks.*MatchQualTweaks.*piB0;
		tau = tau/(sum(tau));
		

        if (sum(isnan(tau)~=0))
        %if sum(tau) = 0, not enough info in data to distinguish heterogeneity cases. This is a hack. Fix later 	
            tau = ones(1,M)/M; 
			exitType=1;
        end
         
		ProdType = find(mnrnd(1,tau)==1);

			
	%done