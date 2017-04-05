function t = spikeFilter(t_spike,t_filter,t_ref,t_bound)
% spike times filter
% t_spike : spike times
% t_filter: array of time windows to remove spikes (nx2)
% t_ref   : reference time for filter's time window
%         : i.e, the i-th window = t_filter + t_ref(i)
% t_bound : terminal time for the filter time window
%         : this is specifically for situation where trial durations have jitters. 
%         : filter value 'inf' tags the end of the trial. 
%         : 
% CALL this function to remove spikes in the referenced time window in repeated trials.

%sort the reference time and bound time.
[t_ref, I ]= sort(t_ref);
t_bound = t_bound(I);

nFilter = size(t_filter,1);
nRef    = numel(t_ref);

I = ones(size(t_spike));

for i = 1 : nFilter
    for j = 1 : nRef
        tmin = t_filter(i,1) + t_ref(j);
        tmax = min([t_filter(i,2) + t_ref(j), t_bound(j)]);
        I = I & ~(t_spike>=tmin & t_spike < tmax) ;
    end
end

t = t_spike(I);

