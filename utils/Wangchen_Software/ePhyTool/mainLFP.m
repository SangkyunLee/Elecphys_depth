%main script to analyze the multi-channel ephy data 
%
%% Configuration
%-----------------------------------------------------------------
% lastSession = getEPhyToolLastSession;
% %seperator chars
% hlfgs = char(ones(1,80,'uint8')*uint8('-'));
% %initialize params
% folder = struct(...
%     'base',[],'subject',[],'exp',[],'date',[],'time',[]...
%     );
% folder(1:3)=struct(folder);
% %default is full loading
% opt = struct(...
%     'fileindex',[],'datatype',[],'nevvar',[]);
% opt.fileindex = 1; % load file
% % opt.nevvar = {'neurons','events'}; %load spikes and stim-event markers
% opt.nevvar = {'events'}; %load spikes and stim-event markers
% opt.datatype = {'mat','nev'};
% %---------------------------------------------------------------
% %
% try close(h_dataLocator); end %close last open window.
% if isempty(getappdata(0,'dataLocator_folder'))
%     folder = parseFolder({lastSession.matFolder,lastSession.matFolder,lastSession.nevFolder});
% end
% h_dataLocator = dataLocator;
% %enable the execuation button
% set(findobj(h_dataLocator,'Tag','pushbutton_OK'),'Enable','on');
% while true
%     pause(0.1)
%     if ~isempty(getappdata(0,'dataLocator_result'))
%         break;
%     end
%     if ~ishandle(h_dataLocator); break; end %if cancel was clicked and fig closed
% end
% ret = getappdata(0,'dataLocator_result');
% if ~isempty(ret) %if not cancled or it will continue with mannual setting
%     folder = ret.folder;
%     opt.fileindex = eval(ret.fileindex);
% else 
%     return
% end

%% read the data 
% load 'neurons' for spikes and 'events' for stim-event-timestamps
fprintf('Loading data files ....\n');
%skip loading the data  and extract the path only.
i = 3;
s.nsxFolder = fullfile(folder(i).base,folder(i).subject,folder(i).exp,folder(i).date,folder(i).time,folder(i).etc);   
nsx_files = dir(fullfile(s.nsxFolder,'*.ns5'));
s.nsxFile = nsx_files(1).name; 

% s = matLoader(folder,opt);
% opt.fileindex = 0; %load session data.
% ss = matLoader(folder,opt);

%==========================================================================
% generate lfp from raw data with user-defined butterworth low-pass filter.
rawFile = fullfile(s(1).nsxFolder,s(1).nsxFile);

%rawFile = strrep(nevFile,'.nev','.ns5');
h = openNSx(rawFile); %read the file header
chunkSize = 500;  %max chunk size to read the continuous data (in MB)
%data points to read in each chunk. by default the continuous data is read as 'int16'. 
readDataPoints = (chunkSize*1e6)/2; 
nChunk = ceil(h.MetaTags.DataPoints/readDataPoints);
%create low-pass butterworth filter.
f_cutoff = 250;
f_type = 'low';
f_sample = 30000;
downsamples = 6; 
f_sample = f_sample/downsamples ; %get a decimated version at 5k sample rate
f_order = 4;
%resample freq for lfp
lfp_fs = 1000;
%skip factor
skip_factor = f_sample/lfp_fs;
%butterworth digital fitler
[ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);
% [ft1_b,ft1_a]=butter(f_order,f_cutoff/(f_sample/2),'high');
%read neural channel only, i.e, no analog channel
nNeuralChan = length(find(h.MetaTags.ChannelID<=128));
iNeuralChan = 0;
%
param.cutoffFreq = f_cutoff;
param.samplingRate = lfp_fs; 

%flag to read the entile file.
f_readFile = true;
%
sel_Chunks = [round(nChunk/2)-1 : round(nChunk/2)+1 ];
%read the selected chunks in continuity.
if f_readFile
    readChunks = [1 : nChunk];
else
    readChunks = sel_Chunks;
end

for i = 1 : h.MetaTags.ChannelCount
    chID = h.MetaTags.ChannelID(i);
    if chID > 128; continue; end;
    x = [];
    fprintf('%d: read data in ch%d ...\n',i,chID); 
    for j = 1 : nChunk
        if ~any(j==readChunks); continue; end
        p = [1,readDataPoints]+(j-1)*readDataPoints;
        if p(1) > h.MetaTags.DataPoints ; break; end
        if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
         h1 = openNSx(rawFile,'read','channels',chID,'duration',p,'skipfactor',downsamples); %read individual channels.
         %pass through the filter         
         disp('LP filtering...');
         fx = filtfilt(ft_b,ft_a,double(h1.Data));
         %resample the filtered data
         fxr = fx(1:skip_factor:end);
         clear fx;
         x = [x fxr]; %low pass lfp
    end
    clear fxr;
    clear h1;
    iNeuralChan = iNeuralChan + 1;
    %
    if iNeuralChan == 1; h.Data = zeros(nNeuralChan,length(x)); end
    h.Data(iNeuralChan,:) = x;
end

%save the file with lfp data 
lfpFile = strrep(rawFile,'.ns5','_LFP.mat');
save(lfpFile,'h','param');

