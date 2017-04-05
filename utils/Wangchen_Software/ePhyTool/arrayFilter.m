function B = arrayFilter(A,f)
% array filter function to remove row and column elements
% A : input array
% f : struct of filters. 
%   :   f.index -- flag to remove the row elements.
%   :           = vector of row indices to be removed. 
%   :           = 0 / [] , keep all rows. 
%   :   f.window -- nx2 array of indices for column elements to be removed
%   :           n is number of filter windows. window=[start index, end index]

[nr,nc] = size(A);

if f.index==0
    f.index = [];
end

nw = size(f.window,1);

% for i = 1 : nw
%     f.window(i,1) = max([f.window(i,1),1]);
%     f.window(i,2) = min([f.window(i,2),nc]);
% end

B = A;

I = [];
%remove columns
for i = 1 : nw
    I = [I f.window(i,1):f.window(i,2)];
end

 
B(:,I) = [];
%remove rows
B(f.index,:) = [];



