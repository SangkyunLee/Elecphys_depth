d_raw = 'g:\Work\Data\CerebusData\last_sorted\mice\NormLuminance\'; %the root directory of raw data
d_mat = 'g:\Work\StimulationData\mice\NormLuminance\'; %the root directory of stimulus data
sdn = 'sort';     %subdirectory to search for raw data files.
%raw data filename struct
s_raw = struct('filename',[],...
           'base',[],...
           'subject',[],...
           'exp',[],...
           'date',[],...
           'time',[],...
           'etc',[]);
%struct for all the stimulus file.
sa_mat = s_raw;
%struct for stimulus files matching the raw data files.
s_mat = s_raw;
       
%find the raw data files
d = rdir(fullfile(d_raw,'**\*.nev'));
%struct of raw data file name
dd = rdir(fullfile(d_mat,'**\*.mat'));

nSelectFiles = 0;
for i = 1 : length(d)
    %datafile = d(i).name;
    %fdir = fileparts(datafile);
    a = parseExperimentName(d(i).name);
    if ~isempty(regexp(a.filename,'-[0-9]{2}.nev'));
        disp('skip');
        continue; %skip the sorted files that are renamed but not saved under subfolder
    end
    if strcmp(a.etc,sdn)
        nSelectFiles = nSelectFiles + 1;
        s_raw(nSelectFiles) = a;
    end
end

for i = 1 : length(dd)
    sa_mat(i) = parseExperimentName(dd(i).name);
end

for i = 1 : length(s_raw)
 for j = 1 : length(dd)
     %search for the trial file 000x.mat. some session are interputed and
     %dont have the trial file.
     if isempty(regexp(sa_mat(j).filename,'[0-9]{4}.mat'))
         continue;
     end
     if checkExperimentName(s_raw(i),sa_mat(j))
         s_mat(i) = sa_mat(j);
         break;
     end
 end
end

fullFile = ones(1,length(s_raw));
%remove the entry for aborted experiment.
for i = 1 : length(s_mat)
    if isempty(s_mat(i).filename) %no trial file
        fullFile(i) = 0;
    end
end

s_raw(~fullFile) = [];
s_mat(~fullFile) = [];

%script to load neural data into workspace. (both trial and neuron structs) 
%
%seperator chars
hlfgs = char(ones(1,80,'uint8')*uint8('-'));
%default is full loading
opt = struct(...
    'fileindex',[],'datatype',[],'nevvar',[]);
opt.fileindex = 1; % load the first file by default
opt.nevvar = {'neurons','events'}; %load spikes and stim-event markers
opt.datatype = {'mat','nex','nev'};
%---------------------------------------------------------------

% %initialize folder
% folder(1) = (s_mat(1));
% folder(2) = folder(1);
% folder(3) = folder(1);

%
%23/40/41 : unequal photodiode events--2012-Jul-02\18-34-01 : aborted
%experiment
%27/28/29/37/38/39 : params missing in mat file. 2012-Jul-04\06-28-18 :
%no recording. missing trial file 000x.mat. 
%45/46/47/48/51/52/84/85 : firingrate computation error
%70 : []
%
%goodlist = [3 7 41 42 43];

%chanList = [2 11 37];
for iFile = 1:length(s_mat)
%     if ~any(goodlist == iFile); continue; end 
%     chan2 = chanList{find(goodlist==iFile)};
%     if ~any([7]==iFile) ; continue; end
    %if ~any([8 18 7 14]==iFile) ; continue; end
    
    clear folder;
    folder(1) = s_mat(iFile);
    folder(2) = s_mat(iFile);
    folder(3) = s_raw(iFile);
    folder = rmfield(folder,'filename');
    %==================================
    %scripts to process data
    fprintf('process folder %d : \n',iFile);
    %
%     cmap = getChannelMapFile(s_raw(iFile).filename,'part'); %or use global variable.
%     %channel indices sorted by depth.
%     %chan2 = [];
%     if isempty(cmap); continue; end
    %
   
    
    try
        loadData; %
        %temp setting, group the single units into one for MUA.
        neurons_cp = neurons; %save a copy of original data.
        neurons = SU2MU(neurons); %merge single unit fields for MUA.
        
        chan2 = cmap(:,end)'; %cmap is loaded in loadData.
        mainRate2; plotRateFigs(chan2,neurons,s,t_SETS);
        %close all;
        %mainSTA_normLuminance; plotSTAFigs(chan2,neurons,s,t_SETS);
        %close all;
        
        %plotPPDFigs(chan2,neurons,s,t_SETS,StimImage);
        %plotResponseFigures(chan2,neurons,s,t_SETS,StimImage);
        close all;
    catch
        fprintf('Error on %d: %s\n', iFile,folder(1).date);
        %lasterror;
    end


end


