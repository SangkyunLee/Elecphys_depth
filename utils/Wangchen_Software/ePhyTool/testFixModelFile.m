function testFixModelFile(errorfiles)
%fix the read error of model files -- refit
diary('c:\work\testFixModel.txt');
diary OFF;

for i = 1 : length(errorfiles)
    fout = errorfiles{i};
    [fdir,fname] = fileparts(fout);
%     fout = fullfile(fdir,[strrep(fname,'Sc','model'),'.mat']);
    f = fullfile(fdir,[strrep(fname,'model','Sc'),'.Htt']);
    fprintf('%d | %d : %s\n', i, length(errorfiles), f);
    
    %         if ~overwrite && exist(fout,'file'); continue; end
    %         et = etime(datevec(datestr(now)),datevec(tstart));
    %         fprintf('\t[%d|%d]..%s,%s, time elapsed %.2f hr,projected : %.2f \n',i,length(d),fname,fdir(end-20:end), et/3600,et/i*length(d)/3600);
    %========================================
    try
        load(fout);
        fprintf('\tUnit: %d spikes\n', length(model.SpikeTimes.data));
        clear model;
%         tt = ah_readTetData(f,'all'); %.Htt file
%         model = MoKsmInterface(tt);
%         model = getFeatures(model,'PCA');
%         % model.params.XYZ = abc;  % to set parameters for fitting
%         % model.params.DTmu = 6000;
%         model.params.Verbose = true; % for plots while fitting
%         model = fit(model);
%         % compressed = compress(model, model.train);  % speed up GUI by using subset of data
%         %manual = ManualClustering(model);  % pops up GUI, output is final model
%         save(fout,'model','-v7.3');
%         fprintf('done\n');
    catch
        diary ON
        lasterr
        fprintf('err on file %s\n', fout);
        diary OFF
    end
end