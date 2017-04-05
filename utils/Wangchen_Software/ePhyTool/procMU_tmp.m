close all;
%summary file with depth
fn = 'c:\Work\Summary\Summary_Dec112012Ephys\Depth_Determination\MU_rate_all_parameters_dec_20_12_screened.xlsx';
%fn = 'c:\Work\2013\MU_rate_summary_all_Jan2013.xlsx';
data = xlsread(fn);

iContrastL = 7;
iContrastH= 8;
iCh   = 9;
iUnit = 10; 
iSponRate     = 11;
iAdaptRateL   = 12;
iSteadyRateL  = 13;
iInitialRateL = 14;
%column index of r-square at Low contrast 
iRsqL     = 15;
iMeanErrL = 16;

%use real or fit data for initial/steady rate estimates
useReal = false;
%contrast values selected for analysis
contrastLow = 6;
contrastHigh = 35;
%r-square threshold to accept cells.
RsqThresholdH = 0.2;
RsqThresholdL = 0; 

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
        iSteadyRateL = iSteadyRateRealL;
    end
    %
else
    %
end

M0=data;

%reverse the rate to get the time constants --- temp modification
data(:,iAdaptRateL) = 1./data(:,iAdaptRateL);
data(:,iAdaptRateH) = 1./data(:,iAdaptRateH);

%keep the selected contrasts
iRemove = (data(:,iContrastL)~=contrastLow | data(:,iContrastH)~=contrastHigh);
data(iRemove,:)=[];
%remove outliers (adaptation rate (from fit)> 100hz ?)
iRemove = (data(:,iAdaptRateL) > 100 | data(:,iAdaptRateH) > 100); 
data(iRemove,:) = [];
fprintf('adapt rate outlier removed %d\n',length(iRemove));

%sort by r2 at high then low contrast 
M = sortrows(data,[iRsqH iRsqL]);
%reverse matrix in decesending order.
M = M(end:-1:1,:);


%
RH = (M(:,iRsqH) < RsqThresholdH);
RL = (M(:,iRsqL) < RsqThresholdL);
R  = RH | RL ;
fprintf('%d cells with R2(H) < %f and R2(L) < %f, removed\n',...
    length(find(R)),RsqThresholdH,RsqThresholdL);
M(R,:) = []; 
%remove channels with negative depth.
D  = M(:,iDepth) < 0;
fprintf('%d cells with negative depth, removed\n',length(find(D)));
M(D,:) = [];
%remove channels with negative rates
D1 = M(:, iAdaptRateL) <=0 ; D2 = M(:, iAdaptRateH) <=0 ; D = D1 | D2 ;
fprintf('%d (%d,%d) cells with negative adaptation rate, removed\n',length(find(D)),length(find(D1)),length(find(D2)));
M(D,:) = [];

D1 = M(:, iSteadyRateL) <=0 ; D2 = M(:, iSteadyRateH) <=0 ; D = D1 | D2 ;
fprintf('%d (%d,%d) cells with negative steady rate, removed\n',length(find(D)),length(find(D1)),length(find(D2)));
M(D,:) = [];

D1 = M(:, iInitialRateL) <=0 ; D2 = M(:, iInitialRateH) <=0 ; D = D1 | D2 ;
fprintf('%d (%d,%d) cells with negative initial rate, removed\n',length(find(D)),length(find(D1)),length(find(D2)));
M(D,:) = [];

fprintf('%d cells remain\n', size(M,1));
% %remove the outlier in adaptation histgram that has rl/rh =100 
% iRemove = find(M(:,iAdaptRateL)./M(:,iAdaptRateH)>50);
% fprintf('manual removed %d\n',length(iRemove));
% M(iRemove,:) = [];




%layer assignment
layer(1).assignment = 'Layer 1';
layer(1).range = [0 200];
layer(2).assignment = 'Layer 2/3';
layer(2).range = [200 400];
layer(3).assignment = 'Layer 4';
layer(3).range = [400 700];
layer(4).assignment = 'Layer 5/6';
layer(4).range = [700 1200];
layer(5).assignment = 'Beyond';
layer(5).range = [1200 Inf];
%
for i = 1 : length(layer)
    x = layer(i).range;
    R = x(1) <= M(:,iDepth) & M(:,iDepth) < x(2) ;
    layer(i).data = M(R,:);
    layer(i).size = size(layer(i).data,1); % number of cells
end

a = {'base','adapt','steady','initial'};
b = {'iSponRate','iSponRate','iAdaptRateL','iAdaptRateH','iSteadyRateL','iSteadyRateH',...
    'iInitialRateL','iInitialRateH'};
%
for i = 1 : length(layer)
    for j = 1 : length(a)
        iL = eval(b{2*j-1});
        iH = eval(b{2*j});
        layer(i).result.rate(j).type = a{j};
        layer(i).result.rate(j).x  = layer(i).data(:,iDepth);
        layer(i).result.rate(j).mx = mean(layer(i).data(:,iDepth));
        layer(i).result.rate(j).ex = ste(layer(i).data(:,iDepth));
        layer(i).result.rate(j).y = [layer(i).data(:,iL) layer(i).data(:,iH)];
        layer(i).result.rate(j).my = [mean(layer(i).data(:,iL)) mean(layer(i).data(:,iH))];%mean
        layer(i).result.rate(j).ey =[ste(layer(i).data(:,iL)) ste(layer(i).data(:,iH))]; %ste
        layer(i).result.rate(j).ry =(layer(i).data(:,iH))./(layer(i).data(:,iL));%ratio b/w high and low
        
        
        
        
    end
end
%figure('name','Depth vs R2');
%figure('name','rates vs depth');

rates = struct;
for i = 1 : length(a)
    rates(i).mx = [];
    rates(i).ex = [];
    rates(i).my = [];
    rates(i).ey = [];
    
    for j = 1 : length(layer)
        rates(i).mx  = [rates(i).mx ; layer(j).result.rate(i).mx];
        rates(i).ex = [rates(i).ex ; layer(j).result.rate(i).ex];
        rates(i).my  = [rates(i).my ; layer(j).result.rate(i).my];
        rates(i).ey = [rates(i).ey ; layer(j).result.rate(i).ey];
        
    end
end

%layers to plot
L1 = 2;
L2 = length(layer)-1; 
LX = L1 : L2; 


%plot rate histgram
for i = 1 : length(a)
    %column index of low/high rates
    iL = eval(b{2*i-1});
    iH = eval(b{2*i});
    
    %if i == 1; continue; end
    figure('name',a{i}); hold on;
    errorbar(rates(i).mx(LX,1), rates(i).my(LX,2),rates(i).ey(LX,2),'r','MarkerFaceColor','red');
    errorbar(rates(i).mx(LX,1), rates(i).my(LX,1),rates(i).ey(LX,1),'b','MarkerFaceColor','blue');
    xlabel('Depth (um)');
    ylabel('Rate (hz)');
    
    if strcmp(a{i},'steady')
        errorbar(rates(1).mx(LX,1), rates(1).my(LX,1),rates(1).ey(LX,1),'k','MarkerFaceColor','black');
        legend('H','L','BG');
    else
        if ~strcmp(a{i},'base')
            legend('H','L');
        end
    end
        
    title(sprintf('Layer Dependence of %s rate',a{i}));
    str = 'samples =  ';
    for ii = L1 : L2
        str = [str sprintf('%d ,',layer(ii).size)];
    end
    str(end)=[];
    xl = xlim; yl = ylim;
    xl = xl(1) + (xl(2)-xl(1))*0.1;
    yl = yl(2) - (yl(2)-yl(1))*0.1;
    text(xl,yl,str,'FontSize',12); 
    %
    if strcmp(a{i},'initial')
        figure('name','initial response (Ri-Rs)');
        subplot(2,2,1); hold on;
        plot(rates(i).mx(LX,1),rates(i).my(LX,1)-rates(3).my(LX,1),'b-o');
        plot(rates(i).mx(LX,1),rates(i).my(LX,2)-rates(3).my(LX,2),'r-o');
        legend('L','H');xlabel('depth(um)');ylabel('Ri-Rs (hz)');title('initial response(wrt current rate)');
        
        subplot(2,2,2); hold on;
        plot(rates(i).mx(LX,1),(rates(i).my(LX,1)-rates(3).my(LX,1))./rates(3).my(LX,1),'b-o');
        plot(rates(i).mx(LX,1),(rates(i).my(LX,2)-rates(3).my(LX,2))./rates(3).my(LX,2),'r-o');
        legend('L','H');xlabel('depth(um)');ylabel('(Ri-Rs)/Rs');title('initial response(normalized)'); 
        %
        subplot(2,2,3); hold on;
        plot(rates(i).mx(LX,1),rates(i).my(LX,1)-rates(3).my(LX,2),'b-o');
        plot(rates(i).mx(LX,1),rates(i).my(LX,2)-rates(3).my(LX,1),'r-o');
        legend('L','H');xlabel('depth(um)');ylabel('Ri-Rs (hz)');title('initial response(wrt prior rate)');
        
        subplot(2,2,4); hold on;
        plot(rates(i).mx(LX,1),(rates(i).my(LX,1)-rates(3).my(LX,2))./rates(3).my(LX,2),'b-o');
        plot(rates(i).mx(LX,1),(rates(i).my(LX,2)-rates(3).my(LX,1))./rates(3).my(LX,1),'r-o');
        legend('L','H');xlabel('depth(um)');ylabel('(Ri-Rs)/Rs');title('initial response(normalized)'); 
        
        figure('name','Scatterplot of intial response');
        for j = L1 : L2
            subplot(2,L2-L1+1,j-(L1-1)); hold on;
            x = layer(j).data(:,iL)-layer(j).data(:,iSteadyRateH);
            str = ['wrt prior'];
            y = layer(j).data(:,iRsqL);
            plot(x,y,'bo');title(['Ri-Rs,',layer(j).assignment,', L']);
            xl = xlim; yl = ylim;
            plot(0*ones(1,2),yl,'g'); ylim(yl);
            if j==L1; xlabel('rate(hz)');ylabel('R2');legend(str);end
            
            subplot(2,L2-L1+1,L2-L1+1+(j-(L1-1)));hold on; 
            x = layer(j).data(:,iH)-layer(j).data(:,iSteadyRateL);
            y = layer(j).data(:,iRsqH);
            plot(x,y,'ro');title(['Ri-Rs,',layer(j).assignment,', H']);
            xl = xlim; yl = ylim;
            plot(0*ones(1,2),yl,'g'); ylim(yl);
            if j==L1; xlabel('rate(hz)');ylabel('R2');legend(str);end
        end
        
        
    end
    %plot the histogram of the rates.
    figure('name',['hist ',a{i}]);
    for j = L1 : L2
        subplot(2,L2-L1+1,j-(L1-1));hist(layer(j).result.rate(i).y(:,1));title([a{i},',',layer(j).assignment,',L']);
%         if j==1; xlabel(['rate(hz)']);ylabel('events'); title([a{i},' hist']); end
        if j==L1; xlabel(['rate(hz)']);ylabel('events'); legend([a{i}]);end
        subplot(2,L2-L1+1,L2-L1+1+(j-(L1-1)));
        hist(layer(j).result.rate(i).y(:,2));title([layer(j).assignment,', H']);
%         if j==1; xlabel(['rate(hz)']);ylabel('events'); title([a{i},' hist']); end
        if j==L1; xlabel(['rate(hz)']);ylabel('events');legend([a{i}]); end
    end
        
    %scatter plot of rates vs rsq
        figure('name',sprintf('Scatterplot of %s rate vs R2',a{i}));
        for j = L1 : L2
            subplot(2,L2-L1+1,j-(L1-1)); hold on;
            if strcmp(a{i},'steady')
                x = layer(j).data(:,iL)-layer(j).data(:,iSponRate);
                str = ['R-R0'];
                
            else
                x = layer(j).data(:,iL);
                str = 'R';
            end
            
            y = layer(j).data(:,iRsqL);
            plot(x,y,'bo');title([a{i},',',layer(j).assignment,',L']);
            if j==L1; xlabel('rate(hz)');ylabel('R2');legend(str);end
            xl = xlim; yl = ylim;
            plot(0*ones(1,2),yl,'g'); ylim(yl);
            %
            subplot(2,L2-L1+1,L2-L1+1+(j-(L1-1)));hold on; 
            if strcmp(a{i},'steady')
                x = layer(j).data(:,iH)-layer(j).data(:,iSponRate);
            else
                x = layer(j).data(:,iH);
            end
            y = layer(j).data(:,iRsqH);
            plot(x,y,'ro');title([a{i},',',layer(j).assignment,',H']);
            if j==L1; xlabel('rate(hz)');ylabel('R2');legend(str);end
            xl = xlim; yl = ylim;
            plot(0*ones(1,2),yl,'g'); ylim(yl);
        end
        figure('name','Scatterplot of Rate Ratio vs R2');
        for j = L1 : L2
            subplot(2,L2-L1+1,j-(L1-1)); hold on;
            plot(layer(j).data(:,iL)./layer(j).data(:,iH),layer(j).data(:,iRsqL),'bo');title([a{i},',',layer(j).assignment,',L']);
            if j==L1; xlabel('Rate Ratio');ylabel('R2(Low)');legend('R(L)/R(H)');end
            xl = xlim; yl = ylim;
            plot(1*ones(1,2),yl,'g'); ylim(yl);
            
            %
            subplot(2,L2-L1+1,L2-L1+1+(j-(L1-1))); hold on;
            plot(layer(j).data(:,iL)./layer(j).data(:,iH),layer(j).data(:,iRsqH),'ro');title([a{i},',',layer(j).assignment,',H']);
            if j==L1; xlabel('Rate Ratio');ylabel('R2(High)');legend('R(L)/R(H)');end
            xl = xlim; yl = ylim;
            plot(1*ones(1,2),yl,'g');ylim(yl);
            
        end
        
        figure('name','Scatterplot of Rate High vs Rate Low');
        for j = L1 : L2
            subplot(1,L2-L1+1,j-(L1-1)); hold on;
            plot(layer(j).data(:,iL),layer(j).data(:,iH),'bo');title([a{i},',',layer(j).assignment,',L vs H']);
            if j==L1; xlabel('Rate Low(hz)');ylabel('Rate High(hz)');end
            xl = xlim; yl = ylim;
            plot(linspace(xl(1),xl(2),100),linspace(xl(1),xl(2),100),'g'); ylim(yl);xlim(xl);
            axis equal;
        end
        
end

if useReal
    sub = 'Real';
else
    sub = 'Fit';
end

fn = sprintf('c:\\work\\2013\\%d_%d\\%s\\rsqL%.1f_rsqH%.1f',contrastLow,contrastHigh,sub,RsqThresholdL,RsqThresholdH);
if ~exist(fn,'dir'); mkdir(fn); end
for i = 1 : 22
    %savefigs(i,fullfile(fn,sprintf('fig%d.png',i)));
end



