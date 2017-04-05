function [s,nex] = nexLoader(folder,opt,nex)
%load the stimulus data/cerebus nev data/nex data into matlab/neuroexploerer.
%Usage :  [s,nex] = nexLoader(folder,opt)--only load files into neuroexploer
%                   neuroexploer is called inside the scope of script.
%                   limitation: can't do much in matlab with returned handle
%         [s,nex] = nexLoader(folder,opt,nex) -- load files into external
%                   neuroexploer interface.
%          
%%folder structure 
%folder.base  - eg,'c:\data'
%      .subject - eg, 'monkey'
%      .exp - name of experiment, eg, 'DotMapping'
%      .date -
%      .time - sim/nev folders might have different names for this subfolder due
%              to a time lag between two machines when creating folders.
%
%
% 1.data file type to load (string or cell of string)
% opt.datatype - 'mat' :   stimulation data in .mat
%              - 'nex' :   experiment event index file .nex
%              - 'nev' :   recorded nev data .nev
%              - 'all'| [] : retreive all the above. 
%
% 2.indice of files to load 
% opt.fileindex  - 0 : do nothing
%                  i : i-th in the file list; 
%                  []: all files 
%
% 3.the type of varibles to load from nev data.
% opt.nevvar - 'neurons' 
%            - 'events'
%            - 'contvars'
%            - 'waves'
%
% nex -- neuroexplorer interface object
%
% Output - 

%Output struct s -- save file info in s so that we know the correspondence b/w data/file. 
%nexData/nevData contains the neuroexplorer doc references to loaded files

s = struct('matData',struct,'matFile',[],'matFolder',[],...
           'nexData',struct,'nexFile',[],'nexFolder',[],...
           'nevData',struct,'nevFile',[],'nevFolder',[]);

matFolder = fullfile(folder(1).base,folder(1).subject,folder(1).exp,...
    folder(1).date,folder(1).time);
%normally it's the same as matFolder
nexFolder = fullfile(folder(2).base,folder(2).subject,folder(2).exp,...
    folder(2).date,folder(2).time);
%recorded nev folder
nevFolder = fullfile(folder(3).base,folder(3).subject,folder(3).exp,...
    folder(3).date,folder(3).time);

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

if ~exist('nex','var') || isempty(nex)
    %open nex interface
    try
        nex = actxserver('NeuroExplorer.Application');
    catch
        nex = [];
        fprintf('NeuroExploer Error\n');
        lasterr;
        return
    end
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
                fprintf('folder not found -- %s\n', matFolder); return
            end
            if nmat==0;fprintf('%s files not found \n',datatype);return; end
            %files are sorted already by os in acending order -- 
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
                        s(m) = []; m = m - 1;
                    end
                end
            end
            
        case 'nex'
            if ~exist(nexFolder,'dir')
                fprintf('folder not found -- %s\n', nexFolder); return
            end
            if nnex==0;fprintf('%s files not found \n',datatype);return; end
            
            m = 0; %file counter
            for j = 1 : nnex
                if any(opt.fileindex==j) || isempty(opt.fileindex)
                    m = m + 1;
                    s(m).nexData = nex.OpenDocument(fullfile(nexFolder,nex_files(j).name));
                    s(m).nexFile = nex_files(j).name;
                    s(m).nexFolder = nexFolder;
                    
                end
            end

        case 'nev'
            if ~exist(nevFolder,'dir')
                fprintf('folder not found -- %s\n', matFolder); return
            end
            if nnev==0;fprintf('%s files not found \n',datatype);return; end
            m = 0;
            for j = 1 : nnex
                if any(opt.fileindex==j) || isempty(opt.fileindex)
                    m = m + 1;
                    s(m).nevData = nex.OpenDocument(fullfile(nevFolder,nev_files(j).name));
                    s(m).nevFile = nev_files(j).name;
                    s(m).nevFolder = nevFolder;
                    
                end
            end

    end
end

%keyboard;


