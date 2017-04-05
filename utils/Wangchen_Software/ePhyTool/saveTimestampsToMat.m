function saveTimestampsToMat(rootdir)

diary('c:\work\saveTimestampsToMat.txt');

fprintf('***RunTime: %s\n', datestr(now));

diary OFF;

%default is full loading
opt = struct(...
    'fileindex',[],'datatype',[],'nevvar',[]);
opt.fileindex = 1; % load file
opt.nevvar = {'events'}; %load spikes and stim-event markers
opt.datatype = {'mat','nex','nev'};
%
ext = 'nev';
%find the nev files
d = rdir(fullfile(rootdir,['**\*.',ext]));
%
for i = 1 : length(d)
    fpath{i} = fileparts(d(i).name);
end

%remove the folders with mulitple recordings. 
[fpath_u,fpath_I,fpath_Iu] = unique(fpath);
[sortIu, sortIuI] = sort(fpath_Iu);
repPos = find(diff(sortIu)==0);
for i = 1 : length(repPos)
    fprintf('%d)%s\n%s\n', i,d(repPos(i)).name,d(repPos(i)+1).name);
end

%if ~isempty(repPos) ; return; end

for i = 1 : length(d)
    
    %skip the folders that have multiple files.
    if any(i == repPos) || any(i == repPos + 1)
        continue;
    end
    
    try
        
        datafile = d(i).name;
        nevFolder = fileparts(datafile);
        matFolder = strrep(nevFolder,'CerebusData','StimulationData');
        folder = parseFolder({matFolder,matFolder,nevFolder});
        fprintf('\n\n[%d | %d] %s....\n', i, length(d),datafile);
        
        %experiment name
        expName = folder(1).exp;
        
        opt.fileindex = 1; %
        s = matLoader(folder,opt);
        opt.fileindex = 0; %load session data.
        ss = matLoader(folder,opt);
        
        if isempty(s.nevData) || isempty(s.matData)
            disp('empty data '); 
            continue;
        end
        
        if isempty(s.matFile) || isempty(s.nevFile) || isempty(ss.matFile) %not-completed recordings.
            disp('unfinished recording');
            continue;
        end
        
        switch expName
            case {'NormLuminance','NormGrating','SquareMappingExperiment','DotMappingExperiment','FlashingBar'}
            otherwise
                continue;
        end
        
        if strcmp(expName,'FlashingBar')
            NEV  = openNEV(fullfile(s.nevFolder,s.nevFile),'read','nowave','nowrite');
            %stimulus onsets
            eventTime = getDigEvents(NEV);
            %
            stimValues = s.matData.params.barColors;
            stimValues = (stimValues - 128)/128;
            %filter
            %minISI = 0.8 * mean(diff(eventTime));
            minISI = 0.8 * sum(s.matData.params.barDurations);
            t_SETS = ISIFilter(eventTime,minISI);
%             varInfo = whos('NEV');
%             fprintf('check NEV size %f (kb) \n', varInfo.bytes/1000);
        else
            %sampling timestamp resolution
            tsr = s(1).nevData.TimeStampResolution;
            %sampling rate
            fs = 1 / tsr;
            %number of files loaded
            nf = length(s);
            %find the stimFrames in trial
            stimFrames = s(1).matData.params.stimFrames;
            %screen refresh rate
            refreshRate = 60;
            %interval b/w adjunct stimulus events.
            ISI = stimFrames/refreshRate;
            %threshold for filter
            minISI = 0.8 * ISI ;
            %filter noise triggered timestamp
            s = filtSETS(s,1,minISI);
            
            %read the stimulus params.
            %create the stimlus image from trial data.
            StimImage = makeStimImage(s,ss);
            %normalize the stim vectors
            stimValues = (StimImage.data -128)/128;
            
            %make the event struct
            %event = makeStimEvent(s);
            %retrive the full set of stim-event-timestamp and lookup table.
            [t_SETS,StimEventLUT] = sortStimEvent(s,makeStimEvent(s));
        end
        
        switch expName
            case {'NormLuminance','NormGrating'}
                %adapation rate analysis
                %1. get the stimulus cycle/block number.
                nBlocks = getTrialParams(s,'nBlocks');
                %the stimulus value points in each contrast
                nStimPts = length(t_SETS)/(nBlocks*2);
                %2. get the onsets for stimulus of each contrast.(assume 2-conditions,low and high, per cycle)
                stimOnsets = t_SETS(1:nStimPts:end);
                %extract onsets for low and high contrast.
                %lowConOnsets = stimOnsets(1:2:end);
                %highConOnsets = stimOnsets(2:2:end);
            case {'SquareMappingExperiment','DotMappingExperiment','FlashingBar'}
                stimOnsets = t_SETS;
                
            otherwise
                disp('continue');
                continue;
        end
        
        
        %=========================================================================
        %save the stimulus values and stimulus onsets to matlab data file.
        stimData.Values = stimValues; %stimulus intensity values (gray values centered and normalized to mean value 128).
        stimData.Timestamps = t_SETS; %timestamps of each stimlus values
        stimData.Onsets = stimOnsets; %timestamps of each contrast cycle.(odd for low, even for high contrast)
        stimData.Params = s.matData;
        %
        %disp('save stimulus data to file');
        save(fullfile(s(1).nevFolder,'stimData.mat'),'stimData');
        fprintf('\n\tSaving file...done\n\n');
        
    catch
        diary ON;
        lasterr
        fprintf('On file : %s\n',datafile);
        diary OFF;
        continue
    end
end
      
end

