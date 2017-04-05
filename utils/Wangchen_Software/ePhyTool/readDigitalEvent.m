function events = readDigitalEvent(filename)
%function to read digital events from NEV file. 
%events : cell array for events. 
%events.timestamps : event timestamps in sec
%events.data       : event data value
%
%WW2014

%read in the whole file without waveforms
NEV = openNEV(filename,'read','nowave','nowrite');

digEvents = unique(NEV.Data.SerialDigitalIO.InsertionReason);
nEvent = length(digEvents);

for i = 1 : nEvent
    events{i}.name = ['DIO',num2str(digEvents(i))];
    I = (NEV.Data.SerialDigitalIO.InsertionReason == digEvents(i));
    events{i}.timestamps = (NEV.Data.SerialDigitalIO.TimeStampSec(I))';
    events{i}.data = (NEV.Data.SerialDigitalIO.UnparsedData(I))';
end
    
% %
% stimFrames = 2;
% %screen refresh rate
% refreshRate = 60;
% %interval b/w adjunct stimulus events.
% ISI = stimFrames/refreshRate;
% %threshold for filter
% minISI = 0.8 * ISI ;
% 
% %the only digital event is from MSU photodiode.
% if nEvent == 1
%     %filter out the events from flickers. 
%     events{1}.timestamps =  ISIFilter(events{1}.timestamps,minISI);
