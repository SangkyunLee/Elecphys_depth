function [STA,STC] = statStimArray(A)
% compute statistic of stimulus vectors array.(Spike-Triggered-Average and 
% Spike-Triggered-Covariance )
% A : stimulus vector array. dimension=(spikes,times)

[ns, nt] = size(A); %num of spikes, num of time points

STA = mean(A,1); %average over spikes

STC = (A'*A - ns*STA'*STA)/ns ; %covariance matrix


