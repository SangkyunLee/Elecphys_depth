function csd_data = rcsd_tetrode(rootdir,expID)
%calculate standard csd from lfp files for tetrode recording in root directory
%
%expID : 1 : oct-2011. 2 : Feb-2012  3: Nov-2012

%load the depth data variable 'tetDepth' 
depthFile = 'W:\data\Wangchen\Acute Experiment Excel Log\tetrode_depth.mat';
load(depthFile); 

switch expID
    case 1
        expToken = 'Oct';
    case 2
        expToken = 'Feb';
    case 3
        expToken = 'Nov';
end

k = 0;
%find the flashingbar experiments in records
for i = 1 : length(tetDepth)
    if strcmp(tetDepth(i).exp,'FlashingBar') && ~isempty(strfind(tetDepth(i).date,expToken))
        k = k + 1;
        F(k) = tetDepth(i);
    end
end

%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,'**\LFP_tt*.mat'));
%
lfp_files = cell(length(F),24);

for i = 1 : length(F)
    expDate = [F(i).date,'\',F(i).time];
    for j = 1 : length(d)
        lfpFile = d(j).name;
        if ~isempty(strfind(lfpFile,expDate))
            [fpath,fname,fext]=fileparts(lfpFile);
            tid = str2num(fname(7:end));
            lfp_files{i,tid} = lfpFile;
        end
    end
end

lfp_data = cell(length(F),24);
erp_data = lfp_data;

%method = 'delta'; %'standard'
%method = 'standard'; %'standard'
method = 'kernel';

%
tets = 1:24;
%load stimulus event timestamps
for i = tets
    for j = 1 : length(F)
        %load the lfp data
        if ~isempty(lfp_files{j,i})
            lfp_data{j,i} = load(lfp_files{j,i});
            load(fullfile(fileparts(lfp_files{j,i}),'stimData.mat'));
            [erp_time,erp_data{j,i}] = geterp(lfp_data{j,i},stimData.Onsets);
        end
    end
end

saveFolder = fullfile(fileparts(depthFile),'Depth_iCSD',method);
if ~exist(saveFolder,'dir'); mkdir(saveFolder); end

D = cat(1,F.depth); %tetrode depth matrix in um
csd_data = cell(1,length(tets));

for i = tets
    el_pos = D(:,i);
    erpMat = cell2mat(erp_data(:,i));
    if all(el_pos==-1); continue; end
    
    %exclude the bad recording (9th) for tt12 on Oct2011
    if i ==12 && expID ==1
        el_pos(9) = [];
        erpMat(9,:) = [];
    end
    
    %remove the recordings at negative depth 
    neg = find(el_pos < 0) ; 
    for nn = 1 : length(neg)
        fprintf('exp%d,tet%d,recording%d has negative depth %f\n',expID,i,neg(nn),el_pos(neg(nn)));
    end
    
    el_pos(neg)=[];
    erpMat(neg,:)=[];
    
    %
    %---------------- Plot ERP (spaced) -------------------------------
    h = plot_erp(erpMat,erp_time,el_pos);%plot scaled and layed out erps
    figure(h);
    title(['ERP tetrode',num2str(i)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('ERP_%s_tt%d.png',expToken,i)));
    close(h);
    %--------------- Plot ERP (overlay) -------------------------------
    h = plot_erps(erpMat,erp_time,el_pos); %plot raw/overlaid erp 
    figure(h);
    title(['ERP tetrode',num2str(i)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('ERPRaw_%s_tt%d.png',expToken,i)));
    close(h);    
    
    %---------------Compute CSD --------------------------------------
     %return csd matrix and updated electrode positions.
    [csd_data{i},el_pos] = getCSD(erpMat,el_pos,method); %need column vector for depth.
   
    %-------------- Plot CSD ---------------------------------------
    if isempty(csd_data{i}); continue; end %skip the empty dataset.
    h = plot_csd(csd_data{i},erp_time,el_pos);
    figure(h);
    title(['CSD tetrode',num2str(i)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('%cCSD_%s_tt%d.png',method(1),expToken,i)));
    close(h);
    
end


function [CSD,pos] = getCSD(erpMat,el_pos, method)
%erp_data : event-related potential matrix (depth recordings x times)
%el_pos   : column vector of electrode position
%method   : csd computation method

CSD = []; pos = [];
%d = D(1:end,tid); % tetrode depth vector
if all(el_pos == -1); return; end
[nrec,npts] = size(erpMat);
%average the erp over recordings made at same depth. 
[uni_pos, uni_pid1] = unique(el_pos,'first');
[uni_pos, uni_pid2] = unique(el_pos,'last');
%
nuq = length(uni_pos); %unique number of depth
pot = zeros(nuq,npts);

for i = 1 : nuq
    pot(i,:) = mean(erpMat(uni_pid1(i):uni_pid2(i),:),1);
end

[CSD,pos] = iCSD(pot,uni_pos,method); 

function h = plot_erps(erpMat,erp_time,el_pos)
%overlay erp 
h = figure; hold on;

for i = 1 : length(el_pos)
    %y = erp_data{i,tid};
    y = erpMat(i,:);
    %y = (y - mean(y))/(max(y)-min(y));
    linecolor = 'k';
    plot(erp_time*1000, y,linecolor); %space b/w channels 1.2
    xlabel('Time(ms)');
    ylabel('ERP');
    set(gca, 'YTick', []);
%     text(erp_time(end)*1000 + 20 , y(end)+(length(z)-i)*1.5,num2str(z(i)));
end

function h = plot_erp(erpMat,erp_time,el_pos)
%
h = figure; hold on;

for i = 1 : length(el_pos)
    %y = erp_data{i,tid};
    %if isempty(y); continue; end
    y = erpMat(i,:);
    y = (y - mean(y))/(max(y)-min(y));
    linecolor = 'k';
    plot(erp_time*1000, y+(length(el_pos)-i)*1.5,linecolor); %space b/w channels 1.2
    xlabel('Time(ms)');
    ylabel('ERP(norm)');
    xlim([erp_time(1)*1000,erp_time(end)*1000 + 50]);
    set(gca, 'YTick', []);
    text(erp_time(end)*1000 + 20 , y(end)+(length(el_pos)-i)*1.5,num2str(el_pos(i)));
end

% scale = 1;
% y = avgLFP;
% y = y - repmat(mean(y,2),1,size(y,2));
% y = y / max(max(abs(y)))*scale;
% n = size(y,1);
% 
% for i = 1:n
%     %ii = recChanID(i);
%     linecolor = 'k';
%     if i == length(channel)-depthIdx+1 ; linecolor = 'b'; end
%     plot(tCSD*1000,y(i,:)+(n-i)+1,linecolor);
% 
%     if i == length(channel)-depthIdx+1 ;
%         plot(tCSD(sinkTimeIdx)*1000,y(i,sinkTimeIdx)+n-i+1,'r+');
%     end
% end


function h = plot_csd(csdMat,t,el_pos)

%csd_data : (depths x times) csd matrix
h = figure; hold on;
pcolor(t*1000,el_pos,csdMat); shading interp;

ylabel('Depth(um)');
xlabel('Time(ms)');

%find the global min within the first 150ms
[ix,iy]=find(csdMat==min(min(csdMat(:,1:150)))); %1k sample rate
plot(t(iy)*1000,el_pos(ix),'w+');
ylim([el_pos(1) el_pos(end)]);
set(gca,'YDir','reverse'); %


function [tSTA,erp_data,erp_err] = geterp(lfp_data,eventTime)

param = lfp_data.LFP.param;
lfp   = lfp_data.LFP.data;  %1d

t = [0 : size(lfp,2)-1]/param.samplingFreq;
bin = 1/(param.samplingFreq); %sta time bin - half of the lfp sample interval
plt = 'n';     %no plot for each individual channel.
SW = [];       %smoothing width
TW = [];       %TW = [0 100]; % select time window in spike train
D = [0 0.2];   %sta time length
err = 0;       %error bar estimate
    
%[mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA1(ts,lfp,t,bin,plt,SW,TW,D,err);

for i = 1 : size(lfp,1)
    %extract event-triggered trace. 
    for j = 1 : length(eventTime)
        [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(eventTime(j),lfp(i,:),t,bin,plt,SW,TW,D,err);

        if i==1 && j==1 ;
            eveLFP = zeros(size(lfp,1), length(eventTime),length(tSTA));
        end

        if ~isempty(mSTA)
            eveLFP(i,j,:)= mSTA;
        end
    end
end

%
driftCorr = true; %apply baseline drift correction
avgPoints = 10; %window size for average baseline in sample points (=ms at 1k rate)

if driftCorr
    for i = 1 : size(lfp,1)
        for j = 1 : length(eventTime)
             eveLFP(i,j,:) = eveLFP(i,j,:) - mean(eveLFP(i,j,1:avgPoints));
        end
    end
end

erp_data = sum(squeeze(eveLFP),1)/length(eventTime);
erp_err  = std(squeeze(eveLFP),1)/sqrt(length(eventTime));


function [probeDepth] = getcsd(lfpFile,nevFile,opt)
%
%
if nargin < 3
    opt = 'open' ;   % 
end

probeDepth = -1; 

%subfolder to save outputs
subfolder = 'output1';

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
%line noise notch filter
% f_cutoff = [59.5 60.5];
% f_type = 'stop';
% f_sample = param.samplingFreq ; %
% f_order = 4;
% %butterworth digital fitler
% [ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);
% lfp = (filtfilt(ft_b,ft_a,LFP.data'))';  %transpose to column vectors for filter input.   

% notch filter to remove 50Hz noise
Q = 1.5;                                    % Quality factor - !!IMPORTANT PARAMETER!!
wo = 60/(param.samplingFreq/2);  
bw = wo/Q;                                  % bandwidth at the -3 dB point set to bw 
[bn,an] = iirnotch(wo,bw);  
lfp = (filter(bn,an,LFP.data'))';

%remove harmonics 120hz
wo = 120/(param.samplingFreq/2);  
bw = wo/Q;                                  % bandwidth at the -3 dB point set to bw 
[bn,an] = iirnotch(wo,bw);  
lfp = (filter(bn,an,LFP.data'))';

% y_notch=filter(bn,an,ecg_sample);
% plot_pwelch(ecg_sample,y_notch,fs);

%-----------------------------------------------------------------------
%stimulus onsets
eventTime = getDigEvents(NEV);

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
        cTag = 'high';
        if strcmp(cTag,'high')
            eventTime = highTimestamps(1 : nFrames : end);
        else
            eventTime = lowTimestamps(1 : nFrames : end); 
        end
        %
    case 'FlashingBar'
        %stimOnset{1}=eventTime;
        if numel(eventTime) > 50;
            fprintf('Possible miscounting events: %d\n', numel(eventTime));
        end
end


%=========================================================================
%spikes per channel
for i = 1 : length(channel)
    ts{i} = getNeuralEventTimeStamp(NEV,channel(i));
end

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
t = [0 : size(lfp,2)-1]/param.samplingFreq;
bin = 1/(2*param.samplingFreq); %sta time bin - half of the lfp sample interval
plt = 'n';     %no plot for each individual channel.
SW = [];       %smoothing width
TW = [];       %TW = [0 100]; % select time window in spike train
D = [0 0.3];   %sta time length
err = 0;       %error bar estimate
    
%[mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA1(ts,lfp,t,bin,plt,SW,TW,D,err);

for i = 1 : size(lfp,1)
    %extract event-triggered trace. 
    for j = 1 : length(eventTime)
        [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(eventTime(j),lfp(i,:),t,bin,plt,SW,TW,D,err);

        if i==1 && j==1 ;
            eveLFP = zeros(size(lfp,1), length(eventTime),length(tSTA));
        end

        if ~isempty(mSTA)
            eveLFP(i,j,:)= mSTA;
        end
    end
end

tCSD = tSTA;

lfp = [t ; lfp];
csd = CSD(lfp');

%instantaneous csd matrix
insCSD = csd(:,2:end)';    %(chan,values)
ncsdChan = size(insCSD,1); %total # of channels for csd, except the first and last channel.

%baseline correction to account for the possible deviation of signal over
%time. the trace is shifted to zero on the stimulus onset.
basePts = 3; %number of points to get baseline for substraction.
avgLFP = zeros(size(eveLFP,1),size(eveLFP,3));
for i = 1 : size(eveLFP,1)
    for j = 1 : length(eventTime)
        eveLFP(i,j,:) = eveLFP(i,j,:) - mean(eveLFP(i,j,1:basePts));
    end
    avgLFP(i,:) = mean(eveLFP(i,:,:),2); %average over events
end

avgCSD = CSD([tCSD;avgLFP]');
avgCSD = avgCSD';

csds = avgCSD';  %plotcsd plots the 1st(topest) on the top and last(deepest) on the bottom of chart.

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
hfig1 = PlotCSD(csds,'lfp',lfps);
figure(hfig1); hold on;
f_folder = fileparts(lfpFile);
fdate = f_folder(end-19:end-9);

%for oct-11, half of the 32channels used. find the depth index by channel
%id.
depthIdx = find(cmap(:,3)==channel(recChanID(sinkChanIdx))); %depth index counted from the deepest.
%
plot(tCSD(sinkTimeIdx)*1e3,(length(channel)-sinkChanIdx+1)*1-1,'w+');

probeDepth = (depthIdx-1)*spacing + 400; %depth of the deepest channel.
% title(sprintf('sink chan index=%d, t %.1f ms',size(csds,2)-sinkChanIdx, tCSD(sinkTimeIdx)*1000));
title(sprintf('%s,sink=%d,t=%.1f ms,probe=%d',fdate,sinkChanIdx, tCSD(sinkTimeIdx)*1000,probeDepth)); %index from the tip channel

%
savFolder = fullfile(f_folder,subfolder);
if ~exist(savFolder,'dir'); mkdir(savFolder); end

%save csd plot
savePlotAsPic(hfig1,fullfile(savFolder,['CSD',cTag,'.png']));
%save the csd to mat file
save(fullfile(f_folder,['CSD',cTag,'.mat']),'csd','csds');

%
hfig2 = figure('name','ERP'); hold on;
set(hfig2,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])

dy = 0 ;

scale = 1;
y = avgLFP;
y = y - repmat(mean(y,2),1,size(y,2));
y = y / max(max(abs(y)))*scale;
n = size(y,1);

for i = 1:n
    %ii = recChanID(i);
    linecolor = 'k';
    if i == length(channel)-depthIdx+1 ; linecolor = 'b'; end
    plot(tCSD*1000,y(i,:)+(n-i)+1,linecolor);

    if i == length(channel)-depthIdx+1 ;
        plot(tCSD(sinkTimeIdx)*1000,y(i,sinkTimeIdx)+n-i+1,'r+');
    end
end
%      
% for i = 1 : length(channel)
%     %subplot(nrow,ncol,i);
%     ii = recChanID(i);    
%     linecolor = 'k'; 
%     %if i == 1; linecolor = 'y'; end
%     if ii == length(channel)-depthIdx+1 ; linecolor = 'b'; end
%     
%     plot(tCSD,avgLFP(i,:)-dy,linecolor);
%         
%     if ii == length(channel)-depthIdx+1 ; 
%         plot(tCSD(sinkTimeIdx),avgLFP(i,sinkTimeIdx)-dy,'r+');
%     end
%     
%     if i > 1
%         dy = dy - max(avgLFP(i,:)-avgLFP(i-1,:)); 
%     end
%     
% end

legend(sprintf('%d)Ch%d',1,channel(recChanID(1)))); %first channel plotted.
%
savePlotAsPic(hfig2,fullfile(savFolder,['ERP',cTag,'.png']));

hfig3 = figure('name','PSTH');
set(hfig3,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])

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

%
savePlotAsPic(hfig3,fullfile(savFolder,['PSTH',cTag,'.png']));

%plot LFPs on one figure
hfig4 = figure('name','ERP in depth');
set(hfig4,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200]);
hold on;
%maxV = max(max(abs(lfps(:,2:end))));
for i = 1 : length(channel)
    %subplot(nrow,ncol,i);
    %ii = recChanID(i);
    linecolor = 'k'; 
    %if i == 1; linecolor = 'y'; end
    if i == length(channel)-depthIdx+1 ; linecolor = 'b'; end
    yy = lfps(:,i+1);
    %yy = (yy - mean(yy))/(2*max(abs(yy))) ;
    yy = (yy-yy(1)) + 0;  %overlay 
    plot(lfps(:,1),yy,linecolor); %deepest at bottom
    if i == length(channel)-depthIdx+1 ; 
        plot(lfps(sinkTimeIdx,1),yy(sinkTimeIdx),'r+');
    end
end

xlim([lfps(1,1),lfps(end,1)]);
%ylim([-1 length(channel)+2]);
ylim auto;
xlabel('Time(s)');
ylabel('LFP');
title(sprintf('%s,ERP in depth',fdate));

%
savePlotAsPic(hfig4,fullfile(savFolder,['ERPinDepth',cTag,'.png']));

if strcmp(opt,'close')
    close(hfig1);
    close(hfig2);
    close(hfig3);
    close(hfig4);
end
