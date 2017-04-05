function plotlfp(rootdir)
%plot lfp 
%
targetFile = 'lfp*.mat';
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));

%fp = fopen('c:\work\openModelDataError.txt','w+');
%
scrsz = get(0,'ScreenSize');
h = figure('name','LFP');
set(h,'Position',[scrsz(1)+50 scrsz(2)+50 scrsz(3)-100 scrsz(4)-200])
hold on;

for i = 1 : length(d)
    %nsxFile = d(i).name;
    %dnev = dir(fullfile(fileparts(lfpFile),'*.nev'));
    %nevFile = fullfile(fileparts(lfpFile),dnev.name);
    fname = d(i).name;
    
    tt(i).data = load(fname);
    
    lfp(i).data = (tt(i).data.LFP.data-mean(tt(i).data.LFP.data))/(max(abs(tt(i).data.LFP.data))-mean(tt(i).data.LFP.data));
    
    plot(linspace(0,length(lfp(i).data)/1000,length(lfp(i).data)),lfp(i).data + i,'k');
    xlabel('time(s)');
    ylabel('lfp');
    
    %fprintf('[%d]/%d : %s ... \n',i,length(d),fname);
    
    
end

