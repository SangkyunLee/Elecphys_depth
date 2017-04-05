function plotRateFigs(chan,neurons,s,t_SETS,saveToDir)
%plot adaptation rate figures 
%chan: selected channels for plotting figures. all units in the channel will
%          be included for plotting
%neurons : neuron data struct
%s       : params struct
%toSave  : write Data summary file to disk.

% if nargin < 5
%     toSave = true;
% end

%temp setting, skip summary file saving
toSave = true; 

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
unitType = 'multiUnit';
% fdir = fullfile(s.nevFolder,'2013',unitType); 
%fdir = fullfile(s.nevFolder,'Sigma3',unitType); 

fdir = fullfile(saveToDir,'Analysis');
if exist(fdir,'dir')~=7 ; mkdir(fdir); end

%sumFile = fullfile('c:\work\2013',[unitType,'_rate_summary_all_',date,'.txt']);
sumFile = fullfile('c:\work\2013\',['rate_summary_',datestr(now,'yyyy-mmm-dd_HH-MM-SS'),'.txt']);

%sumFile = 'c:\work\2013\SU_rate_summary_all_Apr10_2013.txt';   %summary file for all units
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
        
        h = plotRateCluster(d1,d2,cc);
        %export the figure
        fn = fullfile(fdir,sprintf('adaptation_plot_ch%dunit%d.png',cc(1),cc(2)));
        savePlot(h,fn); 
        close(h);
        %plot steability plot
        h = plotSbCluster(d1,d2,lowOnsets,highOnsets,cc);
        fn = fullfile(fdir,sprintf('stability_plot_ch%dunit%d.png',cc(1),cc(2)));
        savePlot(h,fn); 
        close(h);

        p = getRateEntry(neurons,s,cc);
        fn = fullfile(fdir,sprintf('%s_rate_summary.txt',unitType));
        if toSave
            try;writeRateFile(fn,p,'a+');end      %save under each experiment folder
            writeRateFile(sumFile,p,'a+'); %save to the global file.
        end

        h = plotInitialRate(d1,d2,cc);
        fn = fullfile(fdir,sprintf('initialRate_plot_ch%dunit%d.png',cc(1),cc(2)));
        savePlot(h,fn); 
        close(h);
        
    end
    %save the initial rates plots for multi-units(all units grouped)
    
    h = plotInitialRate(neurons{chanIdx(i)});
    fn = fullfile(fdir,sprintf('initialRate_plot_ch_depthID%d_multi-unit.png',i));
    savePlot(h,fn); 
    close(h);
        
end


function p = getRateEntry(neurons,s,cc)
%
%add the estimate of inital rates and steady rates from calcuated data 
%
%time bin size
bin = mean(diff(neurons{1}.clusters{1}.class{1}.member{1}.firingRate.x(1:2)));

%number of points to estimate initial rates
nIR = 1; %first bin 
%number of pts to estimate steady rates
nSR = 15; %first 30sec

fprintf('Rate Calculation: Bin %d, inital rate over %d(sec), steady rate over %d(sec)\n',bin,nIR*bin,nSR*bin); 

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

fprintf('neuron,cluster id: %d %d\n',i,j);
%r1: inital rate; r2: adaptation rate; r3: steady rate
r0 = neurons{i}.clusters{j}.basefr;

%
d1 = neurons{i}.clusters{j}.class{1}.member{1};
d2 = neurons{i}.clusters{j}.class{1}.member{2};
%expontial fit: rateExpFit = fitcoeff(1) +
%fitcoeff(2)*exp(-fitcoeff(3)*xout);
r1_low = d1.firingRate.fit.coeff(1) + d1.firingRate.fit.coeff(2);
r2_low = d1.firingRate.fit.coeff(3); 
r3_low = d1.firingRate.fit.coeff(1);
fg_low = d1.firingRate.fit.goodness;
err_low= mean(d1.firingRate.err);

%estimate of initial rate from rate hist over tirals
r4_low = mean(mean(d1.firingRate.scArray(:,1:nIR),2));
s4_low = std(mean(d1.firingRate.scArray(:,1:nIR),2))/sqrt(size(d1.firingRate.scArray,1));

%estimate of steady rate
r5_low = mean(mean(d1.firingRate.scArray(:,end-nSR+1:end),2));
s5_low = std(mean(d1.firingRate.scArray(:,end-nSR+1:end),2))/sqrt(size(d1.firingRate.scArray,1));


% %estimate of initial rate
% r4_low = mean(d1.firingRate.y(1:nIR));
% s4_low = std(d1.firingRate.y(1:nIR))/sqrt(nIR);
% 
% %estimate of steady rate
% r5_low = mean(d1.firingRate.y(1:nSR));
% s5_low = std(d1.firingRate.y(1:nSR))/sqrt(nSR);
%
r1_high = d2.firingRate.fit.coeff(1) + d2.firingRate.fit.coeff(2);
r2_high = d2.firingRate.fit.coeff(3); 
r3_high = d2.firingRate.fit.coeff(1);
fg_high = d2.firingRate.fit.goodness;
err_high= mean(d2.firingRate.err);
% %estimate of initial rate
% r4_high = mean(d2.firingRate.y(1:nIR));
% s4_high = std(d2.firingRate.y(1:nIR))/sqrt(nIR);
% %estimate of steady rate
% r5_high = mean(d2.firingRate.y(1:nSR));
% s5_high = std(d2.firingRate.y(1:nSR))/sqrt(nSR);

%estimate of initial rate from rate hist over tirals
r4_high = mean(mean(d2.firingRate.scArray(:,1:nIR),2));
s4_high = std(mean(d2.firingRate.scArray(:,1:nIR),2))/sqrt(size(d2.firingRate.scArray,1));

%estimate of steady rate
r5_high = mean(mean(d2.firingRate.scArray(:,end-nSR+1:end),2));
s5_high = std(mean(d2.firingRate.scArray(:,end-nSR+1:end),2))/sqrt(size(d2.firingRate.scArray,1));


%date of experiment
sep = strfind(s.matFolder,'\');
experiment_date = s.matFolder(sep(end-1)+1 : end);
experiment_date = strrep(experiment_date,'\','.');
experiment_date = strrep(experiment_date,'-','.');
expdatevec = datevec(experiment_date,'yyyy.mmm.dd.HH.MM.SS');

p = zeros(1,29);
%
p(1:6)   = expdatevec;          %experiment date
p(7:8)   = [d1.value d2.value]; %contrast value
p(9:10)  = [cc(1) cc(2)];       %channel id, cluster id
p(11)    = r0;                  %baseline firing rate
p(12:20) = [r2_low,r3_low,r1_low,fg_low,err_low,r4_low,s4_low,r5_low,s5_low]; %adapt rate,steady,initial,fit goodness R2, mean err,estimated initial rate(mean),estimated initial rate(std), estimated steady rate(mean),estimated steady rate(std)
p(21:29) = [r2_high,r3_high,r1_high,fg_high,err_high,r4_high,s4_high,r5_high,s5_high];


function writeRateFile(fn,p,mode)

if nargin < 3
    mode = 'w+';
end

fp = fopen(fn,mode);
fprintf(fp,'\n%4d %2d %2d %2d %2d %2d %2d %2d %2d %d %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f %8f\r',...
               p(1),p(2),p(3),p(4),p(5),p(6),p(7),p(8),p(9),p(10),p(11),p(12),p(13),p(14),p(15),p(16),...
               p(17),p(18),p(19),p(20),p(21),p(22),p(23),p(24),p(25),p(26),p(27),p(28),p(29));
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

function h = plotSbCluster(d1,d2,Tl,Th,cc)
%steability plot

scrsz = get(0,'ScreenSize');
h = figure('name','stability','Position',[10 scrsz(4)/2 scrsz(3)-20 scrsz(4)/2-100]);

t1 = d1.timestamps;
t2 = d2.timestamps;
bin = 5; 
%Stim onsets
tBlock = Th(1)-Tl(1);

t = Tl(1):bin:(Th(end)+tBlock);

fr1 = histc(t1,t)/bin;
fr2 = histc(t2,t)/bin;

plot(t,fr1); hold on; plot(t,fr2,'r'); 
xlabel('Time(s)','fontsize',12);ylabel('Firing Rate(hz)','fontsize',12);
legend('LC','HC');
title(sprintf('Ch%d Unit%d', cc(1),cc(2)));

function h = plotInitialRate(d1,d2,cc)
%plot the inital rates 
scrsz = get(0,'ScreenSize');
h = figure('name','Initial Rates','Position',[150 scrsz(4)/2 scrsz(3)-150 scrsz(4)/2-100]);
hold on;

if nargin < 3 %multi-unit
    neuron = d1;
    %sum all spike counts array per units
    x1 = neuron.clusters{1}.class{1}.member{1}.firingRate.x;
    r1 = 0;
    r2 = 0; 
    for j = 1 : length(neuron.clusters)
        r1 = r1 + neuron.clusters{j}.class{1}.member{1}.firingRate.scArray;
        r2 = r2 + neuron.clusters{j}.class{1}.member{2}.firingRate.scArray;
    end
    cc = [neuron.channel 0];
else
    %spike counts array
    x1 = d1.firingRate.x;
    %y1 = d1.firingRate.y;
    r1 = d1.firingRate.scArray;
    %x2 = d2.firingRate.x;
    %y2 = d2.firingRate.y;
    r2 = d2.firingRate.scArray;
end

%binsize.
bin = x1(2)-x1(1); 

%scatterplot of initial Rate - steady Rates at Low Contrast vs High Contrast for the first three bins. 
for iBin = 1 : 3
    subplot(1,3,iBin); hold on;
    for i = 1 : size(r1,1)
        if i == 1 
            dr1 = r1(i,iBin) - r2(end,end); %wrap around the first trial
        else
            dr1 = r1(i,iBin) - r2(i-1,end); %initial rate at LC - steady rate at HC
        end
        dr2 = r2(i,iBin) - r1(i,end);
        plot(dr1/bin,dr2/bin,'ko'); axis image;
        %
        xl = xlim; yl = ylim;
        plot(linspace(xl(1),xl(2),20), zeros(1,20),'r--');
        plot(zeros(1,20),linspace(yl(1),yl(2),20),'r--');
        xlim(xl); ylim(yl);
    end
    xlabel('LC Rate(hz)','fontsize',10);ylabel('HC Rate(hz)','fontsize',10);
    title(sprintf('R(I)-R(S),Ch%d Unit%d,bin#%d', cc(1),cc(2),iBin));
end



function h = plotRateCluster(d1,d2,cc)
%plot
h = figure('name','adaptation rate');
hold on;
%
lineSpec = {'ko','bo','ro','go','mo','yo'};

x1   = d1.firingRate.x;
y1   = d1.firingRate.y;
err1 = d1.firingRate.err;
fy1  = d1.firingRate.fit.y;
%x2   = d2.firingRate.x;
y2   = d2.firingRate.y;
err2 = d2.firingRate.err;
fy2  = d2.firingRate.fit.y;

tbin   = x1(2)-x1(1);
tBlock = x1(end)- x1(1) + tbin; 

n = length(x1); %num of time points

for i = 0 : 3
    x = x1 + (i-1)*tBlock ; 
    if i == 0 || i == 2
        y   = y1;
        err = err1;
        fy  = fy1;
    else
        y   = y2;
        err = err2;
        fy  = fy2;
    end

    errorbar(x,y,err,lineSpec{1},...
                            'MarkerEdgeColor','k',...
                            'MarkerFaceColor',[.49 0.8 .63],...
                            'MarkerSize',2);
    plot(x,fy); %plot fit
       
end

%plot the separation line between contrast.
yl = ylim.*(1+[-1 1]*0.3); %seperator line
ys = linspace(yl(1),yl(end),20);

for i = 0 : 3
    x = x1 + (i-1)*tBlock;
    xs = (x(end)+tbin)*ones(size(ys));
    plot(xs,ys,'k--');
end

xlim([-tBlock/2, 5/2*tBlock]);
ylim([ys(1) ys(end)]);
xlabel('Time(s)','fontsize',12);
ylabel('Firing rate(Hz)','fontsize',12);
set(gca,'XTick',[0 round(tBlock) 2*round(tBlock)],'XTickLabel',{'0',sprintf('%d',round(tBlock)),sprintf('%d',2*round(tBlock))});
%
lowcoeff = d1.firingRate.fit.coeff;
highcoeff = d2.firingRate.fit.coeff;

text(tBlock/2,min(yl)+(max(yl)-min(yl))*0.85,['\fontsize{12} \tau = ',sprintf('%.1f',1/highcoeff(3)), 's'], 'HorizontalAlignment','center');
text(tBlock/2,min(yl)+(max(yl)-min(yl))*0.75,['\fontsize{12} r = ',sprintf('%.1f',highcoeff(1)), 'hz'], 'HorizontalAlignment','center');
text(3*tBlock/2,min(yl)+(max(yl)-min(yl))*0.85,['\fontsize{12} \tau = ',sprintf('%.1f',1/lowcoeff(3)), 's'], 'HorizontalAlignment','center');
text(3*tBlock/2,min(yl)+(max(yl)-min(yl))*0.75,['\fontsize{12} r = ',sprintf('%.1f',lowcoeff(1)), 'hz'], 'HorizontalAlignment','center');

title(sprintf('Ch%d, Unit%d',cc(1),cc(2)));

    