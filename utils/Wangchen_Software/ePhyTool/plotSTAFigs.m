function plotSTAFigs(chan,neurons,s,t_SETS,saveToDir)
%plot adaptation rate figures 
%chan: selected channels for plotting figures. all units in the channel will
%          be included for plotting
%neurons : neuron data struct
%s       : params struct

%-------------------------------
n        = length(neurons);
recChan  = zeros(1,n);
%nBlocks  = getTrialParams(s,'nBlocks');
%stimTime = getTrialParams(s,'stimulusTime');
%tBlock   = stimTime/(nBlocks*2);             %time of each contrast block.

for i = 1 : n
    recChan(i) = neurons{i}.channel;
end

if isempty(chan); chan = recChan; end 
%find channel indices in 'neurons'
chanIdx = zeros(size(chan));
for i = 1 : length(chan)
    chanIdx(i) = find(chan(i)==recChan);
end

%event = makeStimEvent(s);
%[t_SETS,StimEventLUT] = sortStimEvent(s,event);
nBlocks    = getTrialParams(s,'nBlocks');
nStimPts   = length(t_SETS)/(nBlocks*2);  %the stimulus value points in each contrast
stimOnsets = t_SETS(1:nStimPts:end);%2. get the onsets for stimulus of each contrast.(assume 2-conditions,low and high, per cycle)
lowOnsets  = stimOnsets(1:2:end);
highOnsets = stimOnsets(2:2:end);
%
%fdir = fullfile(s.nevFolder,'2013','singleUnit');
fdir = fullfile(saveToDir,'Analysis');
if exist(fdir,'dir')~=7 ; mkdir(fdir); end
%sumFile = 'c:\work\2013\SU_STA_summary_all_Apr10_2013.txt';   %summary file for all units
sumFile = fullfile('c:\work\2013\',['STA_summary_',datestr(now,'yyyy-mmm-dd_HH-MM-SS'),'.txt']);

if exist(fileparts(sumFile),'dir')~=7 ; mkdir(fileparts(sumFile)); end

for i = 1 : length(chan)
    nc      = length(neurons{chanIdx(i)}.clusters);
    cluChan = zeros(1,nc);
    for j = 1 : nc
        cluChan(j) = neurons{chanIdx(i)}.clusters{j}.id;
        if cluChan(j) == 255; continue; end                      %skip invalid unit
        d1 = neurons{chanIdx(i)}.clusters{j}.class{1}.member{1}; %struct data for low contrast
        d2 = neurons{chanIdx(i)}.clusters{j}.class{1}.member{2}; %                high contrast
        if isempty(d1.timestamps) || isempty(d2.timestamps) ; continue; end %skip sparse channel
        %plot rate figure for each cluster
        cc = [chan(i),cluChan(j)];
        
        p = getSTAEntry(neurons,s,cc);
        h = plotSTACluster(d1,d2,cc,p);
        %export the figure
        fn = fullfile(fdir,sprintf('sta_plot_ch%dunit%d.png',cc(1),cc(2)));
        savePlot(h,fn); close(h);
        fn = fullfile(fdir,sprintf('SU_STA_summary.txt'));
        try;writeSTAFile(fn,p,'a+');end      %save under each experiment folder
        writeSTAFile(sumFile,p,'a+'); %save to the global file.
    end
end

function p = getSTAEntry(neurons,s,cc)
%return the entry of given cluster for rate summary output
i = 0 ; %neuron index
j = 0 ; %cluster index
for m = 1 : length(neurons)
    if neurons{m}.channel == cc(1)
        i = m;
        break;
    end
end

for k = 1 : length(neurons{i}.clusters)
    if neurons{i}.clusters{k}.id == cc(2)
        j = k;
        break
    end
end

%
d1 = neurons{i}.clusters{j}.class{1}.member{1};
d2 = neurons{i}.clusters{j}.class{1}.member{2};
%contrast value
c1 = neurons{i}.clusters{j}.class{1}.member{1}.value;
c2 = neurons{i}.clusters{j}.class{1}.member{2}.value;
%normalized by variance 
x  = d1.STA.x;
y1 = d1.STA.y; 
y1 = (y1-127.5)/(c1^2); 
y2 = d2.STA.y;
y2 = (y2-127.5)/(c2^2);

%measure sta
SlopeThreshold = 0;
AmpThreshold = 0.5*max(y1);
SmoothWidth = 3;
FitWidth = 3;
P_low = findpeaks(x,y1,SlopeThreshold,AmpThreshold,SmoothWidth,FitWidth);
%take the maximum peak.
[maxP,maxI] = max(P_low(:,3));
P_low = P_low(maxI,:);

AmpThreshold = 1.1*min(y1);
V_low = findvalleys(x,y1,SlopeThreshold,AmpThreshold,SmoothWidth,FitWidth);
[maxV,maxI] = min(V_low(:,3));
V_low = V_low(maxI,:);

AmpThreshold = 0.5*max(y2);
P_high = findpeaks(x,y2,SlopeThreshold,AmpThreshold,SmoothWidth,FitWidth);
[maxP,maxI] = max(P_high(:,3));
P_high = P_high(maxI,:);

AmpThreshold = 1.1*min(y2);
V_high = findvalleys(x,y2,SlopeThreshold,AmpThreshold,SmoothWidth,FitWidth);
[maxV,maxI] = min(V_high(:,3));
V_high = V_high(maxI,:);

%date of experiment
sep = strfind(s.matFolder,'\');
experiment_date = s.matFolder(sep(end-1)+1 : end);
experiment_date = strrep(experiment_date,'\','.');
experiment_date = strrep(experiment_date,'-','.');
expdatevec = datevec(experiment_date,'yyyy.mmm.dd.HH.MM.SS');

p = zeros(1,22);
%
p(1:6)   = expdatevec;
p(7:8)   = [d1.value d2.value]; %contrast value
p(9:10)  = [cc(1) cc(2)];
p(11:13) = [P_low(1,2),P_low(1,3),P_low(1,4)];
p(14:16) = [V_low(1,2),V_low(1,3),V_low(1,4)];
p(17:19) = [P_high(1,2),P_high(1,3),P_high(1,4)];
p(20:22) = [V_high(1,2),V_high(1,3),V_high(1,4)];


function writeSTAFile(fn,p,mode)

if nargin < 3
    mode = 'w+';
end

fp = fopen(fn,mode);
fprintf(fp,'\n%4d %2d %2d %2d %2d %2d %2d %2d %2d %d %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f\r',...
               p(1),p(2),p(3),p(4),p(5),p(6),p(7),p(8),p(9),p(10),p(11),p(12),p(13),p(14),p(15),p(16),...
               p(17),p(18),p(19),p(20),p(21),p(22));
fclose(fp);



function savePlot(h,fn)
%
export_style = hgexport('readstyle','PowerPoint');
export_style.Format = 'png';

figure(h);
set(gcf,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ;hgexport(gcf,fn,export_style); end
%close(h);


function h = plotSTACluster(d1,d2,cc,p)
%
h = figure('name','STA');
hold on;
%
lineSpec = {'ko','bo','ro','go','mo','yo'};

c1  = d1.value; %contrast
c2  = d2.value;

x1   = d1.STA.x;
y1   = d1.STA.y;
y1   = (y1-127.5)/(c1^2);
%x2   = d2.firingRate.x;
x2   = d2.STA.x;
y2   = d2.STA.y;
y2   = (y2-127.5)/(c2^2);
% 
%     errorbar(x,y,err,lineSpec{1},...
%                             'MarkerEdgeColor','k',...
%                             'MarkerFaceColor',[.49 0.8 .63],...
%                             'MarkerSize',2);

plot(x1,y1,'k'); %plot sta
plot(x2,y2,'b');

legend('L', 'H','Location','NorthWest');
xlabel('Time(s)');
ylabel('STA(gun.value/variance)');
title(sprintf('Elec %d, Cluster %d',cc(1),cc(2))); 

plot(p(11),p(12),'g+'); %peak at low contrast
plot(p(14),p(15),'g+'); %valley at low contrast
plot(p(17),p(18),'r+');
plot(p(20),p(21),'r+');

ylim(ylim.*1.2.*[1 1]);
