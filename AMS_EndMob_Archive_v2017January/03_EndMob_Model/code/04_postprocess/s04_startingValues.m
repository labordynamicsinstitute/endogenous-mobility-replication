%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_startingValues.m
%Author: Ian M. Schmutte
%Date:   May 2013
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
% Compute model parameters based on AKM starting values
%
%nohup matlab -nodisplay -nosplash -singleCompThread -r "s04_startingValues; exit" > s04_startingValues.log &
%%%%%%%%%%%%%%%%%%%%%%%%%


try;
ver
    license checkout Statistics_Toolbox;
    license checkout Distrib_Computing_Toolbox;
    matlabpool open;

    %UNCOMMENT NEXT 3 LINES IF DATA ARE NOT PREPROCESSED
    %dataIn = csvread('/rdcprojects/co2/co00538/programs/schmu005/EndMob/source/data/pik_sample_half_percent_forMatlab.csv',1,0);
    %Y = readHCData(dataIn);
    %clear dataIn;
    %Next line loads matrix Y with columns as in readHCData.m
    load('/rdcprojects/co/co00538/programs/schmu005/EndMob/source/data/pik_sample_half_percent_20130405.mat'); 


imp = ...
    csvread('/rdcprojects/co/co00538/programs/schmu005/EndMob/source/data/AC0_half_10C_new.csv',1,0);
    AbilityClasses0 = imp(:,2)';

imp = ...
    csvread('/rdcprojects/co/co00538/programs/schmu005/EndMob/source/data/PC0_half_10C_new.csv',1,0);
    ProdClasses0 = imp(:,2)';

imp = ... 
    csvread('/rdcprojects/co/co00538/programs/schmu005/EndMob/source/data/MC0_half_10C_new.csv',1,0);
    MatchClasses0 = imp(:,2)';	
		



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
load('./runInfo.csv');
    L=runInfo(5); 
    M=runInfo(6); 
    Q=runInfo(7);
    
	
%get useful information
	I = length(AbilityClasses0);
	J = length(ProdClasses0);
	NumMatch = length(MatchClasses0);
	T = length(w)/I;  %relies on maintaining a balanced data structure
	Xnum = size(Xvars,2); %col dimension of Xvars
	NumLatent = I+J+NumMatch;
	NumParms = L+M+Q+1+1+(L*Q*(M+1))+((M+1)*L*(M+1))*Q+L+M+(L*M*Q)+Xnum;

%Preprocess
%code expects j=J+1 and k=NumMatch+1 for non-employment
jays(find(jays==0))=J+1;
jaysNext(find(jaysNext==0))=J+1;
kays(find(kays==0)) = NumMatch+1;
jaysNext(find(tees==T))=jays(find(tees==T)); %this is a convention since we don't currently use the information in the next year destination

%TRANSFORMATIONS

	%Design Matrices for Population
D = sparse((1:I*T)',eyes,1,I*T,I);
F = sparse((1:I*T)',jays,1,I*T,J+1);
G = sparse((1:I*T)',kays,1,I*T,NumMatch+1);
FNext = sparse((1:I*T)',jaysNext,1,I*T,J+1);

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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
    %UPDATE [alpha theta psi mu]
	    %Create Design Matrix of Ability, Productivity, and Match Type
    Design = [sparse(ones(sum(Employed),1)) D(Employed,:)*AbMat(:,1:L-1) ...
        F(Employed,:)*ProdMat(:,1:M-1) G(Employed,:)*MatClasMat(:,1:Q-1) sparse(Xvars(Employed,:))];	
		%solve (penalized) least squares problem 

    precMat = Design'*Design; %precision matrix 		
	EarnParmOLS = precMat\Design'*w(Employed);	
	    %Cholesky factor for the covariance matrix (using backsolve to invert)

    Alpha0 = EarnParmOLS(1);
    EarnParm = EarnParmOLS(2:end); 		
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
	    %compute wage residual vector
	eps = w_adj(Employed) - (Alpha0 + Theta0(A(Employed))' + Psi0(B(Employed))' + Mu0(K(Employed))');
        Sigma0 = sqrt(eps'*eps/(length(Employed) - (L+M+Q+Xnum+1-3)));

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
	Gamma0 = reshape(gamma(:,1),L,M+1,Q);
    %END update
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UPDATE DELTA
    d = gamrnd(Transitions + (1/(M+1)),1);
	dsum = sum(d,4); %
	Delta0 = (d./repmat(dsum,[1,1,1,M+1]));
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
    piK0 = reshape(piKFlat,L,M,Q); %store as multidimensional array
    %END update 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


save('startingValues.mat','Theta0','Psi0','Mu0','Alpha0','Sigma0','Gamma0', ... 
	'Delta0','piA0','piB0','piK0','Beta0');

clear all;
%matlabpool close;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end

