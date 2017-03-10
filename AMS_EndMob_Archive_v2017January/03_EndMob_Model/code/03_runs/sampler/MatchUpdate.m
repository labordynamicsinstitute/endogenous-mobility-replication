%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   MatchUpdate.m
%Author: Ian M. Schmutte
%Date:   April 2010
%Today:  May 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%
function [MatchType exitType] = MatchUpdate(Data, A, B, BNext, Sigma0, Alpha0, ...
    Theta0, Psi0, Mu0, gamma, delta, piK0,L,M,Q,T)
	
	exitType = 0;
			
	w        = Data(:,1);
	sep      = Data(:,2);
    tees     = Data(:,3);

%STEP 1: residual manipulations
            
    t1 = (w - Alpha0 - Theta0(A)'  - Psi0(B)');
    resid = kron(t1,ones(1,Q)) - kron(Mu0,ones(length(t1),1));
    WageTweaks = prod([normpdf(resid,0,Sigma0);ones(1,Q)]);    %Returns 1xQ row vector

%STEP 2: Mobility Manipulations
    risk = (tees~=T);
	if (sum(risk) == 0)
		sepTweaks = ones(1,Q);
		stayTweaks = ones(1,Q);
	else
	    NumObs = length(A);
	    gamInd = ((M+1)*L)*(repmat(1:Q,NumObs,1)-1) + repmat(L*(B-1)+A,1,Q);
	    delInd = repmat(Q*(M+1)*L*(BNext-1),1,Q) + ((M+1)*L)*(repmat(1:Q,NumObs,1)-1) + repmat(L*(B-1) + A,1,Q);
	    stayTweaks = prod((1-gamma(gamInd(risk,:))).^repmat(1-sep(risk),1,Q));
        sepTweaks = prod((gamma(gamInd(risk,:)).*delta(delInd(risk,:))).^repmat(sep(risk),1,Q));
    end

				
%Step 3:Generate Probabilities and Sample
	piK = reshape(piK0(A(1),B(1),:),1,Q);
	tau = WageTweaks.*stayTweaks.*sepTweaks.*piK;
	tau = tau/(sum(tau));
    if (sum(isnan(tau)~=0))
		exitType=1;
        tau = ones(1,Q)/Q; %if sum(tau) = 0, not enough info in data to distinguish heterogeneity cases. This is a hack. Fix later
        %disp(sprintf('MATCH:In a bad place right now...'));
    end
	MatchType = find(mnrnd(1,tau)==1);

%done