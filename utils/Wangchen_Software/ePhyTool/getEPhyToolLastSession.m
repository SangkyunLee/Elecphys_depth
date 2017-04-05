function  lastSession = getEPhyToolLastSession(varargin)
%get the info for the last opened files of neural data and trial data. 
%
%path to eTool
ePhyToolPath = ePhyTool;
lastSessionFile = fullfile(ePhyToolPath,'ePhyToolLastSession.mat');
if exist(lastSessionFile,'file') == 2
    r = open(lastSessionFile);
    lastSession = r.lastSession;
else
    %nevFile -- spike data
    %matFile -- trial data
    %waveFile -- sorted spike waveform data exported by offline sorter
    lastSession = struct('nevFile','*.nev','nevFolder',ePhyToolPath,...
                         'matFile','*.mat','matFolder',ePhyToolPath,...
                         'waveFile','*.mat','waveFolder',ePhyToolPath);
end
