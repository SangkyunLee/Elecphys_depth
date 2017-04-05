function [peak,onset] = find_latency(x,y,baseline)
%find the peak and onset latency from ERP/lfp trace.
%x     : time-series 
%y     : ERP/lfp data
%sigma : std of noise floor. it's computed from background activity 30ms before
%        stimulus onset.
%

if nargin < 3
    baseline= y(1:20);
end

mb = mean(baseline);
sb = std(baseline);

% %rectify the trace.
% yy = abs(y); 
%find the peak with maximum amplitude 
SlopeThreshold = 0;
AmpThreshold   = 0.5*max(y);
SmoothWidth    = 3;
FitWidth       = 3;
Peaks = findpeaks(x,y,SlopeThreshold,AmpThreshold,SmoothWidth,FitWidth);
%take the maximum peak.
[maxP,maxI] = max(Peaks(:,3));
peak = Peaks(maxI,:);
peak = [peak(2) y(peak(2) == x)]; %keep peak-time, peak-amp values.

%find the response latency
%get the running average before calculating derives
windowSize = 3; %5-pts avg.
ys = filter(ones(1,windowSize)/windowSize, 1, y);
onsetIdx = find(abs(diff(ys)) > sb); %ref: automated method for detection of layer activation. Mahmud et al.
%onsetIdx = find((y-mb) > 1*sb);
if ~isempty(onsetIdx)
    onsetIdx = onsetIdx(1);
    onset = [x(onsetIdx) y(onsetIdx)];
else
    onset = [x(1) y(1)];
end


