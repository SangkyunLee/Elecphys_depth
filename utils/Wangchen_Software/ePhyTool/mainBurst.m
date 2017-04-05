%neruons loaded in workspace. 
%burst pattern analysis.

BurstDeltaT0 = 0 ;
BurstDeltaTM = 10 * 1e-3;
BurstDeltaT1 = 1200 * 1e-3;
BurstDeltaTdt = 10 *1e-3;
BurstDeltaTMdt = 1 * 1e-3;
BurstDeltaN1 = (BurstDeltaT1 - BurstDeltaTM)/BurstDeltaTdt + 1 ;
BurstDeltaN2 = (BurstDeltaTM - BurstDeltaT0)/BurstDeltaTMdt + 1 ;
BurstDeltaN = BurstDeltaN1 + BurstDeltaN2 - 1;

BurstMtpT = [BurstDeltaT0:BurstDeltaTMdt:BurstDeltaTM];
BurstMtpT(end)=[];
BurstMtpT = [BurstMtpT BurstDeltaTM:BurstDeltaTdt:BurstDeltaT1];


% maxBurstN --- highest # of spikes in the burst. 
% BurstDeltaN --- # of bins to divide spike train.

% % %temp test to compare with christols's data.
% % maxSpikeTrainN=48;

nc = 0 ; %non-empty channels
cid = zeros(1,length(neurons));
for i = 1 : length(neurons)
    if ~isempty(neurons{i}.timestamps)
        nc = nc + 1;
        cid(i) = i;
    end
end


%only analyze the first two channels for normluminace data.
cid(4:end) =0;
nc = length(find(cid>0));

pc = 2; 
pr = ceil(nc/pc);

neurons1 = neurons;

maxBurstN = 8;

BurstMtpPct = zeros(maxBurstN,BurstDeltaN);

%select the last segment where f.r modulated with contrast.
tw1 = 2880;
tw2 = 3480;

pid = 0;
for i = 1 : length(neurons)
    if cid(i)==0; continue; end
    pid = pid + 1;
%    subplot(pr,pc,pid);
    for j = 1 : length(neurons{i}.clusters)
        %1 class only
        for k = 1 : length(neurons{i}.clusters{j}.class{1}.member)
            spkt = neurons{i}.clusters{j}.class{1}.member{k}.timestamps;
            spkt = spkt(spkt>=tw1 & spkt < tw2);
            fprintf('computing ch%d,cluster%d,member%d,spikes%d...\n',i,j,k,length(spkt));
            BurstMtpPct = zeros(maxBurstN,BurstDeltaN);
            for m = 1 : BurstDeltaN
                %t = BurstDeltaT0 + ( m - 1) * BurstDeltaT ;
                t = BurstMtpT(m);
                burstpat = BurstPattern(spkt,t);
                burstorder = min([size(burstpat,1) maxBurstN]);
                BurstMtpPct(1:burstorder,m) = burstpat(1:burstorder,2);
                neurons1{i}.clusters{j}.class{1}.member{k}.burst = BurstMtpPct;
            end
            
        end
    end
end
% MultiSpkPct = BurstPattern(InHomoSpikeTrain{maxSpikeTrainN},BurstDeltaT1);
% MultiSpkPct = BurstPattern(a,BurstDeltaT1);

for i = 1 : 2 %2 contrast levels
    for j = 1 : 2 %2 units at most
        figure('name',sprintf('Burst@contrast[%d],unit[%d]',i,j)); hold on;
        cBurstPlot = {'r-','b-','g-','k-','r.-','b.-','g.-','k.-','ro','bo','go','ko'};
        %cid 
        pid = 0;
        for k = 1 : length(neurons)
            if cid(k)==0; continue; end
            pid = pid + 1;
            subplot(pr,pc,pid); hold on;
            title(sprintf('Burst@contrast[%d],unit[%d]',i,j));
            try
                burstpat = neurons1{k}.clusters{j}.class{1}.member{i}.burst;
            catch
                burstpat = zeros(size(BurstMtpPct));
            end
            for m = 1 : maxBurstN
                plot(BurstMtpT, burstpat(m,:),cBurstPlot{mod(m-1,length(cBurstPlot))+1},'LineWidth',1.4);
                legend(['M=',int2str(m)]);
            end
        end
    end
end


% % ======= Burst Analysis for Homo Spk Train.
% 
% BurstDeltaN = (BurstDeltaT1 - BurstDeltaT0)/BurstDeltaT + 1 ;
% 
% % maxBurstN --- highest # of spikes in the burst. 
% % BurstDeltaN --- # of bins to divide spike train.
% 
% HomoMultiSpkPct = BurstPattern(HomoSpikeTrain{maxHomoSpikeTrainI},BurstDeltaT1);
%  
% maxHomoBurstN = size(HomoMultiSpkPct,1);
% 
% HomoBurstMtpPct = zeros(maxHomoBurstN,BurstDeltaN);
% 
% HomoBurstMtpT = [BurstDeltaT0:BurstDeltaT:BurstDeltaT1];
%  
% for i = 1 : BurstDeltaN
%      
%     t = BurstDeltaT0 + ( i - 1) * BurstDeltaT ;
%  
%     HomoMultiSpkPct = BurstPattern(HomoSpikeTrain{maxHomoSpikeTrainI},t);
% 
%     lenHomoBurstMtp = length(HomoMultiSpkPct(:,2));
%     
%     HomoBurstMtpPct(1:lenHomoBurstMtp,i) = HomoMultiSpkPct(:,2);
%    
% end
% 
% figure('name','Multiples Pct% in Burst for Homo'); hold on;
% 
% cBurstPlot = {'r-','b-','g-','k-','r.-','b.-','g.-','k.-','ro','bo','go','ko'};
% 
% for i = 1 : maxHomoBurstN
%         if i > 4 && i < maxHomoBurstN ; continue; end;
%         plot(HomoBurstMtpT, HomoBurstMtpPct(i,:),cBurstPlot{mod(i-1,length(cBurstPlot))+1},'LineWidth',1.4);
%         legend(['Multiples M = ',int2str(i)]);
% end
 