function procTrackImages(C,fpath,opt)
%sort the tracks images and stitch the titled images of each track.

d = rdir(fullfile(fpath,'**\AVG*.tif'));
%
fprintf('Number of Files %d\n',length(d));

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
 
% figure;
% hold on;
% for i = 1 : length(d)
%     plot(xpos(i),ypos(i),'ro');
%     text(xpos(i)+100,ypos(i),num2str(index(i)));
% end

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
    stitchImage(imgfiles,positions,output,opt);
end
