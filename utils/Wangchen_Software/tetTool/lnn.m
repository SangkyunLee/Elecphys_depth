function I = lnn(x,xi)
%find the indices of lower-nearest-neighbor of xi in x (inclusive)
%x and xi are monotonically increasing. (time series)
%xi(k) is extrapolated to the last element in x if xi(k) is greater than x.
%xi(k) is set to nan if less than x.  

%check the dimension match for input
if ~(size(x,1) == size(xi,1) || size(x,2) == size(xi,2))
    error('input dimension mismatch');
end

%set the indices as input for interpolation.
y = 1:length(x);
%keep the dimension consistent
if size(x,1) >= 1 && size(x,2) == 1 
    y = y'; 
end
%indices of nearest neighbor 
yi = interp1(x,y,xi,'nearest','extrap');
%xi's nearest neigbors in x.
xin = x(yi);
%distance of xi from its neighbors
d = xi - xin;
%compare xi with its nearest neighbor xin. 
s = sign(d);
%s=1 : xi is greater than neighbor xin, i.e. xin is lower-nn of xi.
%s=0 or -1 : xi is less than or equal to xin, i.e, xin is upper-nn of xi. 
s(s>0)=0;
%adjust the indices of neighbors by their sign. Note it's only applicable to in-bound elements 
I = yi + s;
%set the out-of-bound element to nan
I(xi < x(1)) = nan; 





