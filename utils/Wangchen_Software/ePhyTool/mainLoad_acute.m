%script to load neural data into workspace. (both trial and neuron structs) 
%
%flag to load data from raw files, i.e, stimulus/neural data files (.mat, .nex, .nev/.mat files). 
%load from saved dataset (_saved.mat) if set false
loadRawData = true; 
%flag to choose data source for units. i.e, clustered MAT files by
%alex/kluster programs (TRUE) or blackrock NEV files (FALSE)
loadUnitFromMAT = false;

%% Configuration
%-----------------------------------------------------------------
%files info for the last session
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
opt.fileindex = 1; % load the first file by default
opt.nevvar = {'neurons','events'}; %load spikes and stim-event markers
opt.datatype = {'mat','nex','nev'};
%---------------------------------------------------------------
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

opt.fileindex = 1; % force to load the first file.   
%% read the data 
% load 'neurons' for spikes and 'events' for stim-event-timestamps
if loadRawData 
    fprintf('Load from raw data files ....\n');
    if loadUnitFromMAT %load from clustered mat file
        opt.datatype = {'mat','nex'};
    end
    s = matLoader(folder,opt);
    if loadUnitFromMAT
        s.nevFolder = fullfile(folder(3).base,folder(3).subject,folder(3).exp,...
            folder(3).date,folder(3).time,folder(3).etc);
        [exp_path,exp_file,exp_ext] = fileparts(s.matFile); 
        s.nevFile = fullfile(s.nevFolder,[exp_file,'_clusters.mat']);
        %load the units from clustered file
        NEV = load(s.nevFile);
        s.nevData = readNEVStruct(NEV,opt.nevvar);
    end
    opt.fileindex = 0; %load session data.
    ss = matLoader(folder,opt);
else
    %load the neural data from clustered file
    fprintf('Load units from saved mat data files ....\n');
    
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
%--------------------------------------------------------------------------
%% load the map file
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
% %or reset the map by hand here if the auto-selection made it wrong, for
% instance, if the data file is unsorted.
cmapFileIdx = 1;
cmapFileName = cmapFiles{cmapFileIdx};
cmapFilePath = fileparts(mfilename);
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
%
global cmap
cmap = readCerebusMap(cmapFile);
%save the original 96tetrode map
cmap0 = cmap;

%% load/create neuron struct
if loadRawData    
    %load the spikes and stim-event-timestamps.
    i = 1;
    s_SETS = s(i);
    %s_SETS = s;  %only process one file
    %trim nevdata before sorting events - return a one-element struct with one-entry of
    %events in nevData.
    s_SETS = trimNEVData(s_SETS,1,1);
    %------------------------------------
    %generate neurons data struct for clusters from trial data.
    neurons = makeNeurons(s_SETS);
    %make the event struct
    event = makeStimEvent(s(i));
    %retrive the full set of stim-event-timestamp and lookup table.
    [t_SETS,StimEventLUT] = sortStimEvent(s(i),event);
    %
    neurons = classifyNeurons(neurons,s(i),ss,t_SETS);
    %--------------------experiment-specific analysis--------------------
    %create the stimlus image from trial data.        
    StimImage = makeStimImage(s(i),ss);
    %normalize the stim vectors
    Stim = (StimImage.data'-128)/128;
    %adapation rate analysis
    %1. get the stimulus cycle/block number.
    nBlocks = getTrialParams(s(i),'nBlocks');
    %the stimulus value points in each contrast
    nStimPts = length(t_SETS)/(nBlocks*2);
    %2. get the onsets for stimulus of each contrast.(assume 2-conditions,low and high, per cycle)
    stimOnsets = t_SETS(1:nStimPts:end);
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
    tBin = 2; 

end  

%the data struct loaded: s,ss,s_SETS,neurons
export_style = hgexport('readstyle','powerpoint');
export_style.Format = 'png';
%date of experiment
sep = strfind(s_SETS.matFolder,'\');
experiment_date = s_SETS.matFolder(sep(end-1)+1 : end);
expdatevec = datevec(experiment_date,'yyyy-mmm-dd\HH-MM-SS');
