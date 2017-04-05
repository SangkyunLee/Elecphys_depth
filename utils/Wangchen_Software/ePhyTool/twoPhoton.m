%config matrix to specify the slice and the titled images.
%slice number, track number, image numbers, padding 0
C = [9  1 49 50 51 0 0
     9  2 53 55 56 0 0
     10 1 58 59 60 0 0
     10 2 62 63 64 65 0
     11 1 66 67 68 69 0
     11 2 70 74 0  0  0
     11 3 71 73 0  0  0
     12 1 77 78 79 0 0
     12 2 83 84 85 0 0 
     12 3 86 88 0 0 0 
     12 4 80 82 0 0 0
     8  1 89 90 91 0 0
     8  2 92 93  0 0 0
     7  1 94 95  0 0 0
     7  2 96 98 0 0 0
     7  3 99 100 0 0 0];
 
rootdir = 'c:\Work\Figures\Histology\2Photon Fluorescence Imaging\Wang_with Sergy\112613\';
 
d = rdir(fullfile(rootdir,'**\AVG*.tif'));
%
fprintf('Files %d\n',length(d));

xpos = zeros(1,length(d));
ypos = xpos;
index = xpos;
xres = xpos;
yres = xpos;
files = cell(1,length(d));

for i = 1 : length(d)
    imgFile = d(i).name;
    files{i} = imgFile;
    xmlFile = dir(fullfile(fileparts(imgFile),'Z*.xml'));
    xmlFile = fullfile(fileparts(imgFile),xmlFile.name);
    xml = xml2struct(xmlFile);
    %pos in micron units
    xpos(i) = str2num(xml.PVScan.Sequence.Frame{1}.PVStateShard.Key{13}.Attributes.value); 
    ypos(i) = str2num(xml.PVScan.Sequence.Frame{1}.PVStateShard.Key{14}.Attributes.value);
    xres(i) = str2num(xml.PVScan.Sequence.Frame{1}.PVStateShard.Key{19}.Attributes.value); 
    yres(i) = str2num(xml.PVScan.Sequence.Frame{1}.PVStateShard.Key{20}.Attributes.value);
    
    index(i) = str2num(imgFile(end-6:end-4));
    fprintf('image%d : %d %d\n', index(i),xpos(i),ypos(i));
    
end

%pos in pixels.
xpix = round(xpos ./ xres) ;
ypix = round(ypos ./ yres) ; 
 
figure;
hold on;
for i = 1 : length(d)
    plot(xpos(i),ypos(i),'ro');
    text(xpos(i)+100,ypos(i),num2str(index(i)));
end

[nTracks,nScans] = size(C);

for i = 1 : nTracks
    %recording file index
    si = C(i,3:end);
    si = si(si~=0);
    %
    fs = zeros(size(si));
    for j = 1 : length(si)
         fs(j) = find(si(j) == index);
    end
    %histology slice index
    his = C(i,1);
    %track index
    tra = C(i,2);
    %
    imgfiles = files(fs);
    positions = [xpix(fs); ypix(fs)];
    output = fullfile(fileparts(imgfiles{1}),sprintf('Stitch_Slice%dTrack%d.tif',his,tra));
    stitchImage(imgfiles,positions,output);
end

    


