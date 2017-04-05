stimBin = mean(diff(t_SETS)); %average of stimuli interval 
staBin  = 5/1000;
staTime = 0.1;

iNeuron = 10;
iCluster = 2;
t_spike = neurons{iNeuron}.clusters{iCluster}.class{1}.member{2}.timestamps';

% 1. make stimuli array from raw data (raw or resampled)
[Al0,Tl0,Ah0,Th0] = makeStimArray(Stim,t_SETS,lowConOnsets,highConOnsets);
[Al,Tl,Ah,Th] = makeStimArray(Stim,t_SETS,lowConOnsets,highConOnsets,staBin);

% 2. select data for analysis
flag = 1;
switch flag
    case 0
        A = Al0; T = Tl0;
        t_ref = lowConOnsets;
        kBin = stimBin;
        rSigma = std(reshape(Al0,1,[]));
    case 1
        A = Ah0; T = Th0;
        t_ref = highConOnsets;
        kBin = stimBin;
        rSigma = std(reshape(Ah0,1,[]));
    case 2
        A = Al; T = Tl;
        t_ref = lowConOnsets;
        kBin = staBin;
        rSigma = std(reshape(Al0,1,[]));
    case 3
        A = Ah; T = Th;
        t_ref = highConOnsets;
        kBin = staBin;
        rSigma = std(reshape(Ah0,1,[]));
end
NB = round(staTime/kBin); %num of bins for kernal size

% opt.Data.stimArray = A;
% opt.Data.timeArray = T;

opt.Param.kernalSize = NB;
opt.Param.kernalBin  = kBin;
opt.Param.kernalTime = staTime;
opt.Param.datasetFlag = flag; 
% opt.Param.sigma = std(reshape(A,1,[]));
opt.Param.sigma = rSigma;
opt.Param.PCx = [1 NB];
opt.Param.view = false;

%filter setting to remove spikes and stimulus.
time_filter = [45 inf]; %time window 
%filter setting to remove trials
trial_filter = [];

t_bound = circshift(t_ref,[0 -1]);
t_bound(end) = t_ref(end)+ 60 ; %or inf

opt.Filter.time_filter  = time_filter;
opt.Filter.trial_filter = trial_filter;
opt.Filter.t_ref        = t_ref;
opt.Filter.t_bound      = t_bound;

%selection window 
sw_start = [0 5 10 15 20 25 30 35 40];
sw_end   = sw_start + 5;

for i = 1 : length(sw_start)
    opt.Filter.time_filter = [0 sw_start(i); sw_end(i) inf];
    r(i) = analyzer(A,T,t_spike,opt); 
end


figure('name','STA over time'); hold on;
peak_amp   = zeros(1,length(sw_start));
valley_amp = zeros(1,length(sw_start));
colors = {'k','b','r','g','y','c','k.-','b.-','r.-','g.-','y.-','c.-'};
subplot(1,2,1); hold on; 
for i = 1 : length(sw_start)
    iColor = mod(i,length(colors));
    if iColor == 0; iColor = length(colors); end
    plot(r(i).spike.preSpike.STA.x,r(i).spike.preSpike.STA.y,colors{iColor});
    peak_amp(i) = max(r(i).spike.preSpike.STA.y);
    valley_amp(i) = min(r(i).spike.preSpike.STA.y);
end
subplot(1,2,2); hold on;
plot(sw_start,peak_amp,'b',sw_start,valley_amp,'r');
legend('sta peak','sta valley');

figure('name','Response over stimulus');hold on;

for i = 1 : length(sw_start)
    if ~any(i==[1 4 9]); continue; end
    iColor = mod(i,length(colors));
    if iColor == 0; iColor = length(colors); end
%     errorbar(r(i).Response.x,r(i).Response.y,r(i).Response.error,colors{iColor});
    plot(r(i).Response.x,r(i).Response.y,colors{iColor});
end





