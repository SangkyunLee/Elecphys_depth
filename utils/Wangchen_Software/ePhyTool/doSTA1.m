function [s,c,E,t,Nspk] = doSTA1(data_spk,data_img,st,bin,plt,w,T,D,err)
%compute sta with 'nearest neighbor'

%data_spk: spike train
%data_img: stimulus vector (row vector)
%st:  stimulus onset time
%bin: sta bin
%T: 
%D: sta time range

% bin = 10/1000; %sta time bin - 10ms
%     %bin = stimFrames/60; %event interval for sta bin
%     plt = 'n';     %no plot for each individual channel.
%     SW = [];       %smoothing width
%     TW = [];       %TW = [0 100]; % select time window in spike train
%     D = [-1.0 0];  %sta time length
%     err = 0;       %error bar estimate
%     xSTA = []; %time elements of sta. 

%sta output
%t = D(1):bin:D(2);
%keep the upper bound, i.e
t = D(2):-bin:D(1);
%reverse the order
t = t(end:-1:1);
%sta kernal size
kSize = length(t);
%sta time duration
kTime = abs(diff(D));
%raw stimulus vector size
rkSize = round(kTime/mean(diff(st)));

%remove spikes at edge
data_spk(data_spk - kTime <= st(1)) = [];
%
Nspk = length(data_spk);
%
spike_counts = histc(data_spk,st);
%
active_index = find(spike_counts>0);
%extract stimulus vectors per bin
stim_vec_bin = makeStimRows(data_img',rkSize,active_index,-1);
%extract time vectors
st_vec_bin = makeStimRows(st',rkSize,active_index,-1);

%prelocate the memory for vectors to speed up the expansion.
sta_vec = zeros(Nspk,rkSize);
st_vec = zeros(Nspk,rkSize);
%
counted = 0;
%expand the vectors
for i = 1 : length(active_index)
    nspk = spike_counts(active_index(i));
    sv = stim_vec_bin(i,:);
    tv = st_vec_bin(i,:);
    if i == 1
        start_idx = 1;
    else
        %start_idx = sum(spike_counts(1:active_index(i-1)))+1; %added spikes.
        start_idx = counted + 1; 
    end
    last_idx = start_idx + nspk -1;
    %sta_vec = [sta_vec ; repmat(sv,nspk,1)];
    %st_vec = [st_vec ; repmat(tv,nspk,1)];
    sta_vec(start_idx : last_idx,:) = repmat(sv,nspk,1);
    st_vec(start_idx : last_idx,:) = repmat(tv,nspk,1);
    counted = last_idx; %counted spikes
end

% staTV_preSpkStim_low = repmat(staOut,length(spkt_low),1) + repmat(spkt_low',1,length(staOut));
%sta time vector array aligned at the spike time
%sta_time = repmat(t,length(data_spk),1) + repmat(data_spk',1,length(t));
sta_time = st_vec - repmat(data_spk',1,rkSize); 
%
%interpolated sta
sta_itp = zeros(Nspk,kSize);

for i = 1 : Nspk
%     sta_itp(i,:) = interpNN(st_vec(i,:),sta_vec(i,:),sta_time(i,:));
      sta_itp(i,:) = interpNN(sta_time(i,:),sta_vec(i,:),t);
end

%flip sta_itp back to row-representation for vectors

%sta
s = mean(sta_itp,1);

%standard error
E = std(sta_itp,1)/sqrt(Nspk);
%
c = zeros(size(s));


% if nargin < 3;error('Require spike, stimulus data and stimulus times');end
% if isstruct(data_spk)
%    [data_spk]=padElement(data_spk); % create a zero padded data matrix from input structural array
% end
% 
% if isempty(data_spk)
%     error('no spike data found');
% end
% 
% verbose = 1;
% %t = st;
% 
% if nargin < 4; bin = st(2)-st(1);end
% if nargin < 5; plt = 'r'; end
% if nargin < 6; w = 0; end
% if nargin < 7; T = [min(st) max(st)]; end
% if nargin < 8; D = 0.25*[-1 0]; end         %default: 250msec
% if nargin < 9; err = 1;end
% 
% if isempty(bin); bin = st(2)-st(1); end
% if isempty(plt); plt = 'r'; end
% if isempty(w); w = 0; end
% if isempty(T); T = [min(st) max(st)]; end
% if isempty(D); D = 0.25*[-1 0]; end
% if isempty(err); err = 1;end
% 
% if w > (T(2)-T(1))/2
%   disp('Smoothing > data segment : should be in seconds : turn off smoothing')
%   w = 0;
% end
% 
% sz = size(data_spk);
% NT = sz(1); %number of trials
% mimg = 0; % mean of stim values
% simg = 0; % square of stim values
% Nspk = 0; %
% smp = mean(diff(st)); %stimulus event interval.
% 
% % %t1: time points when sampling stimulus for each spike
% % if D(1) <= 0 && D(2) >= 0
% %   t1 = [D(1):smp:(-smp+eps) 0:smp:D(2)+eps]; %keep 0
% % else
% %   t1 = (round(D(1)/smp)*smp):bin:D(2);
% % end
% 
% if bin > smp; bin = smp; end %upsampling only
% 
% %t1 = (round(D(1)/bin)*bin):bin:D(2);
% %fix the upper bound and bin, relax the lower bound.
% t = D(2):-bin:D(1);
% t= t(end:-1:1);
% 
% %t1: time points plotted for sta 
% if D(1) <= 0 && D(2) >= 0
%   sta_t1 = [D(1):bin:(-bin+eps) 0:bin:D(2)+eps]; %keep 0
% else
%   sta_t1 = t;
% end

