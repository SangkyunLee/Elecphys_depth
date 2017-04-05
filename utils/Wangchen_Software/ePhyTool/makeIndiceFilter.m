function f = makeIndiceFilter(index_filter,window_filter,T)
% create indices filter for time array (trials,time bins)
% index_filter  : vector of row indices to remove
% window_filter : nx2 array of time range to remove
%               : nx [start time, end time] 
% T             : time array (trials, time bins)
% f             : returned struct of filter 
%

[nr,nc]  = size(T);

bin = T(1,2)-T(1,1);

f.index  = index_filter;
f.window = round(window_filter/bin) + repmat([1 0],size(window_filter,1),1); %convert time to index 
f.window(isinf(f.window)) = nc ; %replace 'inf' with the upper bound of column index
f.window(f.window(:,2)==0,:)=[]; %remove filters that end with 0 time.

