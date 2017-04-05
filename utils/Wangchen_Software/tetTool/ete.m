function E = ete(t,s,events,window)
%extract the event-triggered epoch ensemble. (events could be spikes or stimulus events)
%t : time series of stimulus in column vector(m x 1). x is evenly spaced
%s : columnar array of stimulus values (m x n). m is time dimension, n is spatial dimensions.    
%events : time series of events (in same units as t)
%window : time window [t1,t2] around each event to extract triggered epoch.  
%

%interval
dt = (t(end)-t(1)) / (length(t) -1) ;

%event-related epoch size
npre  = floor(window(1) / dt) ; 
npost = ceil(window(2) / dt) ; 
n     = npost - npre ; 

%find the indices of events in the input sequence.
indices = floor((events - t(1)) / dt + 1) ; 

%find the begin/end indices of each epoch
ibegin = indices + npre  ;
iend   = indices + npost ;

%expunge the out-of-bound events
inbound = (ibegin>0 & iend <= length(t));
%number of inbound events.
ne = length(find(inbound));

%indices array for the epoch ensemble
% iee = repmat((ibegin(inbound))', n , 1) + repmat((1:n)',1, ne) ;
% E   = s(iee);
E = s(repmat((ibegin(inbound))', n , 1) + repmat((1:n)',1, ne));
