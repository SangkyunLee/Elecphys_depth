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
%read the cerebus electrode mapping file
global cmap
mapfile = 'c:\Documents and Settings\sslab\My Documents\Tetrode_96ch_Map.cmp';
fprintf('Loading Cerebus Map File : %s\n',mapfile);
cmap = readCerebusMap(mapfile);

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
t_deadtime = 20/1000; %20ms
if t_deadtime >= t_stim-t_deadtime
    error('stimulation time too short or deadtime too long');
end

fprintf('-----------------------------------------------\n');
fprintf('Stimulation: ON(%d msec), OFF(%d msec)\nCalculation Deadtime : %d msec\n',...
    t_stim*1000,t_blank*1000,t_deadtime*1000);
fprintf('-----------------------------------------------\n\n');

%theroshold for filter.
minISI = t_stim * 0.8;

%filter the stim-event-timestamps
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
    %=======================================
    %struct array to save spike rate for each channel
    SpikeRate = struct('data',[],'id',[]);
    SpikeInfo = struct('string',[]);       %extra info of channels
    spike_train = struct; %make the format compatible with STA computation script
    %actual neuronal channels in case they are not continous numbers or
    %contains a/d channel inputs above elec128.
    m = 0;
    %channel token 'elec' or 'chan' ?
    chanToken = 'elec';
    for k = 1 : nChannels
        %count up neuron channels below 128 only. higher channels are from other
        %A/D inputs. 
        elecname = s_SETS.nevData.neurons{k}.name;
        %
        elecname = regexp(elecname,chanToken,'split');
        %electrodes are renamed and rearranged as 'chxx' to match the sequence on uprobe.
        %elecname = regexp(elecname,'ch','split');
        elecnum = str2num(elecname{2});
        if isempty(elecname) || elecnum > 128
            continue; %skip analog channel timestamps from thershold filtering
        end
        m = m + 1;
        spike_train(m).data{1} = s_SETS.nevData.neurons{k}.timestamps; %extract spiketrain before looping
        spike_train(m).data{1} = (spike_train(m).data{1})'; %transpose to row vector.
        spike_train(m).data{2} = s_SETS.nevData.neurons{k}.units; %sorted units
        spike_train(m).data{2} = (spike_train(m).data{2})';
        %spike_train(m).id = s_SETS.nevData.neurons{k}.name;
        spike_train(m).id = elecnum; %numerical
    end
    
    %reset nChannels? to actual neuron channels read in ?
    nChannels = length(spike_train);
    %---------------------------------------------------------------
    for j = 1 : tune_eid
        %select event operation
        event(tune_vid).string = sprintf('==%d',j);
        %timestamps for the onset of event occurance. -- pass LUT to speed
        %up the sorting process.
        [ timestamps, codes ] = sortStimEvent(s_SETS,event,StimEventLUT);
        %
        if size(timestamps,1)>1; timestamps = timestamps'; end
%         %make timestamps for the onset of blank period, assuming the
%         %accuracy of stim period
%         timestamps1 = timestamps + t_stim;
        timestamps1 = timestamps + t_stim + t_blank;
        
        %exclude the spikes near the transition by shifting the
        %onset/offset of the stimulation
        timestamps = timestamps + t_deadtime;
        timestamps1 = timestamps1 - t_deadtime;
        
        %concate two series to make bounds for computing spike rates.
        timestamps = sort([timestamps timestamps1]);
        
%         %exclude the spikes near the transition by shifting the
%         %onset/offset of the stimulation
%         timestamps(1:2:end) = timestamps(1:2:end)+t_deadtime;
%         timestamps(2:2:end) = timestamps(2:2:end)-t_deadtime;
        %-----------------------------------------------------------
        %count up spikes for the given bin -- go over neuron channels.
        for k = 1 : nChannels
            %go over all the sorted units
            su = sort(unique(spike_train(k).data{2}));
            nu = length(su);
            %spike_train = s_SETS.nevData.neurons{k}.timestamps;
            %rs: struct of spike rate for sorted units.
            rs = calSpikeRate(spike_train(k),timestamps);
            for ss = 1 : nu
                fr = rs(ss).firingrate;
                sc = rs(ss).spikecount;
                units = rs(ss).units;
                %mean and deviation of firing rate.
                %it's the same duration for each stim-event
                mfr = mean(fr(1:2:end)); %averaged firing on stimulus+blank period,excluding the transitions
                vfr = std(fr(1:2:end));
                %SpikeRate(chan).data(1,units,tune_var_x)
                SpikeRate(k).data(1,ss,j) = mfr;
                SpikeRate(k).data(2,ss,j) = vfr;
            end
            SpikeRate(k).id = spike_train(k).id;
        end
        
    end
    
    %plot the spike rate.
    
    for k = 1 : nChannels
        SpikeInfo(k).string = [];
        x = SpikeRate(k).data;
        if isempty(x); continue; end;
        [maxfr,maxfi] = max(squeeze(x(1,:,:)),[],2);
        [mfr,mfi] = max(maxfr);
        %max firing rate: mfr. / tuning variable index of mfr: maxfi(mfi) / sort unit idx : mfi 
        SpikeInfo(k).string = sprintf('uch%02d : peak@(index=%02d, x=%.1f, rate=%.3f)', ...
            SpikeRate(k).id, maxfi(mfi), tune_val(maxfi(mfi)), mfr);
    end
    
    %h = mplotTuningCurve(SpikeRate,SpikeInfo,[s_SETS.nevFile,'--',encode_vars{tune_vid}]);
    h = mplotTuningCurve(SpikeRate,SpikeInfo);
    
end

            
        
        
        
    
    
    
    
    
    
    
    






