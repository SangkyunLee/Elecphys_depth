function rfmSaveParam(paramNames,conditionArray)

nParam = length(paramNames);
[nn,nc] = size(conditionArray);
if nParam ~= nn
    error('unequal number of params to be saved');
end
%
if ismac
    fn = ['~/stimulation/data/','runningTrialParams_',datestr(now,'mmm-dd-yyyy_HH-MM-SS'),'.txt'];
elseif ispc
    fn = ['c:\data\','runningTrialParams_',datestr(now,'mmm-dd-yyyy_HH-MM-SS'),'.txt'];
else
end

fid = fopen(fn,'w');
%write the first row for variable names
s = 'index   ';
for i = 1 : nn
    s = sprintf('%s\t%s\t',s,paramNames{i});
end
fprintf(fid,'%s\n',s);

%format string for writing data.
s = ['%d\t\t',repmat('%8f\t',1,nn),'\n'];

%write values under each variable
for i = 1 : nc
    fprintf(fid,s,i,conditionArray(:,i));
end

fclose(fid);
    
    
