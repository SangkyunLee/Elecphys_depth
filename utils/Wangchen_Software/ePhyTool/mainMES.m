%main script to calculate the MES -- the correlation of firing rate with
%stimulus 

%Stimulus matrix (temporal,spatial) -- Stim
%spike counts vector -- sp
%kernel size -- n 

n = 20;
Stim = StimImage.data';

%time points
ntp = length(Stim);
%stim frame duration (2frames)
dt = 2*(1/60);

%
xout = [t_SETS t_SETS(end)+dt];
%[spikeCount,spikeCountSE,xout] = pePSTH(ts,REF,[0 tBlock-tBin],tBin);
i = 6;
j = 2;

spkt = neurons{i}.clusters{j}.class{1}.member{1}.timestamps;
sp = histc(spkt,xout); 
%
sp(end) = [];

%
maxlags = n ;
MES = xcorr(Stim,sp,maxlags,'biased');
figure;plot(MES);

% % Do STA/STC analysis ------------------------------
[sta,stc,rawmu,rawcov] = simpleSTC(Stim,sp,n);  
figure;plot(sta);
