function stimData = syncPTBPTD(stimData)
% synchronize the timestamps from psychtoolbox to photodiode signal
% synchPTBPTD returns the interpolated photodiode timestamps in the same length as that from psychtoolbox
% 

ptbTimes = stimData.Params.params.swapTimes;
ptdTimes = stimData.Timestamps;

%remove the event timestamps and keep stimulus-timestamps
ptbTimes([1:2,end]) = [];
ptbTimes = ptbTimes' ; 

if isfield(stimData,'swapTimes')
    stimData = rmfield(stimData,'swapTimes');
end

%stimData.swapTimes = ptbTimes;

%ptbDT = mean(diff(ptbTimes)); %each frame duration ~1/60
%ptdDT = mean(diff(ptdTimes)); %each stimlus duration, a multiple of frame duration
%nFrames = round(ptdDT/ptbDT);

nFrames = length(ptbTimes) / length(ptdTimes);
if (mod(nFrames,1)~=0)
    error('stimulus is not a multiple of frames');
end

%time of stimuli on mac
macTimes = ptbTimes(1:nFrames:end);
%linear regression b/w two series.

%time window for regression
window = 5 * 60; 

%number of chunks to run regression
nChunk = ceil((ptbTimes(end)-ptbTimes(1))/window);

swapTimes = zeros(1,length(ptbTimes));

for i = 1 : nChunk
    tw = [(i-1)*window, i*window];
    I  = macTimes - macTimes(1) >= tw(1) & macTimes - macTimes(1) < tw(2);
    x = macTimes(I);
    y = ptdTimes(I);
    [r,m,b] = regression(x,y);
    %plotregression(rx,ry);
    %J = ptbTimes - ptbTimes(1) >= tw(1) & ptbTimes - ptbTimes(1) < tw(2);
    II = find(I);
    J = ptbTimes >= macTimes(II(1)) & ptbTimes <= macTimes(II(end));  
    rx = ptbTimes(J);
    ry = m * rx + b ; 
    swapTimes(find(J)) = ry ; 
end

%replace the fitted times with the recorded times in SwapTimes, i.e, keep the
%stimuli onsets from the photodiode, keep the fitted for the frames that fall in between the stimuli onsets.

%swapTimes(1:nFrames:end) = ptdTimes ;

stimData.ptbSyncTimes = swapTimes;





