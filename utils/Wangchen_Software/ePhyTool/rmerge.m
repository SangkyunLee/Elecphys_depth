function rmerge(rootdir)
%save spike times into manual.mat 
%
targetFile = 'manual*.mat';
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));

fp = fopen('c:\work\openModelDataError.txt','w+');
%
for i = 1 : length(d)
    %nsxFile = d(i).name;
    %dnev = dir(fullfile(fileparts(lfpFile),'*.nev'));
    %nevFile = fullfile(fileparts(lfpFile),dnev.name);
    fname = d(i).name;
    
    fmodel = strrep(fname,'manual','model');
    
    fprintf('[%d]/%d : %s ... \n',i,length(d),fname);
    
    if i < 605; continue; end
    
    try
        clear manual
        clear model;
        load(fname);
        manual.SpikeTimes = [];
        load(fmodel);
        manual.SpikeTimes = model.SpikeTimes;
        save(fname,'manual');
    catch
        fprintf('error on %d|%d: %s\r\n',i,length(d),fname);
        fprintf(fp,'error on %d|%d: %s\r\n',i,length(d),fname);
        lasterr
        
    end
end

fclose(fp);