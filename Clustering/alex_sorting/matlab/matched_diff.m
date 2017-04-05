% [d,idx]=matched_diff(list,refList) subtract from numbers in list the
% closest numbers in refList.
%
% INPUTS:
%    list: a sorted array of numbers (either row or column)
%    refList: a reference list of numbers sorted in the same direction as list
% OUPUTS:
%    d:  for each number in list, the signed distance to the closest member of refList.
%    idx: for each member of list, the index of the closest number in refList.
%
% This function is commonly used to match events in time series sampled at
% different rates.
%
% 2010-08-30, Dimitri Yatsenko

function [d,idx]=matched_diff(list,refList)
idx = nan(size(list));
d   = inf(size(list));
i=1;
for j=1:length(list)
    for i=i:length(refList)
        newd = list(j)-refList(i);
        if abs(newd)>abs(d(j));
            break;
        end
        idx(j)=i;
        d(j) = newd;
    end
    i=i-1;
end
end