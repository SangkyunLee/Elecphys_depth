function [y,I] = ISIFilter(x,minISI)
%ISIFilter implements the ISI filter function in neuroexploer.
%WW2010
%
%x: timestamps of point process 
%minISI: minimum interval. intervals smaller than minISI will be treated
%as 'noise' and the end timestamp in the pair will be removed. 
%y : filtered timestamps
%I : index array of y in x, i.e, y = x(I);

n = length(x);
if n < 2
    fprintf('Not enough points !\n');
end
%pre-allocate the array
y = zeros(size(x));
I = y;
%note the first ts in the sequence is always treated as 'signal'.
c = 1; %count of filtered timestamps.
y(c) = x(c);
I(c) = c;

for i = 2 : n
    %moving screening
    itv = x(i) - y(c);
    if itv > minISI
        %keep the current timestamp
        c = c+1;
        y(c) = x(i);
        I(c) = i;
    end
end

%number of timestamps filtered.
ftN = n - c;
if ftN > 0
    y(c+1:n)=[];
    I(c+1:n)=[];
end


        

