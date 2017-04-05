function events = readDigEvents(filename)
%function to read digital events from NEV file. 

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
    
%
stimFrames = 2;
%screen refresh rate
refreshRate = 60;
%interval b/w adjunct stimulus events.
ISI = stimFrames/refreshRate;
%threshold for filter
minISI = 0.8 * ISI ;

%the only digital event is from MSU photodiode.
if nEvent == 1
    %filter out the events from flickers. 
    events{1}.timestamps =  ISIFilter(events{1}.timestamps,minISI);
end

function [y,I] = ISIFilter(x,minISI)
%ISIFilter implements the ISI filter function in neuroexploer.
%WW2010
%
%x: timestamps of point process 
%minISI: minimum interval. intervals smaller than minISI will be treated
%as 'noise' and the end timestamp in the pair will be removed. 
%y : filtered timestamps
%I : index array of y in x, i.e, y = x(I);

n = length(x);
if n < 2
    fprintf('Not enough points !\n');
end
%pre-allocate the array
y = zeros(size(x));
I = y;
%note the first ts in the sequence is always treated as 'signal'.
c = 1; %count of filtered timestamps.
y(c) = x(c);
I(c) = c;

for i = 2 : n
    %moving screening
    itv = x(i) - y(c);
    if itv > minISI
        %keep the current timestamp
        c = c+1;
        y(c) = x(i);
        I(c) = i;
    end
end

%number of timestamps filtered.
ftN = n - c;
if ftN > 0
    y(c+1:n)=[];
    I(c+1:n)=[];
end

