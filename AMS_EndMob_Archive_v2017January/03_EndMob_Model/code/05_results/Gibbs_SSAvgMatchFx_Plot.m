%Ian M. Schmutte
%Gibss_SSMatchFx_Plot.m
%Generate plot and CSV file for bar plot of AKM average match effect by workerXfirm effect

clear all;
addpath ./v20160324-output;

load deltaOut;
load gammaOut;
load latentProbOut;
load wageParms_Out;

L=10; M=10; Q=10;

%%%FROM makeTransMatrix.m%%%
TransMatAll = zeros(10,101,101);
SS = zeros(101,10);
for ell = 1:10
	for m = 1:11
		for q = 1:10
			for mNext = 1:11
				for qNext = 1:10
					if (mNext <=10 & m <=10)
						g = gammaMean(ell,m,q);
						d = deltaMean(ell,m,q,mNext);
						p = piKmean(ell,mNext,qNext);
						TransMat((mNext-1)*10+qNext,(m-1)*10+q) = ...
							g*d*p + (1-g)*(mNext==m & qNext==q);
					elseif (mNext==11 & qNext==1 & m<=10)
						g = gammaMean(ell,m,q);
						d = deltaMean(ell,m,q,mNext);
						p = 1;
						TransMat((mNext-1)*10+qNext,(m-1)*10+q) = ...
							g*d*p + (1-g)*(mNext==m & qNext==q);
					elseif (m==11 & q ==1 & mNext<=10)
						g = gammaMean(ell,m,q);
						d = deltaMean(ell,m,q,mNext);
						p = piKmean(ell,mNext,qNext);
						TransMat((mNext-1)*10+qNext,(m-1)*10+q) = ...
							g*d*p + (1-g)*(mNext==m & qNext==q);
					elseif (m==11 & mNext==11 & q==1 & qNext==1)
						g = gammaMean(ell,m,q);
						TransMat((mNext-1)*10+qNext,(m-1)*10+q) = ...
							1-g;
					end
				end
			end
		end
	end
	TransMatAll(ell,:,:) = TransMat;
	[V,D] = eig(TransMat);
	%HACK to find the unit eigenvalue
	tmp = abs(diag(D)-1); %tmp rescales everything in terms of distance from 1. 
	[idx idx] = min(tmp); %find 
	vec = V(:,idx);
	SS(:,ell) = vec/sum(vec);
end
SSemp = SS(1:100,:)./repmat(1-SS(end,:),100,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

piA = piA_Out(1,:);
piB = piB_Out(1,:);
Mu = wageParms_Out(1,21:30);
piKtmp = repmat(repmat(piA,10,1).*repmat(piB',1,10),[1,1,10]).*piKmean;
piK_marg = squeeze(sum(sum(piKtmp,1),2));
Mu_center = Mu - piK_marg'*Mu';
% Mu_center = Mu;

SSemp_alt = reshape(SSemp,10,100);
SSemp_alt_cond = SSemp_alt./repmat(sum(SSemp_alt),10,1);
SSemp_alt_avg = SSemp_alt'*Mu_center';
obs_match = reshape(sum(SSemp_alt),10,10);
obs_exp_mu = reshape(SSemp_alt_avg,10,10);

piK_flat = reshape(piKmean,100,10);
mu_avg = piK_flat*Mu_center';
pop_match = repmat(piB',1,10);
pop_exp_mu = reshape(mu_avg,10,10)';

diff_exp_mu = obs_exp_mu-pop_exp_mu;

diff_match = obs_match - pop_match;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% non-employment and unconditional employment distribution
SSunemp = SS(end,:)';
SSemp2 = SS(1:100,:);
SSemp2 = reshape(SSemp2,10,100);
obs = [reshape(sum(SSemp2),10,10);SSunemp'];
obs2 = obs.*repmat(piA,11,1);           %weight by probability each worker type
obs3=obs2(1:10,:)/(1-sum(obs2(11,:)));   %The distribution across employer types conditional on employment


figure(1);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	view(45,45);
	hold on;
	bar3(obs_exp_mu)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Employer Decile','FontSize',16)
	zlabel('Expected Match Effect (Gibbs)','FontSize',16)
	print('-f1','-djpeg','Gibbs_SSAvgMatchFx');
	csvwrite('Gibbs_SSAvgMatchFx.csv',obs_exp_mu);

figure(2);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	view(45,45);
	hold on;
	bar3(pop_exp_mu)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Employer Decile','FontSize',16)
	zlabel('Expected Match Effect (Gibbs)','FontSize',16)
	print('-f2','-djpeg','Gibbs_PopAvgMatchFx');
	csvwrite('Gibbs_PopAvgMatchFx.csv',pop_exp_mu);

figure(3);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	view(45,45);
	hold on;
	bar3(obs_match)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Employer Decile','FontSize',16)
	zlabel('Fraction','FontSize',16)
	print('-f3','-djpeg','Gibbs_ObsMatch');
	csvwrite('Gibbs_ObsMatch.csv',obs_match);

figure(4);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	view(45,45);
	hold on;
	bar3(pop_match)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Employer Decile','FontSize',16)
	zlabel('Fraction','FontSize',16)
	print('-f4','-djpeg','Gibbs_PopMatch');
	csvwrite('Gibbs_PopMatch.csv',pop_match);

figure(5);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	view(45,45);
	hold on;
	surf(obs3)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Employer Decile','FontSize',16)
	zlabel('Fraction','FontSize',16)
	print('-f5','-djpeg','Gibbs_ObsMatch');
	csvwrite('Gibbs_ObsMatchUncond.csv',obs3);

figure(6);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	% view(45,45);
	hold on;
	bar(SSunemp)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Fraction','FontSize',16)
	% zlabel('Fraction','FontSize',16)
	print('-f6','-djpeg','Gibbs_ObsUnemp');
	csvwrite('Gibbs_ObsUnemp.csv',SSunemp);

