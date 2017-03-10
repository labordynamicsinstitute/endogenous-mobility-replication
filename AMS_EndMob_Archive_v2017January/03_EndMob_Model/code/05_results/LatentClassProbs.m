%Ian M. Schmutte
%LatentClassProbs.m
%code to look at how separation probabilities change from AKM to structural model

clear all;
addpath ./v20160324-output;
load latentProbOut;
piA = piA_Out(1,:);
piB = piB_Out(1,:);
piKtmp = repmat(repmat(piA',1,10).*repmat(piB,10,1),[1,1,10]).*piKmean;
piK = squeeze(sum(sum(piKtmp,1),2));
figure(1);
	bar(piA);
	set(gca,'xlim',[0 11])
	xlabel('Worker Type Class','FontSize',16)
	ylabel('Probability','FontSize',16)
	print('-f1','-djpeg','WorkerClassProb_Structural');


figure(2);
	bar(piB);
	set(gca,'xlim',[0 11])
	xlabel('Employer Type Class','FontSize',16)
	ylabel('Probability','FontSize',16)
	print('-f2','-djpeg','EmployerClassProb_Structural');

figure(3);
	bar(piK);
	set(gca,'xlim',[0 11])
	xlabel('Match Type Class','FontSize',16)
	ylabel('Marginal Probability','FontSize',16)
	print('-f3','-djpeg','MargMatchClassProb_Structural');
