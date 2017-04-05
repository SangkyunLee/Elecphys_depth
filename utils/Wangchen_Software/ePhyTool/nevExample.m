%example of reading continuous data type into matlab data struct

%nev data file
% filename = 'C:\MATLAB704\work\Apr-14-2010\datafile001.nev';
%filename = 'C:\CEREBUS\DataFile\CerebusData\mice\GratingExperiment\2011-Jan-20\20-17-13\mice_GratingExperiment004.nev';
%filename = 'E:\cerebus\datafile\cerebusdata\test\TetrodeTest001.nev';
filename = 'E:\cerebus\datafile\cerebusdata\test\Tetrode007.nev';
filename = 'C:\CEREBUS\DataFile\CerebusData\mice\NormLuminance\2011-Jan-28\04-11-34\mice_NormLuminance009.nev';
% filename = 'E:\cerebus\datafile\cerebusdata\test\DiskTest97Ch004.nev';
% %available data types
% dataTypeList = {'neurons','waves','events','contvars'};

%ignore datatype will return the full data set. 
nevData = getNEVData(filename,{'contvars'});
%nevData = getNEVData(filename,{'neurons','events'});
disp('here');
%print the available elements in contvars.
nContVars = length(nevData.contvars);
%return if no contvar exists.
if nContVars==0; 
    fprintf('No Continuous Data Exists\n');
    return 
end
fprintf('Channels for Continuous Data\n'); 
for i = 1 : nContVars
    fprintf('[%d]:\t %s\n',i,nevData.contvars{i}.name);
end

icv = input(sprintf('Select Channel [ %d ~ %d ] : ',1,nContVars));
name = nevData.contvars{icv}.name;
%selected channel
fprintf('[%d]: %s Chosen \n',icv,name);

%sampling timestamp resolution
tsr = nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;
%continuous data.
wave = nevData.contvars{icv}.data;

%clear nevData to save memory
clear nevData;

figure('name',name);
%display part of data.
npt = min([5000,length(wave)]);
x = linspace(0,tsr*(npt-1),npt);
y = wave(1:npt);
plot(x,y);

%apply functions to wave data.
pds = LCDFilter(wave,fs,false);
timestamps = edgeReader(pds,fs);
%timer flash frequency (freq of stimluls event occurance)
flashFreq = 0.5;
%filtered timestamps after apply ISI filter
minISI = (1/flashFreq) * 0.8;
ftts = ISIFilter(timestamps,minISI);

data_spk = sort(((rand(3,100)*8)),2);
data_img = zeros([20,20,length(ftts),size(data_spk,1)]);
a = size(data_img); b = prod(a);
r = randperm(b);
data_img(r) = exp(-(r-b/2).^2);
[s1,t1,E1] = sta2(data_spk,data_img,ftts);

data_lfp = rand(3,length(ftts));
[s2,t2,E2] = sta1(data_spk,data_lfp,ftts);







