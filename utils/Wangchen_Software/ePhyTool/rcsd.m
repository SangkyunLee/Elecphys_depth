function rcsd(rootdir)
%calculate csd from lfp files in root directory
%
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,'**\LFP.mat'));
%
err = 0; 

if strmatch(rootdir(end),filesep); rootdir(end)=[]; end
[tmp,expName] = fileparts(rootdir);

%
depthFile = fullfile(rootdir,['csdDeterminedDepth_',expName,'.txt']);
%
fp = fopen(depthFile,'w+');
fprintf(fp,'%s\r\n',rootdir);
for i = 1 : length(d)
    lfpFile = d(i).name;
    dnev = dir(fullfile(fileparts(lfpFile),'*.nev'));
    nevFile = fullfile(fileparts(lfpFile),dnev.name);
    
    fprintf('[%d]/%d : %s ... \n',i,length(d),fileparts(lfpFile));
    
    getcsd(lfpFile,nevFile,'close');
    continue;
    try
        probeDepth = getcsd(lfpFile,nevFile,'open');
        fprintf(fp,'%d|%d)%s\t%d\r\n',i,length(d),lfpFile(length(rootdir)+2:end), probeDepth);
    catch
        fprintf('error on %d|%d: %s, continue\n',i,length(d),lfpFile);
        lasterr
        err = err + 1;
    end
end

fprintf('\n\nProcessed %d, errors %d \n', length(d)-err, err);
fclose(fp);

function [probeDepth] = getcsd(lfpFile,nevFile,opt)
%
%
if nargin < 3
    opt = 'open' ;   % 
end

probeDepth = -1; 

%subfolder to save outputs
subfolder = 'csd';

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

% %baseline correction of lfp.
% for i = 1 : length(channel)
%     lfp(i,:) = lfp(i,:) - lfp(i,1);
% end

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
D = [0 0.5];   %sta time length
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

% standard csd.
% % csd = CSD(lfp');
% % 
% % %instantaneous csd matrix
% % insCSD = csd(:,2:end)';    %(chan,values)
% % ncsdChan = size(insCSD,1); %total # of channels for csd, except the first and last channel.

%baseline correction to account for the possible deviation of signal over
%time. the trace is shifted to zero on the stimulus onset.
basePts = 10; %number of points to get baseline for substraction.
avgLFP = zeros(size(eveLFP,1),size(eveLFP,3));
for i = 1 : size(eveLFP,1)
    for j = 1 : length(eventTime)
        eveLFP(i,j,:) = eveLFP(i,j,:) - mean(eveLFP(i,j,1:basePts));
    end
    avgLFP(i,:) = mean(eveLFP(i,:,:),2); %average over events
end

%method = 'kernel';
method = 'standard';

%avgCSD = CSD([tCSD;avgLFP]');
pb_pos = [0 : spacing : (size(avgLFP,1)-1)*spacing];
%el_pos : interploted electrode position.
[avgCSD,el_pos] = iCSD(avgLFP, pb_pos' , method);

csds = [tCSD;avgCSD]';  %plotcsd plots the 1st(topest) on the top and last(deepest) on the bottom of chart.

lfps = [tCSD ; avgLFP];
lfps = lfps'; 

%----------------
erpMat = avgLFP;
erp_time = tCSD;
csd_data = avgCSD;
%

f_folder = fileparts(lfpFile);
fdate = f_folder(end-19:end-9);

saveFolder = fullfile(f_folder,subfolder);
if ~exist(saveFolder,'dir'); mkdir(saveFolder); end

 %---------------- Plot ERP (spaced) -------------------------------
    h = plot_erp(erpMat,erp_time,pb_pos);%plot scaled and layed out erps
    figure(h);
%     title(['ERP ',sprintf('%s',fdate)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('ERP.png')));
    close(h);
    %--------------- Plot ERP (overlay) -------------------------------
    h = plot_erps(erpMat,erp_time,pb_pos); %plot raw/overlaid erp 
    figure(h);
    title(['ERP ',sprintf('%s',fdate)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('ERPRaw.png')));
    close(h);    
    
    %---------------Compute CSD --------------------------------------
%       %return csd matrix and updated electrode positions.
%      [csd_data{i},el_pos] = getCSD(erpMat,el_pos,method); %need column vector for depth.
%    
    %-------------- Plot CSD ---------------------------------------
    %if isempty(csd_data{i}); continue; end %skip the empty dataset.
    
    %normalize csd_data
    csdmax = max(max(csd_data));
    csdmin = min(min(csd_data));
    norm_csd_data = (csd_data - csdmin)/(csdmax-csdmin);
    
    h = plot_csd(norm_csd_data,erp_time,el_pos);
    figure(h);
    title(['CSD ',sprintf('%s',fdate)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('%cCSD.png',method(1))));
    close(h);
    
    gauss_csd_data = imgaussian(csd_data,1);
    csdmax = max(max(gauss_csd_data));
    csdmin = min(min(gauss_csd_data));
    gauss_csd_data = (gauss_csd_data - csdmin)/(csdmax-csdmin);
    
    h = plot_csd(gauss_csd_data,erp_time,el_pos);
    figure(h);
%     title(['CSD ',sprintf('%s',fdate)]);    
    savePlotAsPic(h,fullfile(saveFolder,sprintf('%cCSD_gauss.png',method(1))));
    close(h);
    
%--------------------------------------------------------------------    


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

%flip the matrix so that the first row corresponse to the surface,last row
%the wm. 
%erpMat = flipud(erpMat);

h = figure; hold on;
%
scaOpt = 'global'; %or 'local' or 'raw'
ymax = max(erpMat,[],2);
ymin = min(erpMat,[],2);
gmax = max(ymax);
gmin = min(ymin);

%normalize the data
for i = 1 : length(el_pos)
    switch lower(scaOpt)
        case 'global'
            erpMat(i,:) = (erpMat(i,:)-gmin)/(gmax-gmin);
        case 'local'
            erpMat(i,:) = (erpMat(i,:)-ymin(i))/(ymax(i)-ymin(i));
    end
end

dymax = max(abs(diff(erpMat,1,1)),[],2);
%dymin = min(diff(erpMat,1,1),[],2);
dymax = [0;dymax];
spaceFactor = 1.3;
totalPos = 0;
for i = 1 : length(el_pos);
    totalPos = totalPos + dymax(i)*spaceFactor;
end

%lastPos = totalPos;
lastPos = 0;

for i = 1 : length(el_pos)
    
    if i < 15; continue; end
    
    %y = erp_data{i,tid};
    %if isempty(y); continue; end
    y = erpMat(i,:);
    %y = (y - mean(y))/(max(y)-min(y));
%     if strcmpi(scaOpt,'global')
%         y = (y-gmin)/(gmax-gmin);
%     else
%         y = (y-ymin(i))/(ymax(i)-ymin(i));
%     end
    
    linecolor = 'k';
    ploty = y - max(y) + lastPos;
    if i == 19; ploty = ploty - 0.1; end ;%manual adjustment. 
%     plot(erp_time*1000, y+(length(el_pos)-i)*1.5,linecolor); %space b/w channels 1.2
    plot(erp_time*1000, ploty,linecolor); %space b/w channels 1.2
    xlabel('Time(ms)');
    ylabel('ERP');
    xlim([erp_time(1)*1000,erp_time(end)*1000 + 50]);
    set(gca, 'YTick', []);
    %text(erp_time(end)*1000 + 20 , y(end)+(length(el_pos)-i)*1.5,num2str(el_pos(i)));
    
    lastPos = min(ploty);
    
%     if i > 1
%         lastPos = lastPos - dymax(i);
%     end
    
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

%find the global min within the first 150ms
[ix,iy]=find(csdMat==min(min(csdMat(:,200:400)))); %1k sample rate

%set the sink position to layer 4 (400um)
corPos = el_pos - el_pos(ix) + 400; 

%plot(t(iy)*1000,el_pos(ix),'w+');
linex = linspace(t(1), t(end),100)*1000;
liney = repmat(corPos(ix),1,100);

%do gaussian smoothing
pcolor(t*1000,corPos,csdMat); shading interp;

ylabel('Depth(microns)');
xlabel('Time(ms)');

caxis([0 1]);

axis tight;

h_bar = colorbar;

initpos = get(h_bar,'Position');
initfontsize = get(h_bar,'FontSize');

% set(h_bar, ...
%    'Position',[initpos(1)+0*initpos(3)*0.25 initpos(2)+0*initpos(4)*0.25 ...
%       initpos(3)*0.5 initpos(4)*0.5], ...
%    'FontSize',initfontsize*0.5,...
%    'YTick', [0;0.5;1]);

set(h_bar,'YTick',[0;0.5;1]);


plot(linex,liney - 50, '-','Color',[230 230 230]/255,'LineWidth',0.1);
plot(linex,liney + 50, '-','Color',[230 230 230]/255,'LineWidth',0.1);

%ylim([el_pos(1) el_pos(end)]);

set(gca,'YDir','reverse'); %

ylim([0 600]);
xlim([0 300]);


% %find the sink position (minimum) from csd profile.
% [minCSDRow,minCSDRowIdx] = min(csds(:,2:end),[],1);
% [minCSD,minCSDColumnIdx] = min(minCSDRow,[],2);
% sinkChanIdx = round(pos(minCSDColumnIdx)/spacing) +1 ;                 %chan index from top to bottom
% sinkTimeIdx = minCSDRowIdx(minCSDColumnIdx);
% 
% ncol = round(sqrt(length(channel)))+2;
% nrow = ceil(length(channel)/ncol);
% scrsz = get(0,'ScreenSize');
% 
% hfig1 = PlotCSD(csds);
% %hfig1 = PlotCSD(csds,'lfp',lfps);
% figure(hfig1); hold on;
% f_folder = fileparts(lfpFile);
% fdate = f_folder(end-19:end-9);
% 
% %for oct-11, half of the 32channels used. find the depth index by channel
% %id.
% depthIdx = find(cmap(:,3)==channel(recChanID(sinkChanIdx))); %depth index counted from the deepest.
% %
% plot(tCSD(sinkTimeIdx)*1e3,(length(channel)-sinkChanIdx+1)*1-1,'w+');
% 
% probeDepth = (depthIdx-1)*spacing + 400; %depth of the deepest channel.
% % title(sprintf('sink chan index=%d, t %.1f ms',size(csds,2)-sinkChanIdx, tCSD(sinkTimeIdx)*1000));
% title(sprintf('%s,sink=%d,t=%.1f ms,probe=%d',fdate,sinkChanIdx, tCSD(sinkTimeIdx)*1000,probeDepth)); %index from the tip channel
% 
% %
% savFolder = fullfile(f_folder,subfolder);
% if ~exist(savFolder,'dir'); mkdir(savFolder); end
% 
% %save csd plot
% savePlotAsPic(hfig1,fullfile(savFolder,['CSD',cTag,'.png']));
% %save the csd to mat file
% save(fullfile(f_folder,['CSD',cTag,'.mat']),'csd','csds');
% 
% %
% hfig2 = figure('name','ERP'); hold on;
% set(hfig2,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])
% 
% dy = 0 ;
% 
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
% %      
% % for i = 1 : length(channel)
% %     %subplot(nrow,ncol,i);
% %     ii = recChanID(i);    
% %     linecolor = 'k'; 
% %     %if i == 1; linecolor = 'y'; end
% %     if ii == length(channel)-depthIdx+1 ; linecolor = 'b'; end
% %     
% %     plot(tCSD,avgLFP(i,:)-dy,linecolor);
% %         
% %     if ii == length(channel)-depthIdx+1 ; 
% %         plot(tCSD(sinkTimeIdx),avgLFP(i,sinkTimeIdx)-dy,'r+');
% %     end
% %     
% %     if i > 1
% %         dy = dy - max(avgLFP(i,:)-avgLFP(i-1,:)); 
% %     end
% %     
% % end
% 
% legend(sprintf('%d)Ch%d',1,channel(recChanID(1)))); %first channel plotted.
% %
% savePlotAsPic(hfig2,fullfile(savFolder,['ERP',cTag,'.png']));
% 
% hfig3 = figure('name','PSTH');
% set(hfig3,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])
% 
% for i = 1 : length(channel)
%     subplot(nrow,ncol,i);
%     ii = recChanID(i);
%     errorbar(tPETH,sPETH(i,:),ePETH(i,:),'k');
%     title(sprintf('ch%d',channel(ii)));
%     if i == 1; 
%         xlabel('Time(s)'); 
%         ylabel('Firing rate (hz)');
%         title(sprintf('PSTH ch%d',channel(ii)));
%     end
%     xlim([tPETH(1) tPETH(end)]);
% end
% 
% %
% savePlotAsPic(hfig3,fullfile(savFolder,['PSTH',cTag,'.png']));

% %plot LFPs on one figure
% hfig4 = figure('name','ERP in depth');
% set(hfig4,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200]);
% hold on;
% %maxV = max(max(abs(lfps(:,2:end))));
% for i = 1 : length(channel)
%     %subplot(nrow,ncol,i);
%     %ii = recChanID(i);
%     linecolor = 'k'; 
%     %if i == 1; linecolor = 'y'; end
%     if i == length(channel)-depthIdx+1 ; linecolor = 'b'; end
%     yy = lfps(:,i+1);
%     %yy = (yy - mean(yy))/(2*max(abs(yy))) ;
%     yy = (yy-yy(1)) + 0;  %overlay 
%     plot(lfps(:,1),yy,linecolor); %deepest at bottom
%     if i == length(channel)-depthIdx+1 ; 
%         plot(lfps(sinkTimeIdx,1),yy(sinkTimeIdx),'r+');
%     end
% end
% 
% xlim([lfps(1,1),lfps(end,1)]);
% %ylim([-1 length(channel)+2]);
% ylim auto;
% xlabel('Time(s)');
% ylabel('LFP');
% title(sprintf('%s,ERP in depth',fdate));
% 
% %
% savePlotAsPic(hfig4,fullfile(savFolder,['ERPinDepth',cTag,'.png']));
% 
% if strcmp(opt,'close')
%     close(hfig1);
%     close(hfig2);
%     close(hfig3);
%     close(hfig4);
% end
