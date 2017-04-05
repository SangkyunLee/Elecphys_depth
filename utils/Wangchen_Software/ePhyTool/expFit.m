function c = expFit(x,y,N)
%
%y = a(1) + a(2)*exp(-a(3)*x)

if nargin < 3
    N = 100;   %max iteration
end

%convert to column vectors
if size(x,2) > 1 ; x = x'; end
if size(y,2) > 1 ; y = y'; end


res = @(a) a(1)+a(2)*exp(-a(3)*x)-y;
%p0 = [max(y) -(max(y)-min(y)) 2*log(2)/(min(x)+max(x))];
%p0 = [mean(y) max(y)-min(y) (max(x)-min(x))/2];
p0 = [y(end) y(1)-y(end) 1/(x(end)-x(1))];
c = LMFnlsq(res,p0,'MaxIter',N);