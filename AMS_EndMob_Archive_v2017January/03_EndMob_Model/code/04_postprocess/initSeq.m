%function initSeq.m
%Ian M. Schmutte and John Abowd
%11 July 2012
%%%%%%%%%%%%%%%%%%%%%%
%Description:
% This function takes a matrix containing output from an MCMC sampler
% and returns the initial sequence estimators described in Kosorok (2000)
% "Monte Carlo error estimation for multivariate Markov Chains"
%%%%%%%%%%%%%%%%%%%%%%
%INPUTS
% samples     a (stack of) (n X p) matrices where n is the number of draws from
%              the MCMC sampler and p is the number of variables.
%              note: the columns in the input must be independent variables.
%              if the sample covariance matrix is badly conditioned, or not positive
%              definite, this method will perform poorly.
%              samples = [sample1;sample2;sample3;...;sample K] where there are K 
%              independent threads to be combined. It is assumed that the input data
%              are sorted first by thread and then by iteration number
%
% sampleNum   a column vector with length equal to the number of rows in samples and
%             whose entries indicate which sample each row is from. 
%OUTPUTS
% output.mhat        the number of half-lags in the initial sequence
% output.mhat_flag   =1 if mhat was set at hatmax because no negative eigenvalue was encountered. =0 otherwise
% output.numThreads  the number of independent threads used in the calculation
% output.numObs      the number of observations in each thread
% output.threadLength the thread length used to calculate the autocovariance function (it is the min of numObs)
% output.G0hat       the sample covariance matrix
% output.H0hat       the truncated periodogram window estimator of Priestly (1981) p. 437
% output.H1hat       the initial positive sequence estimator
% output.H2hat       the initial monotone sequence estimator
% output.H3hat       the initial convex sequence estimator
% output.betweenVar   the between-thread variance
% output.threadMean   vector of the within thread mean;
% output.sampleMean   the pooled mean across all iterations in all threads
%%%%%%%%%%%%%%%%%%%%%%%
%Modifications to make
%1) Allow user to choose which estimator to output
%2) Allow user to specify mhat
%3) Allow user to request autocovariance matrices
%4) Allow user to specify whether to precondition

function output = initSeq(sampleStack,sampleNum)

    %set parameters
sampleMean = mean(sampleStack);
p = size(sampleMean,2);
K = max(sampleNum); %number of threads to be combined
output.numThreads = K;
numObs = zeros(K,1);
threadMean = zeros(K,p);

for k = 1:K
    numObs(k) = sum(sampleNum==k);
end
output.numObs = numObs;
n = min(numObs);
output.threadLength = n;
mmax = floor(n/2);  %this is the number of lags we might feasibly calculate 
    %compute G for each thread
gmatAll = zeros(p,p,mmax+1,K);
for k = 1:K
    thread = sampleStack(find(sampleNum==k),:);
    threadMean(k,:) = mean(thread);
    for j=0:mmax
        for i=1:(n-j)
            gmatAll(:,:,j+1,k)=gmatAll(:,:,j+1,k)+((thread(i,:)-sampleMean)'*(thread(i+j,:)-sampleMean)+(thread(i+j,:)-sampleMean)'*(thread(i,:)-sampleMean));
        end
    end
end
gmatAll=gmatAll/(2*n);
gmat = mean(gmatAll,4);
G0hat = squeeze(gmat(:,:,1));

    %compute gammaHat
hatmax=floor((mmax-1)/2);
gammaHat=zeros(p,p,hatmax+1);
for ii=0:hatmax
  gammaHat(:,:,ii+1)=gmat(:,:,2*ii+1)+gmat(:,:,2*ii+2);
end

    %find the half-lag length of the initial positive sequence
gammaEig=zeros(p,hatmax+1);
for ii=1:hatmax+1
  gammaEig(:,ii)=eig(squeeze(gammaHat(:,:,ii)));
end

output.mhat_flag = 0; %the default
mhat = find(min(gammaEig(:,2:end),1)<=0,1) - 1; %imposes restriction that j>=1 and helps ensure mhat>=0.
   %could put error handling here for case where mhat DNE. For later (IMS)
if isempty(mhat)
    mhat = hatmax;
    disp(sprintf('No negative half-lag found. Setting mhat = %3i.',hatmax));
    output.mhat_flag = 1;
end
%mhat  = 30;

%compute the truncated periodogram esitmator
H0hat = G0hat + 2*sum(gmat(:,:,2:round(n^(2/3))+1),3);

    %compute initial positive sequence estimator
H1hat = -1*G0hat + 2*sum(gammaHat(:,:,1:mhat+1),3);

if mhat == 0 
    H2hat = H1hat;
    H3hat = H1hat;
else
        %form greatest monotone matrix minorant of the initial sequence
    minorant = zeros(p,p,mhat+1);
    minorant(:,:,1) = gammaHat(:,:,1);
    for j = 1:mhat
        A = minorant(:,:,j);
        B = gammaHat(:,:,j+1);
        Q = -1*B + A;
        [M L] = eig(Q);
        Lstar = L;
        Lstar(find(L<0)) = 0;
        Qplus = M*Lstar*M';
        minorant(:,:,j+1) = -1*(-1*A + Qplus);
    end
    H2hat = -1*G0hat + 2*sum(minorant(:,:,1:mhat+1),3);;
    if mhat < 2
        H3hat = H2hat;
    else
        %form the greatest convex matrix minorant
        convMinorant = zeros(p,p,mhat+1);
        convMinorant(:,:,1) = minorant(:,:,1);
        convMinorant(:,:,mhat+1) = minorant(:,:,mhat+1);
        for ii = 2:mhat
            Astar = convMinorant(:,:,ii-1);
            matMax = (Astar - minorant(:,:,ii));
            for j = ii+1:mhat+1
                B = (Astar - minorant(:,:,j))/(j - ii+1);
                Q = B - matMax;
                [M L] = eig(Q);
                Lstar = L;
                Lstar(find(L<0)) = 0;
                Qplus = M*Lstar*M';
            end
            convMinorant(:,:,ii) = Astar - matMax;
        end
        H3hat = -1*G0hat + 2*sum(convMinorant(:,:,1:mhat+1),3);
    end
end
%H0hat = D0hat*H0hat*D0hat;
%H1hat = D0hat*H1hat*D0hat;
%H2hat = D0hat*H2hat*D0hat;
%H3hat = D0hat*H3hat*D0hat;

betweenVar = sum((threadMean - repmat(sampleMean,K,1)).^2)/K;
%H3hat H2hat H1hat H0hat G0hat mhat sampleMean threadMean betweenVar
output.betweenVar = betweenVar;
output.threadMean = threadMean;
output.sampleMean = sampleMean;
output.mhat = mhat;
output.G0hat = G0hat;
output.H0hat = H0hat;
output.H1hat = H1hat;
output.H2hat = H2hat;
output.H3hat = H3hat;