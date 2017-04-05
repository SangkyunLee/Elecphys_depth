function  r = setEPhyToolLastSession(varargin)
%save the info for the last opened files of neural data and trial data. 
%path to ePhyTool
%
lastSession = varargin{1};
ePhyToolPath = ePhyTool;
lastSessionFile = fullfile(ePhyToolPath,'ePhyToolLastSession.mat');
% if exist(lastSessionFile,'file') == 2
%     lastSession = open(lastSessionFile);
% else
%     lastSession = struct('nevFile','*.nev','nevFolder',eToolPath,...
%                          'matFile','*.mat','matFolder',eToolPath);
% end
save(lastSessionFile,'lastSession');
r = true;
