function wang_setPath
%set the path for the new algorithim of spike sorting (auto-sorting: moksm & manual-sorting: sorting gui)

warning off MATLAB:dispatcher:nameConflict

%need 'matlab' folder for getLocalPath function. need mym libraries ? --
if isequal(computer, 'PCWIN64')
    %addpath(getLocalPath('/lab/libraries/mym/win64'))
else
    %addpath(getLocalPath('/lab/libraries/mym'))
end

base = fileparts(mfilename('fullpath'));
addpath(base)

% % % user specific DJ connection parameters (uses Alex' credentials)
% % initDJ();
% % fprintf('Datajoint connection\n')
% % fprintf('--------------------\n')
% % fprintf('host: %s\n', getenv('DJ_HOST'))
% % fprintf('user: %s\n\n', getenv('DJ_USER'))

addpath(fullfile(base, 'processing'))
addpath(fullfile(base, 'processing/sync'))
addpath(fullfile(base, 'processing/utils'))
addpath(fullfile(base, 'recovery'))
addpath(fullfile(base, 'schemas'))
addpath(fullfile(base, 'migration'))
addpath(fullfile(base, 'sortgui'))
addpath(fullfile(base, 'sortgui/lib'))

% ndx = find(base == filesep, 1, 'last');
% % % DataJoint library is assumed to be in the same directory as the base
% % % diretory
% % addpath(fullfile(base(1:ndx-1), 'datajoint'))

% % TEMP until updated on /lab/libraries
% run(fullfile(base(1:ndx-1), 'hdf5matlab/setPath.m'))
% 
% % spike detection
% run(fullfile(base(1:ndx-1), 'detection/setPath.m'))
% 
% % LFP
% addpath(fullfile(base(1:ndx-1), 'lfp'))

% spike sorting
% addpath(fullfile(base(1:ndx-1), 'clustering'))
% run(getLocalPath('/lab/libraries/various/spider/use_spider'))
% addpath(fullfile(base(1:ndx-1), 'moksm'))

warning on MATLAB:dispatcher:nameConflict
