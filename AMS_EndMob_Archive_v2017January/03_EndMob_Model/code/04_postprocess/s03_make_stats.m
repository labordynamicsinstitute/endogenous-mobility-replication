%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   03_make_stats.m
%Author: Ian M. Schmutte
%Date:   August 2012
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares statistics of interest within each draw from the sampler. They are ready after this for downstream processing through initial sequence, etc.
%
% nohup matlab -nodisplay -nosplash -singleCompThread -r s03_make_stats > s03_make_stats.log &
%%%%%%%%%%%%%%%%%%%%%%%%%

try;
ver
    license checkout Statistics_Toolbox;
    license checkout Distrib_Computing_Toolbox;
    parpool(10);


    load('samplesParms.mat');
    load('samplesIndex.mat');
    load('samplesClasses.mat');



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

    %UNCOMMENT NEXT 3 LINES IF DATA ARE NOT PREPROCESSED
    %dataIn = csvread('wrkpath/pik_sample_half_percent_forMatlab.csv',1,0);
    %Y = readHCData(dataIn);
    %clear dataIn;
    %Next line loads matrix Y with columns as in readHCData.m
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

    %read in the AKM components
    %piksample = csvread([wrk_path,'/AKM_strip_JBES.csv'],1,0); %-->THIS FILE STILL NEEDS TO BE CREATED!!!
    %save([wrk_path,'/AKM_strip_JBES.mat'],'piksample');
    load([wrk_path,'/AKM_strip_JBES.mat']);
    XBetaAKM = piksample(:,1);
    ThetaAKM = piksample(:,2);
    PsiAKM = piksample(:,3);
    MuAKM = piksample(:,4);
    ResidAKM = piksample(:,5); %net of muAKM
    clear piksample;

%Prepare data%

    numIters = size(samplesIndex,1);
    datasize = length(eyes);
    wageParms = zeros(numIters,Xnum+L+M+Q+1+1);
    Delta = zeros(numIters,L*(M+1)*Q*(M+1));
    Gamma = zeros(numIters,L*(M+1)*Q);
    piA = zeros(numIters,L);
    piB = zeros(numIters,M);
    piK = zeros(numIters,L*M*Q);
    corrs = zeros(numIters,121);
    betaMat = zeros(numIters,30);
    samples = [samplesParms(:,1:end-1) samplesClasses(:,1:end-1)];
    autocorr = zeros(numIters,T-2);
    %likelihood = zeros(numIters,1);

%ITERATE OVER DRAWS FROM MCMC TO CREATE AND ANALYZE COMPLETE DATA MODELS%
    parfor ind = 1:numIters
	threadNum = samplesIndex(ind,1);
        iterNum = samplesIndex(ind,2);

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
        %correlogram
        autocorr(ind,:) = MakeCorrelogram(Resid,T,I);
        wageParms(ind,:) = [Theta_Samp_Out, Psi_Samp_Out, Mu_Samp_Out, Alpha_Samp_Out, Beta_Samp, sigma_Samp];
        Delta(ind,:) = Delta_Samp;
        Gamma(ind,:) = Gamma_Samp;
        piA(ind,:) = piA_Samp;
        piB(ind,:) = piB_Samp;
        piK(ind,:) = piK_Samp; 
        corrmat = [w XBetaAKM ThetaAKM PsiAKM MuAKM ResidAKM XBeta Theta Psi Mu Resid ];
        corr_temp = corr(corrmat(employed,:));
        corrs(ind,:) = reshape(corr_temp,1,121);
	Regressors = [ones(size(ThetaAKM)) XBetaAKM ThetaAKM PsiAKM MuAKM ResidAKM];
        beta_XBeta = regress(XBeta, Regressors);
	beta_Theta = regress(Theta, Regressors);
	beta_Psi = regress(Psi, Regressors);
	beta_Mu = regress(Mu, Regressors);
	beta_Resid = regress(Resid, Regressors);
	betaMat(ind,:) = [beta_XBeta' beta_Theta' beta_Psi' beta_Mu' beta_Resid'];
    end

    save('autocorr.mat','autocorr');
    save('wageParms.mat','wageParms');
    save('Delta.mat','Delta');
    save('Gamma.mat','Gamma');
    save('piA.mat','piA');
    save('piB.mat','piB');
    save('piK.mat','piK');
    save('corrs.mat','corrs');
    save('betaMat.mat','betaMat');


catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
exit