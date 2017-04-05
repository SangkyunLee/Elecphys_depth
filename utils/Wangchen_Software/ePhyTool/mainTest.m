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
folder(1).etc = [];

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
  
  %sampling timestamp resolution
tsr = s(1).nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;

%number of files loaded
nf = length(s);
%

%find the stimFrames in trial
stimFrames = s(1).matData.params.stimFrames;

switch folder(1).exp
    case 'NormLuminance'
        %exepcted value of intervals
        eISI = stimFrames/60;
        minISI = eISI * 0.8;
        nBlocks = s(1).matData.params.nBlocks;
    case 'NormGrating'
        blankFrames = s(1).matData.params.blankFrames;
        eISI = (stimFrames+blankFrames)/60;
        minISI = eISI*0.8;
        nBlocks = s(1).matData.params.nBlocks;
end
%

%filter the stim-event-timestamps. assume dig.ch1 contains photodiode pulses
s1 = filtSETS(s,1,minISI);

%check the filtering 
swapTime = s1.matData.params.swapTimes;
macTime = swapTime(3:2:end-1);
msuTime = s1.nevData.events{1}.timestamps;

msuTime0 = s.nevData.events{1}.timestamps;
msuTime0 = msuTime0-msuTime0(1);
macTime = macTime - macTime(1);
msuTime = msuTime - msuTime(1);

[r,badpts]=regISI(msuTime,eISI, 0.1*eISI);
t2 = max([macTime(end) msuTime(end) msuTime0(end)]);
t1 = t2 -10;
x1 = macTime(macTime >= t1 & macTime <= t2);
x2 = msuTime0(msuTime0 >= t1 & msuTime0 <= t2);
x3 = msuTime(msuTime >=t1 & msuTime < t2);
xx = {x2, x3, x1};
rasterplot(xx);
%number of epoches.
nEPO = 2*nBlocks;
%timestamps per epoch
tsPerEPO = length(msuTime)/nEPO;

t_epo_start = msuTime(1:tsPerEPO:end);
t_epo_end = zeros(size(t_epo_start));
t_epo_end(1:end-1) = t_epo_start(2:end);
t_epo_end(end) = t_epo_end(end-1) + mean(diff(t_epo_end(1:end-1)));
low_t1 = t_epo_start(1:2:end);
low_t2 = t_epo_end(1:2:end);
high_t1 = t_epo_start(2:2:end);
high_t2 = t_epo_end(2:2:end);
%shift by the first timestamp of stim onset
t_firstEvent = s1.nevData.events{1}.timestamps(1);
low_t1 = low_t1 + t_firstEvent;
low_t2 = low_t2 + t_firstEvent;
high_t1 = high_t1 + t_firstEvent;
high_t2 = high_t2 + t_firstEvent;










%xx = { macTime, msuTime0,msuTime };


% %write the first 10 ap to audio wave file
% nap = 10;
% dt = s.nevData.waves{nap}.timestamps - s.nevData.waves{1}.timestamps;
% Fs = 30000;
% npt = dt * Fs; 
% waves = zeros(1,npt);
% 
% for i = 1 : nap-1
%     
%     t = s.nevData.waves{i}.timestamps;
%     waveforms = s.nevData.waves{i}.waveforms;
%     idx = round(0.05*(i+1)*Fs); %use 50msec as isi
%     waves(idx:idx+47) = waveforms';
% end
% 
% waves(idx+48 : end)=[];
% 
% waves = waves/max(abs(waves));
% 
% fn = 'SpikeTrainInAudio.wav';
% %
% wavwrite(waves,Fs,fn);



  
  