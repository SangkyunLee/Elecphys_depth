function rtcluster(rootdir)
%run the tetrode data clustering recursively

%search the ns5 files in subfolders under rootdir.
s = fullfile(rootdir,'**\*.ns5');
%
d = rdir(s);
%
for i = 1 : length(d)
    f = d(i).name;
    fprintf('Process File %d/%d\n', i, length(d));
    disp(f);
    fdir = fileparts(f);
    %check if the folder has been analyzed 
    jobfile = rdir(fullfile(fdir,'jobs.mat'));
%     matfile = rdir(fullfile(fdir,'result*.mat'));
    cd(fdir);
    if ~isempty(jobfile)
        runjobs;
    else
        fn= strrep(f,'.ns5','');
        %disp(fn);
        batchDetection(fn,1:24);
        createjobs([],1:24);
        runjobs;
    end
end
