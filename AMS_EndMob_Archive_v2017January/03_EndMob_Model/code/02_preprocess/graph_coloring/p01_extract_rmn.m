% 01_extract_rmn.m
% Ian M. Schmutte
% 6 April 2013
%
% Read MCMC data in and extract the realized mobility network as an adjacency matrix
% nohup matlab -nodisplay -singleCompThread -nosplash -r p01_extract_rmn > p01_extract_rmn.log &

try;
    load('../data/input/pik_sample_half_percent_JBES.mat'); %loads input data matrix Y
%    w        = Y(:,1);
%    eyes     = Y(:,2);
%    tees     = Y(:,3);
%    jays     = Y(:,4);
%keep only eyes and jays, and only for periods of employment
    Data       = Y(Y(:,4)~=0,[2 4]); 
    adj_rmn    = sparse(Data(:,1),Data(:,2),1);
    adj_rmn    = adj_rmn>0;


%run some data checks to make sure the RMN is properly formatted.
    flag = 0;
    if min(sum(adj_rmn,1)==0)
        disp('There are gaps in the employer sequencing');
        flag = 1;
    end
    if (min(sum(adj_rmn,2)==0))
        disp('There are gaps in the worker sequencing');
        flag = 1;
    end

%If things went well then exit
    if (flag==0)
        save('../data/interwrk/adj_rmn.mat','adj_rmn');
        disp('RMN Adjacency matrix saved.');
    else
        disp('You need to fix the input data');
    end

catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
exit;