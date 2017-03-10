%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   export_mean_gibbs.m
%Author: Ian M. Schmutte
%Date:   2014-December-08
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
% Construct datasets whose entries are the mean predicted theta per worker, psi per firm, and mu per match.
%
% nohup matlab -nodisplay -nosplash -singleCompThread -r s03_make_stats > s03_make_stats.log &
%%%%%%%%%%%%%%%%%%%%%%%%%

%try;
ver
    license checkout Statistics_Toolbox;
    license checkout Distrib_Computing_Toolbox;
    %matlabpool open;

    load('samplesParms.mat');
    load('samplesClasses.mat');
    load('samplesIndex.mat');
    
    header;
    load('./runInfo.csv');
    I = runInfo(1); 
    J = runInfo(2); 
    NumMatch = runInfo(3); 
    T = runInfo(4); 
    L=runInfo(5); 
    M=runInfo(6); 
    Q=runInfo(7);
    Xnum=runInfo(8);

    load([wrk_path,'/pik_sample_half_percent_JBES.mat']); 
    w        = Y(:,1);
    eyes     = Y(:,2);
    tees     = Y(:,3);
    jays     = Y(:,4);
    kays     = Y(:,5);
    sep      = Y(:,6);
    jaysNext = Y(:,7);
    Xvars    = Y(:,8:end);
    jays(find(jays==0))=J+1;
    jaysNext(find(jaysNext==0))=J+1;
    kays(find(kays==0)) = NumMatch+1;
    employed = jays ~= J+1;
    clear Y;

%Prepare data%

    numIters = size(samplesIndex,1);
    datasize = length(eyes);
    samples = [samplesParms(:,1:end-1) samplesClasses(:,1:end-1)];

    Theta_vec = zeros(I,1);
    Psi_vec   = zeros(J,1);
    Mu_vec    = zeros(NumMatch,1);
    XBeta_vec = zeros(size(w,1),1);
    Resid_vec = zeros(size(w,1),1);


%ITERATE OVER DRAWS FROM MCMC TO CREATE AND ANALYZE COMPLETE DATA MODELS%
    parfor ind = 1:numIters

        %inhale Gibbs Sampler output
        [AbilityClasses_Samp, ProdClasses_Samp, MatchClasses_Samp, ...
	    Theta_Samp, Psi_Samp, Mu_Samp, Alpha_Samp, sigma_Samp, ...
            Gamma_Samp, Delta_Samp, piA_Samp, piB_Samp, piK_Samp,Beta_Samp] ...
            =  ConvertOutput(samples(ind,:),I,J,NumMatch,L,M,Q,Xnum);
        pc = [ProdClasses_Samp M+1];
        mc = [MatchClasses_Samp 1]; %A convention; match quality does not matter in unemployment

        %renormalize variables
        XBeta=Xvars*Beta_Samp';
        Theta_Samp_Out = Theta_Samp - mean(Theta_Samp(AbilityClasses_Samp)');
        Psi_Samp_Out = Psi_Samp - mean(Psi_Samp(pc(pc~=M+1))');
        Mu_Samp_Out = Mu_Samp - mean(Mu_Samp(mc)');
        ps = [Psi_Samp_Out 0];
        Theta = Theta_Samp_Out(AbilityClasses_Samp(eyes)')';
        Psi = ps(pc(jays)')';
        Mu = Mu_Samp_Out(mc(kays)')';
        Alpha = Alpha_Samp*ones(datasize,1);
        tempResid = w - XBeta - Alpha - Theta - Psi - Mu;
        Alpha = Alpha + mean(tempResid(employed));
        Alpha_Samp_Out = Alpha(1,1);
        Resid = zeros(size(Alpha));
        Resid(employed) = w(employed) - Alpha(employed) -XBeta(employed) - Theta(employed) - Psi(employed) - Mu(employed);
        Resid(~employed) = NaN;
        %END RENORMALIZATION
	
	%PREPARE DATA FOR OUTPUT PROCESSING
	Theta_vec = Theta_vec+Theta_Samp_Out(AbilityClasses_Samp)'/numIters;
	Psi_vec = Psi_vec+Psi_Samp_Out(ProdClasses_Samp)'/numIters;
	Mu_vec = Mu_vec+Mu_Samp_Out(MatchClasses_Samp)'/numIters;
	XBeta_vec = XBeta_vec+XBeta/numIters;
	Resid_vec = Resid_vec+Resid/numIters;
    end

    	%save('Theta_vec.mat','Theta_vec');
	%save('Psi_vec.mat','Psi_vec');
	%save('Mu_vec.mat','Mu_vec');
	%save('XBeta_vec.mat','XBeta_vec');
	%save('Resid_vec.mat','Resid_vec');

        Theta = Theta_vec(eyes);
        pv = [Psi_vec; 0];
        Psi = pv(jays);
        mv = [Mu_vec; 1];
	Mu = mv(kays);
	gibbs_model_out = [(1:datasize)' XBeta_vec Theta Psi Mu Resid_vec employed];
	save('gibbs_model_out.txt','gibbs_model_out','-ascii', '-double', '-tabs');




%matlabpool close;
%clear all;
%catch err;
%    err.message
%    err.cause
%    err.stack
%    exit(1);
%end
%exit