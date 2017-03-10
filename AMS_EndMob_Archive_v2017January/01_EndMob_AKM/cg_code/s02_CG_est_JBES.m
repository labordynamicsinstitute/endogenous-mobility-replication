% /********************
% 	CG_Est.m
% 	Ian M. Schmutte
% 	2016-February
% 	DESCRIPTION: Fits AKM model using the CG method as outlined in ACK 2002
% *********************/

try; 
	 %define file paths
	 header; %define file paths

	addpath ./AKM_MATLAB/;

%load RMN edgelist
	load([wrk_path,'/AKM_Universe_ids.mat']); %loads 'rmn' contains worker and plant IDs for each observation
	disp('edgelist read in complete');
	origsort = rmn(:,4); %final column records the original ordering
	rmn = rmn(:,[1 2]); % Column 1 contains worker id. Column 2 contains firm ID.

	


%load data
	load([wrk_path,'/AKM_Universe_variables.mat']); %loads 'data' 
	    % retain log_earn year age black hispanic female 
	    %        sixq1 sixq2 sixq3 sixq4 sixq5 sixq6 sixqleft sixqright sixqinter sixq4th
			  %  obsnum;
	
	w = data(:,1);
	%sel = w>=0.283 & w<=3.96;
	% % NELLIE -- NEED TO MAKE SURE sel IS A LOGICAL -- otherwise you just get obs 1 repeated 60 million times
	sel = logical(ones(size(data,1),1)); %default; selects all observations
	disp('NELLIE -- check that sel is a logical matrix');
		whos sel
	
	% % ORIGINAL CODE
	year = data(sel,2);
	age = data(sel,3)/10; %in years, and rescaled down by a factor of 10
	black = data(sel,4);
	hispanic = data(sel,5);
	female = data(sel,6);
	sixqblock = data(sel,7:end-1);
	nobs = size(year,1);

    %uncomment this block if there are gaps in the sequence of workerid or plantid.
    %use this to produce more flexible code
	%relabel the matches, workerid, plantid
	%[~,~,wid]=unique(rmn(sel,1));
	%[~,~,pid]=unique(rmn(sel,2));
	%rmn = [wid pid];
	%clear wid pid matchid;
	
	% % NELLIE: CHECKS ON INPUT DATA;
	disp('NELLIE -- check input data');
		whos w year age black hispanic female sixqblock
	
	clear data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grouping
%	adj_rmn    = sparse(rmn(:,1),rmn(:,2),1); %adjacency matrix representation of the realized mobility network
%    adj_rmn    = sparse(adj_rmn>0);
%	disp('Finding connected components output');
%    components = find_components(adj_rmn);
    %When it's done:
%    save([wrk_path,'/components_output_JBES.mat'],'components','-v7.3');
%	disp('components_output.mat saved');
%	clear adj_rmn;
load([wrk_path,'/components_output_JBES.mat']);



%design matrices

	year_inds = sparse((1:nobs)',year-ones(nobs,1)*1998,ones(nobs,1));
	age_quartic = [age age.^2 age.^3 age.^4];
	X = [ones(nobs,1) age_quartic repmat(black,1,4).*age_quartic repmat(hispanic,1,4).*age_quartic repmat(female,1,4).*age_quartic sixqblock(:,2:end) year_inds(:,2:end)];
	X = sparse(X);
	Xnum = size(X,2);
	D  = sparse((1:nobs)',rmn(:,1) ,ones(nobs,1));
	disp('D matrix generated');
	F = sparse((1:nobs)',rmn(:,2) ,ones(nobs,1)); 
	disp('F matrix generated');
	I = size(D,2);
	J = size(F,2);

	% % NELLIE: CHECKS ON DESIGN MATRICES;
	disp('NELLIE -- check design matrices');
		whos year_inds age_quartic X D F

	clear age black hispanic age_quartic female year_inds sixqblock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform PCG routine for TWFE
	xpx = X'*X;
	A = [X D F]'*[X D F];
	b = [X D F]'*w;

	clear D F
	
	% % NELLIE: CHECK THAT xpx IS POSITIVE DEFINITE
	[~,pd_flag] = chol(xpx);
	disp('NELLIE -- Check if xpx is positive definite (if pd_flag = 0, then positive definite, else not)');
	fprintf('pd_flag = %3i \n',pd_flag);
	
	% % creating preconditioner
	U1 = sparse(chol(xpx));
	clear xpx;
	U2 = spdiags(sqrt(spdiags(A(Xnum+1:Xnum+I,Xnum+1:Xnum+I))),0,I,I);
	U3 = spdiags(sqrt(spdiags(A(Xnum+I+1:end,Xnum+I+1:end))),0,J,J);
	U = blkdiag(U1,U2,U3);
	disp('created preconditioner U.');
	clear  U1 U2 U3;

	% %run estimation
	disp('Executing PCG routine');
	tic
	options.pcg_tol = 1e-9;
	options.pcg_maxit =1000;                                            
	options.pcg_x0 =[];                                               %initial guess for pcg
	[output.x output.pcg_flag output.relres output.iter]   = pcg(A,b,options.pcg_tol,options.pcg_maxit,U',U,options.pcg_x0);
	toc

	%diagnostics
	clear A b;
	fprintf('PCG Convergence Flag %3i,\n',output.pcg_flag);
	fprintf('PCG Num. Iter.: %3i,\n',output.iter);
	fprintf('PCG Relative Residual %4.8f,\n',output.pcg_flag);


     id_out=CGPost_identify_effects(output.x,Xnum,components,rmn);
     save([wrk_path,'/CG_output_identified_JBES.mat'],'id_out','-v7.3');


	fprintf('Number of observations: %d,\n',nobs);
	% fprintf('Num. Matches = %d \n',nummatch);
	fprintf('Num Workers = %d \n',I);
	fprintf('Num Firms = %d \n',J);
	disp('Mean of X variables');
	disp(full(mean(X)));
	disp('Mean of dependent variable')
	disp(mean(w));


	D  = sparse((1:nobs)',rmn(:,1) ,ones(nobs,1));
	F = sparse((1:nobs)',rmn(:,2) ,ones(nobs,1)); 
	yhat = [X D F]*output.x;
	resid = w-yhat;
	dof = nobs-J-I+1-Xnum;
	RMSE = sqrt(sum(resid.^2)/dof);
	TSS = sum((w-mean(w)).^2);
	R2 = 1-sum(resid.^2)/TSS;
	adjR2 = 1-sum(resid.^2)/TSS*(nobs-1)/dof;
	fprintf('Residual Sum %1.9f,\n',sum(resid));
	fprintf('RMSE %1.5f,\n',RMSE);
	fprintf('R2 %1.5f,\n',R2);
	fprintf('adjR2 %1.5f,\n',adjR2);
	disp('TWFE Result');
	disp(output.x(1:Xnum));

    pe     = D*id_out.theta;
    fe     = F*id_out.psi;
    Xb     = X(:,2:end)*id_out.beta;
    const  = id_out.alpha;

    yhat_id = const +Xb +pe + fe;
    r = w-yhat_id;
    
    % %
    disp('NELLIE -- check output sizes for concatenation');
	whos origsort const pe fe Xb r
    
    % % NELLIE: constant needs to be transformed into a matrix;
    cg_out = full([origsort const*ones(size(origsort,1),1) pe fe Xb r]);
    save([wrk_path,'/HC_estimates_JBES.mat'],'id_out','-v7.3');
    mycell = {'obsnum    ' 'constAKM  '  'ThetaAKM  ' 'PsiAKM    ' 'XbAKM     '  'ResidAKM  '};
	[nrows,ncols] = size(cg_out);
	filename = [wrk_path,'HC_estimates_JBES.txt'];
	fid2 = fopen(filename, 'w');
    fprintf(fid2,'%s\t%s\t%s\t%s\t%s\t%s\n',mycell{1,:});
    for row = 1:nrows
        %fprintf(fid2,'%f\t%f\t%f\t%f\t%f\t%f\n',mycell{1,row+1},cg_out(row,:));
        fprintf(fid2,'%f\t%f\t%f\t%f\t%f\t%f\n',cg_out(row,:));
    end
    fclose(fid2);

    %clear X D F resid cg_out

    disp('Full Correlation Matrix of Components')
    disp('    y      pe      fe      xb      r')
    corr(full([w,pe,fe,Xb,r]))
    C=cov([w,pe,fe,Xb,r]);

    disp('Decomposition #1')
    disp('var(y) = cov(pe,y) + cov(fe,y) + cov(xb,y) + cov(r,y)');
    c11=C(1,1); c21=C(2,1); c31=C(3,1); c41=C(4,1); c51=C(5,1);
    s=[num2str(c11) ' = ' num2str(c21) ' + ' num2str(c31) ' + ' num2str(c41) ' + ' num2str(c51)];
    disp(s)
    fprintf('\n')
    disp('explained shares:    pe       fe       xb       r')
    s=['explained shares: ' num2str(c21/c11) '  ' num2str(c31/c11) '  ' num2str(c41/c11) '  ' num2str(c51/c11)];
    disp(s)

    fprintf('\n')
    disp('Decomposition #2')
    disp('var(y) = var(pe) + var(fe) + var(xb) + 2*cov(pe,fe) + 2*cov(pe,xb) + 2*cov(fe,xb) + var(r)');
    c11=C(1,1); c22=C(2,2); c33=C(3,3); c44=C(4,4); c55=C(5,5); 
    c23=C(2,3); c24=C(2,4); c34=C(3,4);
    s=[num2str(c11) ' = ' num2str(c22) ' + ' num2str(c33) ' + ' num2str(c44) ' + '  num2str(2*c23) ' + ' num2str(2*c24) ' + ' num2str(2*c34) ' + ' num2str(c55)];
    disp(s)
    fprintf('\n')
    disp('explained shares:    pe      fe      xb   cov(pe,fe)   cov(pe,xb)   cov(fe,xb)   r')
    s=['explained shares: ' num2str(c22/c11) '  ' num2str(c33/c11) '  ' num2str(c44/c11) '  ' num2str(2*c23/c11) '  ' num2str(2*c24/c11) '  ' num2str(2*c34/c11) '  ' num2str(c55/c11)];
    disp(s)
    fprintf('\n')


    %joint distribution and separability
    fedec = ceil(10 * tiedrank(fe) / length(fe));
    pedec = ceil(10 * tiedrank(pe) / length(pe));

    
    for j=1:10
        for k=1:10
            p(j,k)=mean((pedec==j)&(fedec==k));
            meanr(j,k)=mean(r.*(pedec==j).*(fedec==k))/p(j,k);
        end
    end
    disp('Joint distribution of effects (rows are deciles of pe, cols are deciles of fe)')
    p
    disp('Mean residual by pe/fe decile')
    meanr


clear all;
catch err; 
    err.message
    err.cause
    err.stack
   exit(1);
end
exit;