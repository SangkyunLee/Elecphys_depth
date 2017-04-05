function [Al,Tl,Ah,Th] = drawStimArray(s,t,tol,toh)
%draw the raw stimulus values into arrays for trials of low/high contrast
%(see function 'reshapeStimArray')
%

%num of trial
nTrial = numel(tol); 
%
if length(toh)~=nTrial ; error('unequal number of onsets'); end
%total num of samples
nTotal = numel(t);
%num of samples per contrast
nSample = nTotal/(nTrial*2);

Al = zeros(nTrial,nSample);
Ah = Al;
Tl = Al;
Th = Al;

for i = 1 : nTrial
    Al(i,:) = s(1+(i-1)*2*nSample : (i-1)*2*nSample+nSample) ;
    Ah(i,:) = s(1+(i-1)*2*nSample+nSample : i*2*nSample) ; 
    Tl(i,:) = t(1+(i-1)*2*nSample : (i-1)*2*nSample+nSample) ;
    Th(i,:) = t(1+(i-1)*2*nSample+nSample : i*2*nSample) ; 
end

%check for onsets of each contrast
for i = 1 : nTrial
    if Tl(i,1) ~= tol(i) 
        error('error in array of onsets for low contrast');
    end
    if Th(i,1) ~= toh(i) 
        error('error in array of onsets for low contrast');
    end
end
 