close all;
%summary file with depth
%fn = 'c:\Work\Summary\Summary_Dec112012Ephys\Depth_Determination\MU_rate_all_parameters_dec_20_12_screened.xlsx';
%fn = 'c:\Work\2013\MU_rate_summary_all_Jan2013.xlsx';
%run getDepthDatabase on summary file to add depth info for excel file.
% fn = 'c:\Work\2013\MU_rate_summary_all_Jan2013.xlsx';
fn = 'c:\Work\2013\multiUnit_rate_summary_all_04-Jun-2013.xlsx';
data = xlsread(fn);

iContrastL = 7;
iContrastH = 8;
iCh   = 9;
iUnit = 10; 
iSponRate     = 11;
iAdaptRateL   = 12;
iSteadyRateL  = 13;
iInitialRateL = 14;
%column index of r-square at Low contrast 
iRsqL     = 15;
iMeanErrL = 16;
%
iInitialRateEstL = 17; %inital rate estimated from 

%use real or fit data for initial/steady rate estimates
useReal = true;
%contrast values selected for analysis
contrastLow = 6;
contrastHigh = 35;
%r-square threshold to accept cells.
RsqThresholdH = 0;
RsqThresholdL = 0; 
%option to remove/keep the first unit (noise unit) for SU/MU analysis
removeNoiseUnit = true; 
%option to remove cell units for MU analysis
removeCellUnit = false;

%error check for remove unit options
if removeNoiseUnit && removeCellUnit 
    error('All units removed...');
end

if size(data,2) == 22
    iAdaptRateH   = 17;
    iSteadyRateH  = 18;
    iInitialRateH = 19;
    iRsqH     = 20;
    iMeanErrH = 21;
    iDepth    = 22;
elseif size(data,2)==30
    iInitialRateRealL = 17; %inital rate computed from data.
    iInitialRateRealErrL = 18; 
    iSteadyRateRealL = 19;
    iSteadyRateRealErrL = 20;
    iAdaptRateH   = 21;
    iSteadyRateH  = 22;
    iInitialRateH = 23;
    iRsqH     = 24;
    iMeanErrH = 25;
    iInitialRateRealH = 26; %inital rate computed from data.
    iInitialRateRealErrH = 27; 
    iSteadyRateRealH = 28;
    iSteadyRateRealErrH = 29;
    iDepth    = 30;
    
    if useReal
        %compute the initial rates/steady rates with real data
        iInitialRateH = iInitialRateRealH;
        iInitialRateL = iInitialRateRealL;
        iSteadyRateH = iSteadyRateRealH;
        iSteadyRateErrH = iSteadyRateRealErrH;
        iSteadyRateL = iSteadyRateRealL;
        iSteadyRateErrL = iSteadyRateRealErrL;
    end
    %
else
    %
end


M0=data;

%keep the selected contrasts
data(data(:,iContrastL)~=contrastLow | data(:,iContrastH)~=contrastHigh,:)=[];

%remove the single units,i.e, id >0.
data(data(:,iUnit)~=0,:) = [];

%get the experiment num
expDates = unique(data(:,1:6),'rows');

nExp = 0;

scrsz = get(0,'ScreenSize');

for i = 1 : size(expDates,1)
    h = figure('name','stability','Position',[100 100 scrsz(3)-200 scrsz(4)-200]);
    entry = find(datenum(data(:,1:6)) == datenum(expDates(i,:)));
    %sort the channels by depth
    chanMap = getChannelMapFile(datestr(expDates(i,:),'yyyy-mmm-dd\\HH-MM-SS'),'part');
    chanByDepth = chanMap(:,3);
    chanByName  = data(entry,9);
    sortID = zeros(size(chanByName));
    try
    for j = 1 : length(chanByName)
        id = find(chanByName(j)==chanByDepth);
        if ~isempty(id)
            sortID(j) = id; %depth index. 1 is the deepest channel
        end
    end
    catch
        fprintf('channel not found %d\n',chanByName(j));
    end
    
    [chanByOrder,ByOrder] = sort(sortID);
   
    x = data(entry(ByOrder),iInitialRateL);
    xe= data(entry(ByOrder),iInitialRateL+1);
    y = data(entry(ByOrder),iInitialRateH);
    ye= data(entry(ByOrder),iInitialRateH+1);
    for k = 1 : 6
        subplot(2,3,k);
        if k <= 4
            pk = 1+(k-1)*6 : k*6;
        elseif k <= 5
            pk = 1+(k-1)*6 : length(chanByOrder);
        else
            pk = 1 : length(chanByOrder);
        end
        
        pk(pk>length(chanByOrder))=[];
        
        errorbar(x(pk),y(pk), ye(pk),'bo');
        hold on;
        
        if k <= 5
            for p = 1 : length(pk)
                %text(x(pk(p))-diff(xlim)*0.04,y(pk(p)),sprintf('%d\\_',chanByOrder(pk(p))),'FontSize',6); %depth index, channel index on probe
                text(x(pk(p))+diff(xlim)*0.04,y(pk(p)),sprintf('%d\\_%d',chanByOrder(pk(p)),chanByName(ByOrder(pk(p)))),'FontSize',6); %depth index, channel index on probe
            end
        end
        xlabel('LC Rate(hz)'); ylabel('HC Rate(hz)'); 
        if k == 1
            title(datestr(expDates(i,:),'yyyy-mmm-dd,HH-MM-SS'));
        else
            title('Initial Rates Scatterplot');
        end
        %axis image;
        axis equal;
        xl = xlim; yl = ylim;
        plot(linspace(xl(1),xl(2),100),linspace(xl(1),xl(2),100),'r--');
        xlim(xl); ylim(yl);
    end
    savePlotAsPic(h,fullfile(fileparts(fn),sprintf('initialRate_%s.png',datestr(expDates(i,:),'yyyy-mm-dd_HH-MM-SS'))));
    close(h);
end






% %remove outliers (adaptation rate (from fit)> 100hz ?) --> 50
% iRemove = find(data(:,iAdaptRateL) > 50 | data(:,iAdaptRateH) > 50); 
% data(iRemove,:) = [];
% fprintf('adapt rate outlier removed %d\n',length(iRemove));
% 
% 
% %sort by r2 at high then low contrast 
% M = sortrows(data,[iRsqH iRsqL]);
% %reverse matrix in decesending order.
% M = M(end:-1:1,:);
% %
% RH = (M(:,iRsqH) < RsqThresholdH);
% RL = (M(:,iRsqL) < RsqThresholdL);
% R  = RH | RL ;
% fprintf('%d cells with R2(H) < %f and R2(L) < %f, removed\n',...
%     length(find(R)),RsqThresholdH,RsqThresholdL);
% M(R,:) = []; 
% 
% %remove unsorted units, i.e, id == 0
% D = M(:,iUnit) < 1 ; 
% fprintf('%d unsorted units removed\n',length(find(D)));
% M(D,:) = [];
% 
% if removeNoiseUnit
%     %remove noise units , i.e, id == 1
%     D = M(:,iUnit) == 1 ;
%     fprintf('%d noise units removed\n',length(find(D)));
%     M(D,:) = [];
% end
% 
% if removeCellUnit
%     %remove noise units , i.e, id == 1
%     D = M(:,iUnit) > 1 ;
%     fprintf('%d cell units removed\n',length(find(D)));
%     M(D,:) = [];
% end

% %remove channels with negative depth.
% D  = M(:,iDepth) < 0;
% fprintf('%d cells with negative depth, removed\n',length(find(D)));
% M(D,:) = [];
% %remove channels with negative rates
% D1 = M(:, iAdaptRateL) <=0 ; D2 = M(:, iAdaptRateH) <=0 ; D = D1 | D2 ;
% fprintf('%d (%d,%d) cells with negative adaptation rate, removed\n',length(find(D)),length(find(D1)),length(find(D2)));
% M(D,:) = [];
% 
% D1 = M(:, iSteadyRateL) <=0 ; D2 = M(:, iSteadyRateH) <=0 ; D = D1 | D2 ;
% fprintf('%d (%d,%d) cells with negative steady rate, removed\n',length(find(D)),length(find(D1)),length(find(D2)));
% M(D,:) = [];
% 
% D1 = M(:, iInitialRateL) <=0 ; D2 = M(:, iInitialRateH) <=0 ; D = D1 | D2 ;
% fprintf('%d (%d,%d) cells with negative initial rate, removed\n',length(find(D)),length(find(D1)),length(find(D2)));
% M(D,:) = [];
% 
% fprintf('%d cells remain\n', size(M,1));
% %remove the outlier in adaptation histgram that has rl/rh =100 
% iRemove = find(M(:,iAdaptRateL)./M(:,iAdaptRateH)>50);
% fprintf('manual removed %d\n',length(iRemove));
% M(iRemove,:) = [];
% 

