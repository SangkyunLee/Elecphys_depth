function r = analyzer(A,T,t,opt)
% pack of analysis routines for given contrast dataset in adaptation
% experiment.
% s : stimulus data
% t : stimulus time
% tol: low contrast onsets
% toh: high contrast onsets
% opt: struct of options.
% r  : struct of results.

% A   = opt.Data.stimArray ;    %stim array
% T   = opt.Data.timeArray ;    %time array
NB  = opt.Param.kernalSize ;  %kernal size
bin = opt.Param.kernalBin  ;
 
%filter setting
trial_filter = opt.Filter.trial_filter ;
time_filter  = opt.Filter.time_filter;
t_ref        = opt.Filter.t_ref;
t_bound      = opt.Filter.t_bound;
%array indice filter
array_filter = makeIndiceFilter(trial_filter,time_filter,T);

%spike filter to remove spikes in given time window
t_spike = spikeFilter(t,time_filter,t_ref,t_bound);
%apply filter to stim/time array to remove elements out-of-bound 
A = arrayFilter(A,array_filter);
T = arrayFilter(T,array_filter);
%

% 3. extract spike-triggered stimulus array and time array (spikes,times)
I    = findSpikeIndice(T,t_spike);
S    = makeStimVector(A,I,[NB NB+1]);  %stim vector array
TV   = makeStimVector(T,I,[NB NB+1]); %time vector array
IDX_b = 1 : NB+1;
IDX_a = NB+2 : 2*NB+2;
S_b   = S(:,IDX_b);
S_a   = S(:,IDX_a);
TV_b  = TV(:,IDX_b);
TV_a  = TV(:,IDX_a);
clear I S TV;

r = probProjection(S_b,S_a);


% 4. compute STA/STC/EFS probability dist/Response Function
[STA_b,STC_b] = statStimArray(S_b);
[STA_a,STC_a] = statStimArray(S_a);
% %
% %plot std level
% plot(0.35*ones(size(STA)),'r-');

r.spike.preSpike.STA.x   =  (IDX_b-NB-1) * bin ;
r.spike.preSpike.STA.y   = STA_b;
r.spike.preSpike.STC.x   =  (IDX_b-NB-1) * bin ;
r.spike.preSpike.STC.y   = STC_b;
r.spike.postSpike.STA.x  =  (IDX_a-NB-1) * bin ;
r.spike.postSpike.STA.y  = STA_a;
r.spike.postSpike.STC.x  =  (IDX_a-NB-1) * bin ;
r.spike.postSpike.STC.y  = STC_a;

%effective-stimuli values for spike-triggered stimuli
           SES_b = S_b * STA_b' ;
           SES_a = S_a * STA_b' ;
[SESHist_b,xout] = hist(SES_b,20);
       SESHist_a = hist(SES_a,xout);

r.spike.preSpike.EFS.x  = xout;
r.spike.preSpike.EFS.y  = SESHist_b; 
r.spike.postSpike.EFS.x = xout;
r.spike.postSpike.EFS.y = SESHist_a;

%figure('name','eff-stim histogram'); hold on
% bar(xout,efsPrior,'r'); 
% bar(xout+mean(diff(xout))/4,efsPost,'b'); %set(findobj(gca,'Type','patch'),'EdgeColor','w','FaceAlpha',0.75);
% legend('Before-Spike','After-Spike');

%effective-stimuli values over time bins for trials (trials,times)
efsArray = efsStimArray(A,STA_b,'raw');
%corresponding spike counts over time bins for trials
spkCountArray = findSpikeCount(T,t_spike);
%remove out-of-bound elements for given kernal size from Eff Stim Array and Spike Count Array.
%reshape arrays into vectors
[efs,spkCount] = contractESC(efsArray,spkCountArray,STA_b);
%compute the response.
stdBinSize = 1/4; 
%calculate response function.
[x,y,e,n]  = calcResponse(efs,spkCount,stdBinSize);
%figure('name','Repsonse Function');errorbar(x,y,e);

r.Response.x        = x;  % MES values
r.Response.y        = y;  % mean firing probability
r.Response.error    = e;  % standard error
r.Response.bincount = n;  % 

%==========================================================================
%validate Bayesian
%1. prior P(stim)
priorHist = hist(efs/std(efs),x);
priorProb = priorHist/sum(priorHist);
%2. posterior P(stim|spike)
postHist  = hist(SES_a/std(efs),x);
postProb  = postHist/sum(postHist);
%3. likelyhood func. it may contain nans
likelyhoodProb = (postProb./priorProb);
likelyhoodProb = likelyhoodProb/sum(likelyhoodProb);

r.Probability.prior.x = x;
r.Probability.prior.y = priorProb;
r.Probability.posterior.x = x;
r.Probability.posterior.y = postProb;
r.Probability.likelyhood.x = x;
r.Probability.likelyhood.y = likelyhoodProb; 

% figure('name','prob dist');hold on; 
% plot(x,priorProb,'b'); 
% plot(x,postProb,'r');
% plot(x,likelyhoodProb,'k');
% legend('P(stim)','P(stim|spike)','P(spike|stim)');

r.Param = opt.Param;

if opt.Param.view 
    plotAnalyzer(r);
end

%remove score for saving space
r.spike.preSpike.PCA.score   = [];
% r.spike.preSpike.PCA.weight  = [];
r.spike.postSpike.PCA.score  = [];
% r.spike.postSpike.PCA.weight = [];
% r.spike.project.PCA.weight   = [];







