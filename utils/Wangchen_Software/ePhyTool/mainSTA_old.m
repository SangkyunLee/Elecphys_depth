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
    %load nev/nex files into neuroexploerer.
    
    
end
%-------------------------------------------
%
%%
%sampling timestamp resolution
tsr = s(1).nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;

%number of files loaded
nf = length(s);
%
%find the stimFrames in trial
stimFrames = s(1).matData.params.stimFrames;
%
minISI = (stimFrames/60) * 0.8;

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
            
%     m = 0;
%     for k = 1 : nChannels
%         %count up neuron channels below 128 only. higher channels are from other
%         %A/D inputs. 
%         elecname = s_SETS.nevData.neurons{k}.name;
%         elecname = regexp(elecname,'elec','split');
%         %electrodes are renamed and rearranged as 'chxx' to match the sequence on uprobe.
%         %elecname = regexp(elecname,'ch','split');
%         elecnum = str2num(elecname{2});
%         if isempty(elecname) || elecnum > 128
%             continue; %skip analog channel timestamps from thershold filtering
%         end
%         m = m + 1;
%         spike_train(m).data = s_SETS.nevData.neurons{k}.timestamps; %extract spiketrain before looping
%         spike_train(m).data = (spike_train(m).data)'; %transpose to row vector.
%         %spike_train(m).id = s_SETS.nevData.neurons{k}.name;
%         spike_train(m).id = elecnum; %numerical
%     end
    
%     %reset nChannels? to actual neuron channels read in ?
%     nChannels = length(spike_train);
   
%     %write the stimimage file for neuroexploer
%     fprintf('Writing Stim Image File for NeuroExploer....');
%     writeStimImageFile(s_SETS,'.\StimImage.txt');
%     fprintf('Done\n');
%     
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
    D = [-0.4 0];  %sta time length
    err = 0;       %error bar estimate
    xSTA = []; %time axis of sta. 
    
    tCT = []; %timestamps array of contrast transition 
    if strcmp(folder(1).exp,'NormLuminance') 
        %make timestamps for contrast transition.
        
            nStd = length(s_SETS.matData.params.contrast);
            nBlocks = s_SETS.matData.params.nBlocks;
            stimulusTime = s_SETS.matData.params.stimulusTime;
            stimFrames = s_SETS.matData.params.stimFrames;
            %stimulus time of block in msec
            scrt = round(1000*stimulusTime/(nStd*nBlocks));
            mFrames = ceil(scrt*60/1000);
            nFrames = ceil(mFrames/stimFrames);
        try 
            singleContrastRunTime = s_SETS.matData.params.singleContrastRunTime;
            %in sec
            singleContrastRunTime = singleContrastRunTime/1000;
        catch
            %block time in sec
            singleContrastRunTime = (nFrames*stimFrames/60);
        end
        tCT = [0:nBlocks*nStd-1]*singleContrastRunTime;
        %align to the first timestamp of stim-event.
        tCT = tCT + t_SETS(1);
        %
        contrastT = cell(1,nStd); %nStd defaults 2
        contrastT{1} = tCT(1:2:end-1);
        contrastT{2} = tCT(2:2:end);
        %single out the timestamps for each contrast in neurons
        for k = 1 : nChannels
            %sorted units
            ns = length(neurons{k}.singleunit);
            for kk = 1 : ns
                neurons{k}.singleunit{kk}.contrast = cell(1,2);
                ts = neurons{k}.singleunit{kk}.timestamps;
                                
                for cc = 1 : 2
                    for tt = 1 : length(contrastT{1})
                        %set up the boundaries of contrast block.
                        if cc==1
                            t1 = contrastT{1}(tt);
                            t2 = contrastT{2}(tt);
                        else
                            t1 = contrastT{2}(tt);
                            if tt < length(contrastT{1})
                                t2 = contrastT{1}(tt+1);
                            else
                                t2 = contrastT{1}(tt) + singleContrastRunTime;
                            end
                        end
                        %
                        if tt == 1
                            tss = (ts >= t1 & ts < t2);
                        else
                            tss = tss | (ts >= t1 & ts < t2);
                        end
                    end
                    %
                    neurons{k}.singleunit{kk}.contrast{cc}.timestamps = ts(tss);
                end
            end %sort timestamps by units
        end %
                    
    end
            
    for k = 1 : nChannels
        %return a struct  - test the first one
        fprintf('STA Computation for File[%d], uch[%d]...\n',i,k);
        %compute STA for normlumniance and squaremapping.
        ns = length(neurons{k}.singleunit);
        for kk = 1 : ns
            switch folder(1).exp
                case {'DotMappingExperiment' , 'SquareMappingExperiment'}
                    ts = neurons{k}.singleunit{kk}.timestamps;
                    [mSTA,tSTA,eSTA] = doSTA(ts',StimImage.data,t_SETS,bin,plt,SW,TW,D,err);
                    neurons{k}.singleunit{kk}.sta = mSTA;

                case 'NormLuminance'
                    for cc = 1 : 2
                        ts = neurons{k}.singleunit{kk}.contrast{cc}.timestamps;
                        [mSTA,tSTA,eSTA] = doSTA(ts',StimImage.data,t_SETS,bin,plt,SW,TW,D,err);
                        neurons{k}.singleunit{kk}.contrast{cc}.sta = mSTA;
                    end
            end
        end
%         STA(k).data = mSTA;
%         STA(k).id = spike_train(k).id;
        if ~isempty(tSTA); xSTA = tSTA; end;
%         %find the peak/valley in sta.
         msg(k).string = sprintf('uch-%s:',neurons{k}.name);
    end
    %view result
    
%     h_STA = mspecViewer(xSTA,STA,msg,'STA');
%    h_STA = mspecViewer(xSTA,neurons,msg,'STA');
    
    %----------------------------------------------------------------------
    %open the position calculator for r.f ?
    %creat the struct for dot position -- set r.f.center to the first dot
    %in the stimulus array artificially. update the values from computed
    %RF later on.
    %rf position wrt stimulus array
    if ~strcmp(folder(1).exp,'DotMappingExperiment') || ~strcmp(folder(1).exp, 'SquareMappingExperiment')
        continue;
    end
    posStr = struct('x',1,'y',1,'w',s_SETS.matData.params.dotNumX,...
        'h',s_SETS.matData.params.dotNumY,'dotsize',s_SETS.matData.params.dotSize,...
        'scrTarDistance',0,'pixelPitch',0);
    posStr(1).scrTarDistance = [];
    posStr(1).pixelPitch = [];
    posStr(2) = posStr(1);
    %stimulus wrt to screen
    posStr(2).x = s_SETS.matData.params.stimCenterX;
    posStr(2).y = s_SETS.matData.params.stimCenterY;
    posStr(2).w = s_SETS.matData.params.dotNumX * s_SETS.matData.params.dotSize;
    posStr(2).h = s_SETS.matData.params.dotNumY * s_SETS.matData.params.dotSize;
    posCalculator(posStr);
    %----------------------------------------------------------------------
    
end

