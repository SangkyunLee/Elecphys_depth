function neurons = sortNeurons(neurons,s,t,classifier)
%sort neurons struct with classifiers. 
%input: 
%s : struct from data loader
%t:  filtered and sorted stim-event timestamps by sortStimEvent function
%neurons: cell struct from makeNeurons function.
%neurons{}.name
%         .units (removed)
%         .timestamps
%         .clusters{}
%         .clusters{}.id 
%         .clusters{}.timestamps
%
%append new fields to neurons after classifying stim events. 
%neurons{}.clusters{}.class{}
%                             .name   --- e.g 'contrast'
%                             .values --- e.g [6 35]
%                             .member{}
%                             .member{}.value --- e.g 6
%                             .member{}.timestamps --- 
%
% 
% classifier = struct('name','Contrast',...
%     'variable','contrast',...
%     'values',s.matData.params.contrast);
%only take 1 classfier for the moment.

folder = struct('base',[],'subject',[],'exp',[],'date',[],'time',[],'etc',[]);
folder(1:3) = struct(folder);
%ss = {s.matFolder,s.nexFolder,s.nevFolder};
%make it compatible with both 'old' and 'new' data struct. 
if isfield(s,'info')
    fpath = {s.info.matFolder, s.info.nexFolder, s.info.nevFolder};
else
    fpath = {s.matFolder, s.nexFolder, s.nevFolder};
end

folder = parseFolder(fpath);

%experiment name
expName = folder(1).exp;
%
n = length(neurons);
%onset of the first frame, i.e, start of stimulus sequence.
firstTimestamp = t(1);
%flag indicating ways to make boudary timestamps for events. 
%1. regular interval 2. divide recorded pulse with equal size.
opt = 2;

%for the new script and new data struct format.
if isempty(t)
    event = makeStimEvent(s); %extract the stim event struct
    [t,LUT] = sortStimEvent(s,event); % get event timestamp and look-up-table
end

%classify the clusters on specific experiments.
switch expName
    case {'SquareMappingExperiment','DotMappingExperiment','GratingExperiment'}
        for i = 1 : n
            for j = 1 : length(neurons{i}.clusters)
                %append 'class' field to neurons
                    neurons{i}.clusters{j}.class = cell(length(classifier),1);
                    neurons{i}.clusters{j}.class{1}.name = classifier.name;
                    neurons{i}.clusters{j}.class{1}.variable = classifier.variable;
                    neurons{i}.clusters{j}.class{1}.values = classifier.values;
                    %append 'class' field to neurons
                    neurons{i}.clusters{j}.class{1}.member = cell(1,1);
                    neurons{i}.clusters{j}.class{1}.member{1}.value = neurons{i}.clusters{j}.class{1}.values;
                    neurons{i}.clusters{j}.class{1}.member{1}.timestamps = neurons{i}.clusters{j}.timestamps;
            end
        end
        
    case {'NormLuminance','NormGrating'}
        %-------------retrieve trial parameters-----------------
            
            nBlocks = s.matData.params.nBlocks;
            stimulusTime = s.matData.params.stimulusTime; %stimulus ON time.
            stimFrames = s.matData.params.stimFrames;
            if strcmp(expName,'NormLuminance')
                nStd = length(s.matData.params.contrast);
                pauseFrames = 0;
                blankFrames = 0;
            else
                nStd = length(s.matData.params.stdOrient);
                pauseFrames = s.matData.params.pauseFrames;
                blankFrames = s.matData.params.blankFrames;
            end

            %stimulus ON time of block in msec
            scrt = round(1000*stimulusTime/(nStd*nBlocks));
            %refresh rate --- 
            refreshRate = 60; 
            mFrames = ceil(scrt*refreshRate/1000);
            nFrames = ceil(mFrames/stimFrames);
            %singleContrastRunTime not saved in older files.
            try
                singleContrastRunTime = s.matData.params.singleContrastRunTime;
                %in sec
                singleContrastRunTime = singleContrastRunTime/1000;
                
            catch
                %block time in sec
                %singleContrastRunTime = (nFrames*stimFrames/refreshRate);
                singleContrastRunTime = scrt/1000; %works for luminance.
            end
            
            %time for each contrast block. in the case of grating, it
            %includes the stimulus + pause + blank frames
            singleBlockTime = singleContrastRunTime * (stimFrames + blankFrames + pauseFrames)/stimFrames;
            %-------------make boundary times for each block ---------------
            %two ways. 1.) make regular intervals starting from 1st onset
            %          2.) group stim timestamps equally in block size.
            %onset of block time
            %1. regular interval
            if opt ==1
                bts = [0 : nBlocks*nStd-1]*singleBlockTime;
                %align with respect to the onset of stimuli
                bts = bts + firstTimestamp;
            elseif opt ==2
                %2. grouping with equal size
                npt = length(t)/(nBlocks*nStd);
                bts = t(1:npt:end);
            else
                bts = [];
            end
            
            %onset time for each gaussian-contrast value.
            bt = cell(nStd,1);
            for i = 1 : nStd
                %start time
                bt{i}.start = bts(i:nStd:end-(nStd-i));
                %
            end
            
            for i = 1 : nStd
                if i < nStd
                    bt{i}.end = bt{i+1}.start;
                else
                    bt{i}.end = bt{1}.start(2:end);
                    bt{i}.end = [bt{i}.end bt{i}.start(end)+singleBlockTime];
                end
            end
            
                    
            %sort timestamps by gaussian-contrast
            for i = 1 : n
                nu = length(neurons{i}.clusters);
                for j = 1 : nu
                    ts = neurons{i}.clusters{j}.timestamps;
                    neurons{i}.clusters{j}.class = cell(length(classifier),1);
                    
                    %append 'class' field to neurons
                    neurons{i}.clusters{j}.class{1}.name = classifier.name;
                    neurons{i}.clusters{j}.class{1}.variable = classifier.variable;
                    neurons{i}.clusters{j}.class{1}.values = classifier.values;
                    %set for 'contrast' only
                    neurons{i}.clusters{j}.class{1}.member = cell(nStd,1);
                    %    
                    for k = 1 : nStd
                        neurons{i}.clusters{j}.class{1}.member{k}.value = neurons{i}.clusters{j}.class{1}.values(k);
                        %select start/end timestamps for each std
                        tss = zeros(size(ts));
                        for bb = 1 : nBlocks
                            tss = tss | (ts >= bt{k}.start(bb) & ts < bt{k}.end(bb));
                        end
                        neurons{i}.clusters{j}.class{1}.member{k}.timestamps = ts(tss);
                    end
                end
            end
            
 
end


















