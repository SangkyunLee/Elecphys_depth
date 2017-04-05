nNeurons = length(neurons);
%select the channel/cluster to plot
i = 0;
%cluster index
j = 0;
%override the [i,j] indices with the actual channel/unit id indices.
chanIDX = 39; %actual channel id number
unitIDX = 2; %actual unit id number.

if ~isempty(chanIDX)
    i = find(recordChannels == chanIDX);
end
if ~isempty(unitIDX)
    clusterID = zeros(1,length(neurons{i}.clusters));
    for m = 1 : length(clusterID)
        clusterID(m) = neurons{i}.clusters{m}.id;
    end
    j = find(clusterID == unitIDX);
end

if neurons{i}.clusters{j}.id == 255
    disp('invalid unit');
    return;
end
if neurons{i}.clusters{j}.id == 0
    disp('unsorted unit');
    %         return;
end

%%
x = [xout xout+tBlock];
x = x - tBlock;
y = neurons{i}.clusters{j}.class{1}.member{1}.sta;
z = neurons{i}.clusters{j}.class{1}.member{1}.std;
f = neurons{i}.clusters{j}.class{1}.member{1}.fit;
%coeff: 1. baseline 2. Amplitude 3.decay constant
lowcoeff = neurons{i}.clusters{j}.class{1}.member{1}.fitcoeff;
highcoeff = neurons{i}.clusters{j}.class{1}.member{2}.fitcoeff;
%
figure;
%
%
lineSpec = {'ko','bo','ro','go','mo','yo'};
errorbar(x,y,z,lineSpec{1},...
                            'MarkerEdgeColor','k',...
                            'MarkerFaceColor',[.49 1 .63],...
                            'MarkerSize',2);
                        
hold on;

plot(x(1:length(x)/2),f(1:length(x)/2));
plot(x(length(x)/2+1:end),f(length(x)/2+1:end));

xavg = mean(x);

%extend the low/high contrast periods

% errorbar(x-2*tBlock,y,z,lineSpec{1},...
%                             'MarkerEdgeColor','k',...
%                             'MarkerFaceColor',[.49 1 .63],...
%                             'MarkerSize',2);
errorbar(x+2*tBlock,y,z,lineSpec{1},...
                            'MarkerEdgeColor','k',...
                            'MarkerFaceColor',[.49 1 .63],...
                            'MarkerSize',2);

yl = ylim;
yl = yl.*(1+[-1 1]*0.3);

plot(xavg*ones(1,20),linspace(yl(1),yl(end),20),'k--');
                      
plot(x(length(x)/2+1:end)+2*tBlock,f(length(x)/2+1:end));
plot(x(1:length(x)/2)+2*tBlock,f(1:length(x)/2));
% plot((xavg-2*tBlock)*ones(1,20),linspace(yl(1),yl(end),20),'k--');
plot((xavg+2*tBlock)*ones(1,20),linspace(yl(1),yl(end),20),'k--');

% plot((xavg-1*tBlock)*ones(1,20),linspace(yl(1),yl(end),20),'k--');
plot((xavg+1*tBlock)*ones(1,20),linspace(yl(1),yl(end),20),'k--');

xlim([min(x)+tBlock/2,max(x)+tBlock/2+1*tBlock]);
%ylim([min(yl),max(yl)]);
ylim(yl);

xlabel('Time(s)');
ylabel('Firing rate(Hz)');

text(tBlock/2,min(yl)+(max(yl)-min(yl))*0.85,['\fontsize{12} \tau = ',sprintf('%.1f',1/highcoeff(3)), 's'], 'HorizontalAlignment','center');
text(tBlock/2,min(yl)+(max(yl)-min(yl))*0.75,['\fontsize{12} r = ',sprintf('%.1f',highcoeff(1)), 'hz'], 'HorizontalAlignment','center');
text(3*tBlock/2,min(yl)+(max(yl)-min(yl))*0.85,['\fontsize{12} \tau = ',sprintf('%.1f',1/lowcoeff(3)), 's'], 'HorizontalAlignment','center');
text(3*tBlock/2,min(yl)+(max(yl)-min(yl))*0.75,['\fontsize{12} r = ',sprintf('%.1f',lowcoeff(1)), 'hz'], 'HorizontalAlignment','center');

title(sprintf('Eletrode %d, Cluster %d',chanIDX,neurons{i}.clusters{j}.id)); 

savFigFileName = sprintf('adaptation_plot_ch%dunit%d',chanIDX,unitIDX);
savFigFile = fullfile(s.nevFolder,[savFigFileName,'.png']);
set(gcf,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ;hgexport(gcf,savFigFile,export_style); end

%% 
%steability plot,i.e, the average firing rate over recording time  
ts_low = neurons{i}.clusters{j}.class{1}.member{1}.timestamps;
ts_high = neurons{i}.clusters{j}.class{1}.member{2}.timestamps;
%
sb_bin = 5;
%sbt = t_SETS(1):sb_bin:t_SETS(end);
sbt = [];
for cc = 1 : length(lowConOnsets)
    if cc < length(lowConOnsets)
        sbt = [sbt lowConOnsets(cc):sb_bin:highConOnsets(cc)-sb_bin highConOnsets(cc):sb_bin:lowConOnsets(cc+1)-sb_bin];
    else
        sbt = [sbt lowConOnsets(cc):sb_bin:highConOnsets(cc)-sb_bin highConOnsets(cc):sb_bin:highConOnsets(cc)+tBlock-sb_bin];
    end
end

fr_low = histc(ts_low,sbt)/sb_bin;
fr_high= histc(ts_high,sbt)/sb_bin;
%
scrsz = get(0,'ScreenSize');
figure('name','stability','Position',[10 scrsz(4)/2 scrsz(3)-20 scrsz(4)/2-100]);
plot(sbt,fr_low); hold on; plot(sbt,fr_high,'r'); 
xlabel('Time(s)');ylabel('Firing Rate(hz)');legend('Low','High');
title(sprintf('Firing Stability, Electrode%d,Cluster%d',chanIDX,unitIDX));
%export the figure
savFigFileName = sprintf('stability_plot_ch%dunit%d',chanIDX,unitIDX);
savFigFile = fullfile(s.nevFolder,[savFigFileName,'.png']);
set(gcf,'PaperPositionMode','auto'); %print at screen size
%print('-dpng', '-r300', savFigFile);
try; hgexport(gcf,savFigFile,export_style); end

fprintf('Rates: chan#,unit#,spontaneous rate, adaptation time, stable rate, inital rate, fit goodness, mean error\n');
spoRate = neurons{i}.clusters{j}.basefr;
adaRate_low = neurons{i}.clusters{j}.class{1}.member{1}.fitcoeff(3);
staRate_low = neurons{i}.clusters{j}.class{1}.member{1}.fitcoeff(1);
iniRate_low = neurons{i}.clusters{j}.class{1}.member{1}.fitcoeff(1)+ neurons{i}.clusters{j}.class{1}.member{1}.fitcoeff(2);
meanSE_low = mean(neurons{i}.clusters{j}.class{1}.member{1}.std);
adaRate_high = neurons{i}.clusters{j}.class{1}.member{2}.fitcoeff(3);
staRate_high = neurons{i}.clusters{j}.class{1}.member{2}.fitcoeff(1);
iniRate_high = neurons{i}.clusters{j}.class{1}.member{2}.fitcoeff(1)+ neurons{i}.clusters{j}.class{1}.member{2}.fitcoeff(2);
meanSE_high = mean(neurons{i}.clusters{j}.class{1}.member{2}.std);
%fit goodness - R squre
fit_goodness_low = neurons{i}.clusters{j}.class{1}.member{1}.fitgoodness;
fit_goodness_high = neurons{i}.clusters{j}.class{1}.member{2}.fitgoodness;
% fprintf('%4d %2d %2d %2d %2d %2d %2d %d %f %f %f %f %f %f %f %f %f %f %f\n',...
%     expdatevec,chanIDX,unitIDX,spoRate,1/adaRate_low,staRate_low,iniRate_low,fit_goodness_low,...
%     1/adaRate_high,staRate_high,iniRate_high,fit_goodness_high);

%write to the text file
resultFile = fullfile(s.nevFolder,'rate-summary.txt');
fp = fopen(resultFile,'a+');
fprintf(fp,'\n%4d %2d %2d %2d %2d %2d %2d %d %f %f %f %f %f %f %f %f %f %f %f\r',...
    expdatevec,chanIDX,unitIDX,spoRate,1/adaRate_low,staRate_low,iniRate_low,fit_goodness_low,...
    1/adaRate_high,staRate_high,iniRate_high,fit_goodness_high);
fclose(fp);

fprintf('constrast: %d %d\n',s.matData.params.contrast);
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        