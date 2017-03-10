% /********************
% 	CG_load_data.m
% 	Ian M. Schmutte
% 	2016-February
% *********************/

try; 
	header; %define file paths

    rmn = csvread([wrk_path,'/AKM_Universe_ids.csv'],1,0); %read in data matrix from .csv file
    save([wrk_path,'/AKM_Universe_ids.mat'],'rmn','-v7.3');

    data = csvread([wrk_path,'/AKM_Universe_variables.csv'],1,0); %read in data matrix from .csv file
    save([wrk_path,'/AKM_Universe_variables.mat'],'data','-v7.3');
	
clear all;
catch err; 
    err.message
    err.cause
    err.stack
   exit(1);
end
exit;