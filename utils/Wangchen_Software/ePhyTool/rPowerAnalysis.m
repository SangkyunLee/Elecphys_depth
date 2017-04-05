function rPowerAnalysis(rootdir)
%search the 'target' files to locate the data subfolders.

%
targetFile = 'LFP.mat';
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));
%
for i = 1 : length(d)
    fileName = d(i).name;    
    fprintf('[%d]/%d : %s ... \n',i,length(d),fileparts(fileName));
%     getPowerSpec(fileName);
    try
        getPowerSpec(fileName);
    catch
        fprintf('error on %d|%d: %s, continue\n',i,length(d),fileName);
        lasterr
        
    end
    
    close all;
    
end


function [probeDepth] = getPowerSpec(lfpFile,opt)
%
%
if nargin < 2
    opt = 'open' ;   % 
end

fdir = fileparts(lfpFile); %strip off the subfolder
%find the nev file
d = rdir(fullfile(fdir,'*.nev')); %
if length(d) > 1
    disp('multiple nev files found');
end
nevFile = d(1).name;

probeDepth = -1; 

%subfolder to save outputs
subfolder = '';

%temp 
if exist(fullfile(fileparts(nevFile),subfolder),'dir')
   % return;
end

%----obsolate message------------------------------------------------------
% %output1 : baseline correction : inital value was substracted.(for lfp plot only) 
% %output2 : no baseline correction (for lfp plot only)
% %output3 : reverse the depth in csd so that the brain surface corresponse
% %to top of figure. (no baseline correction for csd)
% %output4 : exclude the channels outside of brain from csd calculation (No baseline correction for csd) 
% %output5 : baseline corrected version of output3. i.e, initial value
% %substracted from lfp before csd calculation.
%
%output :  ignore previous results. correction of the filter frequency for
%lfp is applied. csd is averaged after each epoch is calculated from the
%instantanious lfp. 
%output1:  apply notch filter for 60&120 hz, as for 'output'. csd is
%computed from the averaged lfp. 

%get spike event time
NEV  = openNEV(nevFile,'read','nowave','nowrite');
[cmap,spacing] = getChannelMapFile(lfpFile,'part'); %or use global variable.
if isempty(cmap); disp('no cmap'); return; end
    
load(lfpFile); %load LFP data
param = LFP.param; 
channel = param.channel; 
%tetrode = param.tetrode; 

%---------------------------------------------------------
recChanID = zeros(size(channel));
for i = 1 : length(channel)
    ic = find(channel==cmap(i,3));
    if isempty(ic); 
        disp('channels are not continuous by map'); 
        return;
    end
    recChanID(i) = ic;  %depth index. 
end


%--------------------------------------------------------
% %line noise notch filter
% f_cutoff = [59 61];
% f_type = 'stop';
% f_sample = param.samplingFreq ; %
% f_order = 4;
% %butterworth digital fitler
% [ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);
% lfp = (filtfilt(ft_b,ft_a,LFP.data'))';  %transpose to column vectors for filter input.   

% notch filter to remove 50Hz noise
Q = 30;                                    % Quality factor - !!IMPORTANT PARAMETER!!
wo = 60/(param.samplingFreq/2);  
bw = wo/Q;                                  % bandwidth at the -3 dB point set to bw 
[bn,an] = iirnotch(wo,bw);  
lfp = (filter(bn,an,LFP.data'))';

% %remove harmonics 120hz
% wo = 120/(param.samplingFreq/2);  
% bw = wo/Q;                                  % bandwidth at the -3 dB point set to bw 
% [bn,an] = iirnotch(wo,bw);  
% lfp = (filter(bn,an,LFP.data'))';

%save some space
clear LFP;


% y_notch=filter(bn,an,ecg_sample);
% plot_pwelch(ecg_sample,y_notch,fs);

%-----------------------------------------------------------------------
%stimulus onsets
eventTime = getDigEvents(NEV);

stimOnset = eventTime(1);

%baseline correction of lfp.
for i = 1 : length(channel)
    lfp(i,:) = lfp(i,:) - lfp(i,1);
end

%stimulus onsets
%-----------------------------------------------------------------------


expName = [];
if ~isempty(strfind(lfpFile,'NormLuminance')) 
    expName = 'NormLuminance';
end

if ~isempty(strfind(lfpFile,'FlashingBar')) 
    expName = 'FlashingBar';
end

cTag = '';

switch expName
    case 'NormLuminance'
        nBlocks = 30; %or read from mat params.
        nFrames = numel(eventTime)/nBlocks/2; %stim frames per contrast block
        lowTimestamps = [];
        highTimestamps = [];
        for i = 1 : 2*nBlocks
            conTimestamps = eventTime(1+(i-1)*nFrames : i*nFrames);
            if mod(i,2)==1
                lowTimestamps = [lowTimestamps conTimestamps]; 
            else
                highTimestamps = [highTimestamps conTimestamps];
            end
        end
        %stimOnset{1}=lowTimestamps;
        %stimOnset{2}=highTimestamps;
        %pick one contrast conditon for csd
        %cTag = 'high';
        onsetHigh = highTimestamps(1 : nFrames : end);
        onsetLow  = lowTimestamps(1 : nFrames : end); 
        onsetTime = sort(cat(2,onsetLow,onsetHigh));
        %
    case 'FlashingBar'
        %stimOnset{1}=eventTime;
        if numel(eventTime) > 50;
            fprintf('Possible miscounting events: %d\n', numel(eventTime));
        end
        onsetTime = eventTime;
end



%=========================================================================
%spikes per channel

%lfp = lfp(fliplr(recChanID),:); % sort lfp by channels in depth. the deepest chan on the 1ast row
%reverse the channels so that the topest is the first, and the deepest
%channel the last
recChanID = fliplr(recChanID);
lfp = lfp(recChanID,:); % sort lfp by channels in depth. the deepest chan on the 1ast row

%======================================================================

% %exclude the channels potentially in the air from CSD computation 
% %
% nExChan = 0; %1600um for edge probe.-- 100um spacing
% if channel(recChanID(1)) ~= 51 %standard probe, 50um spacing
%     nExChan = 0;
% end
% 
% for i = 1 : nExChan
%     lfp(i,:) = 0;    %zero out the first i-th top channels.
% end

%---------------------------------------------------------------------
% CSD analysis
% t = [0 : size(lfp,2)-1]/param.samplingFreq;
% bin = 1/(2*param.samplingFreq); %sta time bin - half of the lfp sample interval
% plt = 'n';     %no plot for each individual channel.
% SW = [];       %smoothing width
% TW = [];       %TW = [0 100]; % select time window in spike train
% D = [0 0.3];   %sta time length
% err = 0;       %error bar estimate

%event duration
duration = mean(diff(onsetTime));
npoint  =  floor(duration*param.samplingFreq);
t = [0 : npoint-1]/param.samplingFreq;

%[mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA1(ts,lfp,t,bin,plt,SW,TW,D,err);

for i = 1 : size(lfp,1)
    %extract event-triggered trace. 
    for j = 1 : length(onsetTime)
        %[mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(eventTime(j),lfp(i,:),t,bin,plt,SW,TW,D,err);
        if i==1 && j==1 ;
            eveLFP = zeros(size(lfp,1), length(onsetTime),length(t));
        end
        idx = round(onsetTime(j)*param.samplingFreq);
        nx  = idx : idx+npoint-1;
        nx(end) = min([nx(end) size(lfp,2)]);
        
        eveLFP(i,j,1:length(nx))= lfp(i,nx);
        
    end
end


%extract the ongoing activity before the adapation stimuli onset. 
preStimIdx = round(stimOnset*param.samplingFreq);
ongoLFP = zeros(size(lfp,1),preStimIdx);

for i = 1 : size(lfp,1)
    ongoLFP(i,:) = lfp(i,1:preStimIdx);
end


params.Fs=param.samplingFreq; % sampling frequency
params.fpass=[10 100]; % band of frequencies to be kept
% params.tapers=[3 5]; % taper parameters
% params.pad=0; % pad factor for fft
% params.err=[2 0.05];
params.trialavg=1;
%movingwin=[0.5 0.05];
%movingwin= [10 1];

for i = 1 : size(lfp,1) %compute the power spec of lfp over trials
    data = transpose(squeeze(eveLFP(i,:,:))); %trials per channel. (samples x trials)
%     [S,f,Serr]=mtspectrumc(data,params);
    [S,f,Serr]=getPSD(data,params);
    if i == 1 
        stimPSD = zeros(size(lfp,1),length(S));
        stimPSDERR = stimPSD;       
    end
    stimPSD(i,:) = S;
    stimPSDERR(i,:) = Serr;
    %psd of ongoing activity
    [SS,ff,SSerr] = getPSD(ongoLFP(i,:)',params);
    %
    sca = round(numel(ff)/numel(f));
    
    %SS = filter(ones(1,sca)/sca, 1, SS); %moving average.
    SS = smooth(SS,sca);
        
    if i == 1
         preStimPSD = zeros(size(lfp,1),length(SS));
    end
    preStimPSD(i,:) = SS;
    
end

%ff = linspace(f(1),f(end),length(SS));

scrsz = get(0,'ScreenSize');
hfig1 = figure('name','PSD','Position',[10 scrsz(4)/2 scrsz(3)-20 scrsz(4)/2-100]);
hold on;
%hfig1 = figure; hold on;

for i = 1 : size(lfp,1)
    subplot(1,2,1);hold on;
    plot(ff,preStimPSD(i,:),'k'); xlabel('Frequency(Hz)'); ylabel('PSD Spectrum(db)');title('Spontaneous');
    subplot(1,2,2);hold on;
    plot(f,stimPSD(i,:),'k'); xlabel('Frequency(Hz)'); ylabel('PSD Spectrum(db)');title('Evoked');
    
end

%hfig2 = figure;
hfig2 = figure('name','PSD-2D','Position',[10 scrsz(4)/2 scrsz(3)-20 scrsz(4)/2-100]);
hold on;

%top channel on top of the figure. the deepest channel at the bottom
subplot(1,2,1);
imagesc(ff,1:size(lfp,1),preStimPSD); axis image; xlabel('Frequency(Hz)'); ylabel('PSD Spectrum(db)'); 
title('Spontaneous');
subplot(1,2,2);
imagesc(f,1:size(lfp,1),stimPSD); axis image; xlabel('Frequency(Hz)'); ylabel('PSD Spectrum(db)');
title('Evoked');

%
savePlotAsPic(hfig1,fullfile(fdir,['Time_Freq',cTag,'.png']));
savePlotAsPic(hfig2,fullfile(fdir,['Time_Freq_2D',cTag,'.png']));




