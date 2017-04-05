function H = peta(t,e,x)
%preprocessor of per-event-time-histogram. It returns the array of spike
%counts per event H without computing the average and std for psth. This
%makes it easier for setting the filter window to exclude spikes near the transition.   
%
%t : timestamps of spikes
%e : timestamps of events 
%x : time vector of histogram
%H : histogram array which contains the peri-event spike counts

%
n = length(e);
%
m = length(x); 
%
H = zeros(n,m);
%
% x_start = x(1); 
% x_end   = x(end);
bin     = x(2)-x(1);

for i = 1 : n
    xr    = x + e(i);                     %time vector shifted to event time
    edges = xr; 
    edges(end+1) = xr(end) + bin;         %closed bin for the last time element
    ts = t(t>=edges(1) & t<=edges(end));  %selected spikes
    h  = histc(ts,edges);                 %count spikes edges(i-1) <= ts < edges(i)
    if ~isempty(h)  
        h = h(1:end-1); 
    else
        h = zeros(1,m);
    end  %remove the last point which counts ts == edges(end)
    H(i,:) = h ;
end

    
    
