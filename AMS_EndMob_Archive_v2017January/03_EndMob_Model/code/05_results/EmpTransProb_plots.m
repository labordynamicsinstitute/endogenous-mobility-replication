%Ian M. Schmutte
%EmpTransProb_plots.m
%code to look transition probabilities across employer types in the structural model

clear all;
addpath ./v20160324-output;
load deltaOut;
load gammaOut;
% load latentProbOut;


EmpTransProb = zeros(10,11,10,11);
for ell = 1:10
	for m = 1:11
		for q = 1:10
			for mNext = 1:11
					if (mNext <=10 & m <=10)
						g = gammaMean(ell,m,q);
						d = deltaMean(ell,m,q,mNext);
						EmpTransProb(ell,m,q,mNext) = ...
							g*d + (1-g)*(mNext==m);
					elseif (mNext==11 & m<=10)
						g = gammaMean(ell,m,q);
						d = deltaMean(ell,m,q,mNext);
						EmpTransProb(ell,m,q,mNext) = ...
							g*d + (1-g)*(mNext==m);
					elseif (m==11 & q ==1 & mNext<=10)
						g = gammaMean(ell,m,q);
						d = deltaMean(ell,m,q,mNext);
						EmpTransProb(ell,m,q,mNext) = ...
							g*d + (1-g)*(mNext==m);
					elseif (m==11 & mNext==11 & q==1)
						g = gammaMean(ell,m,q);
						EmpTransProb(ell,m,q,mNext) = ...
							1-g;
					end
			end
		end
	end
end

%Now the same thing with AKM starting values

% EmpTransProbAKM = zeros(10,11,10,11);
% for ell = 1:10
% 	for m = 1:11
% 		for q = 1:10
% 			for mNext = 1:11
% 					if (mNext <=10 & m <=10)
% 						g = Gamma0(ell,m,q);
% 						d = Delta0(ell,m,q,mNext);
% 						EmpTransProbAKM(ell,m,q,mNext) = ...
% 							g*d + (1-g)*(mNext==m);
% 					elseif (mNext==11 & m<=10)
% 						g = Gamma0(ell,m,q);
% 						d = Delta0(ell,m,q,mNext);
% 						EmpTransProbAKM(ell,m,q,mNext) = ...
% 							g*d + (1-g)*(mNext==m);
% 					elseif (m==11 & q ==1 & mNext<=10)
% 						g = Gamma0(ell,m,q);
% 						d = Delta0(ell,m,q,mNext);
% 						EmpTransProbAKM(ell,m,q,mNext) = ...
% 							g*d + (1-g)*(mNext==m);
% 					elseif (m==11 & mNext==11 & q==1)
% 						g = Gamma0(ell,m,q);
% 						EmpTransProbAKM(ell,m,q,mNext) = ...
% 							1-g;
% 					end
% 			end
% 		end
% 	end
% end



x=squeeze(EmpTransProb(5,2,:,[2 10 11]));
% xAKM=squeeze(EmpTransProbAKM(5,2,:,[2 10 11]));
 % plot(x./repmat(sum(x,2),1,3) - xAKM./repmat(sum(xAKM,2),1,3))
 plot(x./repmat(sum(x,2),1,3))
 legend('low','high','nonemp')
% plot(x-xAKM)
% plot(x)


