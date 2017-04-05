function I = findSpikeIndice(T,s)
% find the indices of spikes in stimulus array.
% A : stimulus array (trials, times)
% T : times array for stimulus, in sec
% s : spike times (need to be inside the time bounds)
% I : indices matrix. row 1 for trial index, row 2 for times index.
%   : index is determined as the index of lower-nearest-neighbor in T.
% 

%
[nt,ns] = size(T); %(trials,sample times)

TA = reshape(T',1,[]); 

IND = nearest_point(TA,s,'lower'); %left neighbor
%index of sample, index of trial
[IND_s,IND_t] = ind2sub([ns,nt],IND);

I=zeros(2,numel(IND_s));
I(1,:) = IND_t; 
I(2,:) = IND_s;


