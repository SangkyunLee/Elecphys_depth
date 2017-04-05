%% 
%-------------------------------------------------
%initialize params
folder = struct(...
    'base',[],'subject',[],'exp',[],'date',[],'time',[]...
    );
folder(1:3)=struct(folder);
%default is full loading
opt = struct(...
    'fileindex',[],'datatype',[],'nevvar',[]);
%-------------------------------------------------
%%

%%
%--------------------------------------------------
%visual stimulation data folder
folder(1).base='C:\Users\wangchen\Documents\MATLAB\Data\StimulationData';
folder(1).subject='monkey';
folder(1).exp='DotMappingExperiment';
folder(1).date= '2010-Apr-30';
folder(1).time= '17-40-57';

%nex folder
folder(2) = folder(1);

%nev folder
folder(3) = folder(1);
folder(3).base = 'C:\Users\wangchen\Documents\MATLAB\Data\CerebusData';
folder(3).time = '17-40-57';
%%
opt.fileindex = 0;
opt.nevvar = 'events'; %check the timestamps intervals
opt.datatype = {'mat','nex','nev'};

%%
  opt.fileindex = 0; %load session data.
  ss = matLoader(folder,opt);
  %load 1 trial data.
  opt.fileindex = 1;
  s = matLoader(folder,opt);
%--------------------------------------------------
%
useNEX = false;

if useNEX
    %open nex interface
    try
        nex = actxserver('NeuroExplorer.Application');
    catch
        nex = [];
        fprintf('Error::NeuroExploer\n');
        lasterr;
    end
end
  
%%  
%TTL pulses
pulses = s.nevData.events{1}.timestamps;
%number of pulses
np = length(pulses);
%number of stim marker
nm = length(s.nexData.markers{1}.timestamps);
%stim event interval
flashFrames = s.matData.params.stimFrames;
%refresh rate -- found from experiement mat file ?
%TODO: need to be saved in structure. 
fr = 60;
%ttl interval
flashT = flashFrames/fr;
%therold 
minISI = 0.8 * flashT;
%apply ISI filter to TTL pulse.
sets = ISIFilter(pulses,minISI);
%number of filtered stim-event-timestamps
nt = length(sets);
fprintf('ISI Filter: %d before, %d after ISI filter; Events: %d\n',np,nt,nm);


