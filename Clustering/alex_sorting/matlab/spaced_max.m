% function idx = spaced_max( x, min_interval )
% finds local maxima that are separated by at least min_interval samples
% DY: 2010-08-16

function idx = spaced_max( x, min_interval, thresh )
peaks = local_max( x );
if nargin>2
    peaks = peaks(x(peaks)>thresh);
end
if isempty(peaks)
    idx = [];
else
    idx=peaks(1);
    for i=peaks(2:end)'
        if i-idx(end)>=min_interval
            idx(end+1)=i;
        elseif x(i)>x(idx(end))
            idx(end)=i;
        end
    end
end