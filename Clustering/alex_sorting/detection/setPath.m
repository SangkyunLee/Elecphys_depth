function setPath

if ~exist('baseReaderElectrophysiology', 'file')
    run(getLocalPath('c:\work\Clustering\code\wangchen\hdf5matlab\setPath'))
end

base = fileparts(mfilename('fullpath'));
addpath(fullfile(base,''))
addpath(fullfile(base,'alignment'))
addpath(fullfile(base,'detection'))
addpath(fullfile(base,'threshold'))
addpath(fullfile(base,'extraction'))
addpath(fullfile(base,'signals'))
clear base
