function [t, w , y] = spikeDetection(x, Fs, threshold)
% Detect spikes in continuously recorded signal.
%   [t, w] = spikeDetection(x, Fs) detects spikes in the continuous signal
%   x sampled at sampling rate Fs. Spike times t and spike waveforms w are
%   returned.
%
% AE 2012-11-14

if nargin < 3
    threshold = -5; 
end

% Filter raw signal
y = filterSignal(x, Fs);

% Detect threshold crossings
[s, t] = detectSpikes(y, Fs, threshold);

% Extract waveforms
w = extractWaveforms(y, s);

end


% function y = filterSignal(x, Fs)
% % Filter raw signal
% %   y = filterSignal(x, Fs) filters the signal x. Each column in x is one
% %   recording channel. Fs is the sampling frequency. The filter delay is
% %   compensated in the output y.
% 
% rp = 1;                 % Passband ripple
% rs = 40;                % Stopband ripple
% fl = [400 600];         % lowpass cutoff + don't care band
% fh = [5800 6000];       % highpass cutoff + don't care band
% devp = (1 - db2mag(-rp)) / (1 + db2mag(-rp));
% devs = db2mag(-rs);
% [n, fo, ao, w] = firpmord([fl fh], [0 1 0], [devs devp devs], Fs);
% b = firpm(n, fo, ao, w);
% y = filter(b, 1, double(x));
% y = y((n+1)/2:end, :);  % compensate for filter delay
% end

function y = filterSignal(x, Fs)
% use butterworth filter

% f_cutoff = 600;
% f_type   = 'high';
f_cutoff = [600 6000];
f_sample = Fs;
f_order  = 4;
%butterworth digital fitler
[ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2));
%[ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);
%
y = filtfilt(ft_b,ft_a,double(x));
end



function [s, t] = detectSpikes(x, Fs, threshold)
% Detect spikes.
%   [s, t] = detectSpikes(x, Fs) detects spikes in x, where Fs the sampling
%   rate (in Hz). The outputs s and t are column vectors of spike times in
%   samples and ms, respectively. By convention the time of the zeroth
%   sample is 0 ms.

% detect local minima where at least one channel is above threshold
%threshold = -5;    %-5
noiseSD = median(abs(x)) / 0.6745;      % robust estimate of noise SD
z = bsxfun(@rdivide, x, noiseSD);
mz = min(z, [], 2);
r = sqrt(sum(x .^ 2, 2));               % take norm for finding extrema
dr = diff(r);
s = find(mz(2 : end - 1) < threshold & dr(1 : end - 1) > 0 & dr(2 : end) < 0) + 1;
s = s(s > 10 & s < size(x, 1) - 25);    % remove spikes close to boundaries

% if multiple spikes occur within 0.5 ms we keep only the largest
refractory = 0.5 / 1000 * Fs;
N = numel(s);
keep = true(N, 1);
last = 1;
for i = 2 : N
    if s(i) - s(last) < refractory
        if r(s(i)) > r(s(last))
            keep(last) = false;
            last = i;
        else
            keep(i) = false;
        end
    else
        last = i;
    end
end
s = s(keep);
t = s / Fs * 1000;                      % convert to real times in ms
end


function w = extractWaveforms(x, s)
% Extract spike waveforms.
%   w = extractWaveforms(x, s) extracts the waveforms at times s (given in
%   samples) from the filtered signal x using a fixed window around the
%   times of the spikes. The return value w is a 3d array of size
%   length(window) x #spikes x #channels.

win = -7:24;        % window to extract around peak
%win = -12:35;
k = size(x, 2);     % number of channels
n = size(s, 1);     % number of spikes
m = length(win);    % length of extracted window
index = bsxfun(@plus, s, win)';
w = reshape(x(index, :), [m n k]);
end
