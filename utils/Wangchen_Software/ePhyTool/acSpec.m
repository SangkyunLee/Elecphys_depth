function acSpec(fn)
%format of export file from plexon offline sorter v2. 
%Sorted data is exported as Per-waveform for all channels.  
%chan_data(n,m) --- n : number of waveforms in the channel
%               --- m : number of information entry for each waveform.
% %waveform info table --- 18 entries
% Channel
% Unit
% Timestamp
% PC1
% PC2
% PC3
% ChannelName(Raw)
% Slice1
% Slice2
% Peak
% Valley
% Peak-Valley
% Energy
% Nonlinear Enery
% Peak FWHM
% Valley FWHM
% ISI(Previous)
% ISI(Next)

%
Export_Entry = {...
    'Channel','Unit','Timestamp','PC1','PC2','PC3',...
    'Peak','Valley','Peak_Valley',...
    'Peak_FWHM', 'Valley_FWHM' ...
     };

Index = struct;
for i = 1 : length(Export_Entry)
    Index.(Export_Entry{i}) = i;
end

%get files info for the last session
lastSession = getEPhyToolLastSession;

%
if nargin < 1
    waveFileFullPath = [];
else
    waveFileFullPath = fn;
end

%bring up ui if data file not set above.
if isempty(waveFileFullPath)
    [fileName pathName] = uigetfile(fullfile(lastSession.waveFolder,lastSession.waveFile),'Choose Waveform Data File(*.mat)...');
    waveFileFullPath = [pathName fileName];
    if waveFileFullPath==0; 
        %clear variables; 
        disp('No file was selected.');
        return
    end
else
    [pathName fileName] = fileparts(waveFileFullPath);
end

%save the file into last sesssion
lastSession.waveFile = fileName;
lastSession.waveFolder = pathName;
%
setEPhyToolLastSession(lastSession);
%

%load the wave file
d = open(waveFileFullPath);
%
nChan = 32;
%plot the peak-valley vs valley distribution for the beginning and end of
%recording. 
%the percentage of spikes for the plot
percent = 10;
%
nRow = 4;
nCol = 8;
%show all the units (TRUE) or the first sorted unit (FALSE) 
showAllUnit = true;

figure('name','Peak-Valley vs Valley Distribution');
%
% title('Spikes near-Start and near-End');

%channel names
chNames = fieldnames(d);
for i = 1 : nChan
    subplot(nRow,nCol,i);
    ch = d.(chNames{i});
    nSpikes = size(ch,1);
    if nSpikes < 1
        continue;
    end
    nSpikesToShow = floor(nSpikes * percent /100);
    nSpikesToShow = max(1,nSpikesToShow);
    nSpikesToShow = min(5000,nSpikesToShow);
    if showAllUnit
        sortUnit = find(ch(:,Index.Unit)>=0);
    else
        sortUnit = find(ch(:,Index.Unit)==1);
    end
    %for sparse units, display the first half vs second half.
    nSpikesToShow = min(floor(length(sortUnit)/2),nSpikesToShow);
    %showSpikeIndices = sortUnit(1:nSpikesToShow);
    plot(ch(sortUnit(1:nSpikesToShow),Index.Valley), ch(sortUnit(1:nSpikesToShow),Index.Peak_Valley),'b.');
    hold on;
    plot(ch(sortUnit(end-nSpikesToShow+1 : end),Index.Valley), ch(sortUnit(end-nSpikesToShow+1 : end),Index.Peak_Valley),'r.');
    title(chNames{i});
end

figure('name','Peak-Valley vs Time');
%
%title('Spiking Stability near-Start and near-End');

%channel names
chNames = fieldnames(d);
for i = 1 : nChan
    subplot(nRow,nCol,i);
    ch = d.(chNames{i});
    nSpikes = size(ch,1);
    if nSpikes < 1
        continue;
    end
    nSpikesToShow = floor(nSpikes * percent /100);
    nSpikesToShow = max(1,nSpikesToShow);
    nSpikesToShow = min(5000,nSpikesToShow);
    if showAllUnit
        sortUnit = find(ch(:,Index.Unit)>=0);
    else
        sortUnit = find(ch(:,Index.Unit)==1);
    end
    %for sparse units, display the first half vs second half.
    nSpikesToShow = min(floor(length(sortUnit)/2),nSpikesToShow);
    %showSpikeIndices = sortUnit(1:nSpikesToShow);
    plot(ch(sortUnit(1:nSpikesToShow),Index.Timestamp), ch(sortUnit(1:nSpikesToShow),Index.Peak_Valley),'b.');
    hold on;
    plot(ch(sortUnit(end-nSpikesToShow+1 : end),Index.Timestamp), ch(sortUnit(end-nSpikesToShow+1 : end),Index.Peak_Valley),'r.');
    title(chNames{i});
end

return;

T0 = Inf;
T1 = 0;

for i = 1 : nChan
    ch = d.(chNames{i});
    if size(ch,1) < 1
        continue;
    end
    T0 = min(ch(1,Index.Timestamp),T0);
    T1 = max(ch(end,Index.Timestamp),T1);
end

%sample a portion of data for correlation computation
sampPortion = 0.5; %
T1 = T0 + (T1-T0) * 0.5;

binSize = 1e-3; % 1ms bin size for correlation computation.
%
xtime = T0:binSize:T1;
%
maxLag = 10*1e-3/binSize; %10ms lag for output.
%
maxLag = round(maxLag);
XYCORR = zeros(nChan,nChan,2*maxLag+1);
%spike rate
sr = zeros(nChan,length(xtime));
for i = 1 : nChan
    ch = d.(chNames{i});
    x = ch(:,Index.Timestamp);
    if size(ch,1) == 0 ;  continue;  end
    sr(i,:) = hist(x,xtime);
end

sr(:,end)=0;

addpath('.\Archieve\TimeSeries');
%compute auto/cross correlogram
for i = 1 : nChan
    ch1 = d.(chNames{i});
    if size(ch1,1) == 0 ;  continue;  end
    %st1 = ch1(:,Index.Timestamp);
    %st1 = hist(st1,xtime);
    st1 = sr(i,:);
    for j = 1 : nChan
        ch2 = d.(chNames{j});
        %
        if size(ch2,1)==0; continue; end
        %st2 = ch2(:,Index.Timestamp);
        %st2 = hist(st2,xtime);
        st2 = sr(j,:);
        if j <= i
            [C,lags] = xcorr(st1,st2,maxLag);
            XYCORR(i,j,:) = C;
        end
    end
end

%fill the bottom space in correlation matrix with the upper elements
for i = 1 : nChan
    for j = 1 : nChan
        if j <= i
            %
        else
            XYCORR(i,j,:) = XYCORR(j,i,:); %by symmetry
        end
    end
end

clear st1 st2;

figure('Name','Correlation(Channels vs Lag)');

for i = 1 : nChan
    %for j = 1 : nChan
        %k = j + (i-1)*nChan; 
        subplot(nRow,nCol,i);
        pcolor([-maxLag:maxLag],1:nChan,squeeze(XYCORR(i,:,:)));
        shading interp;
        title(sprintf('Ch%d',i));
        
end

%plot the correlogram beteween channels for selected lag
%t = 0;
nLag = maxLag + 1;  %t = 0;
A = squeeze(XYCORR(:,:,nLag));
%
figure('Name','Correlation(Channel vs Channel)');
pcolor(1:nChan, 1: nChan, A); axis image;

%normalize by the auto-correlation and zero the auto-correlation 
for i = 1 : size(A,1)
    if A(i,i)~=0
        %A(i,:) = A(i,:)/A(i,i);
        A(i,i) = 0;
    end
end

figure('Name','Correlation(Channel vs Channel)');
pcolor(1:nChan, 1: nChan, A); axis image;


            



        
        
        
        




