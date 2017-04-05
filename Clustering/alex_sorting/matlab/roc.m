function [tp fp thresholds] = roc(cond1,cond2,thresholds)
% Compute the ROC at a set of thresholds for the two conditions
%
% [tp fp] = roc(cond1,cond2,[threshold])
%
% JC 2008-11-08

if nargin < 3
    thresholds = 0:.1:10;
end

tp = sum(bsxfun(@lt,reshape(cond1,[],1),thresholds),1) / length(cond1);
fp = sum(bsxfun(@lt,reshape(cond2,[],1), thresholds),1) / length(cond2);
