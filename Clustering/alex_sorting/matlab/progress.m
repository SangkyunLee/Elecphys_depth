function progress(i, total, steps)
% Shows the progress in percent.
%   progress(i, total, steps) prints a progress output in increments of
%   100/steps percent, where 'i' is the current loop iteration and 'total'
%   the total number of iterations.
%
% AE 2011-10-10

n = (0:steps) / steps * total;
ndx = find(i < n & i + 1 >= n, 1);
if ~isempty(ndx)
    fprintf('%.1f%%\n', round((ndx - 1) / steps * 1000) / 10)
end
