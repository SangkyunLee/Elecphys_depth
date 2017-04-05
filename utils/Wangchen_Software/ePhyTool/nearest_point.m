function I = nearest_point(x,xi,mode)
% find the nearest value to xi in x.
% Call 'nearestpoint' function to run the actual task.
% 
% x : source vector, monotonically increasing.
% xi: interpolating vector, monotonically increasing
% I : indices in x
% Find the values in x which is closest to each value in xi. 
%
% Note the 'mode' is defined differetly from 'nearestpoint'. 
% mode :  'left' or 'lower' find the lower-bound nearest neighbor. x(I) <= xi
%        'right' or 'upper' find the upper-bound nearest neighbor.x(I) > xi
%        'nearest' find the nearest neighbor.

if nargin < 3
    mode = 'nearest';
end

I = nearestpoint(xi,x,'nearest');

%distance of xi to its nearest neighbors
d = xi - x(I) ;
%sign of distance
s = sign(d);

switch mode
    case 'nearest'
        s = 0 ; 
    case {'lower','left'} %x(I) <= xi or d >=0
        %0,-1. 
        s(s>=0) = 0; %left-adjust by 1 if d < 0
    case {'upper','right'}
        s(s==0) = 1 ;
        s(s<0)  = 0 ; %right-adjust by 1 if d>=0 
end

%indice adjustment according to sign
I = I + s ; 