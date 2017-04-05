% rootdir = 'k:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\';
%rootdir = 'k:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Feb-16\23-29-39\';
%rootdir = 'k:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Feb-16\12-50-58\';
%rootdir = 'k:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2012-Nov-13\03-43-31';
% rootdir = 'c:\Users\Wangchen\Documents\Backup\Disk1\Work\Data\CerebusData\mice\NormLuminance\';
rootdir = 'e:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\';

d = rdir(fullfile(rootdir,'**\*.nev'));
opt.nevvar = {'events'};

hfig = figure;
%
for i = 1 : length(d)
    lfpFile = d(i).name;
    [fpath,fname] = fileparts(lfpFile);
    %skip Aug-24-2011 that has excessvily large NEV file >1gb for
    %normgrating
    if ~isempty(strfind(fpath,'Aug-24')); continue; end
    %nevFile = fullfile(fpath,strrep(fname,'_LFP','.nev')); 
    nevFile = lfpFile;
    fprintf('[%d]/%d : %s ... \n',i,length(d),fpath(length(rootdir):end));
    %extract lfp from raw data
    
    dmat = rdir(fullfile(fileparts(strrep(nevFile,'CerebusData','StimulationData')),'**\*.mat'));
    if isempty(dmat); continue; end %skip .nev files from 'sort' subfolders.
    
    matFile = dmat(1).name;
    
     if ~isempty(strfind(nevFile,'NormLuminance'))
         expName = 'NormLuminance';
     elseif ~isempty(strfind(nevFile,'NormGrating'))
         expName = 'NormGrating';
     else
         expName = '';
     end
%     getcsd(lfpFile,nevFile,'close');
    try
        mm = load(matFile);
        tm = mm.params.swapTimes;
        tm = tm(3:end-1);
        tm = tm(1:2:end);
        dtm = diff(tm);
        switch expName
            case 'NormLuminance'
                largeISI_THR = 1.2 * (mm.params.stimFrames /60); %0.04
                ISIFilter_THR = 0.8 * (mm.params.stimFrames /60);
            case 'NormGrating'
                largeISI_THR = 1.2 * ((mm.params.stimFrames+mm.params.pauseFrames+mm.params.blankFrames) /60); %0.04
                ISIFilter_THR = 0.8 * ((mm.params.stimFrames+mm.params.pauseFrames+mm.params.blankFrames) /60); %0.04
        end
        
        largeTM = find(dtm > filterISI); 
        
        hh = getNEVData(nevFile,opt.nevvar);
         
         tp = hh.events{1}.timestamps;
         tp = ISIFilter(tp,ISIFilter_THR);
         
         tm0 = tm-tm(1);
         tp0 = tp-tp(1);
         
         dt = diff(tp);
         largeTI = find(dt> largeISI_THR);
                  
         fprintf('%d) large ts -- photodiode %d, mac %d \n',i,length(largeTI),length(largeTM));
         if length(largeTI)<3
             for j = 1 : length(largeTI)
                 fprintf('\t%d',largeTI(j));
             end
             fprintf('\n');
         end
         %the break time between sync and stimulus onset
         fprintf('break time : %f (Sec)\n', mm.params.swapTimes(3)-mm.params.swapTimes(1));
         
         if ~isempty(strfind(nevFile,'NormLuminance'))
            lum = reshape(mm.params.rndLumin,1,[]);
         elseif ~isempty(strfind(nevFile,'NormGrating'))
             lum = reshape(mm.params.rndOrient,1,[]);
         else
             lum = [];
         end
         
         
         largeLum_start = lum(largeTI);
         largeLum_end = lum(largeTI+1); %
         
%          figure(hfig);
%          %plot(largeLum_start,'b'); hold on; plot(largeLum_end,'r'); hold off;
%          hist(largeLum_start); %hold on; %hist(largeLum_end);
%          pause;
         
    catch
        fprintf('error on %d|%d: %s, continue\n',i,length(d),lfpFile);
        lasterr
    end
end

% tp = s.nevData.events{1}.timestamps;
% tm = s.matData.params.swapTimes;
% tmm = tm(3:end-1);
% dt = diff(tp);
% figure;hist(dt);
% largeTI = find(dt>0.04);
% fprintf('large t num %d\n',length(largeTI));
% occur = diff(largeTI);
% figure;hist(occur,20);