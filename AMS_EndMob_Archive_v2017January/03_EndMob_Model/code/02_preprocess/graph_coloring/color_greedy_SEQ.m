% color_greedy_SEQ.m
% Ian M. Schmutte
% 2013-04-06
% 
% -------------------------------------------------------------------
% Implements the greedy sequential coloring (SEQ) algorithm
% INPUTS:
%     adj -- the adjacency matrix representation of an undirected unipartite graph with no self edges
%     seq -- the sequence in which nodes are to be colored
% OUTPUT:
%    output.color_mat -- a sparse Jxq color design matrix

function output = color_greedy_SEQ(adj,seq)

%get count of vertices
    J = size(adj,1);

%Initializations
    q = 1;    %current max color
    color_mat = sparse(J,1);
    color_mat(seq(1),q) = 1;

%Control Loop
    for j = 2:J
        v = seq(j);
        nbrs = adj(:,v);    %column vector
        adj_colors = color_mat'*nbrs;    %should be (qx1)
        free_colors = find(adj_colors==0);
        if (length(free_colors) == 0)    %no free colors
            %add new color
            color_mat = [color_mat sparse(J,1)];
            q = q + 1;
            color_mat(v,q) = 1;
            fprintf('adding color %3i\n',q); 
        else
            %this madness finds the free color that has been least used
            color = free_colors(find(min(sum(color_mat(:,free_colors)))));
            color_mat(v,color) = 1; 
            %fprintf('using color %3i\n',color);
        end
    end

    output.color_mat = color_mat;
