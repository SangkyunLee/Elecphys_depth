function c = sigmoidFit(x,y,N)
%sigmoid function fit 
%

% p1=initial value (left horizontal asymptote)
% p2=final value-p1 (right horizontal asymptote - p1)
% p3=center (point of inflection)
% p4=width (dx) 

if nargin < 3
    N = 100;  %max iteration for fit
end

%convert to column vectors
if size(x,2) > 1 ; x = x'; end
if size(y,2) > 1 ; y = y'; end

%f = @(p,x) p(1)^2 + p(2) ./ (1 + exp(-(x-p(3))/p(4)));

res = @(p) p(1)^2 + p(2)./(1 + exp(-(x-p(3))/p(4))) - y ;

p0 = [y(1) y(end)-y(1) median(x) mean(diff(x))];

c = LMFnlsq(res,p0,'MaxIter',N);

