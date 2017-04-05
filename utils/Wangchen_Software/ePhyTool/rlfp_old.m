function rlfp(rootdir)
%generate lfp files from raw data for flashingbar experiments. 
%d : input direcotry. all files in d including subfolders will be processed
%output file 
%split : save lfp data per channel.

% 
% if nargin < 2
%     split = false;
% end

opt.electrode = 'tetrode';
opt.split = false;

overwrite = false; 
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,'**\*.ns5'));
%
for i = 1 : length(d)
    datafile = d(i).name;
    %extract lfp from raw data
    fprintf('%d|%d: %s\n',i,length(d),datafile);
    
    if exist(fullfile(fileparts(datafile),'LFP.mat'),'file') && ~overwrite
        disp('file exist,continue');
        continue;
    else
        getlfp(datafile,opt);
    end

end


% function getlfp(rawFile)
% %
% %read nsx header
% h = openNSx(rawFile);
% %chunk size in MB.  
% chunkSize = 1000;
% %number of data points in INT16
% readDataPoints = (chunkSize*1e6)*2;
% %
% nChunk = ceil(h.MetaTags.DataPoints/readDataPoints);
% %
% readChunks = 1 : nChunk;
% %create low-pass butterworth filter.
% f_cutoff = 250;
% f_type   = 'low';
% f_order  = 4;
% f_sample = 30000;
% %sample freq for lfp
% lfp_fs = 500;
% %skip factor for downsampling
% skip_factor = f_sample/lfp_fs;
% %butterworth digital fitler
% [ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);
% %[ft1_b,ft1_a]=butter(f_order,f_cutoff/(f_sample/2),'high');
% 
% %read neural channel only, i.e, no analog channel
% nChan = length(find(h.MetaTags.ChannelID<=128));
% iChan = 0;
% %
% LFP.SampleFreq = lfp_fs;
% LFP.CutoffFreq = f_cutoff;
% LFP.Channel = [];
% LFP.Data = [];
% %
% for i = 1 : h.MetaTags.ChannelCount
%     chID = h.MetaTags.ChannelID(i);
%     if chID > 128; continue; end;
%     x = [];
%     fprintf('%d: read data in ch%d ...\n',i,chID); 
%     for j = 1 : nChunk
%         %if ~any(j==readChunks); continue; end
%         p = [1,readDataPoints]+(j-1)*readDataPoints;
%         if p(1) > h.MetaTags.DataPoints ; break; end
%         if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
%          h1 = openNSx(rawFile,'read','channels',chID,'duration',p); %read individual channels.
%          %pass through the filter and resample         
%          fxr = downsample(filtfilt(ft_b,ft_a,double(h1.Data)),skip_factor);
%          x = [x fxr]; %low pass lfp
%     end
%     iChan = iChan + 1;
%     %
%     LFP.Channel = [LFP.Channel chID];
%     if iChan == 1; LFP.Data = zeros(nChan,length(x)); end
%     
%     LFP.Data(iChan,:) = x;
% end
% 
% %save the file with lfp data 
% lfpFile = strrep(rawFile,'.ns5','_LFP.mat');
% save(lfpFile,'LFP');