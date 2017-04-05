function s = matLoader(folder,opt)
%load the stimulus data/cerebus nev data/nex data into matlab data.
%%folder structure 
%folder.base  - eg,'c:\data'
%      .subject - eg, 'monkey'
%      .exp - name of experiment, eg, 'DotMapping'
%      .date -
%      .time - sim/nev folders might have different names for this subfolder due
%              to a time lag between two machines when creating folders.
%      .etc - subfolder for sorted nev data by offline-sorter.
%
%
% 1.data file type to load (string or cell of string)
% opt.datatype - 'mat' :   stimulation data in .mat
%              - 'nex' :   experiment event index file .nex
%              - 'nev' :   recorded nev data .nev
%              - 'all'| [] : retreive all the above. 
%
% 2.indice of files to load 
% opt.fileindex  - 0 : flag to load (experiment name).mat which contains
%                      session info for the stimulation.
%                  i : i-th in the file list; 
%                  []: all files 
%
% 3.the type of varibles to load from nev data.
% opt.nevvar - 'neurons' 
%            - 'events'
%            - 'contvars'
%            - 'waves'

%Output struct s -- save file info in s so that we know the correspondence b/w data/file. 
s = struct('matData',struct,'matFile',[],'matFolder',[],...
           'nexData',struct,'nexFile',[],'nexFolder',[],...
           'nevData',struct,'nevFile',[],'nevFolder',[]);

matFolder = fullfile(folder(1).base,folder(1).subject,folder(1).exp,...
    folder(1).date,folder(1).time,folder(1).etc);
%normally it's the same as matFolder
nexFolder = fullfile(folder(2).base,folder(2).subject,folder(2).exp,...
    folder(2).date,folder(2).time,folder(2).etc);
%recorded nev folder
nevFolder = fullfile(folder(3).base,folder(3).subject,folder(3).exp,...
    folder(3).date,folder(3).time,folder(3).etc);

mat_files = dir(fullfile(matFolder,'*.mat'));
nex_files = dir(fullfile(nexFolder,'*.nex'));
nev_files = dir(fullfile(nevFolder,'*.nev'));

nmat = length(mat_files);
nnex = length(nex_files);
nnev = length(nev_files);

%allow string type for in case of single selection
if ~iscell(opt.datatype) %string
    opt.datatype = {opt.datatype};
end

%{'all'} or {[]} 
if any(cellfun(@isempty,opt.datatype)) || ismember('all',opt.datatype)
    opt.datatype = {'mat','nex','nev'};
end

err = false; 

ndt = length(opt.datatype);

for i = 1 : ndt
    
    if err; break; end;
    datatype = opt.datatype{i};
    
    switch datatype
        case 'mat'
            %check folder
            if ~exist(matFolder,'dir')
                fprintf('mat folder not found -- %s\n', matFolder);
            else
                fprintf('Loading stimulation data(*.mat)...\n');
            end
            if nmat==0;fprintf('%s files not found \n',datatype); end
            %files are sorted already by os in acending order -- not alway reliable
            %session mat file will be loaded as the last one   
            m = 0; %number of files read
            for j = 1 : nmat
                if isempty(opt.fileindex) || any(opt.fileindex==j) || ...
                        (any(opt.fileindex == 0)&& strcmp(mat_files(j).name,[folder(1).exp,'.mat']))

                    m = m + 1;
                    s(m).matData = load(fullfile(matFolder,mat_files(j).name));
                    s(m).matFile = mat_files(j).name;
                    s(m).matFolder = matFolder;
                    %remove exp.mat from array. only allow fileindex=0 to
                    %access.
                    if isempty(opt.fileindex) && strcmp(mat_files(j).name,[folder(1).exp,'.mat'])
                        s(m) = []; m = m - 1;  %remove the entry
                    else
                        fprintf('\t%d)--%s\n',m,s(m).matFile); %post msg.
                    end
                end
                
            end
            
        case 'nex'
            if ~exist(nexFolder,'dir')
                fprintf('nex folder not found -- %s\n', nexFolder); 
            else
                fprintf('Loading stimulation param (*.nex) ...\n');
            end
            if nnex==0;fprintf('%s files not found \n',datatype); end
            
            m = 0; %file counter
            for j = 1 : nnex
                if  isempty(opt.fileindex) || any(opt.fileindex==j)
                    m = m + 1;
                    s(m).nexData = readNexFile(fullfile(nexFolder,nex_files(j).name));
                    s(m).nexFile = nex_files(j).name;
                    s(m).nexFolder = nexFolder;
                    if ~isempty(s(m)); fprintf('\t%d)--%s\n',m,s(m).nexFile);end
                end
            end

        case 'nev'
            if ~exist(nevFolder,'dir')
                fprintf('nev folder not found -- %s\n', nevFolder); 
            else
                fprintf('Loading cerebus data (*.nev) ...\n');
            end
            if nnev==0;fprintf('%s files not found \n',datatype); end
            m = 0;
            for j = 1 : nnev
                if  isempty(opt.fileindex) || any(opt.fileindex==j)
                    m = m + 1;
                    s(m).nevData = getNEVData(fullfile(nevFolder,nev_files(j).name),opt.nevvar);
                    s(m).nevFile = nev_files(j).name;
                    s(m).nevFolder = nevFolder;
                    if ~isempty(s(m)); fprintf('\t%d)--%s\n',m,s(m).nevFile);end
                end
            end

    end
end

%keyboard;


