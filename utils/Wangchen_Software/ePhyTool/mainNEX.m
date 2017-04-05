%Plot STA after data collection with DotMapping

%% Load the Data into struct array
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
%--------------------------------------------------

%--------------------------------------------------
%visual stimulation data folder
folder(1).base='C:\Users\wangchen\Documents\MATLAB\Data\StimulationData';
folder(1).subject='gamma';
folder(1).exp='NormLuminance';
folder(1).date= '2010-Apr-29';
folder(1).time= '17-54-42';

%nex folder
folder(2) = folder(1);

%nev folder
folder(3) = folder(1);
folder(3).base = 'C:\Users\wangchen\Documents\MATLAB\Data\CerebusData';
%folder(3).time = '17-15-48';
%folder(3).time = '17-34-44';

opt.fileindex = 1; % load file
opt.nevvar = {'neurons','events','waves'}; %load spikes and stim-event markers
opt.datatype = {'mat','nex','nev'}; 
%----------------------------------------------
%% use gui to locate data folder and set the indices of files to load

popup = true; %use gui to locate folder

%overwrites the mannual setting 
if popup
    try close(h_dataLocator); end %close previous open window.
    h_dataLocator = dataLocator;
    while true 
        pause(0.1)
        if ~isempty(getappdata(0,'dataLocator_result'))
            break;
        end
        if ~ishandle(h_dataLocator); break; end %if cancel was clicked and fig closed
    end
    ret = getappdata(0,'dataLocator_result');
    if ~isempty(ret) %if not cancled or it will continue with mannual setting
        folder = ret.folder;
        opt.fileindex = eval(ret.fileindex);
    end
end

%%
% % load 'neurons' for spikes and 'events' for stim-event-timestamps
%   s = matLoader(folder,opt);
%   opt.fileindex = 0; %load session data.
%   ss = matLoader(folder,opt);
  
  %load the data into nex
  
%--------------------------------------------------
%
useNEX = true;
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

fprintf('Loading data into neuroexploer...\n');
%load nev/nex files into neuroexploerer.
[s,nex] = nexLoader(folder,opt,nex);    
%number of files
n = length(s);

for i = 1 : n
    s_NEX = s(i);
    %write the stimulus image files for dotmappingexperiment.
    %
    if strcmp(folder(1).exp,'DotMappingExperiment') || strcmp(folder(1).exp,'NormLuminance')
        outfile = fullfile(folder(3).base,folder(3).subject,...
            folder(3).exp,folder(3).date,folder(3).time,strrep(s_NEX.nevFile,'nev','txt'));
        fprintf('Writing Stimulus Image Files to:\n %s...\n',outfile);
        writeStimImageFile(s_NEX,outfile,'w');
        fprintf('Done\n');
    end
    %run nex command to do isifilter
    minISI = 0.8*(s_NEX.matData.params.stimFrames/60);
    %digital ch named differently with import dll;
    try 
        varname = 'Digital';
        digital = s_NEX.nevData.Variable(varname);
    catch
        varname = 'digital';
        digital = s_NEX.nevData.Variable(varname);
    end
%it sucks that document reference couldn't be selected programally.
%run isifilter in neuroexploer  
    cmd = sprintf(...
        'doc=GetActiveDocument()\ndoc.StimEventTimestamp=ISIFilter(GetVarByName(doc,"%s"),%f)',...
        varname,minISI);
    nex.RunNexScriptCommands(cmd);
    
end

%run nex script ?
%run ISIFilter here.
%$%for i = 1 : n
    
    
    




