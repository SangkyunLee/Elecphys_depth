function rCheckFileError(rootdir)
%check the error reading files
%rootdir : source direcotry. all files including subfolders will be processed

diary('c:\work\modelfile_readerror.txt');
diary OFF;

%search the 'target' files to locate the data subfolders.
% d = rdir(fullfile(rootdir,'**\*.ns5'));
d = rdir(fullfile(rootdir,['**\model*.mat']));
%
n = 0;

for i = 1 : length(d)
    
    datafile = d(i).name;
    [fdir,fname] = fileparts(datafile);
    fprintf('reading %d|%d %s...\n',i, length(d),datafile);
    try
        load(datafile);
        fprintf('\t unit %d \n', length(model.SpikeTimes.data));
        clear model;
    catch
        diary ON;
        %lasterr
        fprintf('error reading %d|%d %s...\n',i, length(d),datafile);
        diary OFF;
        n = n + 1;
        errorfiles{n} = datafile;
    end
    
end

try 
    save('c:\work\modelfile_readerror.mat','errorfiles');
catch
end
