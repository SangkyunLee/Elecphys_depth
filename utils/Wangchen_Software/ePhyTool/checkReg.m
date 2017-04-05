function checkReg(fdir)
%
%
files = rdir(fullfile(fdir,'**\stimData.mat'));

for i = 1 : length(files)
    file = files(i).name;
    load(file);
    t = stimData.Timestamps;
    dt = diff(t); 
    folder = parseFolder(fileparts(file));
    expName = folder.exp;
    
    switch expName 
        case 'FlashingBar'
            itv = 5 ;
        case 'NormLuminance'
            itv = 2 / 60;
        case 'NormGrating'
            itv = 3 / 60; 
        case 'SquareMappingExperiment'
            itv = 2 / 60;
    end
    
    avg = mean(dt); 
    sig = std(dt); 
    fprintf('%d|%d : %s \n', i, length(files), file);
    fprintf('\t average : %f, std : %f \n\t min : %f , max : %f \n', avg, sig, min(dt), max(dt));
    n = find(abs(dt - itv) > 0.5 * 1 / 60); %find outliers
    fprintf('\t outliers: %d \n\n', length(n));
    
end
    
    