%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   MakeCorrelogram.m
%Author: Ian M. Schmutte
%Date:   Feb 2016
%%%%%%%%%%%%%%%%%%%%%%%%%
function correl = MakeCorrelogram(x,T,I)
%%%%%%%%%%%%%%%%%%%%%%%%%
%compute autocorrelogram from panel data with I units and T observations per unit
%This code assumes the input vector has size T*I and that missing observations are set to NaN
%output is a 1x(T-2) vector of correlations at lag 1,2,...,T-2
%%%%%%%%%%%%%%%%%%%%%%%%%

	correl = zeros(1,T-2);
    for ell=1:T-2
        r_mat = reshape(x,T,I); %groups observations within worker
        r_mat_lag = zeros(size(r_mat));
        r_mat_lag(ell+1:end,:) = r_mat(1:end-ell,:);
        auto = [reshape(r_mat(ell+1:end,:),I*(T-ell),1) reshape(r_mat_lag(ell+1:end,:),I*(T-ell),1)];
        sel = (isnan(auto(:,1))|isnan(auto(:,2)));
        hold = corr(auto(~sel,:));
        correl(ell) = hold(2,1);
        clear auto hold
    end