function clu2nev(fclu,fnev,fout)
%convert the clustered data files (clu,fet) to nev format.
%usage:
%clu2nev('....autoResult.clu.1','.....normLuminance.nev')
[fpath,fn,fext] = fileparts(fclu);
if ~exist('fnev','var')
    f = dir(fullfile(fpath,'*.nev'));
    %only one file under the directory.
    fnev = fullfile(fpath,f(1).name);
    fprintf('NEV file: %s\n', fnev);
end

[nevFp,nevFn] = fileparts(fnev); 

if ~exist('fout','var')
    %fout = fullfile(nevFp,nevFn); %'.out.nev'will be appended by saveNEV.
    fout = fullfile(fpath,[nevFn,'_sort','.mat']); %default output directory to where cluster files are.
    fprintf('Output: %s\n',fout);
end

%read the header from input file
NEV = openNEV(fnev);
% %read all the clu/fet files in the folder
% [fpath,fn,fext] = fileparts(fclu);
%
files = dir(fullfile(fpath,[fn,'.*']));
%
nfiles = length(files);
fdir = zeros(1,nfiles);

for i = 1 : nfiles
    fdir(i) = files(i).isdir ;    
end
%remove the directories.
files(find(fdir==1))=[];
%update the file numbers
nfiles = length(files);
%
%tetrode number
tn = zeros(1,nfiles);

%----------------------------------------
%load the map file
%find the OS type
OS=getenv('OS');
if strfind(OS,'XP')
    pathstr = 'C:\Documents and Settings';
else %win7
    pathstr = 'C:\Users\';
end
%select channel map file -- linear probe of single electrode or plannar array of tetrodes.     
% cmapFilePath = fullfile(pathstr,getenv('USERNAME'),'My Documents');
%cmapFilePath = 'c:\work\Experiment\Latest\New\ePhyTool';
cmapFilePath = fileparts(mfilename);
cmapFileName = 'Tetrode_96ch.cmp';
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
%
%global cmap
cmap = readCerebusMap(cmapFile);
%----------------------------------------------------------

%
%NEV1 = NEV;
%clear spikes in NEV
NEV.Data.Spikes.TimeStamp = [];
NEV.Data.Spikes.Electrode = [];
NEV.Data.Spikes.Unit = [];



for i = 1 : nfiles
    a = regexp(files(i).name,'\.','split');
    if length(a)~=3; continue;  end
    m = str2num(a{3});
    tn(i) = m; %tetrode number.
    cluFile = fullfile(fpath,['autoResult.clu.',num2str(tn(i))]);
    fetFile = fullfile(fpath,['autoResult.fet.',num2str(tn(i))]);
    %cluData = importdata(cluFile);
    %fetData = importdata(fetFile);
    cluData = dlmread(cluFile,' ');
    fetData = dlmread(fetFile,' ');
    %remove the first line which contains the number of dimensions
    fetData = fetData(2:end,:);
    %fprintf('%d\n',tn(i));
    %write the clustered spikes to NEV struct
    %ndim = str2num(fetData.textdata{1}); %dimension of entries in fet file
    [nspks,ndim] = size(fetData);
    ncluster = cluData(1,1);
    %remove the first line containing the number of clusters
    cluData = cluData(2:end,1);
    cluID = unique(cluData(:,1));
    %find the timestamps of the spikes ? -- need the minimum time of spike,
    %i.e, the offset timestamp for each tt.
    offset = 0; %it's not in clu/fet files
    spks = fetData(:,end)+offset;
    %find the channels for the tetrode from map file.
    channels = cmap((m-1)*4+1 : m*4 , 3);
    %write the spike info to the NEV struct.
    tt.TimeStamp = repmat(spks',1,4);
    tt.Electrode = [repmat(channels(1),1,nspks) repmat(channels(2),1,nspks) repmat(channels(3),1,nspks) repmat(channels(4),1,nspks)];
    tt.Unit = repmat(cluData',1,4);
    %
    fprintf('tt: %d \n',m);
    NEV.Data.Spikes.TimeStamp = [NEV.Data.Spikes.TimeStamp tt.TimeStamp]; %sampling index
    NEV.Data.Spikes.Electrode = [NEV.Data.Spikes.Electrode tt.Electrode];
    NEV.Data.Spikes.Unit      = [NEV.Data.Spikes.Unit tt.Unit];
    
end

%write the new NEV struct to data file. -- need to have waveforms data and
%data bytes info. save as .mat file
%saveNEV(NEV,'report'); %the output filename takes the default name as the input.  

save(fout,'NEV');

fprintf('done\n');



