function rspikedata(rootdir)
%calculate csd from lfp files in root directory
%
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,'**\*.ns5'));
%
for i = 1 : length(d)
    nsxFile = d(i).name;
    %dnev = dir(fullfile(fileparts(lfpFile),'*.nev'));
    %nevFile = fullfile(fileparts(lfpFile),dnev.name);
    
    fprintf('[%d]/%d : %s ... \n',i,length(d),fileparts(nsxFile));
    
    try
        getSpikeData(nsxFile);
    catch
        fprintf('error on %d|%d: %s, continue\n',i,length(d),nsxFile);
        lasterr
        
    end
end

function getSpikeData(nsxFile)
%

threshold = -3;

subfolder = sprintf('sigma%d',abs(threshold));

spikeFile = fullfile(fileparts(nsxFile),subfolder,'Spikes.mat'); 

%
if exist(spikeFile,'file')
    disp('spikes file existed. skip');
    return
end

h = openNSx(nsxFile); %header

%read the raw data
chunkSize = 500;  %max chunk size to read the continuous data (in MB)
readDataPoints = (chunkSize*1e6)/2; %data points to read in each chunk. by default the continuous data is read as 'int16'. 
nChunk = ceil(h.MetaTags.DataPoints/readDataPoints);
nChan = numel(find(h.MetaTags.ChannelID <= 128));

Spikes.Channel    = zeros(1,nChan);
Spikes.Timestamp  = cell(1,nChan);
Spikes.Waveform   = cell(1,nChan);

iChan = 0; 
for i = 1 : h.MetaTags.ChannelCount
     chID = h.MetaTags.ChannelID(i);
     if chID > 128; continue; end;
     fprintf('%d: read data in ch%d ...\n',i,chID); 
     
     npts = 0;
     iChan = iChan + 1 ;
     Spikes.Channel(iChan)   = chID;
     Spikes.Timestamp{iChan} = [];
     Spikes.Waveform{iChan}  = [];
     
     for j = 1 : nChunk
        p = [1,readDataPoints]+(j-1)*readDataPoints;
        if p(1) > h.MetaTags.DataPoints ; break; end
        if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
         hd = openNSx(nsxFile,'read','channels',chID,'duration',p); %read individual channels.
         [t,w] = spikeDetection(hd.Data',h.MetaTags.SamplingFreq, threshold);
         npts = npts + numel(hd.Data);
         %
         Spikes.Timestamp{iChan} = cat(2,Spikes.Timestamp{iChan},t');
         Spikes.Waveform{iChan}  = cat(2,Spikes.Waveform{iChan},w');
         
     end
     
     %
     clear hd;
     
end

if ~exist(fileparts(spikeFile),'dir'); mkdir(fileparts(spikeFile)); end
save(spikeFile,'Spikes','-v7.3');






