function E = efsStimArray(A,K,opt)
% compute 'effective-stimulus' values for stimulus array A
% A : stimulus array (m x n) where m is trials, n is time vectors
% K : projection vector. e.g, STA
% p : normalization option. SEE function 'efs' 
% E : output array. out-of-bound elements are padded with 0

if nargin < 3
    opt = 'norm';  %or 'raw' for unnormalization
end

%num of trial, num of samples
[nt,ns] = size(A);

%
E = zeros(size(A));

for i = 1 : nt
    E(i,:) = efs(A(i,:),K,opt);
end




