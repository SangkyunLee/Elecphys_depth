function fout = getDepthDatabase(file_summary, file_base)
%get the depth of sorted channel/unit
%file_summary : rate/sta summary file (text file)
%file_base    : excel file of depth database, which lists the probe type,
%               spacing, reference channel and depth of reference channel 
%e.g, depthDateBase_template_FR_DEC_17_2012.txt in ephyTool folder.

[fs_path,fs_name,fs_ext] = fileparts(file_summary);
%data columns
if regexpi(file_summary,'rate')
    %nc = 21;
    nc = 29 ;  %add rates estimate columns.
    chIdx = 9;   %column index for channel
elseif regexpi(file_summary,'sta')
    nc = 22;
    chIdx = 9;
else
    nc = 0;
    chIdx = 0;
end

    
if strcmpi(fs_ext,'.xls') || strcmpi(fs_ext,'.xlsx')
    a = xlsread(file_summary);
else
%     a = textread(file_summary,'%f','commentstyle','matlab');
%     %
%     a = reshape(a,nc,[]); a = a'; 
      a = dlmread(file_summary);
end

[fb_path,fb_name,fb_ext] = fileparts(file_base);
if strcmpi(fb_ext,'.xls') || strcmpi(fb_ext,'.xlsx')
    b = xlsread(file_base);
else
    b = textread(file_base,'%f','commentstyle','matlab');
    b = reshape(b,10,[]); b = b';
end

cmap = struct;
cmap(1).probe   = 'standard';
cmap(1).channel = [11 51 10 47 12 49 9 43 14 45 8 41 16 44 6 39 18 42 4 35 20 37 2 33 7 40 5 38 3 36 1 34];
cmap(1).spacing = 50;
cmap(2).probe   = 'edge';
cmap(2).channel = [11 10 12 9 14 8 16 6 18 4 20 2 7 5 3 1 34 36 38 40 33 37 35 42 39 44 41 45 43 49 47 51];
cmap(2).spacing = 100;

%experiment date list
list = zeros(size(b,1),1);
%
for i = 1 : length(list)
    list(i) = datenum(b(i,1:6));
end
%experiment date for the channel/unit in the summary file 
xList = zeros(size(a,1),2);
for i = 1 : length(xList)
    xList(i,1) = datenum(a(i,1:6)); %date
    chan = a(i,chIdx);              %channel
    k    = find(xList(i,1)==list);  %index of the exp date in datebase file 
    pt   = b(k,7);                  %probe type
    ps   = b(k,8);
    pr   = b(k,9);
    rd   = b(k,10);
    switch pt
        case 1 %standard probe
            mapID = 1;
        case 0
            mapID = 2;
    end
    %calculate the depth of the channel 
    m = find(chan == cmap(mapID).channel); %lookup channel index on the probe
    z = find(pr   == cmap(mapID).channel); %reference channel index on the probe
    if ~isempty(m)
        xList(i,2) = rd - (m-z)*ps ;
    else
        xList(i,2) = -5000;       %set a large negative number if chan not found
    end
end

fout = fullfile(fs_path,[fs_name,'_depth.xlsx']);

A = [a(:,1:6) xList(:,2)];
%xlswrite(fout,{A,'Depth'});
xlswrite(fout,A);
B = [a xList(:,2)];

xlswrite(fullfile(fs_path,[fs_name,'.xlsx']), B);

disp('done');

