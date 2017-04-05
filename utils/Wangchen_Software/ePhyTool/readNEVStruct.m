function nevData = readNEVStruct(NEV,datatype)
%read the NEV struct to build the data field for the jointed data struct
%for analyzing scripts.
%called by readNEVFile or called directly in the main script to read the clustered mat file  
%nevData = readNEVStruct(NEV,datatype)

nevData = struct;
%sampling time resolution
nevData.TimeStampResolution = 1/double(NEV.MetaTags.SampleRes);

%nevData.TimeStampResolution = FileInfo.TimeStampResolution;
%nevData.TimeSpan = FileInfo.TimeSpan;

%only implement the 'neurons' and 'events' for now. need to rewrite for better data
%structure
%
channels = unique(NEV.Data.Spikes.Electrode);
nChan = length(channels);
neurons = cell(nChan,1);

if any(strcmpi(datatype,'neurons'))
    for i = 1 : nChan
        neurons{i}.name = ['chan',num2str(channels(i))];
        I = (NEV.Data.Spikes.Electrode == channels(i));
        neurons{i}.timestamps = (double(NEV.Data.Spikes.TimeStamp(I)-1)/double(NEV.MetaTags.SampleRes))';
        neurons{i}.units = (NEV.Data.Spikes.Unit(I))';
    end
end
 
digEvents = unique(NEV.Data.SerialDigitalIO.InsertionReason);
nEvent = length(digEvents);
event = cell(nEvent,1);
if any(strcmpi(datatype,'events'))
    for i = 1 : nEvent
        event{i}.name = ['DIO',num2str(digEvents(i))];
        I = (NEV.Data.SerialDigitalIO.InsertionReason == digEvents(i));
        event{i}.timestamps = (NEV.Data.SerialDigitalIO.TimeStampSec(I))';
        event{i}.data = (NEV.Data.SerialDigitalIO.UnparsedData(I))';
    end
end    
    
nevData.neurons = neurons;
nevData.events = event;


