function [Al,Tl,Ah,Th] = reshapeStimArray(s,t,tol,toh,b)
% reshape the stimulus vector into m x n dimensional array, where m is the 
% number of trials, n the number of resample dimension (time bins).
% 
% s : stimulus values
% t : stimulus time (onsets) in sec
% tol: onset timestamps of the low contrast
% toh: onset timestamps of the high contrast
% b : resample time bin size.
% Al: resampled stimlus array of low contrast (m x n)
% Ah:                                        
% Tl: time bins of low contrast (m x n)
% Th: 
%

%num of trials for each contrast condition
nTrial = length(tol); 
%trial time for each contrast
% tTrial = mean(toh-tol);
tTrial = min(toh-tol);  %avoid the overlapping b/w contrasts
%num of resample time bins
nBin = floor(tTrial/b);
%resample time series
Al = zeros(nTrial,nBin);
Ah = zeros(nTrial,nBin);
%
x0 = 0 : b : (nBin-1)*b ;
%
Tl = repmat(tol',1,nBin) + repmat(x0,nTrial,1);
Th = repmat(toh',1,nBin) + repmat(x0,nTrial,1);

for i = 1 : nTrial
    %x = tol(i) : b : tol(i)+(nBin-1)*b; 
    xl = tol(i) + x0;
    xh = toh(i) + x0;
    %resampleTl{i} = tol(i) : b : toh(i);
%     Al(i,:) = upss(s,t,xl);
%     Ah(i,:) = upss(s,t,xh);
    %
    Al(i,:) = regsample(t,s,xl);
    Ah(i,:) = regsample(t,s,xh);
end


    

