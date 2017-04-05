function r = runavg(s,n)
%running average of input signal. 
%s : input data (if s is a matrix, the operation is taken on the columns)
%n : window size (sample points)
%r : output data
%

if nargin < 2
    n = 3; %n-pts avg.
end

r = filter(ones(1,n)/n, 1, s);