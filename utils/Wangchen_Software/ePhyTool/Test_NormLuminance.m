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
folder(1).subject='gamma';
folder(1).exp='NormLuminance';
folder(1).date= '2010-Apr-29';
folder(1).time= '17-54-42';

%nex folder
folder(2) = folder(1);

%nev folder
folder(3) = folder(1);
folder(3).base = 'C:\Users\wangchen\Documents\MATLAB\Data\CerebusData';
%folder(3).time = '17-40-31';
%%
opt.fileindex = 0;
opt.nevvar = {'events','contvars'}; %check the timestamps intervals
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
%check events timestamps consistency
fprintf('ISI Filter: %d before, %d after ISI filter; Events: %d\n',np,nt,nm);
if nt-nm ~=0; fprintf('Inconsistent Numbers of timestampes !! \n'); end
    
%% read luminance data from analog ch
ncv = length(s.nevData.contvars);

fprintf('Channels for Continuous Data\n'); 
for i = 1 : ncv
    fprintf('[%d]:\t %s\n',i,s.nevData.contvars{i}.name);
end

if ncv > 1
    icv = input(sprintf('Select Channel [ %d ~ %d ] : ',1,ncv));
else
    icv = ncv;
end

%selected channel
fprintf('[%d]: %s Chosen \n',icv,s.nevData.contvars{icv}.name);

%sampling timestamp resolution
tsr = s.nevData.TimeStampResolution;
%sampling rate
fs = 1 / tsr;
%continuous data.
wave = s.nevData.contvars{icv}.data;
%filter p.d.s measurement,no plot
pds = LCDFilter(wave,fs,false); 

%find the indices of stim-event-timestamps in wave/pds 
sets_index = round((sets - 0)/tsr);
%margin for the sume
margin_t = flashT * 0.1;
%in sample points
margin_np = round(margin_t/tsr);
%luminance values
lum = zeros(1,nt);
for i = 1 : nt-1
    idx1 = sets_index(i) + margin_np;
    idx2 = sets_index(i+1)- margin_np;
    lum(i) = mean(pds(idx1:idx2));
end
%extend the last point 
idx1 = sets_index(nt) + margin_np;
idx2 = sets_index(nt) + (sets_index(2)-sets_index(1))- margin_np;
lum(nt) = mean(pds(idx1:idx2));

fig = figure('name','Norm Distribution of Luminance');

subplot(2,1,1);
[cLum,xLum]=hist(lum,20);
bar(xLum,cLum);hold on;
%fit to normal dist
[mu,sigma,muci,sigmaci] = normfit(lum);
%generate data array for norm dist
ynorm = normpdf(xLum,mu,sigma);
%fit lum values
fLum = ynorm * sum(cLum)*(xLum(2)-xLum(1));
plot(xLum,fLum,'r'); title(sprintf('Measured: mu=%.1f sigma=%.1f,contrast=%.1f%%',mu,sigma,100*sigma/mu));

subplot(2,1,2);
lum1 = squeeze(s.matData.params.rndLumin);
[cLum1,xLum1]=hist(lum1,20); 
bar(xLum1,cLum1);hold on;
[mu,sigma,muci,sigmaci] = normfit(lum1);
%generate data array for norm dist
ynorm = normpdf(xLum1,mu,sigma);
fLum1 = ynorm * sum(cLum1)*(xLum1(2)-xLum1(1));
plot(xLum1,fLum1,'r'); title(sprintf('Stimulation: mu=%.1f sigma=%.1f,contrast=%.1f%%',mu,sigma,100*sigma/mu));

saveas(fig,sprintf('.\\%s_%s_%03d_margin_%d.jpg',folder(1).date,folder(1).time,opt.fileindex,margin_np));


