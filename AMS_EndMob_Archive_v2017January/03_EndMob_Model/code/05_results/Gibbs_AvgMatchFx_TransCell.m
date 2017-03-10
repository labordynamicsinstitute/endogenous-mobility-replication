%Ian M. Schmutte
%AKM_AvgMatchFx_Plot.m
%Generate plot and CSV file for bar plot of AKM average match effect by workerXfirm effect

clear all;
addpath ./v20160324-output;

load deltaOut;
load gammaOut;
load latentProbOut;
load wageParms_Out;
L=10; M=10; Q=10;

piA = piA_Out(1,:);
piB = piB_Out(1,:);
Mu = wageParms_Out(1,21:30);
piKtmp = repmat(repmat(piA,10,1).*repmat(piB',1,10),[1,1,10]).*piKmean;
piK_marg = squeeze(sum(sum(piKtmp,1),2));
Mu_center = Mu - piK_marg'*Mu';
% Mu_center = Mu;

for ell=1:L
	E_mu_post = zeros(M,M+1);
	for em = 1:M
		G = squeeze(gammaMean(ell,em,:));
		pi = squeeze(piKmean(ell,em,:));
		D = squeeze(deltaMean(ell,em,:,:)); 
		%D_tmp = squeeze(Delta0(ell,em,:,:));  
		%D = D_tmp(:,1:10)./repmat(1-D_tmp(:,11),1,10); %drop transitions to non-employment and rescale transition probabilities accordingly.
		pr_mu_pre = (G.*pi)/(G'*pi);
		% clf
		% plot(cumsum([pi pr_mu_pre])); %interesting diagnostic; how is set of "leavers" different from the population?
		% pause
		for emNext = 1:M+1
			d = D(:,emNext); %10x1
			pr_mu_post = (d.*pr_mu_pre)/(d'*pr_mu_pre);
			E_mu_post(em,emNext) = pr_mu_post'*Mu_center';
		end
	end
	% bar3(E_mu_post);
	% pause
	clf;
	figure(1);
	axis manual;
	axis([1 10 1 11 -0.6 0.6]);
	set(gca,'XTick',1:10,'YTick',1:11)
	grid on;
	view(45,45);
	bar3(E_mu_post)
	xlabel('Destination Employer Class','FontSize',16)
	ylabel('Origin Employer Class','FontSize',16)
	zlabel('Average Match Effect (Gibbs)','FontSize',16)
	print('-f1','-djpeg',['Gibbs_AvgMatchFx_Trans_Wkr',num2str(ell)]);
	csvwrite(['Gibbs_AvgMatchFx_Trans_Wkr',num2str(ell),'.csv'],E_mu_post);
	pause
end





