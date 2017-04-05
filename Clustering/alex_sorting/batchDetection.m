function batchDetection(fn,tetrode)
%batch processing detectSpikesTetrodes with a range of tetrodes.
startTime = datestr(now);
%
n = length(tetrode);

for i = 1 : n
    try
        fprintf('\ttt%d\n',tetrode(i));
        %if ~isempty(dir(fullfile(fileparts(fn),sprintf('Sc%d.Htt',tetrode(i))))); continue; end
        detectSpikesTetrodes(sprintf('%s%s',fn,'.*'),tetrode(i),sprintf('Sc%d.Htt',tetrode(i)));
    catch
        fprintf('error with tt%d\n',tetrode(i));
        %lasterr
    end
end

endTime = datestr(now);

fprintf('start: %s\nend: %s\n',startTime,endTime);


