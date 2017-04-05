%load up the Receptive Field Mapping Control Pannel.

%set the global variables for stim param and windows socket param.
%clear all;

global rfmPar;
global rfmStimPar; %variable passed to remote host for stimulus. trimmed from rfmPar for data transfer over socket

%==========================================================================
%folder to save the parameter files.
folder = struct;
%os-depedent 
if ispc
    folder.base = 'c:\cerebus\datafile\CerebusData';
elseif ismac
    folder.base = '~/stimulation/CerebusData';
else
    folder.base = pwd;
end

rfmPar.rfmRoot=pwd;
rfmPar.rfmPath=fullfile(rfmPar.rfmRoot,'lib');
% %addpath
% addpath(rfmPar.srPath);
% savepath;
%init the params 
rfmPar.RemoteHost = '10.21.19.46';
rfmPar.RemotePort = 7864;

%for ssh connection
rfmPar.puttyPath = 'c:\Software\Putty';
rfmPar.userID = 'sslab';
rfmPar.userPwd = '';
rfmPar.runScript = 'rfm_RunTime';

%screen param of stimulus monitor.
rfmPar.ScrHRes = 1920;
rfmPar.ScrVRes = 1200;
rfmPar.ScrRefRate = 60;

%screen to eye distance (in mm).
rfmStimPar.ScrEyeDistance = 570;
%Mac Screen pixel resolution (in mm)
rfmStimPar.ScrPixSize = 0.27;

%========================================================================

rfmPar.ChID = 1;
%totoal number of channels. 24-ch
rfmPar.ChTN = 24; 
%append the joint-rfb to the end of channel list.

rfmPar.ChSets = cell(1,rfmPar.ChTN+1);

for i = 1 : rfmPar.ChTN
    rfmPar.ChSets{i} = struct('ChID',i,...
        'Visible',false,'TrackCursor',false,'CoCenterStim',false,...
        'DimX',37,'DimY',37,'PosX',rfmPar.ScrHRes/2,'PosY',rfmPar.ScrVRes/2,...
        'DimDX',5,'DimDY',5,...
        'PosDX',5,'PosDY',5,'Orientation',0,'OrientationStepSize',5,...
        'constStepSize', 1, ...
        'hLabel',[],...
        'Color',[0 0 1],'hCircle',[]);
    
    if i < fix(rfmPar.ChTN/3)
        rfmPar.ChSets{i}.('Color')=[i*255/(rfmPar.ChTN/3) 10 10];
    elseif i < fix(rfmPar.ChTN*2/3)
        rfmPar.ChSets{i}.('Color')=[10 (i-rfmPar.ChTN/3)*255/(rfmPar.ChTN/3) 10];
    else
        rfmPar.ChSets{i}.('Color')=[10 10 (i-rfmPar.ChTN*2/3)*255/(rfmPar.ChTN/3)];
    end
    %normalize
    rfmPar.ChSets{i}.('Color') = rfmPar.ChSets{i}.('Color')/255;
end

rfmPar.ChSets{1}.('Visible') = true;

rfmPar.rfbJoint = struct('ChID',rfmPar.ChTN+1,'Visible',true,'TrackCursor',false,...
    'CoCenterStim',false,'DimX',100,'DimY',100,...
    'PosX',rfmPar.ScrHRes/2,'PosY',rfmPar.ScrVRes/2,...
    'DimDX',5,'DimDY',5,...
        'PosDX',5,'PosDY',5,'Orientation',0,'OrientationStepSize',5,...
        'constStepSize', 1, ...
        'hLabel',[],...
        'Color',[1 1 1],'hCircle',[]);
%append joint-rfb to the end of channel list. it'll be easier to manipulate.    
rfmPar.ChSets{rfmPar.ChTN+1} = rfmPar.rfbJoint;    
%range for multi-rfb display
rfmPar.rfbRange = [];

%create the data matrix for the rfb ovals
NOP = 100;
THETA = linspace(0,2*pi,NOP);
RHO = ones(1,NOP);
[circleX,circleY] = pol2cart(THETA,RHO);
rfmPar.circleX = circleX;
rfmPar.circleY = circleY;
%draw cross in the cirle
rfmPar.vCrossY = -1:0.1:1;
rfmPar.vCrossX = zeros(size(rfmPar.vCrossY));
rfmPar.hCrossX = -1:0.1:1;
rfmPar.hCrossY = zeros(size(rfmPar.hCrossX));



rfmPar.rfbDimPosIdx = 1;
%list index for dim/pos menu. Dim/Pos/Stepsize of Dim/Stepsize of Pos
rfmPar.rfbParamsList1{1} = struct('Name','Dimension(2x,2y)',...
    'Var1','x','Var2','y','Val1',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('DimX'),...
    'Val2',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('DimY'));
rfmPar.rfbParamsList1{2} = struct('Name','Dimension StepSize(dx,dy)',...
    'Var1','dx','Var2','dy','Val1',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('DimDX'),...
    'Val2',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('DimDY'));
rfmPar.rfbParamsList1{3} = struct('Name','Position(x,y)',...
    'Var1','x','Var2','y','Val1',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('PosX'),...
    'Val2',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('PosY'));
rfmPar.rfbParamsList1{4} = struct('Name','Position StepSize(dx,dy)',...
    'Var1','dx','Var2','dy','Val1',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('PosDX'),...
    'Val2',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('PosDY'));


rfmPar.rfbDimPosValChgSyn = false;

rfmPar.rfbParamsList2{1} = struct('Name','Orientation(a)',...
    'Var1','a','Val1',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('Orientation'));
rfmPar.rfbParamsList2{2} = struct('Name','Orientation StepSize(da)',...
    'Var1','da','Val1',rfmPar.ChSets{rfmPar.rfbDimPosIdx}.('OrientationStepSize'));
%list index of param menu.
rfmPar.rfbParamsIdx = 1;

%index for stimulus type (bar,grating...)    
rfmPar.StimIdx = 1;  

switch rfmPar.StimIdx
    case 1
        rfmPar.currentTask = 'rfmBar';
    case 2
        rfmPar.currentTask = 'rfmGrating';
end

%use cerebus NSP to record activity
rfmPar.useNSP = false;

folder.subject = 'rfm';
folder.exp = 'NeuronTuning';
folder.date = datestr(now,'yyyy-mmm-dd');
folder.time = datestr(now,'HH-MM-SS');

rfmPar.NSPDataFolder = folder;
rfmPar.NSPFileName = 'rfmData';
rfmPar.NSPDataFile = '';
rfmPar.NSPDataComm = 'receptive field mapping';

rfmPar.ECM = [];
rfmPar.NSP = [];

%cursor mode --- stimulus or control mode.
rfmPar.cursorInStim = false;

rfmPar.Stim{1} = struct('Name','Bar',...
    'Visible',true,'TrackCursor',false,'CoCenterRFB',false,'Static',true,...
    'DimX',3,'DimY',30,'PosX',rfmPar.ScrHRes/2,'PosY',rfmPar.ScrVRes/2,...
        'DimDX',5,'DimDY',5,'PosDX',5,'PosDY',5,...
        'Orientation',0,'OrientationStepSize',5,...
        'constStepSize', 1, ...
        'SpatialFreq',0,'TempoFreq',0,...
        'RefreshOnFrames',rfmPar.ScrRefRate,...
        'RefreshOnFramesStepSize',5,...
        'RefreshOffFrames',rfmPar.ScrRefRate,...
        'RefreshOffFramesStepSize',5,...
        'TrialDuration',7200,...
        'TrialDurationStepSize',5,...
        'TrialRepetition',1,...
        'TrialRepetitionStepSize',1,...
        'InterTrialDuration',0.1,...
        'InterTrialDurationStepSize',0.01,...
        'InvColor',false,'Color',[1 1 1]);
rfmPar.Stim{2} = struct('Name','Grating',...
    'Visible',true,'TrackCursor',false,'CoCenterRFB',false,'Static',false,...
    'DimX',150,'DimY',150,'PosX',rfmPar.ScrHRes/2,'PosY',rfmPar.ScrVRes/2,...
        'DimDX',5,'DimDY',5,'PosDX',5,'PosDY',5,...
        'Orientation',0,'OrientationStepSize',5,...
        'constStepSize', 1, ...
        'RefreshOnFrames',rfmPar.ScrRefRate,...
        'RefreshOnFramesStepSize',5,...
        'RefreshOffFrames',rfmPar.ScrRefRate,...
        'RefreshOffFramesStepSize',5,...
        'TrialDuration',300,...
        'TrialDurationStepSize',5,...
        'TrialRepetition',1,...
        'TrialRepetitionStepSize',1,...
        'InterTrialDuration',0.1,...
        'InterTrialDurationStepSize',0.01,...
        'InvColor',false,'Color',[1 1 1],...
        'SpatialFreq',4,...
        'SpatialFreqStepSize',1,...
        'TempoFreq',1,...
        'TempoFreqStepSize',0.1);
    %spatial freq: #of cycles / degree.

rfmPar.StimParamsList1{1} = struct('Name','Dimension(2x,2y)',...
    'Var1','x','Var2','y','Val1',rfmPar.Stim{rfmPar.StimIdx}.('DimX'),...
    'Val2',rfmPar.Stim{rfmPar.StimIdx}.('DimY'));
rfmPar.StimParamsList1{2} = struct('Name','Dimension StepSize(dx,dy)',...
    'Var1','dx','Var2','dy','Val1',rfmPar.Stim{rfmPar.StimIdx}.('DimDX'),...
    'Val2',rfmPar.Stim{rfmPar.StimIdx}.('DimDX'));
rfmPar.StimParamsList1{3} = struct('Name','Position(x,y)',...
    'Var1','x','Var2','y','Val1',rfmPar.Stim{rfmPar.StimIdx}.('PosX'),...
    'Val2',rfmPar.Stim{rfmPar.StimIdx}.('PosY'));
rfmPar.StimParamsList1{4} = struct('Name','Position StepSize(dx,dy)',...
    'Var1','dx','Var2','dy','Val1',rfmPar.Stim{rfmPar.StimIdx}.('PosDX'),...
    'Val2',rfmPar.Stim{rfmPar.StimIdx}.('PosDY'));

rfmPar.StimDimPosValChgSyn = false;

rfmPar.StimParamsList2{1} = struct('Name','Orientation(a)',...
    'Var1','a','Val1',rfmPar.Stim{rfmPar.StimIdx}.('Orientation'));
rfmPar.StimParamsList2{2} = struct('Name','Orientation StepSize(da)',...
    'Var1','da','Val1',rfmPar.Stim{rfmPar.StimIdx}.('OrientationStepSize'));
rfmPar.StimParamsList2{3} = struct('Name','RefreshOnFrames(RF)',...
    'Var1','RF','Val1',rfmPar.Stim{rfmPar.StimIdx}.('RefreshOnFrames'));
rfmPar.StimParamsList2{4} = struct('Name','RefreshOnFrames StepSize(dRF)',...
    'Var1','dRF','Val1',rfmPar.Stim{rfmPar.StimIdx}.('RefreshOnFramesStepSize'));
rfmPar.StimParamsList2{5} = struct('Name','RefreshOffFrames(RF)',...
    'Var1','RF','Val1',rfmPar.Stim{rfmPar.StimIdx}.('RefreshOffFrames'));
rfmPar.StimParamsList2{6} = struct('Name','RefreshOffFrames StepSize(dRF)',...
    'Var1','dRF','Val1',rfmPar.Stim{rfmPar.StimIdx}.('RefreshOffFramesStepSize'));
rfmPar.StimParamsList2{7} = struct('Name','TrialDuration(t)',...
    'Var1','t','Val1',rfmPar.Stim{rfmPar.StimIdx}.('TrialDuration'));
rfmPar.StimParamsList2{8} = struct('Name','TrialDuration StepSize(dt)',...
    'Var1','dt','Val1',rfmPar.Stim{rfmPar.StimIdx}.('TrialDurationStepSize'));
rfmPar.StimParamsList2{9} = struct('Name','TrialRepetition(n)',...
    'Var1','n','Val1',rfmPar.Stim{rfmPar.StimIdx}.('TrialRepetition'));
rfmPar.StimParamsList2{10} = struct('Name','TrialRepetition StepSize(n)',...
    'Var1','dn','Val1',rfmPar.Stim{rfmPar.StimIdx}.('TrialDurationStepSize'));
rfmPar.StimParamsList2{11} = struct('Name','InterTrialDuration(it)',...
    'Var1','it','Val1',rfmPar.Stim{rfmPar.StimIdx}.('InterTrialDuration'));
rfmPar.StimParamsList2{12} = struct('Name','InterTrialDuration StepSize(dit)',...
    'Var1','dit','Val1',rfmPar.Stim{rfmPar.StimIdx}.('InterTrialDurationStepSize'));

if rfmPar.StimIdx ==2

    rfmPar.StimParamsList2{13} = struct('Name','SpatialFreq(cyc/deg)',...
        'Var1','sf','Val1',rfmPar.Stim{rfmPar.StimIdx}.('SpatialFreq'));
    rfmPar.StimParamsList2{14} = struct('Name','SpatialFreq StepSize(dnc)',...
        'Var1','dsf','Val1',rfmPar.Stim{rfmPar.StimIdx}.('SpatialFreqStepSize'));
    rfmPar.StimParamsList2{15} = struct('Name','TempoFreq(cyc/sec)',...
        'Var1','tf','Val1',rfmPar.Stim{rfmPar.StimIdx}.('SpatialFreq'));
    rfmPar.StimParamsList2{16} = struct('Name','TempoFreq StepSize(dtf)',...
        'Var1','dtf','Val1',rfmPar.Stim{rfmPar.StimIdx}.('TempoFreqStepSize'));
end

%exp control
rfmPar.pauseRunning = false;
rfmPar.stopRunning = true;

%reset stim obj properties (position,visibility,etc.)
rfmPar.isStimChg = true;
%rebuild stim obj (dimension change)
rfmPar.isStimNew = true;
%reset RFB obj properites
rfmPar.isRFBChg = true;
%rebuild RFB ojb (dimension change)
rfmPar.isRFBNew = true;

%
rfmPar.StimImgs = [];

%--------------------------------------------------------------------
%set the rfmStimPar to be sent to remote host for stimulus
rfmStimPar.pauseRunning = rfmPar.pauseRunning;
rfmStimPar.stopRunning = rfmPar.stopRunning;
rfmStimPar.currentTask = rfmPar.currentTask;
rfmStimPar.taskLoaded = false; %flag to indicate remote stim started on screen
rfmStimPar.taskDone = false; %task done.
rfmStimPar.syncTime = -1; %timestamp from NSP when stimulus starts.
rfmStimPar.startNSPTime = -1;
rfmStimPar.endNSPTime = -1;
%params for the stim
rfmStimPar.Stim = rfmPar.Stim{rfmPar.StimIdx};
%measure tuning curve.
rfmStimPar.measureTC = false;
%orientation/ft/fs
rfmStimPar.mtcType = 1 ;
rfmStimPar.mtcStart = 0;
rfmStimPar.mtcStepsize = 15;
rfmStimPar.mtcEnd = 180;
%

%--------------------------------------------------------------------

%load contrl pannel.
rfmControl;



