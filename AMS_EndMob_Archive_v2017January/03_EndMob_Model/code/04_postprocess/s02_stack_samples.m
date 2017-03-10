%code fragment used to build the data to feed to gs_postProcess.m
%July 16,2012
%Today May 10, 2013 (Ian)
%Ian M. Schmutte
%assumes we are starting in the postprocess directory with input data saved in 
%starting sample number chosen based on visual diagnostic of output from 01_reviewSamplerOutput.m
% nohup matlab -nodisplay -nosplash -singleCompThread -r s02_stack_samples > s02_stack_samples.log &
try;

    %set this parameter based on visual diagnostic of output from 01_reviewSamplerOutput.m
    startNum = 301; 

    %load the input parameters

    cd ./run01
    sp1 = load('samplesParms.csv');
    cd ../run02
    sp2 = load('samplesParms.csv');
    cd ../run03
    sp3 = load('samplesParms.csv');

    cd ..
    sn1 = [1*ones(size(sp1,1),1) (1:size(sp1,1))'];
    sn2 = [2*ones(size(sp2,1),1) (1:size(sp2,1))'];
    sn3 = [3*ones(size(sp3,1),1) (1:size(sp3,1))'];
    %relabeling here because initSeq expects these in ascending order from 1 with no gaps
    fprintf('Num. Obs. Sample 1: %i\n',size(sp1,1))
    fprintf('Num. Obs. Sample 2: %i\n',size(sp2,1))
    fprintf('Num. Obs. Sample 3: %i\n',size(sp3,1))
    fprintf('Starting From: %i\n',startNum);
    
    sp1 = sp1(startNum:end,:);
    sp2 = sp2(startNum:end,:);
    sp3 = sp3(startNum:end,:);
    sn1 = sn1(startNum:end,:);
    sn2 = sn2(startNum:end,:);
    sn3 = sn3(startNum:end,:);
    samplesParms = [sp1;sp2;sp3];
    samplesIndex = [sn1;sn2;sn3];
    save('samplesParms.mat','samplesParms');
    save('samplesIndex.mat','samplesIndex');

    clear sp1 sp2 sp3 sn1 sn2 sn3 samplesParms samplesIndex

    cd ./run01
    sc1 = load('samplesClasses.csv');
    cd ../run02
    sc2 = load('samplesClasses.csv');
    cd ../run03
    sc3 = load('samplesClasses.csv');
    cd ..

    sc1 = sc1(startNum:end,:);
    sc2 = sc2(startNum:end,:);
    sc3 = sc3(startNum:end,:);
    samplesClasses = [sc1;sc2;sc3];
    %have to invoke an old version of matlab to handle data items larger than 2G
    save('samplesClasses.mat','samplesClasses','-v7.3'); 

clear all;
catch err;
    err.message
    err.cause
    err.stack
    exit(1);
end

