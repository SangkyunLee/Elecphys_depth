%function rfmGrating

global rfmStimPar rfmCtrlConn

%Constant and Background Color Defined.
BLACK = 0 ;
WHITE = 255;
GRAY = (BLACK+WHITE)/2;
%set background color
bgColorVal = GRAY ; 
bgColor = bgColorVal * [1 1 1];

timer.colors = {BLACK*ones(1,3),WHITE*ones(1,3)};
timer.size = 20*2;
timer.state = false;

%clear off.
Screen('CloseAll');
%by default, primary display is set to 0. 
pScreen = 0;
%open window 
pWin = Screen('OpenWindow',pScreen, bgColor);
Screen('BlendFunction',pWin,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
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

%----------------prepare stimulus---------------------------------------
stimColorVal = WHITE ; 
stimColor = stimColorVal * [ 1 1 1 ];
%initial stim size. client will use the setting for stim scaling.
sinWave = false;

try stimSizeX = rfmStimPar.Stim.('DimX');catch stimSizeX = 200; end
try stimSizeY = rfmStimPar.Stim.('DimY'); catch stimSizeY = 200; end
try stimOrientList = rfmStimPar.Stim.('Orientation'); catch stimOrientList=-90;end
try stimCenter = [rfmStimPar.Stim.('PosX') rfmStimPar.Stim.('PosY')];catch stimCenter = scrCenter; end;
try flashFrames = rfmStimPar.Stim.('RefreshFrames'); catch flashFrames =60; end
try trialDuration = rfmStimPar.Stim.('TrialDuration'); catch trialDuration = 10; end;
try trialRepetition = rfmStimPar.Stim.('TrialRepetition'); catch trialRepetition = 1 ; end;
try interTrialDuration = rfmStimPar.Stim.('InterTrialDuration'); catch interTrialDuration = 0.1; end 

try spatialFreqList = rfmStimPar.Stim.('SpatialFreq'); catch spatialFreqList = 4; end;
try tempoFreqList = rfmStimPar.Stim.('TempoFreq'); catch tempoFreqList = 20; end;

try scrEyeDistance = rfmStimPar.('ScrEyeDistance'); catch scrEyeDistance = 600; end;

driftingPixels = 0;
trialNumber = 0;
iCondition= 1;
frames = 0;
%frames lasted for each condition. 15frames = 1/4sec 
coFrames = 15;
%frames in-b/w each condition
psFrames = 15;
% coFrames = round(trialDuration*pRefRate);
% psFrames = round(interTrialDuration*pRefRate);

KbName('UnifyKeyNames');
kcodeESC = KbName('ESCAPE');

%tell client to begin mirroring stim.
if ~isempty(rfmCtrlConn)
    if (pnet(rfmCtrlConn,'status')>0)
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',1);
    end
end

rfmStimPar.stopRunning = false; %start the listening loop
rfmStimPar.pauseRunning = true; %make the loop wait for the start command from client.

isRunning = true;

while isRunning 
    
    while (rfmStimPar.pauseRunning)
        rfmGetTCPIPData; %check for paramters sent from main control.
        stimUpdated = false;
        %update the stim paramter if changed on client side.
        if rfmStimPar.Stim.DimX ~= stimSizeX
            stimSizeX = rfmStimPar.Stim.DimX;
            stimUpdated = true;
        end
        if rfmStimPar.Stim.DimY ~=stimSizeY
            stimSizeY = rfmStimPar.Stim.DimY;
            stimUpdated = true;
        end
       
        if rfmStimPar.Stim.PosX ~= stimCenter(1)
            stimCenter(1) = rfmStimPar.Stim.PosX;
            stimUpdated = true;
        end
        if rfmStimPar.Stim.PosY ~= stimCenter(2)
            stimCenter(2) = rfmStimPar.Stim.PosY;
            stimUpdated = true;
        end
        
        if trialDuration ~=  rfmStimPar.Stim.('TrialDuration')
            trialDuration = rfmStimPar.Stim.('TrialDuration');
            stimUpdated = true;
        end
        if trialRepetition ~= rfmStimPar.Stim.('TrialRepetition')
            trialRepetition = rfmStimPar.Stim.('TrialRepetition');
        end
        if interTrialDuration ~= rfmStimPar.Stim.('InterTrialDuration')
            interTrialDuration = rfmStimPar.Stim.('InterTrialDuration');
        end
        
        if trialRepetition ~= rfmStimPar.Stim.('TrialRepetition')
            trialRepetition = rfmStimPar.Stim.('TrialRepetition');
        end

        if ~all(rfmStimPar.Stim.('SpatialFreq') == spatialFreqList)
            spatialFreqList = rfmStimPar.Stim.('SpatialFreq');
            stimUpdated = true;
        end

        if ~all(rfmStimPar.Stim.('TempoFreq') == tempoFreqList)
            tempoFreqList = rfmStimPar.Stim.('TempoFreq');
            stimUpdated = true;
        end

        if ~all(rfmStimPar.Stim.('Orientation') == stimOrientList)
            stimOrientList = rfmStimPar.Stim.('Orientation');
            stimUpdated = true;
        end

        %reset the stim position
        if stimUpdated
            %rebuild everything.
            %check if orient/sF/tF are sent in array.
            nOrient = length(stimOrientList );
            nSF = length(saptialFreqList);
            nTF = length(tempoFreqList);

            %nCondition = nOrient*nSF*nTF; %only process one-variable list
            if nOrient > 1
                nCondition = nOrient;
                nTotCondition = nCondition * trialRepetition;
                conditionList = stimOrientList;
                if size(conditionList,1)>1 %make it a row-vector.
                    conditionList = conditionList';
                end
                %total trial/conditions for the given repetition.
                rcList = zeros(1,nTotCondition);
                for k = 1 : trialRepetition
                    randp = randperm(nCondition);
                    rcList((k-1)*nCondition+1:(k-1)*nCondition+nCondition) = conditionList(randp);
                end
                %assume the other two lists are single element...
                conditionArray = [rcList; repmat(spatialFreqList,1,nTotCondition);repmat(tempoFreqList,1,nTotCondition)];
            elseif nSF > 1
                nCondition = nSF;
                nTotCondition = nCondition * trialRepetition;
                conditionList = spatialFreqList;
                if size(conditionList,1)>1 %make it a row-vector.
                    conditionList = conditionList';
                end
                
                %total trial/conditions for the given repetition.
                rcList = zeros(1,nTotCondition);
                for k = 1 : trialRepetition
                    randp = randperm(nCondition);
                    rcList((k-1)*nCondition+1:(k-1)*nCondition+nCondition) = conditionList(randp);
                end
                %assume the other two lists are single element...
                conditionArray = [repmat(stimOrientList,1,nTotCondition);rcList;repmat(tempoFreqList,1,nTotCondition)];
            elseif nTF > 1
                nCondition = nTF;
                nTotCondition = nCondition * trialRepetition;
                conditionList = spatialFreqList;
                if size(conditionList,1)>1 %make it a row-vector.
                    conditionList = conditionList';
                end
                
                %total trial/conditions for the given repetition.
                rcList = zeros(1,nTotCondition);
                for k = 1 : trialRepetition
                    randp = randperm(nCondition);
                    rcList((k-1)*nCondition+1:(k-1)*nCondition+nCondition) = conditionList(randp);
                end
                %assume the other two lists are single element...
                conditionArray = [repmat(stimOrientList,1,nTotCondition);repmat(spatialFreqList,1,nTotCondition);conditionList];
                
            else
                nCondition = 1;
                nTotCondition = nCondition * trialRepetition;
               
                conditionArray = [repmat(stimOrientList,1,nTotCondition);...
                    repmat(spatialFreqList,1,nTotCondition);...
                    repmat(tempoFreqList,1,nTotCondition)];
            end
            
            iCondition = 1; %reset the trial.
            
            %record the start/end timestamp for each condition.
            conditionEvent = zeros(4,nTotCondition);
            
            stimOrient = conditionArray(1,iCondition);
            spatialFreq = conditionArray(2,iCondition);
            tempoFreq = conditionArray(3,iCondition);
            
            sfp = spatialFreq * (atan(scrPixSize/scrEyeDistance)*180/pi);
            %spatial period in terms of pixels / cycle.
            period = 1 / sfp;
            % translate drifting speed into 'pixels per frame'
            % i.e, (pix/cyc) * (cyc/sec) * (sec/frame)
            shiftperframe = period * tempoFreq * ( 1 / pRefRate );
            % initial phase shift in terms of pixels.
            % phaseInPixels = (phi0/360) * period;
            phaseInPixels = 0;
            driftingPixels = phaseInPixels ;
            %totoal frames
            %framesTotal = ceil((trialDuration * pRefRate));
            framesTotal = nTotCondition * (coFrames + psFrames);
            %frames for each trial
            framesTrialTotal = nCondition * (coFrames + psFrames);
            

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

            %create one single static grating image.
            x = meshgrid(-texSize : texSize+ceil(period) , 1);
            y = meshgrid(1 ,-texSize : texSize+ceil(period));

            if sinWave
                %compute sin grating
                grating = GRAY + (WHITE-GRAY)*sin(2*pi*sfp*x);
            else
                %otherwise square wave.
                grating = GRAY + (WHITE-GRAY)*square(2*pi*sfp*x);
            end

            gratingTex = Screen('MakeTexture',pWin,grating);
            texture = gratingTex;

            mask = ones(2*texSize+1, 2*texSize+1,2) * bgColorVal;
            [X,Y] = meshgrid(-1*texSize : 1*texSize, -1*texSize : 1*texSize);
            alphaBlend = WHITE * (sqrt(X.^2 + Y.^2) > diskSize/2);
            mask(:,:,2)= alphaBlend;

            maskTex = Screen('MakeTexture',pWin,mask);
            alpha = maskTex;

        end
    end

    rfmGetTCPIPData; %only process trial pause/stop command. 
               
    if rfmStimPar.Stim.InvColor
        bgColorVal = ~(bgColorVal/WHITE)*WHITE;
        bgColor = bgColorVal * [1 1 1];
        stimColorVal = ~(stimColorVal/WHITE)*WHITE;
        stimColor = stimColorVal * [ 1 1 1];
        Screen('FillRect',pWin,bgColor);
        rfmStimPar.Stim.InvColor = false;
    end
    
    if frames == 0
        %Screen('FillRect',pWin,bgColor);
        vbl=Screen('Flip',pWin);%get the intial timestamp for flip
        t0 = vbl;
    end
    %------------------------Stimulus Presentation-------------------------
   
    % update grating
    u = mod(driftingPixels,period);
    srcRect = [u 0 (u+visibleSize-1) (0+visibleSize-1)];

    Screen('DrawTexture',pWin,texture,srcRect,dstRect,90+stimOrient);
    Screen('DrawTexture',pWin,alpha,patchRect,dstRect,90+stimOrient);
    %draw timer square
    Screen('FillRect',pWin,timer.colors{timer.state+1},[0 0 timer.size timer.size]);
    vbl = Screen('Flip',pWin);
    
    if ~(rfmStimPar.Stim.Static)
        driftingPixels = driftingPixels + shiftperframe ;
    end
    
    frames = frames + 1; %count number of flipped textures(per flashFrames).
    
    %record timestamps of each condition.
    %start of event
    if frames == (iCondition-1)*(coFrames+psFrames)+1
        conditionEvent(1,iCondition)=vbl;
    end
    
    if frames == (iCondition-1)*(coFrames+psFrames)+coFrames
        conditionEvent(2,iCondition)=vbl;
    end
    
    %start of pause between each condition
    if frames == (iCondition-1)*(coFrames+psFrames)+coFrames + 1
        conditionEvent(3,iCondition)=vbl;
    end
    
    if frames == (iCondition)*(coFrames+psFrames)
        conditionEvent(4,iCondition)=vbl;
        iCondition = iCondition + 1;
        %update the condition
        stimOrient = conditionArray(1,iCondition);
        spatialFreq = conditionArray(2,iCondition);
        tempoFreq = conditionArray(3,iCondition);
        %update the timer state
        timer.state = ~timer.state;
        
    end
    
        
   if mod(frames, framesTrialTotal)==0 %go over one repeat of trial
       trialNumber = trialNumber + 1;
       %frames = 0;
       driftingPixels = phaseInPixels;
       try
           pnet(rfmCtrlConn,'printf', 'trialNumber=%d;',trialNumber);
       end
       pause(interTrialDuration);
   end
    %
    %----------------------------------------------------------------------
    
    %check for quit condition
    [kDown,secs,keyCode,deltaSecs] = KbCheck;
    kcodePress = find(keyCode);
    isRunning = (~isequal(kcodePress,kcodeESC) & ~rfmStimPar.stopRunning & ~isempty(rfmCtrlConn));
    %isRunning = ~isequal(kcodePress,kcodeESC);
    if trialNumber >= trialRepetition
        isRunning = false;
    end

end

Screen('CloseAll');
pause(0.2);
if ~isempty(rfmCtrlConn)
    if (pnet(rfmCtrlConn,'status')>0)
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',0);
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskDone=%d;',1);
    end
end

fn = ['~/stimulation/data/','rfmGrating.mat'];
%fn = 'rfmGrating.mat';
save(fn);
   




