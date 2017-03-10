% p03_color_graph.m
% Ian M. Schmutte
% 6 April 2013
%
% nohup matlab -nodisplay -singleCompThread -nosplash -r p03_color_graph > p03_color_graph.log &
%
% Color firm projection graph using the Smallest Last ordering according to the SEQ (Sequential Greedy Coloring) algorithm.

try;

%Add path to the graph coloring function


%LOAD the inputs
    load('../data/interwrk/fp_object.mat'); %loads object fp
    %fp.adj           -- the adjacency matrix of the firm projection
    %fp.degree_list   -- list of node degrees ordered (implicitly) by vertex count
    %fp.node_SL_order -- list of vertices ordered from largest to smallest


%invoke the coloring
    fp_color = color_greedy_SEQ(fp.adj,fp.node_SL_order);
    save('../data/output/fp_color.mat','fp_color');
    size(fp_color.color_mat,1)
    size(fp_color.color_mat,2)
    sum(fp_color.color_mat)'
    
%ERROR TRAPPING
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
exit;