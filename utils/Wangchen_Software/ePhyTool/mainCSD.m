%main script to analyze the multi-channel ephy data 
%
% % %% Configuration
% % %-----------------------------------------------------------------
% % %find the OS type
% % OS=getenv('OS');
% % if strfind(OS,'XP')
% %     pathstr = 'C:\Documents and Settings';
% % else %win7
% %     pathstr = 'C:\Users\';
% % end
% % %select channel map file -- linear probe of single electrode or plannar array of tetrodes.     
% % % cmapFilePath = fullfile(pathstr,getenv('USERNAME'),'My Documents');
% % % cmapFilePath = 'c:\work\Experiment\Latest\New\ePhyTool';
% % cmapFilePath = fileparts(mfilename);
% % %cmapFileName = 'Tetrode_96ch_Map_New.cmp';
% % cmapFileName = '32ch double-headstage map.CMP';
% % %convert to 5-column format for NPMK cmap class function.
% % % cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
% % cmapFile  = fullfile(cmapFilePath,cmapFileName);
% % %
% % global cmap
% % cmap = readCerebusMap(cmapFile);
% % %get files info for the last session
% % lastSession = getEPhyToolLastSession;
% % %seperator chars
% % hlfgs = char(ones(1,80,'uint8')*uint8('-'));
% % %initialize params
% % folder = struct(...
% %     'base',[],'subject',[],'exp',[],'date',[],'time',[]...
% %     );
% % folder(1:3)=struct(folder);
% % %default is full loading
% % opt = struct(...
% %     'fileindex',[],'datatype',[],'nevvar',[]);
% % opt.fileindex = 1; % load file
% % % opt.nevvar = {'neurons','events'}; %load spikes and stim-event markers
% % opt.nevvar = {'events'}; %load spikes and stim-event markers
% % opt.datatype = {'mat','nev'};
% % %---------------------------------------------------------------
% % %
% % try close(h_dataLocator); end %close last open window.
% % if isempty(getappdata(0,'dataLocator_folder'))
% %     folder = parseFolder({lastSession.matFolder,lastSession.matFolder,lastSession.nevFolder});
% % end
% % h_dataLocator = dataLocator;
% % %enable the execuation button
% % set(findobj(h_dataLocator,'Tag','pushbutton_OK'),'Enable','on');
% % while true
% %     pause(0.1)
% %     if ~isempty(getappdata(0,'dataLocator_result'))
% %         break;
% %     end
% %     if ~ishandle(h_dataLocator); break; end %if cancel was clicked and fig closed
% % end
% % ret = getappdata(0,'dataLocator_result');
% % if ~isempty(ret) %if not cancled or it will continue with mannual setting
% %     folder = ret.folder;
% %     opt.fileindex = eval(ret.fileindex);
% % else 
% %     return
% % end

%% read the data 
% load 'neurons' for spikes and 'events' for stim-event-timestamps
fprintf('Loading data files ....\n');
%skip loading the data  and extract the path only.
i = 3;
s.nsxFolder = fullfile(folder(i).base,folder(i).subject,folder(i).exp,folder(i).date,folder(i).time,folder(i).etc);   
nsx_files = dir(fullfile(s.nsxFolder,'*.ns5'));
s.nsxFile = nsx_files(1).name; 

%==========================================================================
% generate lfp from raw data with user-defined butterworth low-pass filter.
rawFile = fullfile(s(1).nsxFolder,s(1).nsxFile);
%
lfpFile = strrep(rawFile,'.ns5','_LFP.mat');
%
load(lfpFile); 
%construct lfp matrix for csd compuation.
f_lfp = param.samplingRate; %the resample frequency for lfp
%time points to read
nPtsToRead = 100*f_lfp; 
%time point to start for reading
startPts = 270*f_lfp; 
lfp = h.Data(:,startPts:startPts+nPtsToRead); %(channels,timepoints)
%clear the data to save space
h.Data = [];

%arrange the channels by depth
%1.check the presentence and continuity of channels.
%recChanInd = find(h.MetaTags.ChannelID,cmap(:,3));
%recChanID = [];
for i = 1 : length(h.MetaTags.ChannelID)
    chID = h.MetaTags.ChannelID(i);
    if chID > 128 ; continue; end
    k = find(chID==cmap(:,3));
    recMapID(i) = k;
end
%recorded channels.
nChan = length(recMapID);
[sortMapID,sortIndices]=sort(recMapID);
if ~all(diff(sortMapID)==1)
    %
    error('channels are not recorded in continuous order !');
end

lfp = lfp(sortIndices,:);
lfp = lfp(end:-1:1,:);   %reverse the order so that the deepest chan '11' is plotted at the bottom of graph by 'plotcsd'

t = [0 : size(lfp,2)-1]/f_lfp; 
lfp = [t ; lfp];
lfp = lfp';
csd = CSD(lfp);
figure('Name','CSD'); PlotCSD(csd,'lfp',lfp);xlabel('Time(s)'); ylabel('CSD');

%save the csd to mat file
csdFile = strrep(lfpFile,'_LFP.mat','_CSD.mat');
save(csdFile,'csd','lfp');


