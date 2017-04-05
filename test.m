fn= 'W:\data\test\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-19\05-27-15\acute_FlashingBar006.ns5'
br = baseReaderBlackrock(fn,1)
 

%%

fd='W:\data\test\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-19\04-13-01'

automan(fd,0,1,1)


i=1
fn='W:\data\test\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-19\04-13-01\acute_NormLuminance005'
tetrode=1
detectSpikesTetrodes(sprintf('%s%s',fn,'.*'),tetrode(i),sprintf('Sc%d.Htt',tetrode(i)));



fn='W:\data\test\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-19\04-13-01\Sc1.Htt'
 tt = ah_readTetData(fn,'all'); %.Htt file
 
 rootdir ='W:\data\test\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-19\04-13-01'
 
 
 fn =fullfile(s.nevFolder,s.nevFile);
 NEV = openNEV(fn,'read','nowave','nowrite');
 
 
 fdir='W:\data\Wangchen\CEREBUS\DataFile\CerebusData\acute'
 checkReg(fdir)
 
 
datafile = 'W:\data\test\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-19\05-27-15\acute_FlashingBar006.ns5'
% datafile='/media/sdd_HGST6T/data/test/CEREBUS/DataFile/CerebusData/acute/FlashingBar/2011-Oct-19/05-27-15/acute_FlashingBar006.ns5'
opt.electrode = 'tetrode'; %standard or tetrode
opt.split = true;          %false    or true for tetrode
getlfp(datafile,opt);


fn = 'W:\data\test\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-19\05-27-15\acute_FlashingBar006.ns5'
 MD5Result = checkMD5_dir(fileparts(fn),'*.ns5','1')
 MD5K=load('X:\ephy_wangchen\wangchen_Cdrive_data_code\Work\MD5_CerebusData\checkMD5Result_SS-STIM01_Disk_K.mat')
MD5K = MD5K.MD5Result;
R4 = compareMD5(MD5Result, MD5K,'acute','acute')
 



%%
i=1
fn='W:\data\test\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-19\05-27-15\acute_FlashingBar006'

tetrode=14
detectSpikesTetrodes(sprintf('%s%s',fn,'.*'),tetrode(i),sprintf('Sc%d.Htt',tetrode(i)));
 
 %convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(file_map);
cmap = readCerebusMap(cmapFile);

%%

datafile='W:\data\test\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-19\04-13-01\acute_NormLuminance005.ns5'
datafile='/media/sdd_HGST6T/data/test/CEREBUS/DataFile/CerebusData/acute/NormLuminance/2011-Oct-19/04-13-01/acute_NormLuminance005.ns5'
opt.electrode = 'tetrode'; %standard or tetrode
opt.split = true;          %false    or true for tetrode
getlfp(datafile,opt);

% tetrode 14
73    75    77    79
% tetrode 17
106   108   110   112

fn='W:\data\test\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-19\04-13-01\acute_NormLuminance005.ns5'
fn='W:\data\Wangchen\CEREBUS\DataFile\CerebusData\acute_raw\FlashingBar\2012-Feb-16\09-40-55\acute_FlashingBar004.ns5'
fn='W:\data\Wangchen\CEREBUS\DataFile\CerebusData\acute_raw\FlashingBar\2012-Nov-14\04-30-23\acute_FlashingBar006.ns5'
readIdx=[1 1e5];
s = openNSx(fn,'read','channels',10,'duration',readIdx); %
figure; plot(s.Data)

% s=openNSx('report','read',fn,'t:3:4','min');
 

%%

sF='W:\data\test\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-19\05-27-15\acute_FlashingBar006.*'

outFile='test.H5lfp'
extractLfpTetrodes(sF, outFile)

fp = H5F.open(outFile, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
H5F.close(fp);

info=h5info(outFile)
h5disp(outFile);
a=h5read(outFile,'/data');

b=load('x.mat')

outFile='W:\data\test\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-19\05-27-15\LFP.h5'
info=h5info(outFile)
h5disp(outFile);
a=h5read(outFile,'/data');

b=load('x.mat')



rootdir='W:\data\Wangchen\CEREBUS\DataFile\CerebusData\acute'
expID=1;
csd_data = rcsd_tetrode(rootdir,expID)




%%

 
 
 