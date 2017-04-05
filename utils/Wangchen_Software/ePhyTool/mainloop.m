%baseDir = 'c:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\';
%baseDir = 'j:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2011-Oct-19\07-29-50\';
fbase{1} = 'j:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Nov-13\';
fbase{2} = 'j:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Nov-14\';
fbase{3} = 'j:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Nov-15\';
fbase{4} = 'j:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Nov-16\';

for k = 1 : 4
    baseDir = fbase{k};
    fd = rdir(fullfile(baseDir,'**\\stimData.mat'));
    clear folder;
    
    for i = 1 : length(fd)
        fprintf('%d | %d ] \t\n', i , length(fd));
        [fpath,fname] = fileparts(fd(i).name);
        if ~isempty(strfind(fpath,'-Aug-')) || ~isempty(strfind(fpath,'-May-11'))
            continue;
        end
        folder(1) = parseFolder(strrep(fpath,'CerebusData','StimulationData'));
        folder(2) = folder(1);
        folder(3) = parseFolder(fpath);
        try
            mainSTA_Func(folder);
        catch
            lasterr
        end
    end
end