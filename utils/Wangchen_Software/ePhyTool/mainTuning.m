%Plot Tuning Curve after data collection with rmf.

%% Load the Data into struct array
%% 
%-------------------------------------------------
%initialize params
folder = struct(...
    'base',[],'subject',[],'exp',[],'date',[],'time',[],'etc',[]...
    );
folder(1:3)=struct(folder);
%default is full loading
opt = struct(...
    'fileindex',[],'datatype',[],'nevvar',[]);
%-------------------------------------------------

%--------------------------------------------------
%visual stimulation data folder
folder(1).base='C:\Users\wangchen\Documents\MATLAB\Data\StimulationData';
folder(1).subject='gamma';
folder(1).exp='NormLuminance';
folder(1).date= '2010-Apr-29';
folder(1).time= '17-54-42';
folder(1).etc = [];

%nex folder
folder(2) = folder(1);

%nev folder
folder(3) = folder(1);
folder(3).base = 'C:\Users\wangchen\Documents\MATLAB\Data\CerebusData';
%folder(3).time = '17-15-48';
%folder(3).time = '17-34-44';

opt.fileindex = 1; % load all
opt.nevvar = {'neurons','events'}; %check the timestamps intervals
opt.datatype = {'mat','nex','nev'};
%----------------------------------------------
%% use gui to locate data folder and set the indices of files to load

%overwrites the mannual setting 
popup = true; %use gui to locate folder

%overwrites the mannual setting 
if popup
    try close(h_dataLocator); end %close previous open window.
    h_dataLocator = dataLocator;
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
end
%-------------------------------------------
%
%
expName = folder(1).exp;
%read the cerebus electrode mapping file
global cmap
%set a default map if no map file specified
%find the OS type
OS=getenv('OS');
if strfind(OS,'XP')
    pathstr = 'C:\Documents and Settings';
else %win7
    pathstr = 'C:\Users\';
end
%select channel map file -- linear probe of single electrode or plannar array of tetrodes.     
cmapFilePath = fullfile(pathstr,getenv('USERNAME'),'My Documents');
%cmapFileName = 'Tetrode_96ch_Map_New.cmp';
cmapFileName = '32ch double-headstage map.CMP';
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));

cmap = readCerebusMap(cmapFile);
%save the original 96tetrode map
cmap0 = cmap;

%%
%sampling timestamp resolution
tsr = s(1).nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;

%number of files loaded
nf = length(s);
%
% %grating patch duration for each condition.
% t_stim = 250 /1000; %250msec
% %blank time between each grating patch duration
% t_blank = t_stim;

t_stim  = s(1).matData.params.stimFrames/60;
t_blank = s(1).matData.params.blankFrames/60;
%set a deadtime for spike rate calculation to exclude edge effect.
t_deadtime = 10/1000; %20ms
if t_deadtime >= t_stim-t_deadtime
    error('stimulation time too short or deadtime too long');
end

fprintf('-----------------------------------------------\n');
fprintf('Stimulation: ON(%d msec), OFF(%d msec)\nCalculation Deadtime : %d msec\n',...
    t_stim*1000,t_blank*1000,t_deadtime*1000);
fprintf('-----------------------------------------------\n\n');

%theroshold for filter.
minISI = t_stim * 0.8;
%
onsetMarker = 'close';
%filter the stim-event-timestamps
s = filtSETS(s,1,minISI,onsetMarker);

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
    
    
%     %find variable that has the most samples,excluding DIOValue
%     [a,b]=max(max(StimEventLUT(:,1:end-1),[],1));
%     %-------------------------------------------------------
%     %determine the tuning variable by having the most samples. 
%     tune_vid = b(1); %variable index
%     tune_eid = a(1); %max index of tune_var 
%     tune_var = encode_vars{tune_vid};
    %look for 'Orientation','SpatialFreq','TempoFreq' in encode_vars and
    %find the length of their samples. the max length is the encoding var.
    grating_vars = {'Orientation','SpatialFreq','TempoFreq'};
    grating_samp = zeros(1,length(grating_vars)); %length of grating_vars values
    grating_indx = zeros(1,length(grating_vars)); %index of grating_vars in encode_vars
    for j = 1 : length(grating_vars)
        m = strmatch(grating_vars{j},encode_vars,'exact');
        if ~isempty(m)
            grating_indx(j) = m;
            grating_samp(j) = length(unique(StimEventLUT(:,m)));
        end
    end
    
        
    [tune_eid , m] = max(grating_samp); %number of values for tune_var
     tune_vid = grating_indx(m);   %var index in encode_vars
     for j = 1 : length(s_SETS.nexData.contvars)
         if strcmp(encode_vars{tune_vid},s_SETS.nexData.contvars{j}.name)
                tune_val = (s_SETS.nexData.contvars{j}.data)'; %sorted values of tune_var,eg [0:15:180] for orientation
                break;
         end
     end
     
    %number of record channels
    nChannels = length(s_SETS.nevData.neurons);
    %==============test====================
    %test - if no neurons, simulate one set
    if nChannels == 0; 
        s_SETS.nevData.neurons{1}.timestamps = linspace(0,t_SETS(end),1000);
        nChannels = 1;
    end
    
    %%-----------------------------------------------------
    %compute tuning curve with 'neurons' struct
    neurons = makeNeurons(s_SETS);
    %
    classifier = struct('name','none',...
        'variable','none',...
        'values',[]);
    viewOption = struct('plot','STA',...
        'plotdim',1,...
        'message','Tuning',...
        'skip',false);
    %return with 1 class 1 member.
    neurons = sortNeurons(neurons,s_SETS,t_SETS,classifier);
    %global max y value
    gStaMax = -Inf;
    gStaMin = Inf;
    %index of classifiers selected for computation. 
    iClass = 1; 
    
    checkChannel = cmap(:,3);
    checkChannel = [10 8];
    
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
    %
    for jj = 1 : tune_eid % value index in tune var
        %select event operation
        event(tune_vid).string = sprintf('==%d',jj);
        %timestamps for the onset of event occurance. -- pass LUT to speed
        %up the sorting process.
        [eventTimestamps, codes ] = sortStimEvent(s_SETS,event,StimEventLUT);
        %
        if size(eventTimestamps,1)>1; eventTimestamps = eventTimestamps'; end
        %         %make timestamps for the onset of blank period, assuming the
        %         %accuracy of stim period
        %         timestamps1 = timestamps + t_stim;
        
        eventTimestamps1 = eventTimestamps + t_stim ;
        %eventTimestamps1 = eventTimestamps + t_stim + t_blank;

        %exclude the spikes near the transition by shifting the
        %onset/offset of the stimulation
        eventTimestamps0 = eventTimestamps + t_deadtime;
        %eventTimestamps0 = eventTimestamps;
        eventTimestamps1 = eventTimestamps1 - t_deadtime;
        %eventTimestamps1 = eventTimestamps1 - 0;

        %concate two series to make bounds for computing spike rates.
        eventTimestamps = sort([eventTimestamps0 eventTimestamps1]);

        for k = 1 : nChannels
            
            if ~any(checkChannel == neurons{k}.channel); continue; end
            
            for kk = 1 : length(neurons{k}.clusters)
                for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                    ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
                    ts = ts';
                    %spike_train = struct;
                    
                    rs = calSpikeRate(ts,eventTimestamps);
                    %spike rate -- counts per sec
                    mSpikeCount = mean(rs.spikecount(1:2:end));
                    sSpikeCount = std(rs.spikecount(1:2:end));
                    %count the spikes b/w the on/offset timestamps
                    mSpikeRate = mean(rs.firingrate(1:2:end));
                    sSpikeRate = std(rs.firingrate(1:2:end));
                    %tuning variable
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.tuningVal(jj) = tune_val(jj);
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.SpikeRate(jj) = mSpikeRate;
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.SpikeCount(jj) = mSpikeCount;
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes(jj) = mSpikeCount;
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.stdSpikeRate(jj) = sSpikeRate;
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.stdSpikeCount(jj) = sSpikeCount;
                    %save reference timestamps -- the paired series of
                    %stimulus onset and stimulus duration (or the averaging
                    %duration for spike counts). 
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.refTimestamps{jj} = eventTimestamps;

                    %for ploting
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta(jj) = mSpikeRate;
                    neurons{k}.clusters{kk}.class{iClass}.member{mm}.std(jj) = sSpikeRate;
                   
                end
            end
        end
    end
    
    for k = 1 : nChannels
        
        if ~any(checkChannel == neurons{k}.channel); continue; end
        
         %generate average profile for multi-unit activity.
        data = zeros(1,length(tune_val));
        Nspk = 0;
        for kk = 1 : length(neurons{k}.clusters)
            for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                Nspk = Nspk + sum(neurons{k}.clusters{kk}.class{iClass}.member{mm}.SpikeCount);
                data = data + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta);
                gStaMax = max([gStaMax max(neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta)]);
                gStaMin = min([gStaMin max(neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta)]);
            end
        end
        %sum firing rate across all clusters and class.
        %data = data / Nspk;
        %multi-unit profile of sta
        neurons{k}.sta = data;
    end
        
    switch expName
         case {'GratingExperiment'}
            %view option for normluminance
            viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
            viewOption.memberID = 1; %member id, .e.g which contrast
            %option for mapping
            viewOption.clusterID = []; %view specified cluster if viewMUA false
            viewOption.viewUnsortedUnit = false; %flag for plotting unsorted unit
            viewOption.viewMUA = false; %view multi-unit for receptive-field
            viewOption.colorscale = [gStaMin-0.3*(gStaMax-gStaMin) gStaMax+0.3*(gStaMax-gStaMin)];%color range.
            viewOption.colorscale = [];%color range.
            
            viewOption.plotSE = true; %plot error data. effective for 1d
            viewOption.plotContour = false; %plot contour. effective for 2d
    end

    h = mspecViewer(tune_val,neurons,viewOption);
    
% %     %plot PSTH for each orientation
% %     nid = 21; cid = 2; clid = 1; mid = 1;
% %     nori = length(neurons{nid}.clusters{cid}.class{clid}.member{mid}.tuningVal);
% %     %repetition
% %     nrep = length(neurons{nid}.clusters{cid}.class{clid}.member{mid}.refTimestamps{1})/2;
% %     refTS = zeros(nori,nrep);
% %     for tmp = 1 : nori
% %         refTS(tmp,:) = neurons{nid}.clusters{cid}.class{clid}.member{mid}.refTimestamps{tmp}(1:2:end);
% %     end
% %     
% %     figure('name','PSTH');
% %     chanList = [1 3 4 5 6 8 9 21];
% %     %chanList = 21;
% %     for xx = 1 : length(chanList)
% %         nid = chanList(xx);
% %         ts = neurons{nid}.clusters{cid}.class{clid}.member{mid}.timestamps;
% %         PSTHdt = 2; %psth time range
% %         tmpCounts = zeros(2,nori);
% %         for tmp = 1: nori
% %             a = subplot(length(chanList),nori,(xx-1)*nori+tmp);
% %             b = cell(1,nrep);
% % 
% %             for tmp1 = 1 : nrep
% %                 b{tmp1} = ts(ts>=refTS(tmp,tmp1) & ts<=(refTS(tmp,tmp1)+ PSTHdt));
% %                 b{tmp1} = b{tmp1}-refTS(tmp,tmp1); %referenced to event onset
% %             end
% % 
% %             tmpSpikes = [];
% %             for tmp1 = 1 : nrep
% %                 tmpSpikes = [tmpSpikes length(b{tmp1})];
% %             end
% % 
% %             %disp('Spike Counts'); tmpSpikes;
% %             tmpCounts(1,tmp) = mean(tmpSpikes);
% %             tmpCounts(2,tmp) = std(tmpSpikes);
% %             rasterplot(b,a);
% %         end
% %     end
    
%     figure(h);
%     title(s_SETS.nevFolder,'Interpreter','none');
    
        %3-points for moving average on 2d array data.
%     viewOption.smoothSize = [3 3]; %not used by 1d smooth
%     neurons1 = smNeurons(neurons,viewOption,'smooth'); 
%     
%     %plot subgroup of tetrodes -- plot channel 97.
%     cmap = trimCerebusMap(1,1,3*24+1,cmap0);
%     h_STA = mspecViewer(tune_val,neurons1,viewOption);
%   
end

            
        
        
        
    
    
    
    
    
    
    
    






