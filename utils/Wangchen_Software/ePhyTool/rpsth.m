function rpsth(rootdir)
%search the 'target' files to locate the data subfolders.

%
targetFile = 'Spikes.mat';
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));
%
for i = 1 : length(d)
    fileName = d(i).name;    
    fprintf('[%d]/%d : %s ... \n',i,length(d),fileparts(fileName));
    
    try
        getPSTH(fileName);
    catch
        fprintf('error on %d|%d: %s, continue\n',i,length(d),fileName);
        lasterr
        
    end
    
    close all;
    
end


function getPSTH(fileName)

plotType = 'line'; %default : '' 

load(fileName); %load Spikes

channel = Spikes.Channel;
for i = 1 : length(channel)
    ts{i} = Spikes.Timestamp{i}/1000; %in sec
end

%
fdir = fileparts(fileparts(fileName)); %strip off the subfolder
%find the nev file
d = rdir(fullfile(fdir,'*.nev')); %
if length(d) > 1
    disp('multiple nev files found');
end
nevFile = d(1).name;

%
%get spike event time
NEV  = openNEV(nevFile,'read','nowave','nowrite');

%stimulus onsets
eventTime = getDigEvents(NEV);

[cmap,spacing] = getChannelMapFile(nevFile,'part'); %or use global variable.
if isempty(cmap); disp('no cmap'); return; end

%peri-stimulus histogram
tbin = 0.5; 
tPETH = 0 : tbin : 2-tbin;
sPETH = zeros(length(channel),size(tPETH,2));
ePETH = sPETH;

for i = 1 : length(channel)
    [sPETH(i,:),ePETH(i,:)] = peth(ts{i},eventTime,tPETH);
end
%change to rates
sPETH = sPETH/tbin;
ePETH = ePETH/tbin;

ncol = round(sqrt(length(channel)))+2;
nrow = ceil(length(channel)/ncol);
scrsz = get(0,'ScreenSize');

hfig3 = figure('name','PSTH');
set(hfig3,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])

depthID = zeros(size(channel));

for i = 1 : length(channel)
    depthID(i) = size(cmap,1)- find(cmap(:,3)==channel(i)) + 1; %count from toppest channel
end

for i = 1 : length(channel)
    %subplot(nrow,ncol,i);
    subplot(nrow,ncol,depthID(i));
    if strcmp(plotType,'bar')
        barwitherr(ePETH(i,:),sPETH(i,:));
        %set(gca,'XTickLabel',{'0','0.5','1','1.5'});
    else
        %ii = recChanID(i);
        errorbar(tPETH,sPETH(i,:),ePETH(i,:),'k');
         xlim([tPETH(1) tPETH(end)+tbin]);
    end
    title(sprintf('ch%d',channel(i)));
    if depthID(i) == 1; 
        xlabel('Time(s)'); 
        ylabel('Firing rate (hz)');
        title(sprintf('PSTH ch%d',channel(i)));
    end
   
end

%
savePlotAsPic(hfig3,fullfile(fileparts(fileName),['PSTH',plotType,'_',num2str(tbin),'.png']));

return;
%if strcmp(plotType,'bar'); return; end

hfig4 = figure('name','Waveform');
set(hfig4,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])

for i = 1 : length(channel)
    %subplot(nrow,ncol,i);
    subplot(nrow,ncol,depthID(i));
    %ii = recChanID(i);
    hold on;
    nspk = size(Spikes.Waveform{i},1);
    if nspk > 200 ;
        spks = 1 : round(nspk/200) : nspk ; %plot a fraction of spikes
    else
        spks = 1 : nspk;
    end
    
    %
    plot(transpose(Spikes.Waveform{i}(spks,:)),'k');
%     
%     for j = 1 : size(Spikes.Waveform{i},1)
%         plot( (0:(length(Spikes.Waveform{i}(j,:))-1))/30, Spikes.Waveform{i}(j,:),'k');
%     end
    
    title(sprintf('ch%d',channel(i)));
    if depthID(i) == 1; 
        xlabel('Time(ms)'); 
        ylabel('Voltage');
        title(sprintf(' ch%d',channel(i)));
    end
end

%
savePlotAsPic(hfig4,fullfile(fileparts(fileName),['Waveform','.png']));

