function mainSorting(rootdir,beforeDate)

diary('/media/sdd_HGST6T/data/scripts//sortinginfo/mainSorting.txt');

fprintf('\nRun--> %s, %s\n', datestr(now), rootdir);

overwrite = true;

if nargin < 2
    beforeDate = [2011 8 30];
end

beforeDateNum = datenum(beforeDate);

%search the ns5 files in subfolders under rootdir.
s = fullfile(rootdir,['**' filesep '*.Htt']);
% s = fullfile(rootdir,'**\Sc15.Htt');
%
d = rdir(s);
%
tstart = datestr(now);
%
doneSize = 0;
totalSize = 0;

for i = 1 : length(d)
    totalSize = totalSize + d(i).bytes;
end

fprintf('%d files, %.2f Gb\n\n',length(d),totalSize/1e9);

diary OFF;

for i = 1 : length(d)
        f = d(i).name;        
        [ix1,ix2] = regexp(f,'\\201\d-\w{3}-\d\d\\');
        expDateNum = datenum(f(ix1+1:ix2-1),'yyyy-mmm-dd');
        if expDateNum < beforeDateNum
%         if d(i).datenum < beforeDateNum || datenum(f(ix1+1:ix2-1)) < beforeDateNum
            fprintf('skip file prior to set date %s\n',f(ix1+1:ix2-1));
            continue;
        end
        [fdir,fname] = fileparts(f);
        fout = fullfile(fdir,[strrep(fname,'Sc','model'),'.mat']);
        if ~overwrite && exist(fout,'file'); continue; end
        et = etime(datevec(datestr(now)),datevec(tstart));
        if doneSize > 0
            pt = et * totalSize / doneSize ; 
        else
            pt = inf;
        end
%         fprintf('\t[%d|%d]..%s,%s, time elapsed %.2f hr,projected : %.2f \n',i,length(d),fname,fdir(end-20:end), et/3600,et/i*length(d)/3600);
        fprintf('\t[%d|%d]..%s,%s, time elapsed %.2f hr,projected : %.2f \n',i,length(d),fname,fdir(end-20:end), et/3600,pt/3600);
        %========================================
        try
            tt = ah_readTetData(f,'all'); %.Htt file
            model = MoKsmInterface(tt);
            model = getFeatures(model,'PCA');
            % model.params.XYZ = abc;  % to set parameters for fitting
            % model.params.DTmu = 6000;
            model.params.Verbose = true; % for plots while fitting
            model = fit(model);
            % compressed = compress(model, model.train);  % speed up GUI by using subset of data
            %manual = ManualClustering(model);  % pops up GUI, output is final model
            save(fout,'model','-v7.3');
            fprintf('done\n');
        catch
            diary ON
            fprintf('err on file %s-->\n', fout);
            lasterr
            diary OFF
        end
        
        clear model;
        doneSize = doneSize + d(i).bytes;%data processed 
        %========================================
end

tend = datestr(now);
fprintf('Start: %s\nEnd: %s\n',tstart,tend);
%============================================================
%assignment = model.cluster(); %cluster assignment of spikes
%grouping = manual.GroupingAssignment.data;  %manual grouping result
