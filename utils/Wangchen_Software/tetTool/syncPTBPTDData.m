fd = 'j:\CEREBUS\DataFile\CerebusData\acute\';

files = rdir(fullfile(fd,'**\stimData.mat'));

for i = 1 : length(files)
    fprintf('%d|%d : %s\n', i, length(files), files(i).name);
    data = load(files(i).name);
    if isempty(data); continue; end
    try 
        stimData = syncPTBPTD(data.stimData);
        save(files(i).name,'stimData');
    catch
        lasterr
    end
end

    
