%Plot Firing Rate for adaption to flicker/orientation.

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

%read the cerebus electrode mapping file
global cmap
%set a default map if no map file specified
%cmap = createCerebusMap(32,'A');
%
%mapfile = 'c:\work\software\ePhyTool\Tetrode_96ch_4C.CMP';
mapfile = 'c:\work\software\ePhyTool\32ch double-headstage map.CMP'; 
%mapfile = 'c:\Documents and Settings\sslab\My Documents\32ch linear map.cmp';
%mapfile = 'c:\Documents and Settings\sslab\My Documents\32ch double-headstage map.cmp';
fprintf('Loading Cerebus Map File : %s\n',mapfile);
cmap = readCerebusMap(mapfile);
%save the original 96tetrode map
cmap0 = cmap;

%%
%experiment name
expName = folder(1).exp;

%sampling timestamp resolution
tsr = s(1).nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;

%number of files loaded
nf = length(s);
%
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
            classifier = struct('name','unclassified',...
                'variable','unknown',...
                'values',[]);
            %
            viewOption = struct;
            viewOption.plot = 'STA';
            viewOption.plotdim = 2; %plot in 1/2d 
            viewOption.message = '';
            viewOption.skip = true; %skip empty data channel for plotting.
            %viewOption.colorscale = [0 1]; %color scale for pcolor. [] for auto
            
        case {'NormLuminance'}
            classifier = struct('name','Gaussian_Contrast',...
                'variable','contrast',...
                'values',s_SETS.matData.params.contrast);
            %'variable' --- variable in 'params' to sort events.
            viewOption = struct;
            viewOption.plot = 'STA';
            viewOption.plotdim = 1; %plot in 1/2d 
            viewOption.message = '';
            viewOption.skip = false; %skip empty data channel for plotting.
            %viewOption.colorscale =[];
        case {'NormGrating'}
            classifier = struct('name','Gaussian_Std',...
                'variable','stdOrient',...
                'values',s_SETS.matData.params.stdOrient);
            %'variable' --- variable in 'params' to sort events.
            viewOption = struct;
            viewOption.plot = 'STA';
            viewOption.plotdim = 1; %plot in 1/2d 
            viewOption.message = '';
            viewOption.skip = false; %skip empty data channel for plotting.
            %viewOption.colorscale =[];
            
    end
    
    neurons = sortNeurons(neurons,s_SETS,t_SETS,classifier);
            
    StimImage = makeStimImage(s_SETS,ss);
    
    STA = struct('data',[],'id',[]);
    msg = struct('string',[]);
    bin = 10/1000; %sta time bin - 10ms
    %bin = stimFrames/60; %event interval for sta bin
    plt = 'n';     %no plot for each individual channel.
    SW = [];       %smoothing width
    TW = [];       %TW = [0 100]; % select time window in spike train
    D = [-0.5 0];  %sta time length
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
    
    %save neurons
    neurons0 = neurons;
    
    %select the spikes,e.g, near the transition of the cycles. the
    %transition(onset of cycle) is given by onsetCycle
    onsetCycle = t_SETS(1:length(t_SETS)/(s.matData.params.nBlocks*2) : end); %assume always 2 contrast vales.
    neurons1 = filtSpikes(neurons0,onsetCycle,[0 2]);
     neurons2 = filtSpikes(neurons0,onsetCycle,[-2 0]);
    % neurons3 = filtSpikes(neurons,onsetCycle,[10 60]);
    %
    neurons = neurons0;
    
    checkChannel = cmap(:,3); %use all channels in the map file
    %checkChannel = [1 3 5];  %select channels for the plot.
    %reference events for low contrast and high contrast.
    REF_low = onsetCycle(1:2:end);
    REF_high = onsetCycle(2:2:end);
    tBlock = s.matData.params.stimulusTime/(s.matData.params.nBlocks*2);
    tBin = 5; %5 sec bin for histogram.
    
    for k = 1 : nChannels
        if ~any(checkChannel == neurons{k}.channel); continue; end
        %return a struct  - test the first one
        fprintf('Firing Rate Computation for File[%d], uch[%d]...\n',i,k);
        %compute STA for normlumniance and squaremapping.
        for kk = 1 : length(neurons{k}.clusters)
            %e.g, mm=2 for 'low' and 'high' contrast for guassian luminance.
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                switch expName
                    case {'DotMappingExperiment' , 'SquareMappingExperiment'}
%                         ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
%                         ts = ts';
%                         [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(ts,StimImage.data,t_SETS,bin,plt,SW,TW,D,err);
%                         neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = mSTA;
%                         neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = mSTC;%covariance
%                         neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = eSTA;%error 
%                         neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = mSpk; %total spikes used in computation.
%                         gStaMax = max([gStaMax max(max(max(mSTA)))]);
%                         gStaMin = min([gStaMin min(min(min(mSTA)))]);

                    case {'NormLuminance','NormGrating'}
                        ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
                        ts = ts';
                        if mm == 1 
                            REF = REF_low;
                        else
                            REF = REF_high;
                        end
                        [spikeCount,spikeCountSE,xout] = pePSTH(ts,REF,[0:tBin:tBlock-tBin]);
%                         [spikeCount,spikeCountSE,xout] = perehist(ts,REF,[0 tBlock],tBin);
                        % [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(ts,StimImage.data,t_SETS,bin,plt,SW,TW,D,err);
                        %append 'sta' to neurons.
                        firingRate = spikeCount/tBin;
                        firingRateSE = spikeCountSE/tBin;
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = firingRate; %firing rate
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = [];%covariance
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = firingRateSE/tBin;%error 
                        neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = sum(spikeCount); %total spikes used in computation.
                        gStaMax = max([gStaMax max(max(firingRate)) max(max(firingRateSE))]);
                        gStaMin = min([gStaMin min(min(firingRate)) min(min(firingRateSE))]);

                end
            end
        end
        xSTA = xout;
        %generate average profile for multi-unit activity.
        data = zeros(size(xSTA));
        Nspk = 0;
        for kk = 1 : length(neurons{k}.clusters)
            %exclude the unsorted unit 
            if neurons{k}.clusters{kk}.id == 0 ; continue; end
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
            %view option for normluminance
            viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
            viewOption.memberID = 1; %member id, .e.g which contrast
            %option for mapping
            viewOption.clusterID = []; %view specified cluster if viewMUA false
             viewOption.viewUnsortedUnit = true; %flag for plotting unsorted unit
            viewOption.viewMUA = true; %view multi-unit for receptive-field
            %viewOption.colorscale = [gStaMin-0.3*(gStaMax-gStaMin) gStaMax+0.3*(gStaMax-gStaMin)]; %[] for 'auto'. 
            viewOption.colorscale = [];
            viewOption.plotSE = false; %plot error data. effective for 1d
            viewOption.plotContour = false; %plot contour. effective for 2d 
    end

    h_STA = mspecViewer(xSTA,neurons,viewOption);
    viewOption.memberID = 2;
    h_STA = mspecViewer(xSTA,neurons,viewOption);
    
%     neurons1 = neurons;
%     
%     %normalize the sta with contrast value
%     for ii = 1 : length(neurons)
%         for jj = 1 : length(neurons{ii}.clusters)
%             for kk = 1 : length(neurons{ii}.clusters{jj}.class{1}.member)
%                 try
%                    neurons1{ii}.clusters{jj}.class{1}.member{kk}.sta = neurons{ii}.clusters{jj}.class{1}.member{kk}.sta/neurons{ii}.clusters{jj}.class{1}.member{kk}.value; 
%                 end
%             end
%         end
%     end
%        
%     viewOption.memberID = 1;
%     h_STA = mspecViewer(xSTA,neurons1,viewOption);
%     viewOption.memberID = 2;
%     h_STA = mspecViewer(xSTA,neurons1,viewOption);
    
  

end

