function [r] = calSpikeRate(spike_train,edges)
%WW2010
%spike_train , edges are in the same units. and in sequential order
%
%c - spike counts 
%f - bin-averaged spike counts (firing rate)
%bin - 
% 
%
%spike_train.data{1} = timestamp
%spike_train.data{2} = unit
%
%r.fr : firing rate {}
%r.sc : spike count {}
%r.units : spike sorted unit {}
%
%convert vector input to struct.
if ~isstruct(spike_train)
    %vector
    s = struct('data',[]);
    s.data{1} = spike_train;
    s.data{2} = zeros(size(spike_train));
    %spike_train = s;
else
    s = spike_train; %struct
end

%number of sorted units. 
su = sort(unique(s.data{2}));
nsu = length(su);

r = struct('firingrate',[],'spikecount',[],'units',[]);

dt = edges(2:end)-edges(1:end-1);
% 
% for i = 1 : length(edges) - 1
%         f(i) = c(i)/(edges(i+1)-edges(i));
% end

for k = 1 : nsu
    uid = su(k);
    if uid==255; continue; end; %noise spikes
    a = (s.data{2}==uid);
    b = s.data{1}(a);
    c = histc(b,edges);
    %remove the last element which is for spike_time == edges(end)
    c(length(c)) = [];
   
    f = c./dt;
    
    %cell array or struct array ?
    r(k).firingrate = f;
    r(k).spikecount = c;
    r(k).units = uid;
    
end

return 

% slower than histc
% bin = zeros(1,length(edges)-1);
% c = bin;
% f = bin;
% for i = 1 : length(edges) - 1
%     bin(i) = mean(edges(i:i+1));
%     dt = edges(i+1)-edges(i);
%     %
%     y = spike_train >= edges(i) & spike_train < edges(i+1);
%     %
%     c(i) = sum(y);
%     f(i) = c(i)/dt;
% end
% 
