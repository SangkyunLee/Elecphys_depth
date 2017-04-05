function cmap = getChannelMapping(p)
%p: electrode type 
%cmap : channel map
%

cmapFiles{1} = 'Tetrode_96ch_4C.CMP';
cmapFiles{2} = '32ch double-headstage map.CMP';
cmapFiles{3} = '32ch-EDGE double-headstage map.CMP';

switch p
    case 'standard'
        cmapFileIdx = 2;
    case 'edge'
        cmapFileIdx = 3;
    case 'tetrode'
        cmapFileIdx = 1;
end

cmapFileName = cmapFiles{cmapFileIdx};
%
cmapFilePath = fileparts(mfilename('fullpath'));
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(fullfile(cmapFilePath,cmapFileName));
%
cmap = readCerebusMap(cmapFile);