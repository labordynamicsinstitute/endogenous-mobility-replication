%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   RunSampler.m
%Author: Ian M. Schmutte
%Date:   April 2010
%Today:  2013-04-06 Add parallelization of productivity updates through greedy coloring. Added 
%%%%%%%%%%%%%%%%%%%%%%%%%


function samples = RunSampler(NumSamples,tracking,Y,color_mat,AbilityClasses0, ...
    ProdClasses0,MatchClasses0,Theta0,Psi0,Mu0,Alpha0,Beta0,Sigma0,Gamma0, ... 
	Delta0,piA0,piB0,piK0,essPrior,nuPrior)
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRIPTION OF INPUTS
%%
%%  %GIBBS SAMPLER CONTROL
	%NumSamples: the number of samples to draw in this run
	%tracking:   indicates whether to activate certain tracking features. 
		%        tracking functionality is not currently developed
%%  %OBSERVED DATA
    %Y is the matrix of observed data. It has the following properties:  
		%1. Y = [w i t j MatchIdx s jNext Xvars]. 
		%2. There is an entry for each i for t=1,...,T (i.e. balanced panel). 
		%3. Wages are treated as missing just when j=J+1. 
		%4. MatchIdx is a unique integer identifying the ixj pair. It must run 
		%    from 1 to NumMatch where NumMatch is the number of ij pairings 
		%    obsered in the data with 0<j<J+1.
		%5. i runs from 1 to I
		%6. j runs from 0 to J. j=0 only when wages are missing. These correspond to periods of nonemployment.
		%7. k runs from 0 to NumMatch. k=0 if and only if j=0.
		%8. The separation index s=1 in the last period on the old job. s=0 otherwise.
                %9. color_mat is a sparse Jxnum_colors matrix that partitions firms into disconnected groups for updating

%%  %LATENT DATA
		%AbiliityClasses0 is 1xI where I is the number of people in the sample. 
			%Entries are integers in {1,...,L)
		%ProductivityClasses0 is 1x(J+1) where J is the number of employers in the sample. 
			%It's entries are integers {1,...,M,M+1} 
			%(the M+1 entry is assigned to the non-employment state, j=0.)
		%MatchClasses0 is 1xNumMatch where NumMatch is the number of ij matches that actually occur in the data. 
			%Entries in {1,...,Q}

%%  %MODEL PARAMETERS
		 %Theta0: 1xI vector of effects associated with levels of worker ability
		 %Psi0:   1xJ vector of effects associated with levels of employer productivity
		 %Mu0:    1xQ vector of effects associated with levels of match quality
		 %Alpha0: 1x1 average wage effect
		 %Beta0:  1xXnum vector of effects associated with Xvars
		 %Sigma0: 1x1 standard deviation of the log earnings residual
		 %Gamma0: 1xL(M+1)Q vector of separation probabilities. 
		 %		  Reshaped from a (L,M,Q) matrix of separation probabilities.
		 %Delta0: 1x(M+1)L(M+1)Q vector of probabilities. 
		 %        Reshaped from an (L,(M+1),Q,(M+1)) stochastic matrix 
		 %        whose entries describing the probability of transition from a 
		 %        match of type ell,m,q to a match with an employer in each of 
		 %        (M+1) latent classes (including to unemployment, associated 
		 %        with m=0)
		 %piA0:   is 1xL and is the probability over worker ability classes
		 %piB0:   is 1xM and is the probability that an employer has type M
		 %piK0 is 1xLMQ and is reshaped from an (L,M,Q) matrix 
		 %        describing the probability that a match between a type ell 
		 %        worker and a type m employer has match quality q.
		 %essPrior and nuPrior are parameters for the inverse-gamma prior on Sigma0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
%parse the data matrix
	%Y = [w i t j MatchIdx s jNext ];
	w        = Y(:,1);
	eyes     = Y(:,2);
	tees     = Y(:,3);
	jays     = Y(:,4);
	kays     = Y(:,5);
	sep      = Y(:,6);
	jaysNext = Y(:,7);
	Xvars    = Y(:,8:end);
        clear Y;


		
%EXTRACTING INFORMATION FROM THE INPUTS
	
%get useful information
	I = length(AbilityClasses0);
	J = length(ProdClasses0);
	NumMatch = length(MatchClasses0);
	L = length(Theta0);
	M = length(Psi0);
	Q = length(Mu0);
	T = length(w)/I;  %relies on maintaining a balanced data structure
	Xnum = size(Xvars,2); %col dimension of Xvars
	NumLatent = I+J+NumMatch;
	NumParms = L+M+Q+1+1+(L*Q*(M+1))+((M+1)*L*(M+1))*Q+L+M+(L*M*Q)+Xnum;
        NumColors = size(color_mat,2); %number of colors?
        
%output some useful run information
    runInfo = [I J NumMatch T L M Q Xnum];
    dlmwrite('runInfo.csv',runInfo,'precision','%i');
    disp(sprintf('Run Information'));
    disp(sprintf('Number of workers: %3i',I));
    disp(sprintf('Number of employers: %3i',J));
    disp(sprintf('Number of periods: %3i',T));
    disp(sprintf('Number of jobs: %3i',NumMatch));
    disp(sprintf('Number of control variables: %3i',Xnum));
    disp(sprintf('-----------------\n'));

%Preprocess
%code expects j=J+1 and k=NumMatch+1 for non-employment
jays(find(jays==0))=J+1;
jaysNext(find(jaysNext==0))=J+1;
kays(find(kays==0)) = NumMatch+1;
jaysNext(find(tees==T))=jays(find(tees==T)); %this is a convention since we don't currently use the information in the next year destination

%TRANSFORMATIONS

	%convert 1xQLM vector to LMxQ matrix
piK = reshape(piK0,Q,L*M)';
	%Design Matrices for Population
D = sparse((1:I*T)',eyes,1,I*T,I);
F = sparse((1:I*T)',jays,1,I*T,J+1);
G = sparse((1:I*T)',kays,1,I*T,NumMatch+1);
FNext = sparse((1:I*T)',jaysNext,1,I*T,J+1);

    %storage for firm updates
    colorlists = cell(NumColors,1);
    F_color = cell(NumColors,1);
    FNext_color = cell(NumColors,1);
    for c = 1:NumColors
        colorlists{c} = find(color_mat(:,c)==1);
        F_color{c} = F(:,colorlists{c});
        FNext_color{c} = FNext(:,colorlists{c});
    end
        clear color_mat;

%structure match labels in a useful way
%NEWNEW
[a IX] = sort(kays);
eys = eyes(IX);
jys = jays(IX);
kys = a;
currK = kys(1);
MatchList = zeros(NumMatch,3);
MatchList(1,:) = [eys(1) jys(1) kys(1)];
ind = 1;

for cc = 2:I*T
    testK = kys(cc);
    if (testK>currK & jys(cc)~= J+1) 
        ind = ind+1;
        MatchList(ind,:) = [eys(cc) jys(cc) kys(cc)];
        currK = testK;
    end
end

if ind ~=NumMatch
    disp(sprintf('Something has gone wrong in counting matches'));
end
clear eys jys kys currK cc ind testK IX a; 
%NEWNEW

%MatchLabelGrid = zeros(I,J+1); %CHANGE 8/29/2012 was zeros(I,J+1)
%for count = 1:I*T
%	MatchLabelGrid(eyes(count),jays(count))=kays(count);
%end
%count = 0;
%for ey = 1:I
%    for jy=1:J
%	    if MatchLabelGrid(ey,jy) ~=0
%		    count = count+1;
%		    MatchList(count,:) = [ey jy MatchLabelGrid(ey,jy)];
%		end
%	end
%end
%clear count ey jy MatchLabelGrid;	

	%To select observations with positive earnings
Employed = jays ~= J+1;

%Create conformable columns containing the latent classifications
	P = [ProdClasses0 M+1]; %(J+1)x1
	MatClas = [MatchClasses0 1];
	AbMat = sparse((1:I)',AbilityClasses0,1,I,L);
	ProdMat = sparse((1:J+1)',P,1,J+1,M+1);
	MatClasMat = sparse((1:NumMatch+1)',MatClas,1,NumMatch+1,Q);
	
	A = AbilityClasses0(eyes')'; %Nx1
	B = P(jays')'; %Nx1
	BNext = P(jaysNext')'; %Nx1
	MatClas = [MatchClasses0 1];
	K = MatClas(kays')'; %Nx1

%INITIALIZATIONS
	%initialize these matrices for later
Separations = zeros(L,(M+1),Q);
Elements = zeros(size(Separations));
Transitions = zeros(L,(M+1),Q,M+1);
MatchCounts = zeros(L,M,Q);

	%initialize the global separation rate (this goes into the prior for gamma)
sepRate = sum(sep(tees~=T))/sum(tees~=T);


	%track whether latent class updates fail	
AbilityFail=zeros(I,1);
ProdFail = zeros(J,1);
MatchFail = zeros(NumMatch,1);
	%Initialize output dataset 'samples'
samples = zeros(1,NumLatent+NumParms);
dispMat = zeros(max([L,M,Q]),3); %matrix to hold vectors of wage components for output display

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
%Iterate the Gibbs Sampler
for count = 1:NumSamples
    tic;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SOME EARLY REPORTING
	%renormalize variables
    XBeta=Xvars*Beta0';
    ThetaRep = Theta0 - mean(Theta0(AbilityClasses0));
	PsiRep = Psi0 - mean(Psi0(ProdClasses0));
	MuRep = Mu0 - mean(Mu0(MatchClasses0));
	tempResid = w(Employed) - XBeta(Employed) - Alpha0 - ThetaRep(A(Employed))' ...
		- PsiRep(B(Employed))' - MuRep(K(Employed))';
    AlphaRep = Alpha0 + mean(tempResid);
    disp(sprintf('Sample Number %3i',count));
    disp(sprintf('-----------------\n'));
    disp(sprintf('Sigma = %1.3f',Sigma0));
    disp(sprintf('Alpha = %1.3f',AlphaRep));
    disp('   Theta  Psi   Mu');
    dispMat(1:L,1) = ThetaRep';
    dispMat(1:M,2) = PsiRep';
    dispMat(1:Q,3) = MuRep';
    disp(dispMat);
	%END REPORTING
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
    %UPDATE [alpha theta psi mu]
    fprintf('Updating Earnings Parameters at time = %8.4f\n',toc);
	    %Create Design Matrix of Ability, Productivity, and Match Type
    Design = [sparse(ones(sum(Employed),1)) D(Employed,:)*AbMat(:,1:L-1) ...
        F(Employed,:)*ProdMat(:,1:M-1) G(Employed,:)*MatClasMat(:,1:Q-1) sparse(Xvars(Employed,:))];	
		%solve (penalized) least squares problem 
    lambda = (Sigma0/essPrior)^2;   %May want to change this??
    precMat = Design'*Design + lambda*eye(1+L+M+Q+Xnum-3); %precision matrix 		
	EarnParmOLS = precMat\Design'*w(Employed);	
	    %Cholesky factor for the covariance matrix (using backsolve to invert)
    C = Sigma0*(chol(precMat\eye(1+L+M+Q+Xnum-3)));
	EarnParmDraw = EarnParmOLS + C'*normrnd(zeros(length(EarnParmOLS),1),1);
    Alpha0 = EarnParmDraw(1);
    EarnParm = EarnParmDraw(2:end); 		
	    %impose identification by setting one effect to zero, always the max category              
	theta = [EarnParm(1:L-1)' 0];                      
	psi = [EarnParm(L:L+M-2)' 0];
	mu = [EarnParm(L+M-1:L+M+Q-3)' 0];
	Beta0 = EarnParm(L+M+Q-2:end)';
	    %fix samples to preserve ordering of the wage components from smallest
		%to largest.
	[a b] = sort(theta);
	Theta0 = a - max(a);
	Alpha0 = Alpha0 + max(a);
	AbilityClasses0 = b(AbilityClasses0);
	[a b] = sort(psi);
	Psi0 = a -max(a);
	Alpha0 = Alpha0 + max(a);
	ProdClasses0 = b(ProdClasses0);
	[a b] = sort(mu);
	Mu0 = a - max(a);
	Alpha0 = Alpha0 + max(a);
	MatchClasses0 = b(MatchClasses0);	
		%fix design matrices to reflect resorting
	P = [ProdClasses0 M+1]; %(J+1)x1
	MatClas = [MatchClasses0 1];
	AbMat = sparse((1:I)',AbilityClasses0,1,I,L);
	ProdMat = sparse((1:J+1)',P,1,J+1,M+1);
	MatClasMat = sparse((1:NumMatch+1)',MatClas,1,NumMatch+1,Q);
	A = AbilityClasses0(eyes')'; %Nx1
	B = P(jays')'; %Nx1
	BNext = P(jaysNext')'; %Nx1
	K = MatClas(kays')'; %Nx1	
	XBeta=Xvars*Beta0'; %we will use this a lot
	w_adj = w-XBeta;
	w_adj(~Employed) = -99;
	XBeta(~Employed) = -99;	
	%END update[alpha theta psi mu]
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE SIGMA
    fprintf('Updating Sigma at time = %8.4f\n',toc);
	    %compute wage residual vector
	eps = w_adj(Employed) - (Alpha0 + Theta0(A(Employed))' + Psi0(B(Employed))' + Mu0(K(Employed))');
	    %update sigma by sampling from inverse Gamma. 
	    %Note in Matlab the scale parameter, B, is the inverse of the gamma
            %parameter (using Zellner's notation). For sampling, use sqrt(1/x) where x is
            %gamma with shape alpha=nu/2 and scale gamma = nuess_sq/2 (see Zellner (1971 p. 371).
        nu = sum(Employed) + nuPrior - (L+M+Q+1-3);
	nuess_sq = eps'*eps + essPrior^2*nuPrior;
	Sigma0 = sqrt(1./gamrnd(nu/2, 2/nuess_sq)); 

	%END update Sigma0
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Updating Transition Parameters at time = %8.4f\n',toc);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%UPDATE COUNTS
	aFreq = sum(AbMat);
	bFreq = sum(ProdMat(:,1:M));
	MatchType = [AbilityClasses0(MatchList(:,1))' P(MatchList(:,2))' ...
        MatClas(MatchList(:,3))']; %NumMatchesX3
	sample1 = (tees~=T & Employed==1);
    sample2 = (tees~=T & Employed==0);
        PTmp = full(FNext(sample1,:)*ProdMat); %needed to parallelize (see line 329)
	for ell = 1:L
	    for em = 1:M
	        parfor q = 1:Q
			
			        %grab vector indicating matches of type ell-em-q
			    vec_lmq = full(D*AbMat(:,ell)).*(F*ProdMat(:,em)).*(G*MatClasMat(:,q));
				
				    %count the number of observations at risk for separation
				Elements(ell,em,q) = full(sum(vec_lmq(sample1)));
				
				    %count the number of these that are separations
				Separations(ell,em,q) = vec_lmq(sample1)'*sep(sample1);
				
			%generate a 1X(M+1) vector of number of transitions to each employer type
				Transitions(ell,em,q,:) = (vec_lmq(sample1)'.*sep(sample1)')*PTmp;
					%Count matches of type ell, em, q
                MatchCounts(ell,em,q) = sum((MatchType(:,1)==ell).* ...
			        (MatchType(:,2)==em).*(MatchType(:,3)==q));
                end
	    end
		
			%Separations from non-employment
		vec_l = full(D*AbMat(:,ell)).*(F*ProdMat(:,M+1));
		Elements(ell,M+1,1) = sum(vec_l(sample2)');
		Separations(ell,M+1,1) = vec_l(sample2)'*sep(sample2);
		Transitions(ell,M+1,1,:) = vec_l(sample2)'.*sep(sample2)'*(FNext(sample2,:)*ProdMat);
	end
        clear PTmp;
	%END UPDATE COUNTS
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE GAMMA
    d = gamrnd([(Separations(:) + sepRate) ...
        ((Elements(:) - Separations(:))+(1-sepRate))],1);
	gamma = (d./kron(sum(d,2),ones(1,2)));
	gamma = reshape(gamma(:,1),L,M+1,Q);
    %END update
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE DELTA
    d = gamrnd(Transitions + (1/(M+1)),1);
	dsum = sum(d,4); %
	delta = (d./repmat(dsum,[1,1,1,M+1]));
    %END update
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE piA
    d = gamrnd(aFreq + ((1/L)),1);
    piA0 = d./sum(d);
    %END update
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE piB
    d = gamrnd(bFreq + ((1/M)),1);
    piB0 = d./sum(d);
    %END update 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE piK    
    MatchCountsFlat = reshape(MatchCounts,L*M,Q); %convert from multidim array
    d = gamrnd(MatchCountsFlat + ((1/Q)),1);
    piKFlat = d./repmat(sum(d,2),1,Q);
    piK = reshape(piKFlat,L,M,Q); %store as multidimensional array
    %END update 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE AbilityClasses 
	
		%(NOTE: AbilityUpdate can be vectorized/parallelized because these updates are
        %independent)
        fprintf('Updating Ability Classes at time = %8.4f\n',toc);
    parfor i = 1:I
		changer = full(D(:,i))==1; %pick the data rows for person i
		queues = MatchType(MatchList(:,1)==i,2:3); %%%%%MATCH CLASSES HANDLING
		[AbilityClasses0(i) AbilityFail(i)] = AbilityUpdate([w_adj(changer) sep(changer) tees(changer)], ...
			 Employed(changer),B(changer),BNext(changer),K(changer), ...
			queues,Sigma0,Alpha0,Theta0,Psi0,Mu0,gamma,delta, ...
			piA0,piK,L,M,Q,T);				
	end 
	disp(sprintf('Worker Update Failures: %3i', sum(AbilityFail)));
	A = AbilityClasses0(eyes')';
	MatchType(:,1) = AbilityClasses0(MatchList(:,1))';	
	%END UPDATE
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	%UPDATE Productivity Classes
        fprintf('Updating Productivity Classes at time = %8.4f\n',toc);
	for color = 1:NumColors
            col = colorlists{color};
            Fcol = F_color{color};
            FNextcol = FNext_color{color};
            ProdClassesTmp = zeros(size(col));
            ProdFailTmp = zeros(size(col));
            parfor v = 1:length(col)
                target = full(Fcol(:,v))==1;
		    %get observations where there is a separation and j is the destination
			%firm
		target2 = (full(FNextcol(:,v))==1 & sep==1);
		dest = 0;
		ASource = 1;
		BSource = 1;
		KSource = 1;
		if sum(target2 ~= 0) 
		    dest =1;
			ASource = A(target2);
			BSource = B(target2);
			KSource = K(target2);
		end
		queues = MatchType(MatchList(:,2)==col(v),[1 3]); %for some reason this works as a slice
		[ProdClassesTmp(v) ProdFailTmp(v)] = ProdUpdate([w_adj(target) sep(target) tees(target)], ...
		    A(target),  BNext(target), K(target), ...
			dest, ASource, BSource, KSource, ...
			queues, Sigma0, Alpha0, Theta0, Psi0, ... 
			Mu0, gamma, delta, piB0,piK,L,M,Q,T);
		%B(target) = ProdClasses0(j);                     
			%these are expensive steps. Find a way to fix
		%BNext(target2) = ProdClasses0(j);
		%MatchType(MatchList(:,2)==j,2)=ProdClasses0(j);	
            end
            %update whole classification between colors. Might be a more efficient way
            ProdClasses0(col) = ProdClassesTmp;
            ProdFail(col) = ProdFailTmp;
            P = [ProdClasses0 M+1];
            B = P(jays')'; %Nx1
	    BNext = P(jaysNext')'; %Nx1
            MatchType(:,2)=P(MatchList(:,2))';	
        end
	disp(sprintf('Firm Update Failures: %3i', sum(ProdFail)));
	P = [ProdClasses0 M+1]; %(J+1)x1
    %END UPDATE
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%UPDATE MatchClasses 
        fprintf('Updating Match Classes at time = %8.4f\n',toc);
    parfor k = 1:NumMatch
        target = (kays==k);
        [MatchClasses0(k) MatchFail(k)] = MatchUpdate([w_adj(target) sep(target) tees(target)], A(target), ...
	  	    B(target), BNext(target),Sigma0, Alpha0, Theta0, ...
	    	Psi0, Mu0, gamma, delta, piK,L,M,Q,T);
    end 
	disp(sprintf('Match Update Failures: %3i', sum(MatchFail)));
	MatClas = [MatchClasses0 1];
	K = MatClas(kays')'; %Nx1
	MatchType(:,3) = MatClas(MatchList(:,3))';
	%END UPDATE
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%OUTPUT
    Gamma0 = reshape(gamma,1,L*(M+1)*Q); 
    Delta0 = reshape(delta,1,L*(M+1)*Q*(M+1));
    piK0 = reshape(piK,1,L*M*Q);

    samples = [Theta0,Psi0,Mu0,Alpha0,Sigma0, ...
	    Gamma0,Delta0,piA0,piB0,piK0,Beta0,AbilityClasses0, ...
	    ProdClasses0,MatchClasses0];
    %provide some information to the user
	disp(sprintf('runtime this iteration = %8.4f',toc));
    disp(sprintf('=======================\n'));
    %SAVE OUTPUT
    dlmwrite('samplesParms.csv',[samples(1:NumParms) count],'precision','%.8f','-append','roffset',0);
	dlmwrite('samplesClasses.csv',[samples(NumParms+1:end) count],'precision','%i','-append','roffset',0);
    %redundancy
    dlmwrite('samplesParms_B.csv',[samples(1:NumParms) count],'precision','%.8f','-append','roffset',0);
	dlmwrite('samplesClasses_B.csv',[samples(NumParms+1:end) count],'precision','%i','-append','roffset',0);
    samples = zeros(1,NumLatent+NumParms);
	%END OUTPUT
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
end %Gibbs Iteration
%done