function [Al,Tl,Ah,Th] = makeStimArray(s,t,tol,toh,b)
% make stimulus array from the original vector of stimuli and times
% CALL drawStimArray and reshapeStimArray  
% s : stimulus values
% t : stimulus time (onsets) in sec
% tol: onset timestamps of the low contrast
% toh: onset timestamps of the high contrast
% b : resample time bin size. 
%   : return raw stimuli and times if not set or empty value 
% Al: resampled stimlus array of low contrast (m x n)
% Ah:                                        
% Tl: time bins of low contrast (m x n)
% Th: 

if nargin < 5
    b = []; 
end

if isempty(b)
    [Al,Tl,Ah,Th] = drawStimArray(s,t,tol,toh); %draw raw stimulus array
else
    [Al,Tl,Ah,Th] = reshapeStimArray(s,t,tol,toh,b);
end

