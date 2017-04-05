function C = findSpikeCount(T,s)
% find the counts of spikes in time bins specifid by stimulus array.
% A : stimulus array (trials, times)
% T : times bins array for stimulus, in sec
% s : spike times (need to be inside the time bounds)
% C : spike counts in bins specified by T (trials,times) 

[nt,ns] = size(T);

C = zeros(nt,ns+1); % additional one bin to count spikes that belongs to [ns,ns+1)

for i = 1 : nt
    ex = [T(i,:) T(i,ns)+T(i,2)-T(i,1)];
    C(i,:) = histc(s,ex);
end

C(:,ns+1) = [];        % remove last column which counts spikes == T(:,ns+1)

