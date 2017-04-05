d_raw = 'h:\Work\Data\CerebusData\mice\FlashingBar\'; %the root directory of raw data
d_mat = 'h:\Work\Data\StimulationData\mice\FlashingBar\'; %the root directory of stimulus data
%d_raw = 'h:\Work\Data\CerebusData\mice\FlashingBar\2012-Jul-24\';
%d_mat = 'h:\Work\Data\StimulationData\mice\FlashingBar\2012-Jul-24\';

sdn = '';     %subdirectory to search for raw data files.
% % %raw data filename struct
% % s_raw = struct('filename',[],...
% %            'base',[],...
% %            'subject',[],...
% %            'exp',[],...
% %            'date',[],...
% %            'time',[],...
% %            'etc',[]);
% % %struct for all the stimulus file.
% % sa_mat = s_raw;
% % %struct for stimulus files matching the raw data files.
% % s_mat = s_raw;

clear sa_mat s_mat s_raw;

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

beforeDate = [2011 8 31];
afterDate  = [2013 1 1 ];
beforeDateNum = datenum(beforeDate);
afterDateNum = datenum(afterDate);

for iFile = 1:length(s_mat)
    
    clear folder;
    folder(1) = s_mat(iFile);
    folder(2) = s_mat(iFile);
    folder(3) = s_raw(iFile);
    folder = rmfield(folder,'filename');
    %weild behavior of datenum with string input. it works every other time
    %only. the other half time it throws error.
    try 
        expDateNum = datenum(folder(1).date,'yyyy-mmm-dd');
    catch
        expDateNum = datenum(folder(1).date,'yyyy-mmm-dd');
    end
    
    if expDateNum < beforeDateNum || expDateNum > afterDateNum 
        continue;
    end
    %==================================
    %scripts to process data
    fprintf('process folder %d : \n',iFile);
    try
        %loadData;
        %mainRate2; plotRateFigs(chan2,neurons,s,t_SETS);
        %close all;
        %mainSTA_normLuminance; plotSTAFigs([],neurons,s,t_SETS);
        cmap = getChannelMapFile(folder(1));
        mainLFP;
        close all;
        
        %plotPPDFigs(chan2,neurons,s,t_SETS,StimImage);
        %plotResponseFigures(chan2,neurons,s,t_SETS,StimImage);
    catch
        fprintf('Error on %d: %s\n', iFile,folder(1).date);
        %lasterror;
    end


end


