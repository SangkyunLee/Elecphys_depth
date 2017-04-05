function [Ep,Cp] = contractESC(E,C,K)
% contract Effective-stimulus array and spike count array
% 1. extract the MES values for valid vectors and valid response in time domain. 
%   i.e, for each trial, remove first N-1 element that don't make full projection 
%   onto <STA> and the last element that has time bin out-of-range for spike count.
% 2. match up the input-output pair 
%   i.e, left shifting 1 bin in the spike count matrix
% E : effective stimulus array mxn = (trials, time bins)
% C : spike counts array (mxn)
% K : projection vector for MES values,e.g, STA
% Ep: contracted ES array in row vector
% Cp: contracted spike counts array for Ep

[nt,ns] = size(E);

N = length(K); %kernal size. 

%C(i) counts spikes between T(i) and T(i+1) for given trial. 
%E(i) computes 'ES' value for projections of vectors S(i-N+1 : i) onto K
%the effectiveness of E(i) (time range T(i-N+1) : T(i)+bin )is matched to C(i+1)
%(time range  T(i)+bin : T(i)+2*bin )

Cp = circshift(C,[0 -1]); 
Ep = E;
%remove (first 1:N-1) elements for incomplete projection and last element for out-of-bound time bin.
Cp(:,[1:N-1,ns]) = []; 
Ep(:,[1:N-1,ns]) = [];

Cp = reshape(Cp',1,[]);
Ep = reshape(Ep',1,[]);
