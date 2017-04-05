function AddPsychtoolboxToPath
% Use this script to add Psychtoolbox Folders to Matlab Path when using a
% single installation on multiple Computers mounting the drive.
%
% AE 2007-10-04

% base directory
base = getLocalPath('/lab/libraries/');

% need those
addpath(fullfile(base,'Psychtoolbox/PsychBasic'));
addpath(fullfile(base,'Psychtoolbox/PsychOneliners'));

% check if saved path string is up to date
ver = PsychtoolboxVersion;
pathFile = fullfile(base,'matlab/path.mat');
loaded = false;
if exist(pathFile) == 2
    savedPath = load(pathFile);
    if isequal(savedPath.ver,ver)
        pathStr = savedPath.pathStr;
        loaded = true;
    end
end

% generate path (don't use genpath since we don't want the .svn folders in
% there)
if ~loaded
    oldDir = cd(base);
    dirs = getSubDirs('Psychtoolbox');
    cd(oldDir);

    % build path string
    n = length(dirs);
    pathStr = cell(1,n);
    for i = 1:n
        pathStr{i} = ['<BASE>' dirs{i}];
    end

    save(pathFile,'pathStr','ver');
end

% add to path
pathStr = strrep(strrep(pathStr,'<BASE>',base),'\','/');
addpath(pathStr{:});

% remove PsychInit directory as it causes some wierd behavior
rmpath(getLocalPath('/lab/libraries/Psychtoolbox/PsychInitialize'))

% save path
if exist('savepath')
   err = savepath;
else
   err = path2rc;
end

if ~err
    disp('Psychtoolbox was added to Matlab''s path');
end


%% Recursively add subdirectories excluding .svn
function dirs = getSubDirs(baseDir)

dirs = {baseDir};
d = dir(baseDir);
for i = 1:length(d)
    if d(i).isdir && ~strncmp(d(i).name,'.',1) && ~strncmp(d(i).name,'private',7)
%         [baseDir '/' d(i).name]
        subDirs = getSubDirs([baseDir '/' d(i).name]);
        dirs = [dirs, subDirs];
%         for j = 1:length(subDirs)
%             dirs{end+1} = subDirs{j};
%         end
    end
end

