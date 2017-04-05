function nevData = getNEVData(filename,datatype)
%get data with the chosen type from nev file
%WW2010

%available data types
dataTypeList = {'neurons','waves','events','contvars'};
    
if ~exist('datatype','var') || isempty(datatype) || ~isempty(strmatch('all',datatype))
    datatype = dataTypeList;
end

if ~iscell(datatype); datatype = {datatype}; end

cDataType = length(datatype);
idx = zeros(1,cDataType);

for i = 1 : cDataType
  s = datatype{i};  
  idx(i) = strmatch(s,dataTypeList,'exact');
end

%remove the selected datatype from list 
rmDataType = dataTypeList;
rmDataType(idx) = [];

%retrieve data -- or skip read the specified data segment in readNEVFile to
%speed up.
%nevData = readNEVFile(filename);
nevData = readNEVFile(filename,datatype);
%check if datatype exists in nevData
fds = isfield(nevData,rmDataType);
%remove the unselected datatype from returned data struct.
nevData = rmfield(nevData,rmDataType(fds));


    
    