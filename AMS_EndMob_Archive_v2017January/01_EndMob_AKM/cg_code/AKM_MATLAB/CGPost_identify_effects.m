% CGPost_identify_effects.m
% Ian M. Schmutte
% 2013-04-05 (by Ian)
%--------------------------------------------------------------------
    function output = CGPost_identify_effects(x,Xnum,groups,edgelist)
        %INPUT ARGS
        %x is the vector of effects returned by CG
        %Xnum is the number of X variables
        %I is the number of worker effects
        %groups is a vector conformable with the worker effects that
        %indexes the corresponding group. i.e. output from the grouping code
%--------------------------------------------------------------------
%INITIALIZATION
        lambda         = 0.5; %allocation of group means to theta for group 2 and higher
        Data_group     = groups.i(edgelist(:,1)); %vector of group labels conformable with data matrix
        I              = max(edgelist(:,1));
        J              = max(edgelist(:,2));
        group_design_i = sparse((1:I)',groups.i,1); %for fast lookups of indexes of workers in each group
        group_design_j = sparse((1:J)',groups.j,1); %for fast lookups of indexes of employers in each group
        group_design   = sparse((1:size(edgelist,1))',Data_group,1); % for fast lookup of data observations in each group
        fprintf('Initialization Complete.\n');

%Parse the CG Output
        beta        = x(2:Xnum);
        theta_raw   = x(Xnum+1:Xnum+I);
        psi_raw     = x(Xnum+I+1:Xnum+I+J);
        % Xb          = Data(:,5:end-1)*beta;
        alpha       = x(1);
        G           = max(groups.i);
        fprintf('Output parsing complete.\n');

        nobs = size(edgelist, 1);
        D  = sparse((1:nobs)',edgelist(:,1) ,ones(nobs,1));
        disp('D matrix generated');
        F = sparse((1:nobs)',edgelist(:,2) ,ones(nobs,1)); % Column 2 of edgelist contains plant IDs
        disp('F matrix generated');

%STEP 1: Recenter population-level theta, psi, and alpha
         theta_obs = D*theta_raw;
           psi_obs = F*psi_raw;
        theta_mean = mean(theta_obs);
          psi_mean = mean(psi_obs);
         theta_raw = theta_raw - theta_mean;
           psi_raw = psi_raw - psi_mean;
             alpha = alpha + psi_mean + theta_mean;
         theta_obs = D*theta_raw;
         psi_obs   = F*psi_raw;
         fprintf('Recentering Complete.\n');

%STEP 2: Identify Group 1
        g = 1;
        fprintf('Processing Group 1.\n');
        group   = group_design(:,g)==1;
        group_i = group_design_i(:,g)==1;
        group_j = group_design_j(:,g)==1;

        theta_mean = mean(theta_obs(group));
          % psi_mean = mean(psi_obs(group));

        theta_raw(group_i) = theta_raw(group_i) - theta_mean;
        psi_raw(group_j) = psi_raw(group_j) + theta_mean;
        fprintf('Group 1 Complete.\n');

%STEP 3: Identify Groups 2..G

        for g = 2:G
            %fprintf('Processing group %3i,\n',g);
            group   = group_design(:,g)==1;
            group_i = group_design_i(:,g)==1;
            group_j = group_design_j(:,g)==1;

            theta_mean = mean(theta_obs(group));
              % psi_mean = mean(psi_obs(group));
               % mu_g    = theta_mean + psi_mean;

            theta_raw(group_i) = theta_raw(group_i) - (1-lambda)*theta_mean;
            psi_raw(group_j) = psi_raw(group_j) + (1-lambda)*theta_mean;
        end

fprintf('Identification complete for %3i groups.\n',G);
        output.beta  = beta;
        output.theta = theta_raw;
        output.psi   = psi_raw;
        output.alpha = alpha;