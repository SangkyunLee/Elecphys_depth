function rfmSaveParam(nexStruct,folder)

%save the param list and event code into marker data type for neuroexplorer.
%nexStruct
%nexStruct.params : name of encoding params,{'Orientation','SpatialFreq',...}
%nexStruct.values : values for encoding params.{[0:10:100],[0:1:2],...}
%nexStruct.DIOValue: encoded index of event(stimulus present).
%nexStruct.convars: name of constant variables. (non-variant params.) 
%nexStruct.convals: value of constant variables. (non-variant params.)
% 
% folder = struct;
% 
% if ispc
%     folder.base = 'c:\data\';
%     
% elseif ismac
%     folder.base = '~/stimulation/data';
% else
% end
% 
% folder.subject = 'rfm';
% folder.exp = 'NeuronTuning';
% folder.date = datestr(now,'yyyy-mmm-dd');
% folder.time = datestr(now,'HH-MM-SS');
% 
% rfmFolder = fullfile(folder.base,folder.subject,folder.exp,folder.date,folder.time);

%mkdir(rfmFolder);

fn = 'StimEventLUT.nex';

file = fullfile(folder.base,folder.subject,folder.exp,folder.date,folder.time,'0001.nex');
% %save one copy on top level for the running experiment. 
file1 = fullfile(folder.base,folder.subject,folder.exp,fn);
    
nexFile = struct('version',101,...
        'comment',datestr(now),...
        'freq',30000,...
        'tbeg',0,...
        'tend',1);

%    
nParam = length(nexStruct.params);
%length of events.
n = length(nexStruct.DIOValue);    
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
ndim = nParam;

if size(nexStruct.DIOValue,2)>1
    nexStruct.DIOValue = (nexStruct.DIOValue)' ;
end
%project onto the param dimension to get the encoding indices
[sub{1:ndim}] = ind2sub(paramLen(1:end),(nexStruct.DIOValue));
sub{ndim+1} = (nexStruct.DIOValue);
sub = sub';

for i = 1 : nFields
    value.name = markerFields{i};
    %value.strings = {num2str(sub{i})}; 
    for j = 1 : n
        value.strings{j,1} = num2str(sub{i}(j));
    end
    if size(value,2) > 1 ; value = value'; end;
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
    if size(value,2) > 1 ; value = value'; end;
    contvar.data = value;
    nexFile.contvars{i,1} = contvar;
end

nexConVar = size(nexFile.contvars,1);
%write non-variant params into continuous var data.
%i.e.,they are not indices encoding variables. 
nConVar = length(nexStruct.convars);
for i = 1 : nConVar
    value = nexStruct.convals{i};
    contvar.name = nexStruct.convars{i};
    contvar.ADFrequency = 1; %fake info
    contvar.timestamps = 1; %fake info
    contvar.fragmentStarts = 1; %
    if size(value,2) > 1 ; value = value'; end;
    contvar.data = value;
    nexFile.contvars{i+nexConVar,1} = contvar;
end

result = writeNexFile(nexFile,file);
copyfile(file,file1);
