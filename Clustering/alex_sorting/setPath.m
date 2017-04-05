function setPath
%
%set the path for new algorithm of spike sorting. (matlab, hdf5matlab,detection, moksm,
%peabody -- GUI)

%
base = fileparts(mfilename('fullpath'));
addpath(base);
% TEMP until updated on /lab/libraries
run(fullfile(base, 'hdf5matlab/setPath.m'))

% spike detection
run(fullfile(base, 'detection/setPath.m'))

% % LFP
% addpath(fullfile(base(1:ndx-1), 'lfp'))

%spike sorting
addpath(fullfile(base, 'moksm'))

%getLocalPath
addpath(fullfile(base, 'matlab'))

%manual sorting GUI
run(fullfile(base, 'peabody/wang_setPath.m'))

%save
savepath;