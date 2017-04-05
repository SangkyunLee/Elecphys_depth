function nevData = readNEVFile(filename,datatype)
%read blackrock data with NPMK functions. replace the old readNEVFile
%function. - WW2011
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

% nevData = struct;
% nevData = struct('TimeSpan',0,'TimeStampResolution',0,...
%     'neurons',[],'events',[],'waves',[],'contvars',[]...
%     );

%default is return full set of data
if ~exist('datatype','var') || isempty(datatype) || ~isempty(strmatch('all',datatype,'exact'))
    datatype = {'neurons','events','waves','contvars'};
end
%note that 'neurons' will always be retrieved in the file -- 'waves' has dependence on it.

%read the entire data
NEV = openNEV(filename,'read','nowave','nowrite');

nevData = readNEVStruct(NEV,datatype);
