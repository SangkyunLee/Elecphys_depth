%example of reading continuous data type into matlab data struct

%nev data file
filename = 'C:\MATLAB704\work\data\gamma\NormLuminance\2010-Apr-27\14-57-46\gamma_NormLuminance002.nev';
%filename = 'C:\MATLAB704\work\data\gamma\NormLuminance\2010-Apr-27\15-22-25\gamma_NormLuminance004.nev';
%
stimname ='C:\MATLAB704\work\data\gamma\NormLuminance\2010-Apr-27_15-22-25\0004.mat';
stimname = 'C:\MATLAB704\work\data\gamma\NormLuminance\2010-Apr-27_14-57-46\0003.mat';
stim = load(stimname);
% %available data types
% dataTypeList = {'neurons','waves','events','contvars'};

%ignore datatype will return the full data set. 
nevData = getNEVData(filename,{'contvars','events'});
%print the available elements in contvars.
nContVars = length(nevData.contvars);
nEvents = length(nevData.events);
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

fprintf('Event Channel\n\n');
if nEvents >0
    for i = 1 : nEvents
        fprintf('%d :\t %s\n',i,nevData.events{i}.name);
    end
end

iev = input(sprintf('Select Channel [ %d ~ %d ] : ',1,nEvents));
name = nevData.events{iev}.name;
%selected channel
fprintf('[%d]: %s Chosen \n',iev,name);

%sampling timestamp resolution
tsr = nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;
%continuous data.
wave = nevData.contvars{icv}.data;

events = nevData.events{iev}.timestamps;

%clear nevData to save memory
%clear nevData;


%display part of data.
npt = length(wave);
x = linspace(0,tsr*(npt-1),npt);

% figure('name',name);
% plot(x(1:3000),wave(1:3000));

%apply functions to wave data.
pds = LCDFilter(wave,fs,false);
%
%clear wave;

% pds_diff = abs(diff(pds));
% %find peaks
% p = findpeaks(pds_diff);
% %filter the times by 10 frames. 
% idx = p.loc;
% %filter the index by the stimulus segment
% idx = idx(idx>round(events(1)/tsr) & idx < round(events(2)/tsr));
% 
% timestamps = x(idx);
% %timestamps = edgeReader(pds,fs);
% %timer flash frequency (freq of stimluls event occurance)

flashFreq = 6;
%filtered timestamps after apply ISI filter
minISI = (1/flashFreq) * 0.8;
[ftts,I] = ISIFilter(events,minISI);

ftidx = round(ftts/tsr);

for i = 1 : length(ftidx)-1
    lum(i)=mean(pds(ftidx(i):ftidx(i+1)));
end

figure('name','hist of intensity');hold off;
[cLum,xLum]=hist(lum,20);
bar(xLum,cLum);hold on;
[mu,sigma,muci,sigmaci] = normfit(lum);
%generate data array for norm dist
ynorm = normpdf(xLum,mu,sigma);
yLum = ynorm * sum(cLum)*(xLum(2)-xLum(1));
plot(xLum,yLum,'r'); title(sprintf('mu=%.1f sigma=%.1f,contrast=%.1f%%',mu,sigma,100*sqrt(2)*sigma/mu));
%f

figure('name','data');hold on;
plot(x(1:10*30*1000),pds(1:10*30*1000),'r');
plot(x(1:10*30*1000),wave(1:10*30*1000),'b-.');
%plot(events,280*ones(size(events)),'bo');
plot(x(ftidx),280*ones(size(ftidx)),'ko');
xlim([x(1) x(10*30*1000)]);

figure('name','stim data');hold off;
stimLum = squeeze(stim.params.rndLumin);
[cStimLum,xStimLum]=hist(stimLum,20); 
bar(xStimLum,cStimLum);hold on;
[mu,sigma,muci,sigmaci] = normfit(stimLum);
%generate data array for norm dist
ynorm = normpdf(xStimLum,mu,sigma);
yStimLum = ynorm * sum(cStimLum)*(xStimLum(2)-xStimLum(1));
plot(xStimLum,yStimLum,'r'); title(sprintf('mu=%.1f sigma=%.1f,contrast=%.1f%%',mu,sigma,100*sqrt(2)*sigma/mu));

