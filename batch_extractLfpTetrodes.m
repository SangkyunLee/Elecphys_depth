
% Extract LFP for tetrodes.
%   extractLfpTetrodes(sourceFile, outFile) extracts the LFP by taking
%   channel averages for tetrodes and treating references individually. A
%   lowpass filter with a 200 Hz cutoff is applied before downsampling.
% and highpass filtering with 1Hz
%   

rootdir = '/media/sdd_HGST6T/data/Wangchen/CEREBUS/DataFile/CerebusData/acute_raw/FlashingBar/';
d=rdir(fullfile(rootdir,'**/*.ns5'));



for i = 1 : length(d)
    
    dvec = datevec(d(i).datenum);
    if dvec(1)==2011 && dvec(2)<10
        continue;
    end
    sourceFile = d(i).name;
    
    fprintf('%d|%d: %s\t%.1f\n',i,length(d),sourceFile,d(i).bytes/1e6);
    
    sourceFile  = strrep(sourceFile,'.ns5','.*');
    outpath = fileparts(sourceFile);
    outpath = strrep(outpath,'acute_raw','acute');
    extractLFPTetrode(sourceFile, @(x) mean(x, 2), [0 200],outpath);

end

