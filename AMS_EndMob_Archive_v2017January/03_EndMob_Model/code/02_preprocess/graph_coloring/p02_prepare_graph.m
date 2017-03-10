% p02_prepare_graph.m
% Ian M. Schmutte
% 6 April 2013
%
% nohup matlab -nodisplay -singleCompThread -nosplash -r p02_prepare_graph > p02_prepare_graph.log &
% prepare the firm projection and nodelist for coloring. There are three steps
% Step 1: Read the RMN and build the one-mode projection onto employer nodes.
% Step 2: measure the employer degree distribution
% Step 3: produce the Smallest Last (SL) ordering for the coloring

try;
    load('../data/interwrk/adj_rmn.mat'); %loads adj_rmn

%STEP 1: Create the employer projection adjacency matrix
    adj_rmn = double(adj_rmn); %otherwise can't do matrix multiply
    fp.adj = tril((adj_rmn'*adj_rmn) > 0,-1);
    fp.adj = fp.adj + fp.adj';
    disp('Finished making the employer projection');


%STEP 2: The degree list
    fp.degree_list               = sum(fp.adj,2);
    disp('Finished making the employer degree list');


%STEP 3: The Smallest Last (SL) ordering
    sein_count            = (1:size(fp.adj,1))';
    [null SL_idx] = sort(fp.degree_list,'descend');
    fp.node_SL_order      = sein_count(SL_idx);
    disp('Finished making the Smallest Last ordering');


%save in preparation for the coloring
    save('../data/interwrk/fp_object.mat','fp');
    disp('Object fp saved.');

%ERROR TRAPPING
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
exit;


