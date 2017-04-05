function rtDetection(rootdir)

overwrite = true;

%search the ns5 files in subfolders under rootdir.
s = fullfile(rootdir,'**\*.ns5');
%
d = rdir(s);
%
tstart = datestr(now);

for i = 1 : length(d)
    f = d(i).name;
    fprintf('%d/%d: %s\n', i, length(d),fileparts(f));
    if i > 1
        et = etime(datevec(datestr(now)),datevec(tstart));
        ft = et/(i-1) * length(d);
        fprintf('elapsed time : %.1f hr, \t projected end time : %.1f hr\n',et/3600 , ft/3600);
    end
    %skip if Htt file exists
    if ~isempty(rdir(fullfile(fileparts(f),'*.Htt'))) && ~overwrite
        continue;
    end
    cd(fileparts(f));
    fn = strrep(f,'.ns5','');
    %detect spikes
    batchDetection(fn,1:24);
    
end

tend = datestr(now);

fprintf('Start: %s\nEnd: %s\n',tstart,tend);


