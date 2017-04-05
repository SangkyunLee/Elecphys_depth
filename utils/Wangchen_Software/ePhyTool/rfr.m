function [xr,yr]=rfr(x,y,m,n)
%recalculate the average over combined bins. 
%x : time bin series (uniformly spaced)
%y : spike counts matrix (events,times)
%m : number of bins for averaging
%n : number of bins for counting exculsion at the start of time series.

if m <=n ; error('larger bin required for average'); end
%
bin = x(2)-x(1);
%
nx = length(x);
%
xr = x(1:m:end);
yr = zeros(size(y,1),length(xr));
%
for i = 1 : length(xr)
    
    if i == 1 
        t = (m-n)*bin;     %bins included for the first data point of spike counting
        c = n+1 : m ;      %bin index to sum up
    elseif i == length(xr)
        t = (nx-(i-1)*m)*bin; %remaining time bin size at the end
        c = (i-1)*m+1 : nx;
    else
        t = m*bin;
        c = (1:m) + (i-1)*m;
    end
    counts = sum(y(:,c),2);
    yr(:,i) = counts / t ;
end
    
       
    
    

