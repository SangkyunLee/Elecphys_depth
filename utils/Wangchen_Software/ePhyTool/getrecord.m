function getrecord(rootdir)

targetFile = '*.ns5';
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));
%
fp = fopen('c:\work\normLuminance_experiment_timetable.txt','w+');

for i = 1 : length(d)
    fileName = d(i).name;    
    if ~isempty(strfind(fileName,'Aug'))
        continue;
    end
    r = parseExperimentName(fileName);
    r.time = strrep(r.time,'-','_');
    for j = 1 : 24
        fprintf(fp,'%s\t%s\t%s\t%s\t%d\r\n',r.subject,r.exp,r.date,r.time,j);
    end
    %fprintf('[%d]/%d : %s ... \n',i,length(d),fileparts(fileName));
    
%     try
%         getPowerSpec(fileName);
%     catch
%         fprintf('error on %d|%d: %s, continue\n',i,length(d),fileName);
%         lasterr
%         
%     end
%     
        
end

fclose(fp);