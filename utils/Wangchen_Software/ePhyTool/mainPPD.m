%compute the prior/posterior distribution, i.e P(s)/P(s|r). run after 'main' script for rate histogram
%stimulus vectors extraction
% *1)Projection distribution.1)count the spikes in raw time bins (recorded onsets,~33ms) and extract the raw vectors for non-zero bins. 
%                            2)expand the vector array and onset array per-spike.
%                            3)make resample bins (mean interval from recorded onsets) per-spike and interpolate the raw
%                            vectors.
% *2)STA:  the same procedure as *1). use finer bins.(~5ms)
% *3)Effective Stimulus :    1) resample the raw stim with STA bin.  
%                            2) compute the effective stimulus and firing rate.
%

%% channel selection
%override the [i,j] indices with the actual channel/unit id indices.
chanIDX = 16; %actual channel id number
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

if isempty(i); disp('Channel not found'); end
if isempty(j); disp('Unit not found'); end

if neurons{i}.clusters{j}.id == 255
    disp('invalid unit');
    return;
end
if neurons{i}.clusters{j}.id == 0
    disp('unsorted unit');
    %         return;
end

%% time vectors setup
%stim vector length in time (second) 
stimVT = 0.5;
%average onsets interval.
mbin = mean(diff(t_SETS));
%resampling bin for projection calculation
pbin = mbin;
%sta bin 
staBin = 5*1e-3;
%kernel size in the raw time bins
stimVL = round(stimVT/mbin);
%kernal size in the resample bins for projection
pStimVL = round(stimVT/pbin);
%kernel size in the resmapled sta bin
rStimVL = round(stimVT/staBin);
%sta time output
staOut = -(rStimVL-1)*staBin:staBin:0;

%flip Stim to row vector
if size(Stim,1) > size(Stim,2)
    Stim = Stim';
end
%
if size(t_SETS,1) > size(t_SETS,2)
    t_SETS = t_SETS';
end

%flag to resample. set to false to skip resampling for different channels from the same data set 
resampleRaw = true;
%resampled time to compute effective stimulus 
if resampleRaw 
    disp('Resample the raw stimulus for effective stimulus computation');
    rt = t_SETS(1):staBin:t_SETS(end);
    rStim = interpNN(t_SETS,Stim,rt);
    disp('Resample done');
end

%--------------------------------------------------------------------------
%select time window for response calculation.
t_exclude = [0 0]; %exclusion window size.
%spike trains for low/high contrast
spkt_low = neurons{i}.clusters{j}.class{1}.member{1}.timestamps;
spkt_high = neurons{i}.clusters{j}.class{1}.member{2}.timestamps;

if size(spkt_low,1) > size(spkt_low,2)
    spkt_low = spkt_low';
end

if size(spkt_high,1) > size(spkt_high,2)
    spkt_high = spkt_high';
end

%remove the spikes in transition state with selected time window and spikes
%with short foward and backward vectors(i.e, shorter than the kernel)
for cc = 1 : length(lowConOnsets)
        tind1 = spkt_low >= lowConOnsets(cc)+t_exclude(1) &  spkt_low < lowConOnsets(cc)+t_exclude(2);
        tind2 = (spkt_low >= lowConOnsets(cc))& (spkt_low <= highConOnsets(cc)) & ...
            ((spkt_low < lowConOnsets(cc)+ stimVT) | spkt_low>highConOnsets(cc)-stimVT);
        spkt_low(tind1 | tind2) = [];
end

for cc = 1 : length(highConOnsets)
        tind1 = spkt_high >= highConOnsets(cc)+t_exclude(1) &  spkt_high < highConOnsets(cc)+t_exclude(2);
        tind2 = (spkt_high >= highConOnsets(cc))& (spkt_high <= highConOnsets(cc)+tBlock) & ...
            ((spkt_high < highConOnsets(cc)+ stimVT) | spkt_high>highConOnsets(cc)+tBlock-stimVT);
        spkt_high(tind1 | tind2) = [];
end

%spike counts in raw time bins.
sc_low = histc(spkt_low,t_SETS);
sc_high= histc(spkt_high,t_SETS);
%index of bins having spikes.  
si_low = find(sc_low>0);
si_high =find(sc_high>0);

%% stimulus vectors setup 
%============1. Extract Raw Stimulus Vectors/Onsets ==========================
%array of stimulus vectors triggered on bins with spikes. the bin index is shifted
%by 1 for the post-spike extraction.
OnSpike_preSpkStim_low = makeStimRows(Stim',stimVL,si_low,-1);
OnSpike_postSpkStim_low = makeStimRows(Stim',stimVL,si_low+1,1);
OnSpike_preSpkStim_high = makeStimRows(Stim',stimVL,si_high,-1);
OnSpike_postSpkStim_high = makeStimRows(Stim',stimVL,si_high+1,1);
%extract the onset timestamps of stim for sta interpolation
OnSpike_preSpkStimOnset_low = makeStimRows(t_SETS',stimVL,si_low,-1);
OnSpike_postSpkStimOnset_low = makeStimRows(t_SETS',stimVL,si_low+1,1);
OnSpike_preSpkStimOnset_high = makeStimRows(t_SETS',stimVL,si_high,-1);
OnSpike_postSpkStimOnset_high = makeStimRows(t_SETS',stimVL,si_high+1,1);

%===========2. Expand the arrays per spike =================================
%expand the stimulus vector array by spike counts
preSpkStim_low = [];
postSpkStim_low = [];
preSpkStim_high = [];
postSpkStim_high = [];
%
preSpkStimOnset_low = [];
postSpkStimOnset_low = [];
preSpkStimOnset_high = [];
postSpkStimOnset_high =[];

for cc = 1 : length(si_low)
    nspks = sc_low(si_low(cc));
    preSpkStim_low = [preSpkStim_low ; repmat(OnSpike_preSpkStim_low(cc,:),nspks,1)];
    postSpkStim_low= [postSpkStim_low; repmat(OnSpike_postSpkStim_low(cc,:),nspks,1)];
    preSpkStimOnset_low = [preSpkStimOnset_low; repmat(OnSpike_preSpkStimOnset_low(cc,:),nspks,1)];
    postSpkStimOnset_low= [postSpkStimOnset_low;repmat(OnSpike_postSpkStimOnset_low(cc,:),nspks,1)];
end

for cc = 1 : length(si_high)
    nspks = sc_high(si_high(cc));
    preSpkStim_high = [preSpkStim_high;  repmat(OnSpike_preSpkStim_high(cc,:),nspks,1)];
    postSpkStim_high= [postSpkStim_high; repmat(OnSpike_postSpkStim_high(cc,:),nspks,1)];
    preSpkStimOnset_high = [preSpkStimOnset_high; repmat(OnSpike_preSpkStimOnset_high(cc,:),nspks,1)];
    postSpkStimOnset_high= [postSpkStimOnset_high;repmat(OnSpike_postSpkStimOnset_high(cc,:),nspks,1)];
end

%==========  3.Setup time array for sta interpolation  ====================
%sta time array to interpolate stimulus array.
staTV_preSpkStim_low = repmat(staOut,length(spkt_low),1) + repmat(spkt_low',1,length(staOut));
staTV_preSpkStim_high = repmat(staOut,length(spkt_high),1) + repmat(spkt_high',1,length(staOut));
%sta 
sta_preSpkStim_low = zeros(size(staTV_preSpkStim_low));
sta_preSpkStim_high= zeros(size(staTV_preSpkStim_high));

%==========4. Interpolate the sta vectors with the raw vectors ============
for cc = 1 : length(spkt_low)
    sta_preSpkStim_low(cc,:) = interpNN(preSpkStimOnset_low(cc,:),preSpkStim_low(cc,:),staTV_preSpkStim_low(cc,:));
end

for cc = 1 : length(spkt_high)
    sta_preSpkStim_high(cc,:) = interpNN(preSpkStimOnset_high(cc,:),preSpkStim_high(cc,:),staTV_preSpkStim_high(cc,:));
end
%compute STA
sta_low = mean(sta_preSpkStim_low,1);
sta_high= mean(sta_preSpkStim_high,1);
%standard error
ste_low = std(sta_preSpkStim_low,1)/sqrt(size(sta_preSpkStim_low,1));
ste_high = std(sta_preSpkStim_high,1)/sqrt(size(sta_preSpkStim_high,1));
%optional: override sta in neuron struct. run plotStaFig afterwards
neurons{i}.clusters{j}.class{1}.member{1}.sta = (sta_low * 128) + 128; %scale back to gun values for plotSTAFig.
neurons{i}.clusters{j}.class{1}.member{1}.std = (ste_low * 128);
neurons{i}.clusters{j}.class{1}.member{2}.sta = (sta_high* 128) + 128;
neurons{i}.clusters{j}.class{1}.member{2}.std = (ste_high* 128);
%reset sta time
xSTA = staOut;

%compute STA(or MES) from the raw vectors
MES_low = mean(preSpkStim_low,1);
MES_post0_low = mean(postSpkStim_low,1);
MES_high= mean(preSpkStim_high,1);
MES_post0_high= mean(postSpkStim_high,1);

%% =========================================================================
%compute the effective stimulus 
%========== divide the e.s bins by contrast ===================
idx_low = [];
for cc = 1 : length(lowConOnsets)
    IDX = find(rt >= lowConOnsets(cc) & rt < highConOnsets(cc));
    IDX(rt(IDX)<lowConOnsets(cc)+stimVT)=[]; %remove edge indices giving shorter kernal. 
    idx_low = [idx_low IDX];
end
%idx_high = setdiff(rt_idx,idx_low);
idx_high = [];
%remove edges
for cc = 1 : length(highConOnsets)
    if cc < length(highConOnsets)
        IDX = find(rt >= highConOnsets(cc) & rt < lowConOnsets(cc+1));
    else
        IDX = find(rt >= highConOnsets(cc) & rt < highConOnsets(cc)+tBlock);
    end
    IDX(rt(IDX)<highConOnsets(cc)+stimVT)=[]; %remove edge indices giving shorter kernal. 
    idx_high = [idx_high IDX];
end

%
ES_low = zeros(size(idx_low));
ES_high = zeros(size(idx_high));
%spike counts in resampled e.s bins
rsc_low = histc(spkt_low,rt);
rsc_high= histc(spkt_high,rt);
%compute ES
for cc = 1 : length(idx_low)
    ES_low(cc) = rStim((idx_low(cc)-rStimVL):idx_low(cc)-1)*sta_low'/(norm(sta_low));
end
%subset of spike counts for bins computed for ES
rsc_sub_low = rsc_low(idx_low);
%
for cc = 1 : length(idx_high)
    ES_high(cc) = rStim((idx_high(cc)-rStimVL):idx_high(cc)-1)*sta_high'/(norm(sta_high));
end
%
rsc_sub_high = rsc_high(idx_high);
% %extract the full set of stim vectors progressive in time, which includes the spike-triggered
% %sets.
% stimVec_low = makeStimRows(rStim,rStimVL, idx_low-1, -1);
% stimVec_high= makeStimRows(rStim,rStimVL, idx_high-1,-1);
%=========================================================================
%effective stimulus calculation
%divide the effective stim values in the unit of half-sigma.
%contrast in percentage
contrast_low = neurons{i}.clusters{j}.class{1}.member{1}.value;
contrast_high= neurons{i}.clusters{j}.class{1}.member{2}.value;
%std in gun value.
std_low = contrast_low * 128 / 100;
std_high= contrast_high * 128 / 100;
%std normalized by mean,i.e, contrast in percentage.  
std_low = std_low /128;
std_high= std_high/128;
%
% %effective stimulus
% ES_low = (MES_low/norm(MES_low)) * stimVec_low' ;
% ES_high= (MES_high/norm(MES_high))* stimVec_high';
%normalize to the contrast/std
ES_low = ES_low/std_low;
ES_high = ES_high/std_high;
%effective sigma from fit 
[effs_mu_low,effs_std_low] = normfit(ES_low);
[effs_mu_high,effs_std_high]=normfit(ES_high);
%bin the histogram of effective stim values in half-sigma
% esh_low_bin = min(ES_low)-effs_std_low/2 : effs_std_low/2 : max(ES_low)+effs_std_low/2;
% esh_high_bin= min(ES_high)-effs_std_high/2 : effs_std_high/2: max(ES_high)+effs_std_high/2;
esh_low_bin = min(ES_low) : effs_std_low/2 : max(ES_low)-effs_std_low/4;
esh_high_bin= min(ES_high) : effs_std_high/2: max(ES_high)-effs_std_high/4;
%effective stimulus histogram.
esh_low = hist(ES_low,esh_low_bin);
esh_high= hist(ES_high,esh_high_bin);

%
%===================================================================
%effective stimulus for the spike-triggered vectors.
preSpk_ES_low = (MES_low/norm(MES_low)) * preSpkStim_low' ;
preSpk_ES_high= (MES_high/norm(MES_high))* preSpkStim_high';
%normalize to the contrast/std
preSpk_ES_low = preSpk_ES_low/std_low;
preSpk_ES_high = preSpk_ES_high/std_high;
%
postSpk_ES_low = (MES_low/norm(MES_low)) * postSpkStim_low'  ;
postSpk_ES_high= (MES_high/norm(MES_high))* postSpkStim_high';
%normalize to the contrast/std
postSpk_ES_low = postSpk_ES_low/std_low;
postSpk_ES_high = postSpk_ES_high/std_high;

%effective sigma from fit 
[preSpk_effs_mu_low,preSpk_effs_std_low] = normfit(preSpk_ES_low);
[preSpk_effs_mu_high,preSpk_effs_std_high]=normfit(preSpk_ES_high);
%
[postSpk_effs_mu_low,postSpk_effs_std_low] = normfit(postSpk_ES_low);
[postSpk_effs_mu_high,postSpk_effs_std_high]=normfit(postSpk_ES_high);

%bin the histogram of effective stim values in half-sigma
% esh_low_bin = min(ES_low)-effs_std_low/2 : effs_std_low/2 : max(ES_low)+effs_std_low/2;
% esh_high_bin= min(ES_high)-effs_std_high/2 : effs_std_high/2: max(ES_high)+effs_std_high/2;
preSpk_esh_low_bin = min(preSpk_ES_low)-preSpk_effs_std_low/2 : preSpk_effs_std_low/2 : max(preSpk_ES_low);
preSpk_esh_high_bin= min(preSpk_ES_high)-preSpk_effs_std_high/2 : preSpk_effs_std_high/2: max(preSpk_ES_high);

postSpk_esh_low_bin = min(postSpk_ES_low)-postSpk_effs_std_low/2 : postSpk_effs_std_low/2 : max(postSpk_ES_low);
postSpk_esh_high_bin= min(postSpk_ES_high)-postSpk_effs_std_high/2 : postSpk_effs_std_high/2: max(postSpk_ES_high);

%effective stimulus histogram.
preSpk_esh_low = hist(preSpk_ES_low,preSpk_esh_low_bin);
preSpk_esh_high= hist(preSpk_ES_high,preSpk_esh_high_bin);

postSpk_esh_low = hist(postSpk_ES_low,postSpk_esh_low_bin);
postSpk_esh_high= hist(postSpk_ES_high,postSpk_esh_high_bin);

figure('name','effective stim hist, H/L C'); subplot(2,1,1);
plot(preSpk_esh_low_bin,preSpk_esh_low,'b'); hold on; 
plot(postSpk_esh_low_bin,postSpk_esh_low,'r');
xlabel('Effective Stimulus'); ylabel('Histogram');title('Effective Stimulus Hist,Low C');legend('Pre-Spike','Post-Spike');
subplot(2,1,2);
plot(preSpk_esh_high_bin,preSpk_esh_high,'b'); hold on; 
plot(postSpk_esh_high_bin,postSpk_esh_high,'r');
xlabel('Effective Stimulus'); ylabel('Histogram');title('Effective Stimulus Hist,High C');legend('Pre-Spike','Post-Spike');

%% =======================================================================
%compute response function 
resp_low = zeros(size(esh_low));
resp_high = zeros(size(esh_high));
%standard error of spike rate
resp_low_se = zeros(size(esh_low));
resp_high_se = zeros(size(esh_high));
%find the indices in preceeding spikes vector (w_spks_mes_low) by binned
%esv effs_low and esv_low_bin
for cc = 1 : length(esh_low_bin)
    startval = esh_low_bin(cc) - effs_std_low/4;
    lastval = esh_low_bin(cc) + effs_std_low/4;
    indices = find(ES_low > startval & ES_low <= lastval);
    if ~isempty(indices)
        %resp_low(cc) = sum(w_spks_mes_low(indices))/sum(spks_low(indices));
        resp_low(cc) = mean(rsc_sub_low(indices))/staBin; %mean rate
        resp_low_se(cc) = std(rsc_sub_low(indices))/sqrt(length(indices))/staBin; %
    end
end
    
for cc = 1 : length(esh_high_bin)
    startval = esh_high_bin(cc) - effs_std_high/4;
    lastval = esh_high_bin(cc) + effs_std_high/4;
    indices = find(ES_high > startval & ES_high <= lastval);
    if ~isempty(indices)
        %resp_high(cc) = sum(w_spks_mes_high(indices));
        %resp_high(cc) = sum(w_spks_mes_high(indices))/sum(spks_high(indices));
        resp_high(cc) = mean(rsc_sub_high(indices))/staBin;
        resp_high_se(cc) = std(rsc_sub_high(indices))/sqrt(length(indices))/staBin;
    end
end

figure('name','response function'); 
subplot(2,1,1); plot(esh_low_bin/(effs_std_low/2),resp_low/stimVT);xlabel('Effective Stimulus'); ylabel('Frequency');title('Response Func - Low C');
subplot(2,1,2); plot(esh_high_bin/(effs_std_high/2),resp_high/stimVT);xlabel('Effective Stimulus'); ylabel('Frequency');title('Response Func - High C');

%% ===================================================================
%Projection analysis
%
%PCA on the pre-spike stimulus -- stimulus vector before spiking
[COEFF_pre_low,SCORE_pre_low,LATENT_pre_low] = princomp(preSpkStim_low);
[COEFF_pre_high,SCORE_pre_high,LATENT_pre_high] = princomp(preSpkStim_high);
%normalize the eigenvalues to the variance of the gaussian
LATENT_pre_low = LATENT_pre_low/(std_low^2);
LATENT_pre_high = LATENT_pre_high/(std_high^2);
%normalize score to std. 
SCORE_pre_low = SCORE_pre_low/std_low;
SCORE_pre_high= SCORE_pre_high/std_high;
%projection of post-spike stimulus vectors onto the same component space.
SCORE_post_low = (postSpkStim_low)/(COEFF_pre_low');
SCORE_post_high= (postSpkStim_high)/(COEFF_pre_high');
%
SCORE_post_low = SCORE_post_low/std_low;
SCORE_post_high= SCORE_post_high/std_high;
%PCA on the post-spike stimulus
[COEFF_post0_low,SCORE_post0_low,LATENT_post0_low] = princomp(postSpkStim_low);
[COEFF_post0_high,SCORE_post0_high,LATENT_post0_high] = princomp(postSpkStim_high);
%normalize the eigenvalues to the variance of the gaussian
LATENT_post0_low = LATENT_post0_low/(std_low^2);
LATENT_post0_high = LATENT_post0_high/(std_high^2);
%
figure('name','Eigenvalues for raw vectors');
subplot(2,1,1);plot(1:length(LATENT_post0_low),sqrt(LATENT_post0_low),'b-o');xlabel('Index');ylabel('Eigenvalues');
title('EigenValues as STD (Prior),LowC'); 
subplot(2,1,2);plot(1:length(LATENT_post0_high),sqrt(LATENT_post0_high),'b-o');xlabel('Index');ylabel('Eigenvalues');
title('EigenValues as STD (Prior),HighC'); 
%-------------plot the projections-----------------------------------------
%project the raw stimulus into principal components.
%PC index
PCx1 = 1;
PCx2 = 15; 
%
h1=figure('name',sprintf('PC%d vs PC%d',PCx1,PCx2));
%prior distribution for low c -- centered on the 'zero-vector' 
subplot(2,4,1);plot(SCORE_post_low(:,PCx1),SCORE_post_low(:,PCx2),'k.');
hold on; plot(SCORE_pre_low(:,PCx1),SCORE_pre_low(:,PCx2),'b.');axis image; 
xlabel(sprintf('PC%d',PCx1));ylabel(sprintf('PC%d',PCx2));
title(sprintf('Low C, Elec%d, Cluster%d',chanIDX,neurons{i}.clusters{j}.id));
%histgram of the scores
[hist_score_post_low1,binout] = hist(SCORE_post_low(:,PCx1),20);
hist_score_post_low2 = hist(SCORE_post_low(:,PCx2),binout);
hist_score_pre_low1 = hist(SCORE_pre_low(:,PCx1),binout);
hist_score_pre_low2 = hist(SCORE_pre_low(:,PCx2),binout);
%normfit the raw dist
[fit_score_post_mean1,fit_score_post_std1]=normfit(SCORE_post_low(:,PCx1));
[fit_score_post_mean2,fit_score_post_std2]=normfit(SCORE_post_low(:,PCx2));
%area under curve
area_post_low1 = trapz(binout,hist_score_post_low1);
area_post_low2 = trapz(binout,hist_score_post_low2);
%generate the fit data
fit_y1 = area_post_low1 * normpdf(binout,fit_score_post_mean1,fit_score_post_std1);
fit_y2 = area_post_low2 * normpdf(binout,fit_score_post_mean2,fit_score_post_std2);
subplot(2,4,2);plot(binout,hist_score_post_low1,'k');hold on;plot(binout,hist_score_pre_low1,'b');
%plot the fit
plot(binout,fit_y1,'r.-');legend('prior','post',sprintf('%.1f',fit_score_post_std1));
title(sprintf('PC%d projection',PCx1));xlabel(sprintf('PC%d',PCx1));ylabel('Counts');
subplot(2,4,3);plot(binout,hist_score_post_low2,'k');hold on;plot(binout,hist_score_pre_low2,'b');
plot(binout,fit_y2,'r.-');legend('prior','post',sprintf('%.1f',fit_score_post_std2));
title(sprintf('PC%d projection',PCx2));xlabel(sprintf('PC%d',PCx2));ylabel('Counts');
%pc for low contrast
%projection stimulus vectors are not regenerated and the raw stimulus vectors are used directly for projection analysis. 
subplot(2,4,4);plot(-(pStimVL-1)*pbin:pbin:0,COEFF_pre_low(:,PCx1),'k');hold on; plot(-(pStimVL-1)*pbin:pbin:0,COEFF_pre_low(:,PCx2),'g'); 
plot(-(pStimVL-1)*pbin:pbin:0,MES_low/std_low,'r');
plot(-(pStimVL-1)*pbin:pbin:0,MES_post0_low/std_low,'b.'); %raw stim mean
% legend(sprintf('PC%d',PCx1),sprintf('PC%d',PCx2),'MES','Location','NorthEastOutside');
legend(sprintf('PC%d',PCx1),sprintf('PC%d',PCx2),'MES');
xlim([-pStimVL*pbin 0]); xlabel('Lag Time(s)');
%
figure(h1);
%spike trigger stim vec
subplot(2,4,5);plot(SCORE_post_high(:,PCx1),SCORE_post_high(:,PCx2),'k.');
hold on;plot(SCORE_pre_high(:,PCx1),SCORE_pre_high(:,PCx2),'b.'); axis image;xlabel(sprintf('PC%d',PCx1));ylabel(sprintf('PC%d',PCx2));
%plot(mes_score_high(1),mes_score_high(2),'r+');
title(sprintf('High C, Elec%d, Cluster%d',chanIDX,neurons{i}.clusters{j}.id)); 

%histgram of the scores
[hist_score_post_high1] = hist(SCORE_post_high(:,PCx1),binout);
hist_score_post_high2 = hist(SCORE_post_high(:,PCx2),binout);
hist_score_pre_high1 = hist(SCORE_pre_high(:,PCx1),binout);
hist_score_pre_high2 = hist(SCORE_pre_high(:,PCx2),binout);

%normfit the raw dist
[fit_score_post_mean1,fit_score_post_std1]=normfit(SCORE_post_high(:,PCx1));
[fit_score_post_mean2,fit_score_post_std2]=normfit(SCORE_post_high(:,PCx2));
%area under curve
area_post_high1 = trapz(binout,hist_score_post_high1);
area_post_high2 = trapz(binout,hist_score_post_high2);
%generate the fit data
fit_y1 = area_post_high1 * normpdf(binout,fit_score_post_mean1,fit_score_post_std1);
fit_y2 = area_post_high2 * normpdf(binout,fit_score_post_mean2,fit_score_post_std2);

subplot(2,4,6);plot(binout,hist_score_post_high1,'k');hold on;plot(binout,hist_score_pre_high1,'b');
plot(binout,fit_y1,'r.-');legend('prior','post',sprintf('%.1f',fit_score_post_std1));
title(sprintf('PC%d projection',PCx1));xlabel(sprintf('PC%d',PCx1));ylabel('Counts');
subplot(2,4,7);plot(binout,hist_score_post_high2,'k');hold on;plot(binout,hist_score_pre_high2,'b');
plot(binout,fit_y2,'r.-');legend('prior','post',sprintf('%.1f',fit_score_post_std2));
title(sprintf('PC%d projection',PCx2));xlabel(sprintf('PC%d',PCx2));ylabel('Counts');
%pc for high c
subplot(2,4,8);plot(-(pStimVL-1)*pbin:pbin:0,COEFF_pre_high(:,PCx1),'k');hold on; plot(-(pStimVL-1)*pbin:pbin:0,COEFF_pre_high(:,PCx2),'g'); 
plot(-(pStimVL-1)*pbin:pbin:0,MES_high/std_high,'r');
plot(-(pStimVL-1)*pbin:pbin:0,MES_post0_high/std_high,'b.');
legend(sprintf('PC%d',PCx1),sprintf('PC%d',PCx2),'MES');
% h_pos = get(h_leg,'Position'); set(h_leg,'Position',[0.8 0.5 h_pos(3:4)]); 
xlim([-(pStimVL)*pbin 0]);xlabel('Lag Time(s)');
%
figure('name','Eigenvalues(Posterior)');
subplot(2,1,1);plot(1:length(LATENT_pre_low),sqrt(LATENT_pre_low),'b-o');xlabel('Index');ylabel('Eigenvalues');
title('Eigenvalues as STD(Posterior),LowC');
subplot(2,1,2);plot(1:length(LATENT_pre_high),sqrt(LATENT_pre_high),'b-o');xlabel('Index');ylabel('Eigenvalues');
title('Eigenvalues as STD(Posterior),HighC');
%plot the histogram of the eigenvalues.
figure('name','Hist of E.V(low)');
[hist_ev_pre_low,binout] = hist(sqrt(LATENT_pre_low(1:end)));
hist_ev_post0_low = hist(sqrt(LATENT_post0_low(1:end)),binout);
subplot(2,1,1); bar(binout,hist_ev_post0_low);
title('E.V Hist(Prior),Low C');
subplot(2,1,2);bar(binout,hist_ev_pre_low);
title('E.V Hist(Posterior),Low C');
figure('name','Hist of Prior E.V(High)');
[hist_ev_pre_high,binout] = hist(sqrt(LATENT_pre_high(1:end)));
hist_ev_post0_high = hist(sqrt(LATENT_post0_high(1:end)),binout);
subplot(2,1,1);bar(binout,hist_ev_post0_high);
title('E.V as STD(Prior),High C');
subplot(2,1,2);bar(binout,hist_ev_pre_high);
title('E.V as STD(Posterior),High C');

figure('name','Response Function (H/L)'); hold on;
errorbar(esh_low_bin/effs_std_low,(resp_low/stimVT)/max(resp_low/stimVT),(resp_low_se/stimVT)/max(resp_low/stimVT),'b');
% plot(esh_high_bin/(effs_std_high/2),(resp_high/stimVT)/max(resp_high/stimVT),'r');xlabel('Effective Stimulus'); ylabel('R/Rm');
errorbar(esh_high_bin/effs_std_high,(resp_high/stimVT)/max(resp_high/stimVT),(resp_high_se/stimVT)/max(resp_high/stimVT),'r');
xlabel('Effective Stimulus(Std/2)'); ylabel('R/Rm,P/Pm');title('Response Function');
%effective stimulus
plot(postSpk_esh_low_bin,postSpk_esh_low/max(postSpk_esh_low),'b-.'); 
plot(postSpk_esh_high_bin,postSpk_esh_high/max(postSpk_esh_high),'r-.');
legend('R(L)','R(H)','P(L)','P(H)');

xrange = xlim;
%show the postive half
xlim([0 xrange(2)]);

