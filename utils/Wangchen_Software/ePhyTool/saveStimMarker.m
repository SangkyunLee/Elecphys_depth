function saveStimMarker(nexStruct,data)
%save the param list and event code into marker data type for neuroexplorer.
%nexStruct
%nexStruct.params : name of params,{'Orientation','SpatialFreq',...}
%nexStruct.values : values for params.{[0:10:100],[0:1:2],...}
%nexStruct.DIOValue: encoded index of event(stimulus present).

%fileName = sprintf('%s/%.4d.mat',data.fallback,length(data.params.trials));
%data: stimulation data
filename = fullfile(data.fallback,[length(data.params.trials) '.nex']);

if ispc
    fn = ['.\','runningTrialParams.nex'];
elseif ismac
    fn = ['~/stimulation/data/','runningTrialParams.nex'];
else
end

%header info.
nexFile = struct('version',101,...
        'comment','',...
        'freq',30000,...
        'tbeg',0,...
        'tend',1);

%    
nParam = length(nexStruct.params);
%length of events.
n = length(nexStruct.DIOValue);
%length for each param-list
paramLen = zeros(1,nParam);
for i = 1 : nParam
    paramLen(i) = length(nexStruct.values{i});
end
nexFile.tend = n;
%write stim info into one marker 
marker = struct;
marker.name = 'StimMarker';
marker.timestamps = [1:n]';
%fields
markerFields = nexStruct.params;
markerFields{nParam+1} = 'DIOValue';
nFields = length(markerFields);
%encoding-variable dimension.
ndim = nParam;
%project onto the param dimension to get the encoding indices
[sub{1:ndim}] = ind2sub(paramLen,(nexStruct.DIOValue)');
sub{ndim+1} = (nexStruct.DIOValue)';
sub = sub';

for i = 1 : nFields
    value.name = markerFields{i};
    for j = 1 : n
        value.strings{j,1} = num2str(sub{i}(j));
    end
    marker.values{i,1} = value;
end
    
nexFile.markers{1} = marker;

%write the param values into contuniuous var.
for i = 1 : nParam
    value = nexStruct.values{i};
    contvar.name = nexStruct.params{i};
    contvar.ADFrequency = 1; %fake info
    contvar.timestamps = 1; %fake info
    contvar.fragmentStarts = 1; %
    contvar.data = value';
    nexFile.contvars{i,1} = contvar;
end

result = writeNexFile(nexFile,fn);
