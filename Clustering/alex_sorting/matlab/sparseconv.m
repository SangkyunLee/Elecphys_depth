%  function x=sparseconv( x, k )
%
%  convolves x by the kernel k (1D only).  Unlike other convolution functions,
%  sparseconv does not waste time on zero coefficients in k.  So if k is
%  sparse, sparseconv will be much faster than other filtering functions.
%  You can make the kernel sparse without loss of accuracy if both k and x 
%  are bandlimited. 
% 
%  x and k must be column vectors
%
%  sparseconv preserves the length of the result by zero-padding the input
%  similar to conv2(x,k,'same')
%
%  Dimitri Yatsenko, 2010-08-05

function y=sparseconv( x, k )
assert( nargin==2 && size(x,2)==1 && size(k,2)==1, 'inputs must be column vectors');

n = length(k);
j = -floor(n/2-0.5):floor(n/2);

y = zeros(size(x));
for i=find(k~=0)'
    y = y + k(i)*[zeros(max(0,j(i)),1); x(max(1,1-j(i)):end-max(0,j(i))); zeros(max(0,-j(i)),1)];
end
    
