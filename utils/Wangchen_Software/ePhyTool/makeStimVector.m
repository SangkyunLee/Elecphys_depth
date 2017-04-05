function [S,I] = makeStimVector(A,si,n)
% make stimulus vectors where each vector is loaded with stimulus at a
% particular moment in time. (REF: makeStimRows.m) 
% A : stimulus array constructed by reshapeStimArray. dimension = (trials, times)
%   : the assiciated time array is reguar array.
% si: indices of spike times in A. (2xn)
%   : where column n is num of spikes, row is indices of trial and time
%     samples
%   : [trial index, .....
%      sample index, ......]       
% n : kernal size (num of time bins to make the stimulus vectors) 
%   : [n1,n2] n1 -- num of bins before spike time,excluding 0. n2 -- after
%   : spike, excluding 0
% S : stimulus array of spike-triggered vectors. (size of spikes,size of kernal)
% I : index (logic matrix) for valid spikes (within bounds),i.e, valid spikes = si(:,I);
%
%

[nt,ns] = size(A); %(num of trials, num of stimulus samples)
%
n1 = n(1);     %num of bins before spikes
if length(n)==2
    n2 = n(2); %num of bins after spikes
else
    n2 = 0;
end

% %kernal size (before spike + after spike + time zero)
nk = abs(n1) + abs(n2) + 1;

%filter spikes out of bounds.
%flag = ones(1,size(si,2));
IND = (si(2,:)-n1 < 1 | si(2,:)+n2 > ns) ;
si(:,IND) = [];
%logic flag for remaining spikes.
I = ~IND;
%remaining spikes
nSpike = size(si,2);
%
S = zeros(nSpike, nk);

%
for i = 1 : nSpike
    iTrial = si(1,i);
    iBin   = si(2,i);
    S(i,:) = A(iTrial, iBin-n1 : iBin+n2);
end



