function I=unn(x,xi)
%return upper-nearest-neighbor indices
%
M = lnn(x,xi);
I = M + 1;
%
n = length(x);
I(I>n)=n;