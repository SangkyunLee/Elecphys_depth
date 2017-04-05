%reconstruct the 2p images for tetrode tracks.

%read in the mapping matrix of slice number, image number and track number
rootdir = 'c:\Work\Histology\2Photon Imaging\AVG\';
imgFolderName = {'V11262013','V12092013','V12112013'};
nSet = length(imgFolderName);
imgFolder = cell(1,nSet);
txtFile = cell(1,nSet);
for i = 1 : nSet
    imgFolder{i} = fullfile(rootdir,imgFolderName{i});
    txtFile{i} = fullfile(rootdir,[imgFolderName{i},'_TrackConfig.txt']);
end

%data set to be processed
pid = [1:3];

for i = 1 : length(pid)
    m = pid(i);
    C = dlmread(txtFile{m});
    if m == 1
        opt = 'x'; %stitch along x 
    else
        opt = 'y'; %stitch along y
    end
    procTrackImages(C,imgFolder{m},opt);
end


