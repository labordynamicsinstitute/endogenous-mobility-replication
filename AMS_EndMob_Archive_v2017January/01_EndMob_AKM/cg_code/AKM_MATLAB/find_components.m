%Ian M. Schmutte
%find_components.m
%2013-02-24
%Code implements breadth first search to construct component structure of a (bipartite) edgelist.
%valid for undirected graphs only.
%intended as preparation for AKM decomposition in employer-employee matched data
%copies of edges are possible
%INPUT: adj - the (sparse, improper), adjacency matrix representation of the network
%OUTPUT: components - a structure
	%components.i is Ix1 where I is the number of rows in the adjacency matrix
	%components.j is Jx1 where J is the number of columns in the adjacency matrix
function components = find_components(adj)
        adjt = adj';
	tic;
	%initialize component indicators
	           I = size(adj,1);                                       % number of row indices / type 1 (worker) nodes
	           J = size(adj,2);                                       % number of col indices / type 2 (employer) nodes
	components.i = zeros(I,1);                                        %holds component indicators for row indices
	components.j = zeros(J,1);                                        %holds component indicators for col indices
           edges = nnz(adj);
    %check input data
    if (I==0||J==0||edges==0||full(max(max(adj)))>1)
       disp('ERROR: Input dataset is invalid. Exiting now.')
       return;
    end
	disp('Starting Breadth-First Search to Count Components');
	disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
	fprintf('Graph structure: I=%3i. J=%3i. Number of edges=%3i.\n',I,J,edges);
	        % done = 0;	
	    comp_num = 1;
        num_found_i = 0;
        num_found_j = 0;
	for node =1:I
        if (components.i(node)==0)
    % while (~done)
            % node = find(components.i==0,1);
        % if (isempty(node))
            % done = 1;
        % else 
		%%%%%%%%INNER LOOP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
			visits=0;
		    % fprintf('Visiting Component %3i from node %3i\n',comp_num,node)
			components.i(node) = comp_num;
                  num_found_i = num_found_i+1; 
                  visit_list_i = zeros(I-num_found_i+10,1);
               visit_list_i(1) = node;
                  visit_list_j = zeros(J-num_found_j+10,1);
                        vind_i = 1;                                    %Points to next i node to visit.
                        vind_j = 1;                                    %Next j node to visit.
                      vpoint_i = 1;                                    %points to the last non-zero entry of the visit list
                      vpoint_j = 0;                                    %points to the last non-zero entry of the visit list
                        done_i = 0;
                        done_j = 0;
			
			while (done_i==0||done_j==0)
                visiting = visit_list_i(vind_i);
                if (visiting==0)
                    done_i=1;
                else
                       done_i = 0;
                       vind_i = vind_i+1;
		    %nbr = adjt(:,visiting);
                    nbr = find(adjt(:,visiting)==1);
                    nbr = nbr.*(components.j(nbr)~=comp_num);
                    neighbors = nbr(find(nbr~=0));
                    %neighbors = find(nbr & (components.j~=comp_num)); %the unvisited neighbors
                    if (~isempty(neighbors))
				        problems = find(components.j(neighbors)~=0,1);
				        if (~isempty(problems))
				            disp('ERROR: Found a node in two components from i. Exiting.');
					        return;
                        end
                        k = length(neighbors);
                        visit_list_j(vpoint_j+1:vpoint_j+k) = neighbors;
                        vpoint_j = vpoint_j+k;
                        num_found_j = num_found_j+k;
				        components.j(neighbors) = comp_num;              %mark unvisited neighbors as being in the component
                    end
                    visits = visits+1;
                end
				%now visit the col nodes
				visiting = visit_list_j(vind_j);
                if (visiting == 0) 
                    done_j=1;
                else
                    done_j=0;
                    vind_j = vind_j+1;
                    nbr = find(adj(:,visiting)==1);
                    nbr = nbr.*(components.i(nbr)~=comp_num);
                    neighbors = nbr(find(nbr~=0));
		    %nbr = adj(:,visiting);
                    %neighbors = find(nbr & (components.i~=comp_num)); %the unvisited neighbors
                    if (~isempty(neighbors))
				        problems = find(components.i(neighbors)~=0,1);
				        if (~isempty(problems))
					        disp('ERROR: Found a node in two components from j. Exiting.');
					        return;
                        end
                        k = length(neighbors);
                        visit_list_i(vpoint_i+1:vpoint_i+k) = neighbors;
                        vpoint_i = vpoint_i+k;
                        num_found_i = num_found_i+k;
                        components.i(neighbors) = comp_num;
                    end
                    visits = visits+1;
                end
                %%%%%%%%%%ERROR CHECKING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (vind_i > I+2 || vind_j > J+2 || vpoint_i > I || vpoint_j > J)
                    fprintf('ERROR: Pointers are out of range. Exiting.\n')
                    fprintf('vind_i = %3i\nvind_j=%3i\n%vpoint_i=%3i\nvpoint_j=%3i\n',vind_i,vind_j,vpoint_i,vpoint_j);
                end
				if (visits>edges)
					fprintf('ERROR: Too many visits from node %3i. Exiting.\n',node);
					return;
                elseif (mod(visits,1000)==0)
                    % fprintf('%3i visits so far from node %3i.\n',visits,node);
				end
				%%%%%%%%%END ERROR CHECKING%%%%%%%%%%%%%%%%%%%%%%%%%%%
			end %END INNER LOOP
			comp_num = comp_num+1;                                    %increment component index
			if (comp_num > I+J+1)
				fprintf('ERROR: More components than number of nodes. Exiting.\n');
				return;
			end
		end 
	end %END OUTER LOOP
	disp('Done finding connected components. Mopping up singletons.')

	%now clean up any undiscovered j nodes. By construction these must be singletons.
	              singletons = find(components.j==0);
	          num_singletons = length(singletons);
	components.j(singletons) = (comp_num:1:comp_num+num_singletons-1);
	fprintf('Elapsed time: %g. I=%3i. J=%3i. Number of edges=%3i. Number of connected components: %3i.\n',toc,I,J,edges,comp_num-1);