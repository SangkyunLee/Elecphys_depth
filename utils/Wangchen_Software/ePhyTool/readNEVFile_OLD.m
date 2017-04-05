function nevData = readNEVFile(filename,datatype)
%read spike/event/analog data from NEV file(blackrock microsystem) into 
%matlab struct data. -WW2010
%usage: nevData = readNEVFile(filename)
%       nevData = readNEVFile(filename,datatype)
%
%nevData struct format :
%
%nevData                       - matlab struct containing nev data
%nevData.TimeSpan              - recording duration
%nevData.TimeStampResolution   - sampling resolution
%
%nevData.neurons               - array of neurons (recording channels)
%        neurons{i}.name       - name of neurons/channels
%        neurons{i}.timestamps - array of spike timestamps (in Sec)
%        neurons{i}.units      - spike sorting units
%
%nevData.events                - array of events
%        events{i}.name        - name of event variable
%        events{i}.timestamps  - array of event timestamps
%        events{i}.data        - array of event values
%
%nevData.waves                 - array of waves (AP)
%        waves{i}.name         - name of neuron/channel
%        waves{i}.NPointsWave  - number of data points in AP waveform
%        waves{i}.timestamps   - spike time
%        waves{i}.unitNumber   - spike sorting unit
%        waves{i}.waveforms    - matrix of waveforms (in milivolts)
%
%nevData.contvars              - array of continuous-variable structures
%        contvars{i}.name      - name of contvar
%        contvars{i}.contCount - count of data points in the contvar
%        contvars{i}.data      - matrix of values for contvar
%

nevData = struct;
% nevData = struct('TimeSpan',0,'TimeStampResolution',0,...
%     'neurons',[],'events',[],'waves',[],'contvars',[]...
%     );

%default is return full set of data
if ~exist('datatype','var') || isempty(datatype) || ~isempty(strmatch('all',datatype,'exact'))
    datatype = {'neurons','events','waves','contvars'};
end
%note that 'neurons' will always be retrieved in the file -- 'waves' has dependence on it.

%DLLName = 'C:\Software\NeuroShare\nsNEVLibrary.dll';
DLLName = which('nsNEVLibrary');
if isempty(DLLName) 
    disp('NEV library not found in the path !'); %add your neuroshare folders to matlab path. 
    return
end
%load the DLL
[nsresult] = ns_SetLibrary(DLLName);
if (nsresult ~= 0)
    disp('DLL was not found!');
    return
end

% Load data file and display some info about the file
% Open data file
[nsresult, hfile] = ns_OpenFile(filename);
if (nsresult ~= 0)
    disp('Data file did not open!');
    return
end

%Get file information
[nsresult, FileInfo] = ns_GetFileInfo(hfile);
% Gives you EntityCount, TimeStampResolution and TimeSpan
if (nsresult ~= 0)
    disp('Data file information did not load!');
    return
end

%sampling time resolution
nevData.TimeStampResolution = FileInfo.TimeStampResolution;
nevData.TimeSpan = FileInfo.TimeSpan;

% Build catalogue of entities
[nsresult, EntityInfo] = ns_GetEntityInfo(hfile, [1 : 1 : FileInfo.EntityCount]);

NeuralList = find([EntityInfo.EntityType] == 4);    % List of EntityIDs needed to retrieve the information and data
SegmentList = find([EntityInfo.EntityType] == 3);
AnalogList = find([EntityInfo.EntityType] == 2);
EventList = find([EntityInfo.EntityType] == 1);

%clear fields to save memory
EntityInfo = rmfield(EntityInfo,'EntityType');

% How many of a particular entity do we have
cNeural = length(NeuralList);       
cSegment = length(SegmentList);
cAnalog = length(AnalogList);
cEvent = length(EventList);

NeuralLabels = strvcat(EntityInfo(NeuralList).EntityLabel);

neuronCount = 0;
waveCount = 0;
contCount = 0;
eventCount = 0;

for i = 1 : cSegment
    
    label = EntityInfo(SegmentList(i)).EntityLabel;
    % Have to figure out which Neural entities correspond with the selected segment entities
    list = strmatch(label,NeuralLabels, 'exact');
    
    if isempty(list); continue; end;
    
    neuronCount = neuronCount + 1;
    %list contains index in segmentlist.
    nevData.neurons{neuronCount,1}.name = label;
    nevData.neurons{neuronCount,1}.timestamps =[]; 
    nevData.neurons{neuronCount,1}.units =[];
    
    %list contains sorted units
    %nsu = length(list); 
    
    % Retrieve the data
    [nsresult, NeuralInfo] = ns_GetNeuralInfo(hfile, NeuralList(list));
    
    %retrieve timestamps by each units.
    for ss = 1 : length(list)
        
        %save 'noise' spikes ? -- No. 
        if NeuralInfo(ss).SourceUnitID==255 ; continue; end;

        [nsresult, NeuralData] = ns_GetNeuralData(hfile, NeuralList(list(ss)), 1, EntityInfo(NeuralList(list(ss))).ItemCount);

        %ns_GetNeuralData sucks. It didn't return full set of data when
        %function ends. Need to add pause loop here to make sure data are
        %actually loaded before proceed.
        %nsresult returns a failure for large data ?!
        for j = 1 : 200
            if isempty(NeuralData) %NeuralData should return something.
                fprintf('empty neuraldata\n')
                pause(.5);
            else
                break;
            end
        end

        %NeuralData not read out from GetNerualData function completely ?
        %add delay here. -- another check point. make sure ind not messed up.

        for j = 1:200
            ind = [1 : 1 : size(NeuralData,1)*size(NeuralData,2)];
            if any(isnan(ind))
                %fprintf('%d) NaN in array\n',j);
                pause(.5);
            else
                break;
            end
        end

        if any(isnan(ind)); fprintf('still NaN in array ?!\n\n'); keyboard; end
        % Get the neural timestamps in column vector
        NeuralData = reshape(NeuralData, size(NeuralData,1)*size(NeuralData,2), 1);
        %create fields for first unit.
        
        nevData.neurons{neuronCount,1}.timestamps = [nevData.neurons{neuronCount,1}.timestamps; NeuralData];
        %
        nevData.neurons{neuronCount,1}.units = [nevData.neurons{neuronCount,1}.units; ones(size(NeuralData))*NeuralInfo(ss).SourceUnitID];
    end

    if ~isempty(strmatch('waves',datatype,'exact'))
        %--------------------read spike waveforms -----------------------------
        %     [nsresult, nsSegmentInfo] = ns_GetSegmentInfo(hfile, SegmentList(i));
        %     [nsresult, nsSegmentSourceInfo] = ns_GetSegmentSourceInfo(hfile, SegmentList(i), 1);

        % Load all the ap waveforms on each selected channel
        [nsresult, timestamps_wf, waveforms, sampleCount, unitIDs] = ...
            ns_GetSegmentData(hfile, SegmentList(i), 1:length(nevData.neurons{neuronCount,1}.timestamps));

        if nsresult~=0 || isempty(timestamps_wf); continue; end

        for j = 1 : length(timestamps_wf)
            %skip 'noise' spikes
            if unitIDs(j) == 255; continue; end
            %
            waveCount = waveCount + 1;
            %neuron name (or electrode name)
            nevData.waves{waveCount,1}.name = nevData.neurons{neuronCount,1}.name;
            %spiking time
            nevData.waves{waveCount,1}.timestamps = timestamps_wf(j);
            %points of ap
            nevData.waves{waveCount,1}.NPointsWave = sampleCount(j);
            %unit id (spike sorting)
            nevData.waves{waveCount,1}.unitNumber = unitIDs(j);
            %ap waveform
            nevData.waves{waveCount,1}.waveforms = waveforms(:,j);
        end
        %-----------------read spike waveforms end ----------------------------
    end
end

%clear to save memory
clear NeuralData ind timestamps_wf waveforms sampleCount unitIDs;

if ~isempty(strmatch('contvars',datatype,'exact'))
    for i = 1 : cAnalog
        channel = AnalogList(i);
        %return the whole length.
        count = EntityInfo(channel).ItemCount;
        % Get the fist data points of the waveform and show it
        [nsresult, ContinuousCount, wave] = ns_GetAnalogData(hfile, channel, 1, count);
        if nsresult ~= 0 || ContinuousCount == 0
            continue;
        end
        contCount = contCount + 1;
        %channel name
        nevData.contvars{contCount,1}.name = EntityInfo(channel).EntityLabel;
        %ContinuousCount---Number of continuous data values starting with
        nevData.contvars{contCount,1}.contCount = ContinuousCount;
        nevData.contvars{contCount,1}.data = wave;
    end
    clear wave;
end

if ~isempty(strmatch('events',datatype,'exact'))
    for i = 1 : cEvent
        channel = EventList(i);
        %return the whole length.
        count = EntityInfo(channel).ItemCount;
        % Retrieve the event
        [nsresult, EventInfo] = ns_GetEventInfo(hfile, channel);
        [nsresult, timestamps, data, dataSize] = ns_GetEventData(hfile, channel, 1:count);
        if nsresult~=0 || isempty(timestamps)
            continue;
        end
        eventCount = eventCount + 1;
        nevData.events{eventCount,1}.name = EntityInfo(channel).EntityLabel;
        nevData.events{eventCount,1}.timestamps = timestamps;
        nevData.events{eventCount,1}.data = data;
    end
    clear timestamps data;
end

%clear the entity info.
clear EntityInfo;

% Close data file. Should be done by the library but just in case. 
ns_CloseFile(hfile);

% Unload DLL
clear mexprog;



    
    

