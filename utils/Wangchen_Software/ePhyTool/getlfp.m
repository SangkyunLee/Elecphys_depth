function LFP = getlfp(nsxFile,opt)
%resample the raw data and filter the downsampled data for lfp signal.
%nsxFile :  .ns5 raw data file
%split   :  option to save lfp data per channel.

if nargin < 2
    opt.electrode = 'standard'; %'standard','edge','tetrode';
    opt.split = false; %default to save as one single file (mice neuronexus data) 
end
%split = false; %option to split the data per channel (true) or in a single file (false)  
SamplingFreq = 30000; %raw data sample freq 
h = openNSx(nsxFile); %read the file header
assert(h.MetaTags.SamplingFreq == SamplingFreq, 'only process raw data sampled at 30k');

lfp_fs = 1000;      %lfp sample freq
%downsampleFactor = 6; % the skip factor in reading raw data
downsampleFactor = SamplingFreq / lfp_fs ; % the skip factor in reading raw data
dsp_fs = SamplingFreq / downsampleFactor ; % get a decimated version at ?k sample rate for lfp 

%-------------------------------------------------
%lfp filter params
flt_type   = 'low';
flt_cutoff = 250  ; 
flt_order  = 4    ;

%butterworth digital fitler
[ft_b,ft_a]= butter(flt_order,flt_cutoff/(dsp_fs/2),flt_type);

%
param.samplingFreq = lfp_fs;
param.filterType = flt_type;
param.filterCutoffFreq = flt_cutoff; 
param.filterOrder = flt_order;
%-------------------------------------------------

%--------------------------------------------------
%read the raw data
chunkSize = 500;  %max chunk size to read the continuous data (in MB)
readDataPoints = (chunkSize*1e6)/2; %data points to read in each chunk. by default the continuous data is read as 'int16'. 
nChunk = ceil(h.MetaTags.DataPoints/readDataPoints);

dspDataSize = round( h.MetaTags.DataPoints * ( dsp_fs / SamplingFreq )); %downsample data size
lfpDataSize = round( h.MetaTags.DataPoints * ( lfp_fs / SamplingFreq )); %lfp data size

%downsample the downsampled & filtered data for lfp  
downsampleFactor2 = round(dsp_fs / lfp_fs);

%read neural channel only, i.e, no analog channel
nNeuralChan = length(find(h.MetaTags.ChannelID<=128));
iNeuralChan = 0;

LFP.param = param;
LFP.param.channel = [];
LFP.param.tetrode = [];

for i = 1 : h.MetaTags.ChannelCount
    chID = h.MetaTags.ChannelID(i);
    if chID > 128; continue; end;
    fprintf('%d: read data in ch%d ...\n',i,chID); 
    %lfpData = zeros(1,lfpDataSize);
    dspData = zeros(1,dspDataSize);
    %
    npts = 0; 
    for j = 1 : nChunk
        p = [1,readDataPoints]+(j-1)*readDataPoints;
        if p(1) > h.MetaTags.DataPoints ; break; end
        if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
         h1 = openNSx(nsxFile,'read','channels',chID,'duration',p,'skipfactor',downsampleFactor); %read individual channels.
         dspData(npts+1 : npts+numel(h1.Data)) = h1.Data;
         npts = npts + numel(h1.Data);
    end
    
    %rounding off difference 
    if npts ~= dspDataSize
        dspData(npts+1 : end) = []; 
    end
    
    clear h1; %release memory
    %
    iNeuralChan = iNeuralChan + 1;
    %
    lfpData = filtfilt(ft_b,ft_a,double(dspData));
    %
    clear dspData; %release memory
    
    %notch filter to remove 60hz
    lfpData = linenotch(lfpData,lfp_fs,4);
    
    %
    lfpData = lfpData(1 : downsampleFactor2 : end);
    
    if iNeuralChan == 1 
        LFP.data = zeros(nNeuralChan, numel(lfpData));
    end
    %filter
    LFP.data(iNeuralChan,:) = lfpData;
    %
    LFP.param.channel = [LFP.param.channel chID];
    %
    clear lfpData;
end

%tetrode
cmap = getChannelMapping(opt.electrode);

%
switch opt.electrode
    case {'standard','edge'}
        save(fullfile(fileparts(nsxFile),'LFP.mat'),'LFP'); %mice data
    case 'tetrode'
        L = LFP;
        clear LFP;
        for i = 1 : size(cmap,1)/4 %
            chans = cmap(1+(i-1)*4 : i*4,3);
            LFP.param = L.param;
            LFP.param.channel = chans; %channels per tetrode
            idx = [];
            for j = 1 : 4
                idx = [idx find(L.param.channel == chans(j))];
            end
            if isempty(idx); continue; end
            if opt.split
                LFP.data = L.data(idx,:);
            else
                LFP.data = mean(L.data(idx,:),1); %average over channels.
            end
            LFP.param.tetrode = i;
            save(fullfile(fileparts(nsxFile),sprintf('lfp_tt%d.mat',i)),'LFP'); %monkey data
        end
        
end


% 
% if ~opt.split
%     
% else
%     LFP1 = LFP; %save a copy
%     clear LFP; 
%     for i = 1 : length(LFP1.param.channel)
%         LFP.param = LFP1.param;
%         LFP.param.channel = LFP1.param.channel(i);
%         LFP.data  = LFP1.data(i,:);
%         save(fullfile(fileparts(nsxFile),sprintf('lfp%d.mat',LFP.param.channel)),'LFP'); %monkey data
%     end
%     %
%     LFP = LFP1; %
% end
% 
