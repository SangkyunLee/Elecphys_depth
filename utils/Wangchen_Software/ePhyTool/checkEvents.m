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
opt.nevvar = {'events'}; %load spikes and stim-event markers
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
mapfile = 'c:\Documents and Settings\sslab\My Documents\Tetrode_96ch_Map.cmp';
%mapfile = 'c:\Documents and Settings\sslab\My Documents\32ch linear map.cmp';
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
    
end
