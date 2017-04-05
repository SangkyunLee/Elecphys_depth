function writeClu2Nev(fpath,fnev)
%write the clustered files (clustering.mat) into NEV structure and save
%that into mat file.
%fpath: path to the clustered files
%fnev : nev file to read for creating the NEV struct. 
%e.g writeClu2Nev('c:\work\data','c:\work\data\test.nev');
%the default output filename will be nev filename with '_clusters' appended. e.g 'test_sort.mat'

%fields in clustering structure
% %
%    cluBySpike: [1x368234 int16]
%        spikeTimes: []
%        noiseTimes: [368234x1 double]
%        nbClusters: 0
%     idxRangeBegin: 1
%       idxRangeEnd: 368234
%       cluSegments: {}
%       cluSegTimes: []
%          projAxes: {[28x3 double]  [28x3 double]  [28x3 double]  [28x3 double]}
%            contam: []
%

%----------------------------------------
%load the map file
cmapFilePath = fileparts(mfilename);
cmapFileName = 'Tetrode_96ch.cmp';
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
%
%global cmap
cmap = readCerebusMap(cmapFile);
%
[fd,fn,fext] = fileparts(fnev);
%output file for clustered units
fout = fullfile(fd,[fn,'_clusters','.mat']);
%output file for multi-units (neuron unit + noise unit per channel)
fout1= fullfile(fd,[fn,'_mua','.mat']);

%open the nev file
NEV = openNEV(fnev);
%clear spikes record in NEV
NEV.Data.Spikes.TimeStamp = [];
NEV.Data.Spikes.Electrode = [];
NEV.Data.Spikes.Unit = [];

%read the clustered files
files = dir(fullfile(fpath,'clusteringTT*.mat'));
%
for i = 1 : length(files)
    %
    f = fullfile(fpath,files(i).name);
    %
    d = load(f);
    %wirte the clusters into NEV structure.
    %
    nbClusters = d.clustering.nbClusters;
    clusterID = unique(d.clustering.cluBySpike);
    %tetrode number 
    fname = strrep(files(i).name,'.mat','');
    m = str2num(fname(strfind(fname,'TT')+2:end));
    %find the channels for the tetrode from map file.
    channels = cmap((m-1)*4+1 : m*4 , 3);
    %set the noise units first
    units = zeros(1,length(d.clustering.noiseTimes));
    timestamps = d.clustering.noiseTimes';
    
    %concrate 
    for j = 1 : nbClusters
        x = d.clustering.spikeTimes{j};
        units = [units repmat(clusterID(j),1,length(x))];
        timestamps = [timestamps x'];
    end
    %timestamps are in msec. convert to indices.
    timestamps = (timestamps/1000)*30000;
    
    nspks = length(timestamps);
    %copy the spikes for tetrodes 
    tt.TimeStamp = repmat(timestamps,1,4);
    tt.Electrode = [repmat(channels(1),1,nspks) repmat(channels(2),1,nspks) repmat(channels(3),1,nspks) repmat(channels(4),1,nspks)];
    tt.Unit = repmat(units,1,4);
    %
    fprintf('tt: %d \n',m);
    NEV.Data.Spikes.TimeStamp = [NEV.Data.Spikes.TimeStamp tt.TimeStamp]; %sampling index
    NEV.Data.Spikes.Electrode = [NEV.Data.Spikes.Electrode tt.Electrode];
    NEV.Data.Spikes.Unit      = [NEV.Data.Spikes.Unit tt.Unit];
  
    %
end

%
NEV1 = NEV;
%set all units to unsorted unit
NEV1.Data.Spikes.Unit = zeros(size(NEV1.Data.Spikes.Unit));

%save the NEV 
save(fout,'NEV');
%
NEV = NEV1;
save(fout1,'NEV');

fprintf('done\n');
