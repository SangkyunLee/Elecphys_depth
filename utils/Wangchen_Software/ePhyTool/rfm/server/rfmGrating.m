function rfmGrating
%the latest verion gets loaded ?

global rfmStimPar rfmCtrlConn

%Constant and Background Color Defined.
BLACK = 0 ;
WHITE = 255;
GRAY = (BLACK+WHITE)/2;
%set background color
bgColorVal = GRAY ; 
bgColor = bgColorVal * [1 1 1];

timer.colors = {BLACK*ones(1,3),WHITE*ones(1,3)};
timer.size = 20*5;
%
%timer.state = false;
%or set as true for the first init frame.
%then the actual stim starts with the a black square.
timer.state = false;

%re-seed rand generator.
rand('seed',sum(100*clock));
randn('seed',sum(100*clock));

%clear off.
Screen('CloseAll');
%by default, primary display is set to 0. 
pScreen = 0;
%open window 
pWin = Screen('OpenWindow',pScreen, bgColorVal);
%Screen('BlendFunction',pWin,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
% Make sure the GLSL shading language is supported:
AssertGLSL;

%refresh rate from primary screen
flipInterval = Screen('GetFlipInterval',pWin);
%pRefRate=Screen('NominalFrameRate',pWin);
pRefRate = 1/flipInterval;
% %screen pixels pitch (in mm).
scrPixPitch = 0.27;
%screen sizes
pRect = Screen('rect',pWin);
scrWidth = pRect(3) - pRect(1) ;
scrHeight = pRect(4) - pRect(2) ;
%screen center
scrCenter = [mean(pRect([1,3])) mean(pRect([2,4]))];
HideCursor;
pause(0.2);

%draw timer square. flip screen before NSP record photodiode TTL. 
Screen('FillRect',pWin,timer.colors{timer.state+1},[0 0 timer.size timer.size]);
%timer.state = ~timer.state;
Screen('Flip',pWin);

%----------------prepare stimulus---------------------------------------
stimColorVal = WHITE ; 
stimColor = stimColorVal * [ 1 1 1 ];
%initial stim size. client will use the setting for stim scaling.
sinWave = true;

pause(0.5);
rfmGetTCPIPData; %retrieve rfmStimPar data? 
pause(0.5);

try stimSizeX = rfmStimPar.Stim.('DimX');catch stimSizeX = 200; end
try stimSizeY = rfmStimPar.Stim.('DimY'); catch stimSizeY = 200; end
try stimOrient = rfmStimPar.Stim.('Orientation'); catch stimOrient=0;end
try stimCenter = [rfmStimPar.Stim.('PosX') rfmStimPar.Stim.('PosY')];catch stimCenter = scrCenter; end;
try flashFrames = rfmStimPar.Stim.('RefreshFrames'); catch flashFrames =60; end
try trialDuration = rfmStimPar.Stim.('TrialDuration'); catch trialDuration = 10; end;
try trialRepetition = rfmStimPar.Stim.('TrialRepetition'); catch trialRepetition = 1 ; end;
try interTrialDuration = rfmStimPar.Stim.('InterTrialDuration'); catch interTrialDuration = 0.1; end 

try spatialFreq = rfmStimPar.Stim.('SpatialFreq'); catch spatialFreq = 2; end;
try tempoFreq = rfmStimPar.Stim.('TempoFreq'); catch tempoFreq = 1; end;
try scrEyeDistance = rfmStimPar.('ScrEyeDistance'); catch scrEyeDistance = 600; end;

try measureTC = rfmStimPar.('measureTC'); catch measureTC = false; end;
try mtcType = rfmStimPar.('mtcType'); catch mtcType = 1; end;
try mtcStart = rfmStimPar.('mtcStart'); catch mtcStart = 0; end;
try mtcStepsize = rfmStimPar.('mtcStepsize'); catch mtcStepsize = 10; end;
try mtcEnd = rfmStimPar.('mtcEnd'); catch mtcEnd = 180; end;

driftingPixels = 0;
trialNumber = 0;

%frames lasted for each condition. 15frames = 1/4sec 
coFrames = round(250*pRefRate/1000);
%frames in-b/w each condition
psFrames = round(250*pRefRate/1000);

KbName('UnifyKeyNames');
kcodeESC = KbName('ESCAPE');

%build the condition list
if measureTC
    conditionList = [mtcStart:mtcStepsize:mtcEnd];
    nCondition = length(conditionList);
    switch mtcType
        case 1
            stimOrientList = conditionList;
            spatialFreqList = repmat(spatialFreq,1,nCondition);
            tempoFreqList = repmat(tempoFreq,1,nCondition);
        case 2
            stimOrientList = repmat(stimOrient,1,nCondition);
            spatialFreqList = conditionList;
            tempoFreqList = repmat(tempoFreq,1,nCondition);
        case 3
            stimOrientList = repmat(stimOrient,1,nCondition);
            spatialFreqList = repmat(spatialFreq,1,nCondition);
            tempoFreqList = conditionList;
    end
else
    stimOrientList = stimOrient;
    spatialFreqList = spatialFreq;
    tempoFreqList = tempoFreq;
    
    conditionList = stimOrientList;
    nCondition = length(conditionList);
end

%count the repeats of conditionlist 

%--------------------------------------------------------------------------
 %rebuild everything.
            %measurement time 
            tCL = (nCondition*(coFrames + psFrames)/pRefRate);
            %number of blocks for measurement.
            nBlocks = ceil(trialDuration / tCL);
            %total measurement points for one repeat of trial
            
            nTotCondition = nBlocks * nCondition * trialRepetition;
            %full list for repetitions of trial
            srList = [];
            idxList =[]; %index list of the parameters.
            for i = 1 : trialRepetition
                for j = 1 : nBlocks
                    encodedIdx = zeros(1,nCondition);
                    randp = randperm(nCondition);
                    for k = 1 : nCondition
                        encodedIdx(k) = sub2ind([nCondition nBlocks trialRepetition],randp(k),j,i);
                    end
                    idxList = [idxList encodedIdx];
                    srList = [srList conditionList(randp)];
                end
            end
                    
            conditionArray = repmat([stimOrientList;spatialFreqList;tempoFreqList],1,nBlocks*trialRepetition);
            %set the varying param list.
            conditionArray(mtcType,:)=srList;
            
            %shorten the list if non-t-c measurement.
            if nCondition == 1
                conditionArray = conditionArray(:,1);
            end

            iCondition = 1; %reset the trial.
            
            %record the start/end timestamp for each condition.
            conditionEvent = zeros(4,nTotCondition);
            
            stimOrient = conditionArray(1,iCondition);
            spatialFreq = conditionArray(2,iCondition);
            tempoFreq = conditionArray(3,iCondition);
            
            diskSize = max([2*stimSizeX, 2*stimSizeY]);
            %visible size of the grating. make it odd so that grating is symm around
            %the center
            visibleSize = 2* round(diskSize /2) + 1 ;
            %texture size of the grating -- half of width
            texSize = (visibleSize - 1)/2;
            
            %rect size of texture
            patchRect = [0 0 visibleSize-1 visibleSize-1];
            %stim center rect for alignment
            cenRect = [stimCenter(1)-1 stimCenter(2)-1 stimCenter(1)+1 stimCenter(2)+1];
            %position the dstRect to the stim center.
            dstRect = CenterRect(patchRect,cenRect);
            
            penSize = round(texSize*(sqrt(2)-1));
            maskRect = CenterRect(sqrt(2)*patchRect,cenRect);

            mask = ones(2*texSize+1, 2*texSize+1,2) * bgColorVal;
            [X,Y] = meshgrid(-1*(texSize+0) : 1*(texSize+0), -1*(texSize+0) : 1*(texSize+0));
            alphaBlend = WHITE * (sqrt(X.^2 + Y.^2) > diskSize/2);
            mask(:,:,2)= alphaBlend;
            maskTex = Screen('MakeTexture',pWin,mask);
            alpha = maskTex;
            
            clear X Y alphaBlend;
            
            sfp = spatialFreq * (atan(scrPixPitch/scrEyeDistance)*180/pi);
            %spatial period in terms of pixels / cycle.
            period = 1 / sfp;
            
            phase = 0;
            phaseincrement = (tempoFreq*360)*(1/pRefRate);
            
            %or [];
            rotateMode = kPsychUseTextureMatrixForRotation;
            %rotateMode = [];            

%             gratingTex = CreateProceduralSineGrating(pWin, visibleSize, visibleSize, [0.5 0.5 0.5 0.0]);
            gratingTex = CreateProceduralSineGrating(pWin, visibleSize, visibleSize, [0.5 0.5 0.5 0.0]);
    
            %use trialDuration to time the trial in non-mtc mode
            if measureTC
                %totoal frames
                %framesTotal = ceil((trialDuration * pRefRate));
                framesTotal = nTotCondition * (coFrames + psFrames);
                %frames for each trial
                framesTrialTotal = nBlocks * nCondition * (coFrames + psFrames);
                %round up ...
                fprintf('Tuning Curve: framesTotal=%d,framesTrialTotal=%d\n',framesTotal,framesTrialTotal);
            else
                framesTrialTotal = round((trialDuration * pRefRate));
                framesTotal = round(trialRepetition * framesTrialTotal);
                fprintf('No TC: framesTotal=%d,framesTrialTotal=%d\n',framesTotal,framesTrialTotal);
            end
 
%--------------------------------------------------------------------------
%write the encoded parameters list into nex file. load it into neuroexploer 
%for online analysis.
constNames = {'Orientation','SpatialFreq','TempoFreq'};
constValues = {stimOrientList(1), spatialFreqList(1), tempoFreqList(1)};
%encoding params
paramNames = {'trialRepetition','nBlocks','TuneVar'};
paramValues = {[1:trialRepetition],[1:nBlocks],[]};
nParam = length(paramNames);
nConst = length(constNames);
%fill in the tunevar
paramNames{nParam} = constNames{mtcType};
paramValues{nParam} = conditionList;
%remove the tunevar from the non-variant list
constNames(mtcType) = [];
constValues(mtcType) = [];
nConst = max([0,nConst-1]);

nexStruct.params = paramNames;
%save the list of param.
nexStruct.values = cell(1,nParam);
for i = 1 : nParam
    %assign a vector (not cell type) to values.
    nexStruct.values{i} = paramValues{i}(1:end);
    %only measure with one-variable condition.
 
end

nexStruct.DIOValue = idxList;

nexStruct.convars = constNames;
nexStruct.convals = cell(1,nConst);
for i = 1 : nConst
    nexStruct.convals{i} = constValues{i}(1:end);
end

% folder.subject = 'rfm';
% folder.exp = 'NeuronTuning';
% folder.date = datestr(now,'yyyy-mmm-dd');
% folder.time = datestr(now,'HH-MM-SS');

%take folder info from the control pc.
folder = rfmStimPar.NSPDataFolder;
%change folder base
if ispc
    folder.base = 'c:\data\StimulationData';
elseif ismac
    folder.base = '~/stimulation/StimulationData';
else
end

rfmFolder = fullfile(folder.base,folder.subject,folder.exp,folder.date,folder.time);
mkdir(rfmFolder);

pnet(rfmCtrlConn,'printf','disp(''Write Stimulus-event Lookup-Table...'');');

rfmSaveParam(nexStruct,folder);

%pnet(rfmCtrlConn,'printf','disp(''done with nex file'');');
clear nexStruct;

%notify the client to start cerebus recording.
if ~isempty(rfmCtrlConn)
    if (pnet(rfmCtrlConn,'status')>0)
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',1);
        
    end
end

%wait period if NSP records data on client pc.
pause(2);

isRunning = true;
firstFrame = true;
frames = 0;

t0 = GetSecs;

while isRunning 
    
    while (rfmStimPar.pauseRunning)
        rfmGetTCPIPData; %check for paramters sent from main control.
        pause(0.02);       
    end

    rfmGetTCPIPData; %only process trial pause/stop command. 
    
    %------------------------Stimulus Presentation-------------------------
    if firstFrame %first frame
        %tell client to begin mirroring stim. take the timestamp from cerebus.
        if ~isempty(rfmCtrlConn)
            if (pnet(rfmCtrlConn,'status')>0)
                %pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',1);
                pnet(rfmCtrlConn,'printf','rfmStimPar.syncTime=cbmex(''time'');');
            end
        end
        
        fprintf('On firstFrame, with frames = %d\n',frames);
        firstFrame = false;
        %
        %mark frame for the range of stimulus/inter-stimulus presentation.
        %draw gratingtex only for stimulus-on stage.
        cFrameStart = (iCondition-1)*(coFrames+psFrames)+1;
        cFrameEnd = (iCondition-1)*(coFrames+psFrames)+coFrames;
        pFrameStart = (iCondition-1)*(coFrames+psFrames)+coFrames + 1;
        pFrameEnd = (iCondition)*(coFrames+psFrames);
    
    end
   
    frames = frames + 1; %count number of flipped textures(per flashFrames).
    
    if measureTC
        if (frames >= cFrameStart) && ...
                (frames <= cFrameEnd )

            Screen('DrawTexture', pWin, gratingTex, [], dstRect, 90+stimOrient, ...
                [], [], [],[], [], [phase, sfp, 0.5, 0]);
            %           Screen('FillRect',pWin,WHITE,dstRect);
            phase = phase + phaseincrement;
        end
    else %always draw the texture if non-mtc mode.
        Screen('DrawTexture', pWin, gratingTex, [], dstRect, 90+stimOrient, ...
            [], [], [],[], [], [phase, sfp, 0.5, 0]);
        %           Screen('FillRect',pWin,WHITE,dstRect);
        phase = phase + phaseincrement;
    end

    %decide on timer state
    if measureTC
       if frames == cFrameStart || frames == cFrameEnd
           timer.state = ~timer.state;
       end
    end
    
    %mask
    Screen('FrameOval',pWin,bgColorVal,maskRect,penSize);
    %draw timer square
    Screen('FillRect',pWin,timer.colors{timer.state+1},[0 0 timer.size timer.size]);
    %
    vbl = Screen('Flip',pWin);
    
    if ~firstFrame && (mod(frames, framesTrialTotal)==1) %start of trial
        trialNumber = trialNumber + 1;
        %frames = 0;

        try
            pnet(rfmCtrlConn,'printf', 'trialNumber=%d;',trialNumber);
        end
    end    
    
    %else %inside the trial

        if measureTC
            
            
            %take timestamp within the trial
            %record timestamps of each condition.
            %start of event
            if frames == cFrameStart
                conditionEvent(1,iCondition)=vbl;
                
            end

            if frames == cFrameEnd
                conditionEvent(2,iCondition)=vbl;
                
            end

            %start of pause between each condition
            if frames == pFrameStart
                conditionEvent(3,iCondition)=vbl;
            end

            if frames == pFrameEnd
                conditionEvent(4,iCondition)=vbl;
                %check if it comes to the end. 
                if frames < framesTotal %update param

                    iCondition = iCondition + 1;
                    %update the marking indices.
                    cFrameStart = (iCondition-1)*(coFrames+psFrames)+1;
                    cFrameEnd = (iCondition-1)*(coFrames+psFrames)+coFrames;
                    pFrameStart = (iCondition-1)*(coFrames+psFrames)+coFrames + 1;
                    pFrameEnd = (iCondition)*(coFrames+psFrames);

                    %update the condition
                    stimOrient = conditionArray(1,iCondition);
                    spatialFreq = conditionArray(2,iCondition);
                    tempoFreq = conditionArray(3,iCondition);
                    %update the period,phase
                    sfp = (spatialFreq * (atan(scrPixPitch/scrEyeDistance)*180/pi));
                    phaseincrement = (tempoFreq*360)*(1/pRefRate);
                    phase = 0; %or make a continuous movement.
                   
                end
            end
        else
            %nothing
        end
    
    
    %end
    %
    %----------------------------------------------------------------------
    
%     %check for quit condition
%     [kDown,secs,keyCode,deltaSecs] = KbCheck;
%     kcodePress = find(keyCode);
    %isRunning = (~isequal(kcodePress,kcodeESC) & ~rfmStimPar.stopRunning & ~isempty(rfmCtrlConn));
    isRunning = ~rfmStimPar.stopRunning ;
    if trialNumber > trialRepetition
        isRunning = false;
    end

end

t = GetSecs - t0;

if ~isempty(rfmCtrlConn)
    if (pnet(rfmCtrlConn,'status')>0)
        pnet(rfmCtrlConn,'printf','t=%f;',t);
        pnet(rfmCtrlConn,'printf','framesTotal=%d;',framesTotal);
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',0);
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskDone=%d;',1);
    end
end


%Screen('CloseAll');
Screen('FillRect',pWin,bgColorVal);
%draw timer square in black
Screen('FillRect',pWin,timer.colors{1},[0 0 timer.size timer.size]);
%
vbl = Screen('Flip',pWin);

pause(0.5);
% %retreive rfmStimPar.syncTime from client ?
rfmGetTCPIPData;


fn = '0001.mat';

file = fullfile(rfmFolder,fn);
%save one copy on top level for the running experiment. 
file1 = fullfile(folder.base,folder.subject,folder.exp,fn);

save(file);
copyfile(file,file1);

   




