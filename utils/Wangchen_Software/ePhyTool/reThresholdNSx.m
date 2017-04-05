function reThresholdNSx(rootdir)
%generate lfp files from raw data for flashingbar experiments. 
%d : input direcotry. all files in d including subfolders will be processed
%output file 

%spike detection threshold
threshold = 2.5;
%subfolder to save the generated NEV files
sub = sprintf('thr%f',threshold);

%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,'**\*.ns5'));
%
for i = 1 : length(d)
    datafile = d(i).name;
    [fdir,fname] = fileparts(datafile);
    %extract lfp from raw data
    fprintf('%d|%d: %s\n',i,length(d),datafile);
    if exist(fullfile(fdir,sub,[fname,'.nev']),'file')
        disp('NEV file exists. skip');
        continue; %skip existing one.
    end
    NSx2NEV(datafile,threshold);
end


function NSx2NEV(rawFile,threshold)
%
%read nsx header
h = openNSx(rawFile);
%create high-pass butterworth filter.
f_cutoff = 250;
f_type   = 'high';
f_order  = 4;
f_sample = 30000;
%butterworth digital fitler
[ft_b,ft_a]= butter(f_order,f_cutoff/(f_sample/2),f_type);
%read neural channel only, i.e, no analog channel
nChan = length(find(h.MetaTags.ChannelID<=128));
iChan = 0;
%
for i = 1 : h.MetaTags.ChannelCount
    chID = h.MetaTags.ChannelID(i);
    if chID > 128; continue; end;
    %
    fprintf('%d: read data in ch%d ...\n',i,chID); 
    p = [1,h.MetaTags.DataPoints];
    h1 = openNSx(rawFile,'read','channels',chID,'duration',p); %read individual channels.
    iChan = iChan + 1;
end
