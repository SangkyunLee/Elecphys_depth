function tiffrgb2gray(fpath)
%convert tiff files in rgb to gray
%
d1 = rdir(fullfile(fpath,'**\*.tif'));
d2 = rdir(fullfile(fpath,'**\*.tiff'));

d = [d1 d2];

outpath = fullfile(fpath,'gray');
if ~exist(outpath,'dir'); mkdir(outpath); end

for i = 1 : length(d)
    [fdir,fname,fext] = fileparts(d(i).name);
    I = rgb2gray(imread(d(i).name));
    imwrite(I,fullfile(outpath,[fname,fext]));
end


    