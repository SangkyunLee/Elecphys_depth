function stitchImage(files,positions,outfile,opt)
%stitch all the input 2photon images 
%files : input filenames
%positions : xy coordinates 
%output    : stitched file 

xPos = positions(1,:);
yPos = positions(2,:);

imgInfo.Width  = zeros(1,length(files));
imgInfo.Height = imgInfo.Width;

%skip the check on resolution consistency.

for i = 1 : length(files)
    info = imfinfo(files{i});
    imgInfo.Width(i) = info.Width;
    imgInfo.Height(i) = info.Height;
    %imgInfo.XResolution(i) = info.XResolution;
    %imgInfo.YResolution(i) = info.YResolution;
    imgInfo.RowsPerStrip(i) = info.RowsPerStrip;
    imgInfo.MaxSampleValue(i) = info.MaxSampleValue(1);
    imgInfo.MinSampleValue(i) = info.MinSampleValue(1);
%   fprintf('W%d,H%d,X%d,Y%d,RP%d\n',info.Width, info.Height,info.XResolution, info.YResolution, info.RowsPerStrip);
end

%return;

%find the canvas size to stitch the images
x0 = min(xPos);
y0 = min(yPos);
x1 = max(xPos + imgInfo.Width);
y1 = max(yPos + imgInfo.Height);

imgCompression = 'none'; 

outputWidth  = x1-x0 + 1 ;
outputHeight = y1-y0 + 1 ;

Y = imgInfo.MaxSampleValue(1)*ones(outputHeight,outputWidth,3);

%sort the files by x-coordinates
[xPos_sort,xPos_Idx] = sort(xPos);
[yPos_sort,yPos_Idx] = sort(yPos,'descend');

for i = 1 : length(files)
    if strcmp(opt,'x')
        sid = xPos_Idx(i);
    else
        sid = yPos_Idx(i);
    end
    X = imread(files{sid});
    %X = imrotate(X,theta);
    [sh,sw,sc] = size(X);
    %position in canvas
    cx = xPos(sid) - x0 + 1 ; 
    cy = yPos(sid) - y0 + 1 ;
    if strcmp(opt,'y')
        cy = outputHeight - cy - imgInfo.Height(sid) + 1 ;
    end
    Y(cy:cy+imgInfo.Height(sid)-1,cx:cx+imgInfo.Width(sid)-1,:) = X ; 
end

Y = eval([class(X),'(Y);']);
%Y = uint16(Y);

if strcmp(opt,'x')
    %rotate the slices by 90.
    Y = permute(Y,[2 1 3]);
    %flip x to keep the tilted image the same direction
    Y = flipdim(Y,2);
end
%figure;image(Y);

%save to the folder of the first file

% outfile = fullfile(fdir,sub,[fname,fext]);
% if ~exist(fileparts(outfile),'dir'); mkdir(fileparts(outfile)); end

imwrite(Y,outfile,'Compression',imgCompression);
% 
% fprintf('%d | %d : \t done\n',i,length(d));
    




    
