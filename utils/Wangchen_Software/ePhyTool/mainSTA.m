%Plot STA after data collection with DotMapping

%% Load the Data into struct array
%% 
%-------------------------------------------------
%initialize params
folder = struct(...
    'base',[],'subject',[],'exp',[],'date',[],'time',[]...
    );
folder(1:3)=struct(folder);
%default is full loading
opt = struct(...
    'fileindex',[],'datatype',[],'nevvar',[]);
%--------------------------------------------------

%--------------------------------------------------
%visual stimulation data folder
folder(1).base='C:\Users\wangchen\Documents\MATLAB\Data\StimulationData';
folder(1).subject='gamma';
folder(1).exp='NormLuminance';
folder(1).date= '2010-Apr-29';
folder(1).time= '17-54-42';

%nex folder
folder(2) = folder(1);

%nev folder
folder(3) = folder(1);
folder(3).base = 'C:\Users\wangchen\Documents\MATLAB\Data\CerebusData';
%folder(3).time = '17-15-48';
%folder(3).time = '17-34-44';

opt.fileindex = 1; % load file
opt.nevvar = {'neurons','events'}; %load spikes and stim-event markers
opt.datatype = {'mat','nex','nev'};
%----------------------------------------------
%% use gui to locate data folder and set the indices of files to load

popup = true; %use gui to locate folder

%overwrites the mannual setting 
if popup
    try close(h_dataLocator); end %close last open window.
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
    else
        fprintf('no file chosen. exit\n');
        return
    end
end

%%
% load 'neurons' for spikes and 'events' for stim-event-timestamps
fprintf('Loading data files ....\n');
  s = matLoader(folder,opt);
  opt.fileindex = 0; %load session data.
  ss = matLoader(folder,opt);
  
%--------------------------------------------------
%
useNEX = false;
if useNEX
    %open nex interface
    try
        nex = actxserver('NeuroExplorer.Application');
    catch
        nex = [];
        fprintf('Error::NeuroExploer\n');
        lasterr;
    end
    %load nev/nex files into neuroexploerer.
    
    
end
%-------------------------------------------
%
%%
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
%filter the stim-event-timestamps. assume dig.ch1 contains photodiode pulses
s = filtSETS(s,1,minISI);

%--------------------------------------------------------------------------
%recorded channels
recordChannels = zeros(1,length(s(1).nevData.neurons));
%
recordSpikesInChannel = zeros(size(recordChannels));
%
recordUnitsInChannel = zeros(size(recordChannels));
%
for i = 1 : length(recordChannels)
    chName = s(1).nevData.neurons{i}.name;
    chUnit = unique(s(1).nevData.neurons{i}.units);
    recordChannels(i) = str2num(strrep(chName,'chan',''));
    recordSpikesInChannel(i) = length(s(1).nevData.neurons{i}.timestamps);
    recordUnitsInChannel(i) = length(chUnit>0 & chUnit~=255); 
end
%8 channels with least number of spikes
[tmp,chSizeOrder] = sort(recordSpikesInChannel);
[tmp,unitSizeOrder] = sort(recordUnitsInChannel); 
%automate the selection of the channel map file
cmapFiles{1} = 'Tetrode_96ch.cmp';
cmapFiles{2} = '32ch double-headstage map.CMP';
cmapFiles{3} = '32ch-EDGE double-headstage map.CMP';
%cmapFileName = '32ch double-headstage map.CMP';
nRecordChannels = length(recordChannels);
if nRecordChannels > 32
    cmapFileIdx = 1;
else
    %last 16 channels in map file
    standardProbeChan = [18 42 4 35 20 37 2 33 7 40 5 38 3 36 1 34];
    edgeProbeChan = [34 36 38 40 33 37 35 42 39 44 41 45 43 49 47 51];
    %map selection criteria priority: 1. unit size order 2. spike size order
    unitSizeIdx = recordChannels(unitSizeOrder(1:length(standardProbeChan)));
    %
    if length(intersect(unitSizeIdx,standardProbeChan)) > length(intersect(unitSizeIdx,edgeProbeChan))
        cmapFileIdx = 2;
    else
        cmapFileIdx = 3;
    end
end
% %or reset the map by hand here if the auto-selection made it wrong, for
% instance, if the data file is unsorted.
% cmapFileIdx = 0;
cmapFileName = cmapFiles{cmapFileIdx};
%
cmapFilePath = fileparts(mfilename);
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
%
global cmap
cmap = readCerebusMap(cmapFile);
%save the original 96tetrode map
cmap0 = cmap;


%---------------------------------------------------
for i = 1 : nf
    %load the spikes and stim-event-timestamps.
    s_SETS = s(i);
       
    %trim nevdata before sorting events - return a one-element struct with one-entry of
    %events in nevData.
    s_SETS = trimNEVData(s_SETS,1,1);
    %
    %show the encoding variables in the stim event LUT
    marker = s_SETS.nexData.markers{1};

    %------------------------------------------------------
    encode_vars = cell(1,length(marker.values));
    for j = 1 : length(marker.values)
        encode_vars{j} = marker.values{j}.name;
    end
    %
    fprintf('[File #%d %s] -- \tEncoding Variables : \n',i,s_SETS.nexFile);

    event = struct; %reset event
    for j = 1 : length(encode_vars)
        event(j).type = encode_vars{j};
        event(j).string = '>0';
        event(j).operator = '&';
    end
    %-------------------------------------------------------
    %retrive the full set of stim-event-timestamp and lookup table.
    [t_SETS,StimEventLUT] = sortStimEvent(s_SETS,event);
    if size(t_SETS,1)>1; t_SETS = t_SETS'; end
    
      
    %show the range of variables
    for j = 1 : length(encode_vars)
            %the #values for each variable
            %num = length(ss.nexData.contvars{i}.name)
            if j ~= length(encode_vars)
                fprintf('[%d]:\t%s - Min=%d,Max=%d  \n',...
                    j,event(j).type,min(StimEventLUT(:,j)),max(StimEventLUT(:,j)));
            end
    end
    
    fprintf('Stim Event Interval: (%.1f ms, %d frames)\n', (stimFrames/60)*1000, stimFrames);
    
%     %find variable that has the most samples,excluding DIOValue
%     [a,b]=max(max(StimEventLUT(:,1:end-1),[],1));
%   
%     %use DIOValue as sorting event - this will return spikes over time for
%     %all events.
%     a = size(StimEventLUT,1);
%     b = size(StimEventLUT,2);
%     %determine the tuning variable by having the most samples. 
%     tune_vid = b(1); %variable index
%     tune_eid = a(1); %max index of samples in tune_var 
%     tune_var = encode_vars{tune_vid};
    

    %------------------------------------
    %check the number of record channels. if elec# above 128
    if isfield(s_SETS.nevData,'neurons')
        nChannels = length(s_SETS.nevData.neurons);
    else
        nChannels = 0;
    end
    %==============test====================
    %test - if no neurons, simulate one set
    if nChannels == 0; 
        s_SETS.nevData.neurons{1}.timestamps = linspace(0,t_SETS(end),200);
        nChannels = 1;
    end
    
    %struct array to save spike rate for each channel
    SpikeRate = struct('data',[],'id',[]);
    SpikeInfo = struct('string',[]);       %extra info of channels
    spike_train = struct;
    %actual neuronal channels in case they are not continous numbers or
    %contains a/d channel inputs above elec128.
    
    neurons = makeNeurons(s_SETS);
    %classify neurons by gaussian-contrast
    %
    switch expName
        case {'DotMappingExperiment' , 'SquareMappingExperiment'}
            classifier = struct('name','none',...
                'variable','none',...
                'values',[]);
            %
            viewOption = struct;
            viewOption.plot = 'STA';
            viewOption.plotdim = 2; %plot in 1/2d 
            viewOption.message = '';
            viewOption.skip = false; %skip empty data channel for plotting.
            %viewOption.colorscale = [0 1]; %color scale for pcolor. [] for auto
            
        case 'NormLuminance'
            classifier = struct('name','Gaussian_Contrast',...
                'variable','contrast',...
                'values',s_SETS.matData.params.contrast);
            %'variable' --- variable in 'params' to sort events.
            viewOption = struct;
            viewOption.plot = 'STA';
            viewOption.plotdim = 1; %plot in 1/2d 
            viewOption.message = '';
            viewOption.skip = true; %skip empty data channel for plotting.
            %viewOption.colorscale =[];
    end
    
    neurons = sortNeurons(neurons,s_SETS,t_SETS,classifier);
  
    %now we have t_SETS,spike_train, need stimulation images.
    %Stimulus: 1. DotMappingExperiment -- values represented by 2d images/matrix
    %          2. NormLuminance - values represented by 1d vector
    %write a function for producing stim images/vectors:
    %input,s_SETS,output, image array/vector
    StimImage = makeStimImage(s_SETS,ss);
    
    STA = struct('data',[],'id',[]);
    msg = struct('string',[]);
    bin = 10/1000; %sta time bin - 10ms
    %bin = stimFrames/60; %event interval for sta bin
    plt = 'n';     %no plot for each individual channel.
    SW = [];       %smoothing width
    TW = [];       %TW = [0 100]; % select time window in spike train
    D = [-0.2 0];  %sta time length
    err = 0;       %error bar estimate
    xSTA = []; %time elements of sta. 
    
    %index of classifiers selected for STA computation. 
    iClass = 1; 
    
    gStaMax = -Inf;
    gStaMin = Inf;
    
    %initalize the sta fileds in neurons
    for k = 1 : nChannels
        for kk = 1 : length(neurons{k}.clusters)
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = [];
                neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = [];%covariance
                neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = [];%error
                neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = []; %total spikes used in computation.
            end
        end
        neurons{k}.sta = []; %multi-unit sta
    end
    
    checkChannel = cmap(:,3); %use all channels in the map file
    %checkChannel = [16];  %select channels for the plot.
        
    for k = 1 : nChannels
        if ~any(checkChannel == neurons{k}.channel) ; continue; end
        %return a struct  - test the first one
        fprintf('STA Computation for File[%d], uch[%d]...\n',i,k);
        %compute STA for normlumniance and squaremapping.
        for kk = 1 : length(neurons{k}.clusters)
            %e.g, mm=2 for 'low' and 'high' contrast for guassian luminance.
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                switch expName
                    case {'DotMappingExperiment' , 'SquareMappingExperiment'}
                        ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
                        ts = ts';
                        [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(ts,StimImage.data,t_SETS,bin,plt,SW,TW,D,err);
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = mSTA;
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = mSTC;%covariance
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = eSTA;%error 
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = mSpk; %total spikes used in computation.
                        gStaMax = max([gStaMax max(max(max(mSTA)))]);
                        gStaMin = min([gStaMin min(min(min(mSTA)))]);

                    case 'NormLuminance'
                        ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
                        ts = ts';
                        [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(ts,StimImage.data,t_SETS,bin,plt,SW,TW,D,err);
                        %append 'sta' to neurons.
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = mSTA;
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = mSTC;%covariance
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = eSTA;%error 
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = mSpk; %total spikes used in computation.
                        gStaMax = max([gStaMax max(max(mSTA))]);
                        gStaMin = min([gStaMin min(min(mSTA))]);

                end
            end
        end
        if ~isempty(tSTA); xSTA = tSTA; end;
        %generate average profile for multi-unit activity.
        data = zeros(size(mSTA));
        Nspk = 0;
        for kk = 1 : length(neurons{k}.clusters)
            %exclude the unsorted unit 
            if neurons{k}.clusters{kk}.id == 0 ; continue; end
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                Nspk = Nspk + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes);
                data = data + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta)*(neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes);
            end
        end
        if Nspk > 0 ;  data = data / Nspk;   end
        %multi-unit profile of sta
        neurons{k}.sta = data;
    end
    
    switch expName
        case {'DotMappingExperiment','SquareMappingExperiment'}
            %view option for normluminance
            viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
            viewOption.memberID = 1; %member id, .e.g which contrast
            %option for mapping -- view cluster 2 if loaded from sorted
            %.nev files. cluster 1 is be unsorted units
            viewOption.clusterID = [1]; %view specified cluster if viewMUA false
            viewOption.viewUnsortedUnit = true; %flag for plotting unsorted unit
            viewOption.viewMUA = false; %view multi-unit for receptive-field
            % viewOption.colorscale = [gStaMin gStaMax]; %color range.
            viewOption.colorscale = []; %auto scale
            viewOption.plotStd = false; %plot error data. effective for 1d
            viewOption.plotContour = false; %plot contour. effective for 2d   

        case 'NormLuminance'
            %view option for normluminance
            viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
            viewOption.memberID = 2; %member id, .e.g which contrast
            %option for mapping
            viewOption.clusterID = []; %view specified cluster if viewMUA false
             viewOption.viewUnsortedUnit = false; %flag for plotting unsorted unit
            viewOption.viewMUA = false; %view multi-unit for receptive-field
            viewOption.colorscale = [gStaMin-0.3*(gStaMax-gStaMin) gStaMax+0.3*(gStaMax-gStaMin)]; %[] for 'auto'. 
                        
            viewOption.plotStd = false; %plot error data. effective for 1d
            viewOption.plotContour = false; %plot contour. effective for 2d 
    end

    h_STA = mspecViewer(xSTA,neurons,viewOption);
    %smooth data
    
    %viewOption.smooth = true;
    %3-points for moving average on 2d array data.
    viewOption.smoothSize = [2 2];
    %true: sum over clusters on each channel and across channel. false: sum
    %sum
    %neurons2 = smNeurons(neurons,viewOption,'sum');
    %divide plots for tetrodes
    
     %plot subgroup of tetrodes
%     cmap = trimCerebusMap(1,1,3*24+1,cmap0);

    %----------------------------------------------------------------------
    %open the position calculator for r.f ?
    %creat the struct for dot position -- set r.f.center to the first dot
    %in the stimulus array artificially. update the values from computed
    %RF later on.
    %rf position wrt stimulus array
    if ~(strcmp(expName,'DotMappingExperiment') || strcmp(expName, 'SquareMappingExperiment'))
        continue;
    end
    posStr = struct('x',1,'y',1,'w',s_SETS.matData.params.dotNumX,...
        'h',s_SETS.matData.params.dotNumY,'dotsize',s_SETS.matData.params.dotSize,...
        'dotPixels',s_SETS.matData.params.dotPixels,...
        'scrTarDistance',0,'pixelPitch',0);
    %posStr(1).scrTarDistance = [];%in mm
    posStr(1).scrTarDistance = ss.matData.stim.params.constants.scrTargetDistance;
    posStr(1).pixelPitch = [];
    posStr(2) = posStr(1);
    %stimulus wrt to screen
    posStr(2).x = s_SETS.matData.params.stimCenterX;
    posStr(2).y = s_SETS.matData.params.stimCenterY;
    posStr(2).w = s_SETS.matData.params.dotNumX * s_SETS.matData.params.dotPixels;
    posStr(2).h = s_SETS.matData.params.dotNumY * s_SETS.matData.params.dotPixels;
    %posCalculator(posStr);
    %----------------------------------------------------------------------
    
end

