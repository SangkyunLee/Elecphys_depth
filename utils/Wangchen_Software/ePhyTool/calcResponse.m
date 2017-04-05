function [x,y,e,n] = calcResponse(E,C,p)
% calculate the response function from effective-stimulus and spike counts
% E : contracted vector of effective stimulus value 1xm 
% C : contracted vector of spike counts vector (1xm)
% p : bin size in units of std. i.e, bin size = p * std(effective stimulus)
% x : row vector for effective stimulus values binned across trials, in
%     unit of standard deviation.
% y : mean firing probablity 
% e : standard error of mean firing probability
% n : probability distribution of MES bins. (number counts)

%
minE = min(E); 
maxE = max(E);
%
stdE = std(E); 
%x for edge counting
xg = floor(minE/(stdE))-p/2 : p : ceil(maxE/(stdE))+p/2; 
%remove bins out of range [xmin, xmax]
ia = 0;
ib = 0;
for i = 1 : length(xg)
    if minE/stdE >=xg(i) && minE/stdE < xg(i)+p 
        ia = i;
    end
    if maxE/stdE >=xg(i) && maxE/stdE < xg(i)+p
        ib = i;
    end
end

xg = [xg(ia:ib) xg(ib)+p]; %contract the bins

[nCount,binIND] = histc(E/stdE,xg); %num of counts, bin index
%remove last element from histc counting.
nCount(end) = [];
binIND(binIND==length(xg))=[]; %remove values out of range,i.e >xg(end)
xg(end) = [];

%create bins for hist calculation, i.e, centered 
x = xg + p/2; 
y = zeros(size(x));
e = y;
n = y;
%mean rate
for i = 1 : length(xg)
    b = C(binIND==i); %array of rates that satifisy the bin condition
    if isempty(b) ; continue; end
    y(i) = mean(b);
    n(i) = length(b);
    e(i) = std(b)/sqrt(n(i));
    if n(i)~=nCount(i);
        fprintf('unequal ?!!\n');
    end
end

%
%y = hist(A,x); %hist func: the selection of y open on lower bound, close on upper bound. i.e, x(i)-bin/2 <y(i) <= x(i)+bin/2

