warning off MATLAB:dispatcher:ShadowedMEXExtension

% SAMBA doesn't support change notification handles
% system_dependent('RemotePathPolicy','TimecheckDirFile');
% system_dependent('RemoteCWDPolicy','TimecheckDirFile');

addpath(fileparts(mfilename('fullpath')))
% addpath(getLocalPath('/lab/libraries/recDB'))
% addpath(getLocalPath('/lab/libraries/jobDB'))
% addpath(getLocalPath('/lab/libraries/clustering'))
% addpath(getLocalPath('/lab/libraries/clustering_lib'))

% to get mym to work, I need to go into its folder, use it once so the
% library gets loaded, then I can cd wherever I want
addpath(getLocalPath('/lab/libraries/mym'))
old = cd(getLocalPath('/lab/libraries/mym'));
mym close; cd(old); clear old

global dataCon %#ok<NUSED>
run '/lab/projects/steinbruch/alex/setPath.m'
run '/lab/projects/steinbruch/philipp/setPath.m'
run '/lab/projects/steinbruch/library/setPath.m'

% libraries to read MPI data
% addpath(getLocalPath('/lab/libraries/various/mex_adf'))
% addpath(getLocalPath('/lab/libraries/various/mex_tt'))
% addpath(getLocalPath('/lab/libraries/various/mex_dg'))

global GLOBAL_VIS2P_CONNECTION
GLOBAL_VIS2P_CONNECTION = struct(...
    'host'  , 'localhost',...
    'schema', 'vis2p',...
    'user'  , 'aecker',...
    'pass'  , 'aecker#1');
