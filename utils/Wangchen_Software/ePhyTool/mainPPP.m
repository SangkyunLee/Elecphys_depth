%prior/posterior distribution. run after 'main' script for rate histogram
%
%normalize the stim vectors
Stim = (StimImage.data'-128)/128;
%
%stim vector length in time (second) 
stimVT = 0.5; 
%stimulus frames refresh frequency
stimFreq = 30; %every 2 frames 
%stim vector length in units of stimulus bins.  
stimVL = stimVT * stimFreq; 
%observation x variables
X = reshape(Stim,[],stimVL);
%
nRow = size(X,1);
%variables per contrast block. 
nVar = tBlock*30 / stimVL;
%number of blocks for variables 
nVB = nRow / nVar;
%
lcIDX = []; hcIDX = [];
for i = 1 : nVB
    if mod(i,2)==1
        lcIDX = [lcIDX (i-1)*nVar+(1:nVar)];
    else
        hcIDX = [hcIDX (i-1)*nVar+(1:nVar)];
    end
end
X_low = X(lcIDX,:);
X_high =X(hcIDX,:);

%--------------------------------------------------------------------------
%extract the spike-triggered matrix
i = 16;
j = 1;
%or specifiy the channel index
chanIDX = 66;
if ~isempty(chanIDX)
    for k = 1 : length(neurons)
        if neurons{k}.channel == chanIDX
            i = k; 
            break;
        end
    end
end

if neurons{i}.clusters{j}.id == 255
    disp('invalid unit');
    return;
end

if neurons{i}.clusters{j}.id == 0 
    disp('unsorted unit');
%     return;
end

%select time window for response calculation.
t_exclude = [0 10]; %exclusion window size.

spkt_low = neurons{i}.clusters{j}.class{1}.member{1}.timestamps;
spkt_high = neurons{i}.clusters{j}.class{1}.member{2}.timestamps;
%contrast block onset

%remove the transistion spikes and keep the spikes from stable state.
for cc = 1 : length(lowConOnsets)
        tind = spkt_low > t_SETS(cc)+t_exclude(1) &  spkt_low <= t_SETS(cc)+t_exclude(2);
        spkt_low(tind) = [];
end

for cc = 1 : length(highConOnsets)
        tind = spkt_high > t_SETS(cc)+t_exclude(1) &  spkt_high <= t_SETS(cc)+t_exclude(2);
        spkt_high(tind) = [];
end

%spike counts per bin
sp_low = histc(spkt_low,[t_SETS t_SETS(end)+2/60]);
sp_low(end) = [];
%

%spike counts per bin
sp_high = histc(spkt_high,[t_SETS t_SETS(end)+2/60]);
sp_high(end) = [];

%
%seperate the low/high contrast spikes
%time bins in each contrast block
nTimeBins = tBlock * 60 /2;

iisp_low = find(sp_low>0);
iisp_high =find(sp_high>0);
%remove spikes near the border for vector extraction
iisp_low(iisp_low < stimVL | iisp_low + stimVL > length(Stim)) = [];
iisp_high(iisp_high < stimVL | iisp_high + stimVL > length(Stim)) = [];

%stim matrix where each row is loaded with full space-time stimulus at a particular
%moment in time.
SS_low = makeStimRows(Stim, stimVL,iisp_low,-1);
SS_high = makeStimRows(Stim, stimVL,iisp_high,-1);
%extract vectors after spikes
SS_low_as = makeStimRows(Stim,stimVL,iisp_low,1);
SS_high_as= makeStimRows(Stim,stimVL,iisp_high,1);

[COEFF_spk_low,SCORE_spk_low,LATENT_spk_low] = princomp(SS_low);
[COEFF_spk_high,SCORE_spk_high,LATENT_spk_high] = princomp(SS_high);

% SCORE_low = (X_low)/(COEFF_spk_low');
% SCORE_high= (X_high)/(COEFF_spk_high');
SCORE_low = SS_low_as/(COEFF_spk_low');
SCORE_high= SS_high_as/(COEFF_spk_high');

%stim vector average
sva_low = mean(SS_low,1);
sva_high= mean(SS_high,1);
%
sva_low_score = sva_low/COEFF_spk_low';
sva_high_score = sva_high/COEFF_spk_high';

%project the raw stimulus into principal components.
h1=figure('name','PC1 vs PC2');
%prior for low c
subplot(2,2,1);plot(SCORE_low(:,1),SCORE_low(:,2),'k.');axis image;
%pc for low contrast
subplot(2,2,2);plot(COEFF_spk_low(:,1),'k');hold on; plot(COEFF_spk_low(:,2),'g'); plot(mean(SS_low,1)/norm(mean(SS_low,1)),'r');
h_leg = legend('PC1','PC2','MES');
% h_pos = get(h_leg,'Position'); set(h_leg,'Position',[0.8 0.5 h_pos(3:4)]); 
xlim([1 stimVL]);
%prior for high c
subplot(2,2,3);plot(SCORE_high(:,1),SCORE_high(:,2),'k.');axis image;
%pc for high c
subplot(2,2,4);plot(COEFF_spk_high(:,1),'k');hold on; plot(COEFF_spk_high(:,2),'g'); plot(mean(SS_high,1)/norm(mean(SS_high,1)),'r');
legend('PC1','PC2','MES');
% h_pos = get(h_leg,'Position'); set(h_leg,'Position',[0.8 0.5 h_pos(3:4)]); 
xlim([1 stimVL]);

figure(h1);
%spike inducing stim vec
subplot(2,2,1);hold on;plot(SCORE_spk_low(:,1),SCORE_spk_low(:,2),'b.'); axis image;xlabel('PC1');ylabel('PC2');
%
plot(sva_low_score(1),sva_low_score(2),'r+');
title(sprintf('Low C, Elec%d, Cluster%d',chanIDX,neurons{i}.clusters{j}.id));
%spike inducing stim vec for high.
subplot(2,2,3);hold on;plot(SCORE_spk_high(:,1),SCORE_spk_high(:,2),'b.'); axis image;xlabel('PC1');ylabel('PC2');
plot(sva_high_score(1),sva_high_score(2),'r+');
title(sprintf('High C, Elec%d, Cluster%d',chanIDX,neurons{i}.clusters{j}.id)); 

nbins = 21; x_pc = linspace(-1,1,nbins);
%histgram of projections along components.
hist_low_pc1 = hist(SCORE_spk_low(:,1),x_pc);
prob_low_pc1 = hist_low_pc1/sum(hist_low_pc1);
hist_low_pc2 = hist(SCORE_spk_low(:,2),x_pc);
prob_low_pc2 = hist_low_pc2/sum(hist_low_pc2);
%
raw_hist_low_pc1 = hist(SCORE_low(:,1),x_pc);
raw_prob_low_pc1 = raw_hist_low_pc1/sum(raw_hist_low_pc1);
raw_hist_low_pc2 = hist(SCORE_low(:,2),x_pc);
raw_prob_low_pc2 = raw_hist_low_pc2/sum(raw_hist_low_pc2);
%
hist_high_pc1 = hist(SCORE_spk_high(:,1),x_pc);
prob_high_pc1 = hist_high_pc1/sum(hist_high_pc1);
hist_high_pc2 = hist(SCORE_spk_high(:,2),x_pc);
prob_high_pc2 = hist_high_pc2/sum(hist_high_pc2);
%
raw_hist_high_pc1 = hist(SCORE_high(:,1),x_pc);
raw_prob_high_pc1 = raw_hist_high_pc1/sum(raw_hist_high_pc1);
raw_hist_high_pc2 = hist(SCORE_high(:,2),x_pc);
raw_prob_high_pc2 = raw_hist_high_pc2/sum(raw_hist_high_pc2);

figure('name','Histgram of Projection');  
subplot(2,2,1);hold on; plot(x_pc,raw_prob_low_pc1,'k');plot(x_pc,prob_low_pc1,'b');title('Low C, PC1 Projection');legend('P(stim)','P(stim|spike)');
subplot(2,2,2);hold on; plot(x_pc,raw_prob_low_pc2,'k'); plot(x_pc,prob_low_pc2,'b');title('Low C, PC2 Projection');
subplot(2,2,3);hold on; plot(x_pc,raw_prob_high_pc1,'k');plot(x_pc,prob_high_pc1,'b');title('High C, PC1 Projection');
subplot(2,2,4);hold on; plot(x_pc,raw_prob_high_pc2,'k'); plot(x_pc,prob_high_pc2,'b');title('Low C, PC2 Projection');
figure('name','Quotient of Raw and Spike');
subplot(2,2,1);hold on; plot(x_pc,prob_low_pc1./raw_prob_low_pc1,'k');title('Low C, PC1'); xlabel('PC1 Response');ylabel('Firing Rate');
subplot(2,2,2);hold on; plot(x_pc,prob_low_pc2./raw_prob_low_pc2,'k');title('Low C, PC2'); xlabel('PC2 Response');ylabel('Firing Rate');
subplot(2,2,3);hold on; plot(x_pc,prob_high_pc1./raw_prob_high_pc1,'k');title('High C, PC1'); xlabel('PC1 Response');ylabel('Firing Rate');
subplot(2,2,4);hold on; plot(x_pc,prob_high_pc2./raw_prob_high_pc2,'k');title('High C, PC2'); xlabel('PC2 Response');ylabel('Firing Rate');

figure('name','Eigenvalues');
subplot(2,1,1);plot(1:length(LATENT_spk_low),LATENT_spk_low,'b-o');xlabel('Index');ylabel('Eigenvalues');
subplot(2,1,2);plot(1:length(LATENT_spk_high),LATENT_spk_high,'b-o');xlabel('Index');ylabel('Eigenvalues');

%==========================================================================
%------------- compute everything with resmapled stimulus -----------------
%resample the stimlus with finer bin size
resbin = 5*1e-3; %bin size in ms.
%kernel size for the resampling bin size
rStimVL = round(stimVT/resbin);
%resmaple time vector.
rts = t_SETS(1):resbin:t_SETS(end);
%resampled stimulus. interp1q takes column vectors
rStim = interp1q(t_SETS',Stim,rts');
%spike counts per bin
rsc_low = histc(spkt_low,rts);
rsc_high= histc(spkt_high,rts);
%index of bins having spikes.  
rsi_low = find(rsc_low>0);
rsi_high =find(rsc_high>0);
%remove spikes near the border for vector extraction
rsi_low(rsi_low < rStimVL | rsi_low + rStimVL > length(Stim)) = [];
rsi_high(rsi_high < rStimVL | rsi_high + rStimVL > length(Stim)) = [];
%pre-spike and post-spike stimulus vector array.
preSpkStim_low = makeStimRows(rStim,rStimVL,rsi_low,-1);
postSpkStim_low = makeStimRows(rStim,rStimVL,rsi_low,1);
preSpkStim_high = makeStimRows(rStim,rStimVL,rsi_high,-1);
postSpkStim_high = makeStimRows(rStim,rStimVL,rsi_high,1);

%bin index for spike counts over the full course of stimulus
%stimIDX = rStimVL+1 : length(rts);
%seperate bins for the L/H
stimIDX_low = [];
stimIDX_high = [];
%num of resample bins in each contrast block.
nrsBins = tBlock /resbin;

for cc = 1 : nVB
    indices = (cc-1)*nrsBins+(1:nrsBins);
%remove the indices at the boundary. i.e, less than the length of kernel
%size. 
    indices(1:rStimVL)=[];
    if mod(cc,2)==1
        stimIDX_low = [stimIDX_low indices];
    else
        stimIDX_high = [stimIDX_high indices];
    end
end

%spike counts for resample bins associated with stimulus vectors.
spikeCounts_low = rsc_low(stimIDX_low);
spikeCounts_high= rsc_high(stimIDX_high);

%reampled stimulus vectors over the full course of stimulus
rX_low = makeStimRows(rStim,rStimVL+1,stimIDX_low,-1);
rX_high = makeStimRows(rStim,rStimVL+1,stimIDX_high,-1);
%remove the tailing element in the vectors so that they are right after the
%bin for spike counting.
rX_low(:,end)=[];
rX_high(:,end)=[];

%
MES_low = mean(preSpkStim_low,1);
%normalized MES
MES_low = MES_low/norm(MES_low);
MES_high= mean(preSpkStim_high,1);
%
MES_high = MES_high/norm(MES_high);
%effective stimulus
effs_low = MES_low * rX_low' ;
effs_high= MES_high* rX_high';
%divide the effective stim in the unit of half-sigma.
%contrast in percentage
contrast_low = neurons{i}.clusters{j}.class{1}.member{1}.value;
contrast_high= neurons{i}.clusters{j}.class{1}.member{2}.value;
%std in gun value.
std_low = contrast_low * 128 / 100;
std_high= contrast_high * 128 / 100;
%normalize to mean value
std_low = std_low /128;
std_high= std_high/128;
%
%effective sigma from fit 
[effs_mu_low,effs_std_low] = normfit(effs_low);
[effs_mu_high,effs_std_high]=normfit(effs_high);
%bin the histogram of effective stim in half-sigma
esv_low_bin = min(effs_low)-effs_std_low : effs_std_low/2 : max(effs_low)+effs_std_low;
esv_high_bin= min(effs_high)-effs_std_high : effs_std_high/2: max(effs_high)+effs_std_high;

esv_low = hist(effs_low,esv_low_bin);
esv_high= hist(effs_high,esv_high_bin);

figure('name','effective stim hist'); plot(esv_low_bin/(effs_std_low/2),esv_low,'b'); hold on; plot(esv_high_bin/(effs_std_high/2),esv_high,'r');
xlabel('Effective Stimulus'); ylabel('Histogram');title('Effective Stimulus Values');legend('Low Contrast','High Contrast');
% %# of spikes(> 0) in bin of stim frames. 
% spks_low = rsc_low(rsi_low);
% spks_high= rsc_high(rsi_high);
% %
% spks_mes_low = zeros(size(spks_low));
% spks_mes_high= zeros(size(spks_high));
% %# of spikes after each stimulus vector.
% for cc = 1 : length(spks_mes_low)
% %     startbin = iisp_low(cc);
% %     lastbin = startbin - stimVL;
% %     if lastbin < 1; lastbin = 1; end
%     spks_mes_low(cc) = sp_low(rsi_low(cc));
% end
%     
% for cc = 1 : length(spks_mes_high)
%     startbin = iisp_high(cc);
%     lastbin = startbin - stimVL;
%     if lastbin < 1; lastbin = 1; end
%     spks_mes_high(cc) = sum(sp_high(lastbin:startbin));
% end
% 
% %preceeding spikes weighted by spike counts in each bin.
% w_spks_mes_low = spks_mes_low .* spks_low;
% w_spks_mes_high= spks_mes_high.* spks_high;

%
resp_low = length(esv_low_bin);
resp_high = length(esv_high_bin);
%find the indices in preceeding spikes vector (w_spks_mes_low) by binned
%esv effs_low and esv_low_bin
for cc = 1 : length(esv_low_bin)
    startval = esv_low_bin(cc) - effs_std_low/4;
    lastval = esv_low_bin(cc) + effs_std_low/4;
    indices = find(effs_low > startval & effs_low <= lastval);
    if ~isempty(indices)
%         resp_low(cc) = sum(w_spks_mes_low(indices));
        %resp_low(cc) = sum(w_spks_mes_low(indices))/sum(spks_low(indices));
        resp_low(cc) = mean(spikeCounts_low(indices));
    else
        resp_low(cc) = 0;
    end
end
    
for cc = 1 : length(esv_high_bin)
    startval = esv_high_bin(cc) - effs_std_high/4;
    lastval = esv_high_bin(cc) + effs_std_high/4;
    indices = find(effs_high > startval & effs_high <= lastval);
    if ~isempty(indices)
        %resp_high(cc) = sum(w_spks_mes_high(indices));
        %resp_high(cc) = sum(w_spks_mes_high(indices))/sum(spks_high(indices));
        resp_high(cc) = mean(spikeCounts_high(indices));
    else
        resp_high(cc) = 0;
    end
end

figure('name','response function'); 
subplot(2,1,1); plot(esv_low_bin/(effs_std_low/2),resp_low/stimVT);xlabel('Effective Stimulus'); ylabel('Frequency');title('Response Func - Low C');
subplot(2,1,2); plot(esv_high_bin/(effs_std_high/2),resp_high/stimVT);xlabel('Effective Stimulus'); ylabel('Frequency');title('Response Func - High C');



