%%%%%%%%%%%%%%%%%%%%%%%%%
%File:   s04_corrMat_out.m
%Author: Ian M. Schmutte
%Date:   May 10, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%
%DESCRPITION
%
%Prepares summary of posterior dist of correlation matrix for disclosure avoidance review
% nohup matlab -nodisplay -nosplash -singleCompThread -r s04_corrMat_out > s04_corrMat_out.log &
%%%%%%%%%%%%%%%%%%%%%%%%%

try;
ver
    license checkout Statistics_Toolbox;
    license checkout Distrib_Computing_Toolbox;
    matlabpool open;
    addpath ../../postprocess;
    load('./samplesIndex.mat');

    %CORRELATION MATRIX POSTPROCESSING%
    load('./corrs.mat');
    corrMean = reshape(mean(corrs),11,11);
    disp(corrMean);

    MCSE = zeros(1,121);
    parfor i =1:121
        [a b] = ind2sub([11,11],i);
        if (a <= b)
            output = initSeq(corrs(:,i),samplesIndex(:,1));
            MCSE(i) = sqrt(output.H1hat/output.threadLength);
        end
    end

    corrMean = reshape(mean(corrs),11,11);
    corrMCSE = reshape(MCSE,11,11);

    save('corrMat.mat','corrMean','corrMCSE');

    matlabpool close;
clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end
