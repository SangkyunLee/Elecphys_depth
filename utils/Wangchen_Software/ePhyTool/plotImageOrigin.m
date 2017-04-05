function plotImageOrigin(rootdir)
%plot the origins from 2photon z-scan images

%rootdir = 'c:\Work\Figures\Histology\2Photon Fluorescence Imaging\Wang_with Sergy\112613\';
 
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
    
    index(i) = str2num(xmlFile(end-6:end-4));
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
