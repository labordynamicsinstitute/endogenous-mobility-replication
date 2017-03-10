%Ian M. Schmutte
%Gibbs_AvgMatchFx_Plot.m
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
piKtmp = repmat(repmat(piA',1,10).*repmat(piB,10,1),[1,1,10]).*piKmean;
piK_marg = squeeze(sum(sum(piKtmp,1),2));
Mu_center = Mu - piK_marg'*Mu';
% Mu_center = Mu;

piK_flat = reshape(piKmean,100,10);
mu_avg = piK_flat*Mu_center';
P = reshape(mu_avg,10,10)';



figure(1);
	% axis manual;
	% axis([1 10 1 10 -0.1 0.1]);
	set(gca,'XTick',1:10,'YTick',1:10)
	grid on;
	view(45,45);
	hold on;
	bar3(P)
	xlabel('Worker Decile','FontSize',16)
	ylabel('Employer Decile','FontSize',16)
	zlabel('Average Match Effect (Gibbs)','FontSize',16)
	print('-f1','-djpeg','Gibbs_AvgMatchFx');
	csvwrite('Gibbs_AvgMatchFx_Start.csv',P);



