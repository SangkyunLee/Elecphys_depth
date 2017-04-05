function [rt,rs] = resample_stim(t,s,dt)
%resample the stimulus vector/array at fine time resolution 
%Input : 
%    t : time series of stimulus in column vector (each stimulus point onset)
%    s : column vector/array of stimulus values. The values
%      : should be normalized to the range [-1 1] with -1 for black, 0 for median
%      : gray, 1 for white. 
%      : for contrast experiment, s is 1d columnular vector
%      : for receptive field experiment, s is a 3d array, i.e, [i j v] in which [i,j] is positional indices, v is lum value 
%Output:
%    rt: time series of resampled stimulus with interval dt
%    rs: resampled stimulus. 1d column vector for vector input (m x 1), or sparse
%        matrix (m x n) for 3d array input, where m is the stimulus sample size, n is the grid size. (16*16 eg) 
%

%[nPt, nSd] = size(s); %number of sample points, number of stimulus variable dimension. (1 for constrast exp, 3 for r.f exp)
nDim = ndims(s);

%average stim-interval of input t
itv = mean(diff(t));
%find the lnn indices
rt = t(1) : dt : t(end)+itv ; 
rt = rt'; 
I  = lnn(t, rt);

if nDim == 1 || nDim == 2
    rs = s(I);
end

if nDim == 3 
    [nRow, nCol, nPts] = size(s); 
    s = reshape(shiftdim(s,2), nPts, nRow * nCol); %shift into (nPts,nRow,nCol) before reshaping to 2d matrix;
    s = sparse(s);
    rs = s(I,:);
end







