function ss = trimNEVData(s,struct_index,event_index)
%trim the data to make it compatiable with sortStimEvent
%
%s - struct array, 
%struct_index - selected element in s. each element in s contains data for one set files 
%event_index - select event in s.nevData.events. by default,it's the
%              stimulus event timestamps recorded on digital channel.
%
%ss - returned one-entry struct with one-entry of events in nevData.

ss = s(struct_index);
%remove datatype other than events
removes = {'contvars','waves'};
%get rid of remove-fields if not found in nevData
removes(~(isfield(ss.nevData,removes)))=[];
if ~isempty(removes)
    ss.nevData = rmfield(ss.nevData,removes);
end
%remove events entries.
z = zeros(length(ss.nevData.events),1);
z(event_index) = 1;
ss.nevData.events(~z)=[];
