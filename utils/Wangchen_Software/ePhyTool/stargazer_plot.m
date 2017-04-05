%seisure event time from eeg2
te1 = [173.49, 1570.58, 2004.21, 2954.97, 3193.05, 3211.08];
te2 = [1109.17, 1370.00, 1454.16, 1558.18, 2369.13, 3490.43, 3894.35, 4013.33, 4375.34, 4658.01, 4773.50];

eegdataIdx = 2;
switch eegdataIdx 
    case 1
        te = te1;
        data_eeg = load('c:\work\Experiment\Latest\new\ePhyTool\eeg1.mat');
        nchans = 10;
    case 2
        te = te2;
        data_eeg = load('c:\work\Experiment\Latest\new\ePhyTool\eeg2.mat');
        nchans = 8;
end


%plot seisure time length
ET = 3; %3sec

lfp_sampleRate = 1000; 

inbrain_chans = cmap(1:nchans,3); %1000um for standard probe

% figure;
% nr = 1;
% nc = length(te2);
x0 = -1 : 1/lfp_sampleRate : ET;

ie = round(te * lfp_sampleRate) ; %indices

clear data_lfp;
%data_lfp = zeros(length(te),length(inbrain_chans),length(x0));

for i = 1 : length(te)
    x = te(i) + x0;
    
    ind1 = x(1)*lfp_sampleRate;
    ind2 = x(end)*lfp_sampleRate;
    t1 = x(1);
    t2 = x(end);
%     ind1 = ie(i);
%     ind2 = ind1 + ET * lfp_sampleRate;
%     t1 = ind1 / lfp_sampleRate;
%     t2 = ind2 / lfp_sampleRate;
%     
    %x = t1:1/lfp_sampleRate:t2;
    
    data_lfp(i).eegOnset = te(i);
    data_lfp(i).time = x;
    data_lfp(i).lfp = zeros(length(inbrain_chans),length(x));
    
    fig_h = figure('name',sprintf('EEG event %d',i)); hold on;
    
    %subplot(nr,nc,i); hold on;
    
    eind1 = round(t1 * 2000); %indices in eeg data 
    eind2 = round(t2 * 2000); 
    
    for j = 1 : length(inbrain_chans)
        chanIDX = find(inbrain_chans(j) == [h.ElectrodesInfo.ElectrodeID]);
        
        y = h.Data(chanIDX,ind1:ind2);
        ymin = min(y);
        ymax = max(y);
        if j == 1
            ymin_old = ymin;
            ymax_old = ymax;
            ymin_1 = ymin;
            ymax_1 = ymax;
        end
        %raw lfp data
        data_lfp(i).lfp(j,:) = y;
        
        y = y + ymax_old + (ymax_old-ymin_old)*0.6;
            
        plot(x,y,'k');
        
        ymin_old = min(y);
        ymax_old = max(y);
        
        layertext = ''; %reset text
        
        switch j
            case 1
                layertext = 'Layer 5/6';
            case 7
                if eegdataIdx == 1; 
                    layertext = 'Layer 4';
                end
            case 4
                if eegdataIdx == 2
                    layertext = 'Layer 4'; 
                end
            case 6
                if eegdataIdx == 2
                    layertext = 'Layer 2/3'; 
                end
            case 9
                if eegdataIdx == 1
                    layertext = 'Layer 2/3';
                end
            otherwise
                layertext = '';
        end
        
        text(x(end)-(x(end)-x(1))*0.15, y(end)-(ymax_old-ymin_old)*0.39, layertext);

    end

    %plot eeg trace on top
    ex = [eind1 : 1 : eind2] / 2000 ;
    ey = double(data_eeg.y(eind1:eind2));
    ey = 2.2 * ey; %amplify the signal for display.
    ey = ey + ymax_old + (ymax_old-ymin_old)*0.8;
    
    plot(ex,ey,'r');
    
    ymax_old = max(ey);
    ymin_old = min(ey);
    
    xlim([t1,t2]);
    ylim([ymin_1 ymax_old+(ymax_old-ymin_old)*0.7]);
    yl = ylim;
    
    plot(te(i)*ones(1,100),linspace(yl(1),yl(2),100),'k--');
    
    xlabel('Time (s)','fontsize',12);
    ylabel('LFP','FontSize',12);
    set(gca,'XTick',round(t1:1:t2));
    set(gca,'YTickLabel','');
    title(sprintf('EEG%d,Event%d',eegdataIdx,i));
    savePlotAsPic(fig_h,sprintf('c:\\work\\stargazer_LFP%d_event%d.png',eegdataIdx,i));
end

%==========================================================================

fr_max = zeros(length(te),length(inbrain_chans));

for i = 1 : length(te)
    ind1 = ie(i);
    ind2 = ind1 + ET * lfp_sampleRate;
    t1 = ind1 / lfp_sampleRate;
    t2 = ind2 / lfp_sampleRate;
    
    fig_h = figure('name',sprintf('Firing Rate event %d',i)); hold on;
    
    dt = 200/lfp_sampleRate;
    x = t1:dt:t2;
    
    fr_chan = zeros(length(inbrain_chans),length(x));
    
    for j = 1 : length(inbrain_chans)
        chanIDX = find(inbrain_chans(j) == [NEV.ElectrodesInfo.ElectrodeID]);
        tI = (double(NEV.Data.Spikes.Electrode)==inbrain_chans(j));
        ts = double(NEV.Data.Spikes.TimeStamp(tI))/30000; %
        y = histc(ts,x);
        y = y/dt; 
        
        if isempty(y) 
            y = zeros(size(x));
        end
        
        ymin = min(y);
        ymax = max(y);
        if j == 1
            ymin_old = ymin;
            ymax_old = ymax;
            ymin_1 = ymin;
            ymax_1 = ymax;
        end
        
        fr_max(i,j) = ymax;
        
        %y = y + ymax_old + (ymax_old-ymin_old)*0.2;
            
        %plot(x,y,'k');
        fr_chan(j,:) = y;
        
        ymin_old = min(y);
        ymax_old = max(y);

    end
    
    for j = 1 : length(inbrain_chans)
        y = fr_chan(j,:);
        ymax = max(y);
        ymin = min(y);
        if j == 1 
            ymax_old = ymax;
            ymin_old = ymin;
            ymin_1  = ymin;
            ymax_1  = ymax;
        end
        if all(y==0)
            y = y + ymax_old + max(fr_max(i,:))/2;
        else
            y = y + ymax_old + max(fr_max(i,:))*0.2;
        end
        
        plot(x,y,'k');
        ymax_old = max(y);
        ymin_old = min(y);
    end
    
    xlim([t1,t2]);
    y1 = ymin_1-max(fr_max(i,:))*0.1;
    y2 = ymax_old+max(fr_max(i,:))*0.1;
    if y1==y2
        y2 = y1 + 1;
    end
    ylim([y1,y2]);
    xlabel('Time (s)','fontsize',12);
    ylabel('Firing Rate','FontSize',12);
    set(gca,'XTick',round(t1:1:t2));
    set(gca,'YTickLabel','');
    title(sprintf('EEG%d,Event%d',eegdataIdx,i));
    savePlotAsPic(fig_h,sprintf('c:\\work\\stargazer_FiringRate%d_event%d.png',eegdataIdx,i));

%%=========================================================================

end


fig_h = figure('name','firing rate');
for j = 1 : length(inbrain_chans)
    chanIDX = find(inbrain_chans(j) == [NEV.ElectrodesInfo.ElectrodeID]);
    tI = (NEV.Data.Spikes.Electrode==inbrain_chans(j));
    ts = double(NEV.Data.Spikes.TimeStamp(tI))/30000; %
    tbin = 0 : 1 : h.MetaTags.DataPoints/30000;
    y = histc(ts,tbin);
    y = y/10;

    if isempty(y)
        y = zeros(size(x));
    end

    ymin = min(y);
    ymax = max(y);
    if j == 1
        ymin_old = ymin;
        ymax_old = ymax;
        ymin_1 = ymin;
        ymax_1 = ymax;
    end

    %fr_max(j) = ymax;

    y = y + ymax_old + (ymax_old-ymin_old)*0.2;

    plot(tbin,y,'k');
    %fr_chan(j,:) = y;

    ymin_old = min(y);
    ymax_old = max(y);
    xlabel('Time(s)');
    ylabel('Firing Rate(hz)');

end

savePlotAsPic(fig_h,sprintf('c:\\work\\stargazer_FiringRate%d.png',eegdataIdx));

save(['lfp',num2str(eegdataIdx),'.mat'], 'data_lfp');


