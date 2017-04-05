function [ h ] = mplotTuningCurve(s,msg,plt)
%plot tuning curve for multi-channels WW2010
%Input:
% s - struct array or 2d data array padded with NaN (channels x samples)
%     e.g, s(i,:) contains firing rate data for i-th channel 
% msg - info for each channel
% plt - plot title
%
% This function calls mspecViewer

%%load data.
if ~exist('plt','var') || isempty(plt)
    plt = 'Tuning';
end

viewOption = struct('plot',plt);

% h = mspecViewer(s,msg,viewOption);

h = mspecViewer([],s,viewOption);


