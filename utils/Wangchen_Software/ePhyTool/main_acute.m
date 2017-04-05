%main script to analyze the clustered acute data 
%
%% Configuration
%-----------------------------------------------------------------
%find the OS type
OS=getenv('OS');
if strfind(OS,'XP')
    pathstr = 'C:\Documents and Settings';
else %win7
    pathstr = 'C:\Users\';
end
%select channel map file -- linear probe of single electrode or plannar array of tetrodes.     
% cmapFilePath = fullfile(pathstr,getenv('USERNAME'),'My Documents');
%cmapFilePath = 'c:\work\Experiment\Latest\New\ePhyTool';
cmapFilePath = fileparts(mfilename('fullpath'));
cmapFileName = 'Tetrode_96ch_4C.cmp';
% cmapFileName = '32ch double-headstage map.CMP';
% cmapFileName = '32ch-EDGE double-headstage map.CMP';
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
%
global cmap
cmap = readCerebusMap(cmapFile);
%get files info for the last session
lastSession = getEPhyToolLastSession;
%seperator chars
hlfgs = char(ones(1,80,'uint8')*uint8('-'));
%initialize params
folder = struct(...
    'base',[],'subject',[],'exp',[],'date',[],'time',[]...
    );
folder(1:3)=struct(folder);
%default is full loading
opt = struct(...
    'fileindex',[],'datatype',[],'nevvar',[]);
opt.fileindex = 1; % load file
opt.nevvar = {'neurons','events'}; %load spikes and stim-event markers
opt.datatype = {'mat','nex','nev'};
%---------------------------------------------------------------
%
try close(h_dataLocator); end %close last open window.
if isempty(getappdata(0,'dataLocator_folder'))
    folder = parseFolder({lastSession.matFolder,lastSession.matFolder,lastSession.nevFolder});
end
h_dataLocator = dataLocator;
%enable the execuation button
set(findobj(h_dataLocator,'Tag','pushbutton_OK'),'Enable','on');
while true
    pause(0.1)
    if ~isempty(getappdata(0,'dataLocator_result'))
        break;
    end
    if ~ishandle(h_dataLocator); break; end %if cancel was clicked and fig closed
end
ret = getappdata(0,'dataLocator_result');
if ~isempty(ret) %if not cancled or it will continue with mannual setting
    folder = ret.folder;
    opt.fileindex = eval(ret.fileindex);
end

%% read the data 
% load 'neurons' for spikes and 'events' for stim-event-timestamps
fprintf('Loading data files ....\n');
s = matLoader(folder,opt);
opt.fileindex = 0; %load session data.
ss = matLoader(folder,opt);

%=======================================================================
%flag to load the sorted cluster files (basename_sort.mat) as opposed to
%the unsorted nev files.
loadClustered = false;
if loadClustered
%     %clustered file
%     sortFile = fullfile(s.nevFolder,strrep(s.nevFile,'.nev','_sort.mat'));
%     %folder(3)
%     %load the cluster file
%     try 
%         load(sortFile);
%     catch 
%         fprintf('cannot open clustered file\n');
%         return;
%     end
%     %replace the neurons data in NEV struct
%     nn = length(s.nevData.neurons);
%     for ii = 1 : nn
%         %
%         channelName = s.nevData.neurons{ii}.name;
%         %electrode id
%         channelId = str2num(strrep(channelName,'chan',''));
%         %
%         E = (NEV.Data.Spikes.Electrode == channelId);
%         s.nevData.neurons{ii}.timestamps = (double(NEV.Data.Spikes.TimeStamp(E))/30000)'; %30k sampling rate
%         s.nevData.neurons{ii}.units = NEV.Data.Spikes.Unit(E)' ; 
%     end
    
    %======================================================================
    %replace the neurons struct with the model files.
    s.nevData.neurons = [];
    
    kk = 1;
    for ii = 1 : 24
        channelID = ii;
        %electrode id
        %load MU from modelxx files
        modelFile = fullfile(s.nevFolder,sprintf('model%d.mat',channelID));
        if ~exist(modelFile,'file'); continue; end
        try
            load(modelFile);
        catch
            lasterr
            continue;
        end
        s.nevData.neurons{kk}.timestamps = (model.SpikeTimes.data/1000); %in sec.
        s.nevData.neurons{kk}.units  = ones(size(s.nevData.neurons{kk}.timestamps));
        s.nevData.neurons{kk}.name = sprintf('chan%d',channelID);
        kk = kk + 1;
        clear model;
    end
    %clear cmap and use 6x4 default arrangement in specviewer.
    cmap = [];
    
end


%-----------read the trial info from data array----------------------
%experiment name
expName = folder(1).exp;
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
%---------------------------------------------------------------------
%filter the stim-event-timestamps. assume dig.ch1 contains photodiode pulses
s = filtSETS(s,1,minISI);
% %reformat the data struct
%trials = reformatData(s);
%---------------------------------------------------
trials = struct;
%
for i = 1 : nf
    %load the spikes and stim-event-timestamps.
    s_SETS = s(i);
    %trim nevdata before sorting events - return a one-element struct with one-entry of
    %events in nevData.
    s_SETS = trimNEVData(s_SETS,1,1);
    %------------------------------------
    %generate neurons data struct for clusters from trial data.
    neurons = makeNeurons(s_SETS);
    %classify neurons by trial params, e.g., gaussian-contrast
    %neurons = classifyNeurons(neurons,s_SETS,ss);
    %convert the data struct format 
    %trials(i) = reformatData(s(i),neurons);
end
%reformat the session struct
%session = reformatData(ss);
%
%run experiment-specific analysis.
for i = 1 : nf
    %trials(i).proc.
    %create the stimlus image from trial data.        
    StimImage = makeStimImage(s(i),ss);
    %make the event struct
    event = makeStimEvent(s(i));
    %retrive the full set of stim-event-timestamp and lookup table.
    [t_SETS,StimEventLUT] = sortStimEvent(s(i),event);
    %
    neurons = classifyNeurons(neurons,s(i),ss,t_SETS);
    %--------------------experiment-specific analysis--------------------
    %adapation rate analysis
    %1. get the stimulus cycle/block number.
    nBlocks = getTrialParams(s(i),'nBlocks');
    %2. get the onsets for stimulus of each contrast.(assume 2-conditions,low and high, per cycle)
    stimOnsets = t_SETS(1:length(t_SETS)/(nBlocks*2):end);
    %t window for select spikes. (in sec)
    selWindow = 2;
    %select the spikes,e.g, near the transition of the conditions. the
    %transition onsets is given by stimOnsets
    %neurons = trials(i).proc.neurons;
    %spikes after transition
    neurons1 = filtSpikes(neurons, stimOnsets, [0 selWindow]);
    %spikes before transition
    neurons2 = filtSpikes(neurons, stimOnsets, [-selWindow 0]);
    %extract onsets for low and high contrast.
    lowConOnsets = stimOnsets(1:2:end);
    highConOnsets = stimOnsets(2:2:end);
    %total time of stimulus blocks.
    stimulusTime = getTrialParams(s(i),'stimulusTime');
    %time of each contrast block.
    tBlock = stimulusTime/(nBlocks*2);
    %bin size for histogram.
    tBin = 3; 
    
    %checkChannel = cmap(:,3); %use all channels in the map file
    %checkChannel = [16];  %select channels for the plot.
    %reference events for low contrast and high contrast.
%    REF_low = onsetCycle(1:2:end);
%    REF_high = onsetCycle(2:2:end);
    checkChannel = cmap(:,3); %use all channels in the map file
    checkChannel = downsample(checkChannel,4); %compute one channel only in tetrode channels.

    nChannels = length(neurons);
    
    iClass = 1;
    gStaMax = -Inf;
    gStaMin = Inf;
   
    for k = 1 : nChannels
        if ~any(checkChannel == neurons{k}.channel); continue; end
        %return a struct  - test the first one
        fprintf('Firing Rate Computation for File[%d], uch[%d]...\n',i,k);
        %compute STA for normlumniance and squaremapping.
        for kk = 1 : length(neurons{k}.clusters)
            %e.g, mm=2 for 'low' and 'high' contrast for guassian luminance.
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                        ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
                        ts = ts';
                        if mm == 1 
                            REF = lowConOnsets;
                        else
                            REF = highConOnsets;
                        end
                        [spikeCount,spikeCountSE,xout] = pePSTH(ts,REF,[0:tBin:tBlock-tBin]);
                        %[spikeCount,spikeCountSE,xout] = pePSTH(ts,REF,[0 tBlock-tBin],tBin);
                        %append 'sta' to neurons.
                        firingRate = spikeCount/tBin;
                        firingRateSE = spikeCountSE/tBin;
                        %
                        fitcoeff = expFit(xout',firingRate');
                        %
                        rateExpFit = fitcoeff(1) + fitcoeff(2)*exp(-fitcoeff(3)*xout);
                        %
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = firingRate; %firing rate
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = [];%covariance
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = firingRateSE;%error 
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.fit = rateExpFit;
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.fitcoeff = fitcoeff;
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = sum(spikeCount); %total spikes used in computation.
                        gStaMax = max([gStaMax max(max(firingRate)) max(max(firingRateSE))]);
                        gStaMin = min([gStaMin min(min(firingRate)) min(min(firingRateSE))]);
            end
        end
        xSTA = xout;
        %generate average profile for multi-unit activity.
        data = zeros(size(xSTA));
        Nspk = 0;
        for kk = 1 : length(neurons{k}.clusters)
            %exclude the unsorted unit 
            if neurons{k}.clusters{kk}.id == 0 ; continue; end
            if neurons{k}.clusters{kk}.id == 255 ; continue; end
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                Nspk = Nspk + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes);
                try
                    data = data + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta)*(neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes);
                catch
                    %sta returns '[]' for channels having no spikes 
                    %data = data + 0;
                end
            end
        end
        if Nspk > 0 ; data = data / Nspk; end
        %multi-unit profile of sta
        neurons{k}.sta = data;
    end
    
end

    switch expName
        case {'DotMappingExperiment','SquareMappingExperiment'}
            %view option for normluminance
            viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
            viewOption.memberID = 1; %member id, .e.g which contrast
            %option for mapping
            viewOption.clusterID = []; %view specified cluster if viewMUA false
            viewOption.viewUnsortedUnit = false; %flag for plotting unsorted unit
            viewOption.viewMUA = true; %view multi-unit for receptive-field
            viewOption.colorscale = [gStaMin gStaMax]; %color range.

        case {'NormLuminance','NormGrating'}
            %
            viewOption = struct;
            viewOption.plot = 'STA';
            viewOption.plotdim = 1; %plot in 1/2d 
            viewOption.message = '';
            viewOption.skip = true; %skip empty data channel for plotting.
            %view option for normluminance
            viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
            viewOption.memberID = 1; %member id, .e.g which contrast
            %option for mapping
            viewOption.clusterID = []; %view specified cluster if viewMUA false
            viewOption.viewUnsortedUnit = true; %flag for plotting unsorted unit
            viewOption.viewMUA = false; %view multi-unit for receptive-field
            %viewOption.colorscale = [gStaMin-0.3*(gStaMax-gStaMin) gStaMax+0.3*(gStaMax-gStaMin)]; %[] for 'auto'. 
            viewOption.colorscale = [];
            viewOption.plotSE = false; %plot error data. effective for 1d
            viewOption.plotContour = false; %plot contour. effective for 2d 
            viewOption.plotCustom = true; %customize the data plotting 
            viewOption.plotCustomType = 'PSTH'; %
            
    end
    
    %concate the two contrast datasets in the 1st struct for the PSTH if
    %'plotCustom' is set true.
    switch expName
        case {'NormLuminance','NormGrating'}
            if viewOption.plotCustom && strcmp(viewOption.plotCustomType,'PSTH')
                %fit the data to exponential curve. 
                for k = 1 : nChannels
                    if ~any(checkChannel == neurons{k}.channel); continue; end
                    for kk = 1 : length(neurons{k}.clusters)
                        if viewOption.plotCustom
                            if neurons{k}.clusters{kk}.id == 255 ; continue; end
                            x = [xSTA xSTA+tBlock];
                            y = [neurons{k}.clusters{kk}.class{iClass}.member{1}.sta neurons{k}.clusters{kk}.class{iClass}.member{2}.sta];
                            z = [neurons{k}.clusters{kk}.class{iClass}.member{1}.std neurons{k}.clusters{kk}.class{iClass}.member{2}.std];
                            %replace both fields with the concrated value
                            neurons{k}.clusters{kk}.class{iClass}.member{1}.sta = y;
                            neurons{k}.clusters{kk}.class{iClass}.member{2}.sta = y;
                            %replace both fields with the concrated
                            %value.
                            neurons{k}.clusters{kk}.class{iClass}.member{1}.std = z;
                            neurons{k}.clusters{kk}.class{iClass}.member{2}.std = z;
                            %
                            fy = [neurons{k}.clusters{kk}.class{iClass}.member{1}.fit neurons{k}.clusters{kk}.class{iClass}.member{2}.fit];
                            neurons{k}.clusters{kk}.class{iClass}.member{1}.fit = fy;
                            neurons{k}.clusters{kk}.class{iClass}.member{2}.fit = fy;
                        end
                    end
                %concate the two contrast datasets. 
                end
            xSTA = [xSTA xSTA+tBlock];    
            end
    end

    
    h_STA = mspecViewer(xSTA,neurons,viewOption);
    %viewOption.memberID = 2;
    %h_STA = mspecViewer(xSTA,neurons,viewOption);
    





