function rcsd(rootdir)
%calculate csd from lfp files in root directory
%
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,'**\*_LFP.mat'));
%
for i = 1 : length(d)
    lfpFile = d(i).name;
    [fpath,fname] = fileparts(lfpFile);
    nevFile = fullfile(fpath,strrep(fname,'_LFP','.nev')); 
    
    fprintf('[%d]/%d : %s ... \n',i,length(d),fpath);
    %extract lfp from raw data

%     getcsd(lfpFile,nevFile,'close');
    try
         getcsd(lfpFile,nevFile,'close');
    catch
        fprintf('error on %d|%d: %s, continue\n',i,length(d),lfpFile);
    end
end


function getcsd(lfpFile,nevFile,opt)
%
%
if nargin < 3
    opt = 'open' ;   % 
end

%subfolder to save outputs
subfolder = 'output5';
%output1 : baseline correction : inital value was substracted.(for lfp plot only) 
%output2 : no baseline correction (for lfp plot only)
%output3 : reverse the depth in csd so that the brain surface corresponse
%to top of figure. (no baseline correction for csd)
%output4 : exclude the channels outside of brain from csd calculation (No baseline correction for csd) 
%output5 : baseline corrected version of output3. i.e, initial value
%substracted from lfp before csd calculation.
cmap = getChannelMapFile(lfpFile,'part'); %or use global variable.

load(lfpFile);
lfp = h.Data;
channel = [h.ElectrodesInfo.ElectrodeID];
channel = channel(1:size(lfp,1));        %neural data channels

%get spike event time
NEV = openNEV(nevFile,'read');
% recChan = unique(NEV.Data.Spikes.Electrode);

%filter the line noise from lfp by a notch filter
%create low-pass butterworth filter.
f_cutoff = [59.5 60.5];
f_type = 'stop';
f_sample = param.samplingRate ; %
f_order = 4;
%resample freq for lfp
%lfp_fs = 1000;
%butterworth digital fitler
[ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);

for i = 1 : length(channel)
    lfp(i,:) = filtfilt(ft_b,ft_a,lfp(i,:));
end

%baseline correction of lfp.
for i = 1 : length(channel)
    lfp(i,:) = lfp(i,:) - lfp(i,1);
end

%stimulus onsets

%-----------------------------------------------------------------------
recChanID = zeros(size(channel));

for i = 1 : length(channel)
    ic = find(channel==cmap(i,3));
    if isempty(ic); 
        error('channels are not continuous by channel map'); 
    end
    recChanID(i) = ic;
end
 
%-----------------------------------------------------------------------

% nspks = zeros(1,length(channel)); %spike# in each channel.
for i = 1 : length(channel)
    ts{i} = getNeuralEventTimeStamp(NEV,channel(i));
    %nspks(i) = length(ts{i});
end

%stimulus onset events
eventTime = getDigEvents(NEV);

%=========================================================================
%peri-stimulus histogram
tbin = 0.01; 
tPETH = 0 : tbin : 2;
sPETH = zeros(length(channel),size(tPETH,2));
ePETH = sPETH;

for i = 1 : length(channel)
    [sPETH(i,:),ePETH(i,:)] = peth(ts{i},eventTime,tPETH);
end
%change to rates
sPETH = sPETH/tbin;
ePETH = ePETH/tbin;

%lfp = lfp(fliplr(recChanID),:); % sort lfp by channels in depth. the deepest chan on the 1ast row
%reverse the channels so that the topest is the first, and the deepest
%channel the last
recChanID = fliplr(recChanID);
lfp = lfp(recChanID,:); % sort lfp by channels in depth. the deepest chan on the 1ast row
sPETH = sPETH(recChanID,:);  % 
ePETH = ePETH(recChanID,:);  %

%exclude the channels potentially in the air from CSD computation 
%
nExChan = 0; %1600um for edge probe.-- 100um spacing
if channel(recChanID(1)) ~= 51 %standard probe, 50um spacing
    nExChan = 0;
end

for i = 1 : nExChan
    lfp(i,:) = 0;    %zero out the first i-th top channels.
end

% t = [0 : size(lfp,2)-1]/LFP.SampleFreq; 
t = [0 : size(lfp,2)-1]/param.samplingRate;

%calculate ERP
% erpTime = [0 : 2*LFP.SampleFreq]/LFP.SampleFreq;

bin = 1/(2*param.samplingRate); %sta time bin - half of the lfp sample interval
plt = 'n';     %no plot for each individual channel.
SW = [];       %smoothing width
TW = [];       %TW = [0 100]; % select time window in spike train
D = [0 0.6];   %sta time length
err = 0;       %error bar estimate
    
%[mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA1(ts,lfp,t,bin,plt,SW,TW,D,err);

lfp = [t ; lfp];
csd = CSD(lfp');

%instantaneous csd matrix
insCSD = csd(:,2:end)';    %(chan,values)
ncsdChan = size(insCSD,1); %total # of channels for csd, except the first and last channel.
%event-triggered csd
%eventTime = ts{(nspks == max(nspks))}; %most firing channel as event reference.
for i = 1 : ncsdChan
    [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(eventTime,insCSD(i,:),t,bin,plt,SW,TW,D,err);
    if i == 1 ; avgCSD = zeros(ncsdChan,length(tSTA)); end
    if ~isempty(mSTA)
        avgCSD(i,:)= mSTA;
    end
end

tCSD = tSTA;

for i = 1 : size(lfp,1)-1
    [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(eventTime,lfp(i+1,:),t,bin,plt,SW,TW,D,err);
    if i == 1 ; avgLFP = zeros(ncsdChan+2, length(tSTA)); end
    if ~isempty(mSTA)
        avgLFP(i,:)= mSTA;
    end
end

csds = [tCSD ; avgCSD];
csds = csds';          %plotcsd plots the 1st(topest) on the top and last(deepest) on the bottom of chart.

lfps = [tCSD ; avgLFP];
lfps = lfps'; 


%find the sink position (minimum) from csd profile.
[minCSDRow,minCSDRowIdx] = min(csds(:,2:end),[],1);
[minCSD,minCSDColumnIdx] = min(minCSDRow,[],2);
sinkChanIdx = minCSDColumnIdx ;                 %chan index from top to bottom
sinkTimeIdx = minCSDRowIdx(minCSDColumnIdx);

ncol = round(sqrt(length(channel)))+2;
nrow = ceil(length(channel)/ncol);
scrsz = get(0,'ScreenSize');

% hfig1 = PlotCSD(csds,'lfp',lfps);
hfig1 = PlotCSD(csds);
figure(hfig1);
f_folder = fileparts(lfpFile);
fdate = f_folder(end-19:end-9);
% title(sprintf('sink chan index=%d, t %.1f ms',size(csds,2)-sinkChanIdx, tCSD(sinkTimeIdx)*1000));
title(sprintf('%s,sink id=%d,t=%.1f ms',fdate,sinkChanIdx, tCSD(sinkTimeIdx)*1000)); %index from the tip channel

saveFigFile = strrep(lfpFile,'_LFP.mat','_CSD.png');
[f_folder,f_file,f_ext] = fileparts(saveFigFile);
mkdir(fullfile(f_folder,subfolder));
saveFigFile = fullfile(f_folder,subfolder,[f_file,f_ext]);
savePlotAsPic(hfig1,saveFigFile);

%save the csd to mat file
csdFile = strrep(lfpFile,'_LFP.mat','_CSD.mat');
[f_folder,f_file,f_ext] = fileparts(csdFile);
mkdir(fullfile(f_folder,subfolder));
csdFile = fullfile(f_folder,subfolder,[f_file,f_ext]);
save(csdFile,'csd','csds');

%
hfig2 = figure('name','ERP'); 
set(hfig2,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-100])

for i = 1 : length(channel)
    subplot(nrow,ncol,i);
    ii = recChanID(i);
    plot(lfps(:,1),lfps(:,i+1),'k');
    title(sprintf('ch%d',channel(ii)));
    if i == 1; 
        xlabel('Time(s)'); 
        ylabel('LFP');
        title(sprintf('ERP ch%d,%s',channel(ii)));
    end
    xlim([lfps(1,1),lfps(end,1)]);
end

erpFile = strrep(lfpFile,'_LFP.mat','_ERP.png');
[f_folder,f_file,f_ext] = fileparts(erpFile);
mkdir(fullfile(f_folder,subfolder));
erpFile = fullfile(f_folder,subfolder,[f_file,f_ext]);
savePlotAsPic(hfig2,erpFile);

hfig3 = figure('name','PSTH');
set(hfig3,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-100])

for i = 1 : length(channel)
    subplot(nrow,ncol,i);
    ii = recChanID(i);
    errorbar(tPETH,sPETH(i,:),ePETH(i,:),'k');
    title(sprintf('ch%d',channel(ii)));
    if i == 1; 
        xlabel('Time(s)'); 
        ylabel('Firing rate (hz)');
        title(sprintf('PSTH ch%d',channel(ii)));
    end
    xlim([tPETH(1) tPETH(end)]);
end

histFile = strrep(lfpFile,'_LFP.mat','_PSTH.png');
[f_folder,f_file,f_ext] = fileparts(histFile);
mkdir(fullfile(f_folder,subfolder));
histFile = fullfile(f_folder,subfolder,[f_file,f_ext]);
savePlotAsPic(hfig3,histFile);

%plot LFPs on one figure
hfig4 = figure('name','ERP in depth');
set(hfig4,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-100]);
hold on;
%maxV = max(max(abs(lfps(:,2:end))));
for i = 1 : length(channel)
    %subplot(nrow,ncol,i);
    ii = recChanID(i);
    yy = lfps(:,i+1);
    %yy = (yy - mean(yy))/(2*max(abs(yy))) ;
    yy = (yy-yy(1)) + 0;  %overlay 
    plot(lfps(:,1),yy,'k'); %deepest at bottom
end

xlim([lfps(1,1),lfps(end,1)]);
%ylim([-1 length(channel)+2]);
ylim auto;
xlabel('Time(s)');
ylabel('LFP');
title(sprintf('%s,ERP in depth',fdate));

erpDepthFile = strrep(lfpFile,'_LFP.mat','_ERPinDepth.png');
[f_folder,f_file,f_ext] = fileparts(erpDepthFile);
mkdir(fullfile(f_folder,subfolder));
erpDepthFile = fullfile(f_folder,subfolder,[f_file,f_ext]);
savePlotAsPic(hfig4,erpDepthFile);


if strcmp(opt,'close')
    close(hfig1);
    close(hfig2);
    close(hfig3);
    close(hfig4);
end
