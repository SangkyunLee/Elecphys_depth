function I = lnn(x,xi)
%find the lower-nearest-neighbor of xi in x. 
%x is monotonically increasing. xi is within x

n = length(x);
y = 1:n;
%nearest neighbor
yi = interp1(x,y,xi,'nearest');
%values of nearest neigbors in x.
v = x(yi);
%distance of xi from neighbors
d = xi - v;
%
s = sign(d);
%0,-1
s(s>0)=0;
%
I = yi + s;
%



