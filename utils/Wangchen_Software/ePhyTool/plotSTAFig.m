%plot individual STA after mainSTA script execution.
nNeurons = length(neurons);
%override the [i,j] indices with the actual channel/unit id indices.
chanIDX = 39; %actual channel id number
unitIDX = 1; %actual unit id number.

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

lowContrast = (neurons_m{i}.clusters{j}.class{1}.member{1}.value); 
highContrast = (neurons_m{i}.clusters{j}.class{1}.member{2}.value);

plotTYPE = 'STA';
% plotTYPE = 'MES';
switch plotTYPE
    case 'STA'
        %
        x = xSTA;
        y1 = neurons{i}.clusters{j}.class{1}.member{1}.sta;
        z1 = neurons{i}.clusters{j}.class{1}.member{1}.std;
       
        %
        y2 = neurons{i}.clusters{j}.class{1}.member{2}.sta;
        z2 = neurons{i}.clusters{j}.class{1}.member{2}.std;
%       %  
        y1 = (y1-127.5)/(lowContrast^2);
        z1 = z1/(lowContrast^2);
        %
        y2 = (y2-127.5)/(highContrast^2);
        z2 = z2/(highContrast^2);

    case 'MES'
        %
        x = xMES;
        y1 = neurons_m{i}.clusters{j}.class{1}.member{1}.sta;
        z1 = neurons_m{i}.clusters{j}.class{1}.member{1}.std;
%         %normalize by std
        y1 = y1/((neurons_m{i}.clusters{j}.class{1}.member{1}.value)^2);
        z1 = z1/((neurons_m{i}.clusters{j}.class{1}.member{1}.value)^2);
        %
        y2 = neurons_m{i}.clusters{j}.class{1}.member{2}.sta;
        z2 = neurons_m{i}.clusters{j}.class{1}.member{2}.std;
         y2 = y2/((neurons_m{i}.clusters{j}.class{1}.member{2}.value)^2);
         z2 = z2/((neurons_m{i}.clusters{j}.class{1}.member{2}.value)^2);
end
        
plotSE = false;
%
figure;
%
% lineSpec = {'ko','bo','ro','go','mo','yo'};
lineSpec = {'k','b','r','g','m','y'};
if plotSE
    errorbar(x,y1,z1,lineSpec{1},...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 0.5 .63],...
        'MarkerSize',2);
    hold on;
    errorbar(x,y2,z2,lineSpec{2},...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',2);
else
    hold on;
    plot(x,y1,'k');
    plot(x,y2,'b');
end

legend('L', 'H','Location','NorthWest');

% if strcmp(plotTYPE,'STA')
%     plot(x, 127.5*ones(size(x)),'k');
% end

xlabel('Time(s)');
ylabel(plotTYPE);

title(sprintf('Elec %d, Cluster %d',chanIDX,unitIDX)); 

%plot the std line for each contrast.
s1 = (lowContrast * 127.5 /100); %std in gun value
%standard error of mean
s1 = s1 /sqrt(neurons{i}.clusters{j}.class{1}.member{1}.spikes);
s1 = s1 /(lowContrast^2); %normalize by variance
s2 = (highContrast*127.5 /100);
s2 = s2 /sqrt(neurons{i}.clusters{j}.class{1}.member{2}.spikes);
s2 = s2 /(highContrast^2);

xl = xlim;
% plot(xl, repmat(s1,1,2), 'r');plot(xl, repmat(-s1,1,2), 'r');
% plot(xl, repmat(s2,1,2), 'g');plot(xl, repmat(-s2,1,2), 'g');

%measure sta
% %low
% staPeak1 = max(y1);
% staPeakTime1 = x(find(y1==staPeak1));
% staValley1 = min(y1);
% staValleyTime1 = x(find(y1==staValley1));
% %high
% staPeak2 = max(y2);
% staPeakTime2 = x(find(y2==staPeak2));
% staValley2 = min(y2);
% staValleyTime2 = x(find(y2==staValley2));
%

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

fprintf('Low: PeakTime,PeakAmp,PeakWidth,ValleyTime,ValleyAmp,ValleyWidth\n'); 
% fprintf('%.3f %.3f %.3f %.3f %.3f %.3f\n',...
%     P_low(1,2),P_low(1,3),P_low(1,4),V_low(1,2),V_low(1,3),V_low(1,4));
fprintf('High: PeakTime,PeakAmp,PeakWidth,ValleyTime,ValleyAmp,ValleyWidth\n'); 
fprintf('%4d %2d %2d %2d %2d %2d %2d %d %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n',...
    expdatevec,chanIDX,unitIDX,P_low(1,2),P_low(1,3),P_low(1,4),V_low(1,2),V_low(1,3),V_low(1,4),P_high(1,2),P_high(1,3),P_high(1,4),V_high(1,2),V_high(1,3),V_high(1,4));

plot(P_low(1,2),P_low(1,3),'g+');
plot(V_low(1,2),V_low(1,3),'g+');
plot(P_high(1,2),P_high(1,3),'r+');
plot(V_high(1,2),V_high(1,3),'r+');

yl = ylim;
yl = yl .* [1.2 1.2];
ylim(yl);

savFigFileName = sprintf('sta_plot_ch%dunit%d',chanIDX,unitIDX);
savFigFile = fullfile(s.nevFolder,[savFigFileName,'.png']);
set(gcf,'PaperPositionMode','auto');
% print('-dpng', '-r600', savFigFile);
hgexport(gcf,savFigFile,export_style);

resultFile = fullfile(s.nevFolder,'sta-summary.txt');
fp = fopen(resultFile,'a+');

fprintf(fp,'%4d %2d %2d %2d %2d %2d %2d %d %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n',...
    expdatevec,chanIDX,unitIDX,P_low(1,2),P_low(1,3),P_low(1,4),V_low(1,2),V_low(1,3),V_low(1,4),P_high(1,2),P_high(1,3),P_high(1,4),V_high(1,2),V_high(1,3),V_high(1,4));

fclose(fp);






                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        