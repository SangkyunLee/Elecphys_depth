function eta(x,y,events,window)
%compute the event-triggered average. (spikes or stimulus events)
%x : time series of stimulus in column vector. (m x 1)
%y : columnar array of stimulus values (m x n). m is stimulus time dimension, n is stimulus spatial dimension.    
%events : time series of events (in same units as x)
%window : time window around each event to extract triggered stimulus 
%

