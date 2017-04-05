global rfmStimPar rfmCtrlConn;

%
BLACK = 0 ;
WHITE = 255;
GRAY = (BLACK+WHITE)/2;
%by default, primary display is set to 0. 
pScreen = 0;
%set background color
bgColorVal = GRAY ; 
bgColor = bgColorVal * [1 1 1];

Screen('CloseAll');
%open window 
pWin = Screen('OpenWindow',pScreen, bgColor);
Screen('BlendFunction',pWin,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
pause(0.2);
HideCursor;
% %screen pixels size (in mm).
% scrPixSize = 0.27;
%refresh rate from primary screen
flipInterval = Screen('GetFlipInterval',pWin);
pRefRate = 1/flipInterval;
%window pixel size
scrPixSizePTB = Screen('PixelSize',pWin);
%Screen('NominalFrameRate',pWin);
pRect = Screen('rect',pWin);
%screen Text Size
scrTextSize = Screen('TextSize',pWin);
%screen sizes
scrWidth = pRect(3) - pRect(1) ;
scrHeight = pRect(4) - pRect(2) ;
%screen center
scrCenter = [mean(pRect([1,3])) mean(pRect([2,4]))];
% %the initial size of stimulus in half width.
% stimSizeX0 = fix(maxStimSize/2) ;
% stimSizeY0 = stimSizeX0+100;
%stim color
stimColorVal = WHITE ; 
stimColor = stimColorVal * [ 1 1 1 ];
%initial stim size. client will use the setting for stim scaling.

sinWave = false;

%rfmGetTCPIPData;

try stimSizeX = rfmStimPar.Stim.('DimX');catch stimSizeX = 100; end
try stimSizeY = rfmStimPar.Stim.('DimY'); catch stimSizeY = 100; end
try stimOrient = rfmStimPar.Stim.('Orientation'); catch stimOrient=0;end
try stimCenter = [rfmStimPar.Stim.('PosX') rfmStimPar.Stim.('PosY')];catch stimCenter = scrCenter; end;
try flashFrames = rfmStimPar.Stim.('RefreshFrames'); catch flashFrames =60; end
try trialDuration = rfmStimPar.Stim.('TrialDuration'); catch trialDuration = Inf; end;
try trialRepetition = rfmStimPar.Stim.('TrialRepetition'); catch trialRepetition = 1 ; end;
try interTrialDuration = rfmStimPar.Stim.('InterTrialDuration'); catch interTrialDuration = 0.1; end 

try spatialFreq = rfmStimPar.Stim.('SpatialFreq'); catch spatialFreq = 4; end;
try tempoFreq = rfmStimPar.Stim.('TempoFreq'); catch tempoFreq = 1; end;

try scrPixSize = rfmStimPar.('ScrPixSize'); catch scrPixSize = 0.27; end;
try scrEyeDistance = rfmStimPar.('ScrEyeDistance'); catch scrEyeDistance = 600; end;

% %check if orient/sF/tF are sent in array.
% nOrient = length(stimOrient );
% nSF = length(saptialFreq);
% nTF = length(tempoFreq);
% 
% %here assume only one variable is in array.
% nCondition = max([nOrient nSF nTF]);

sfp = spatialFreq * (atan(scrPixSize/scrEyeDistance)*180/pi);
%spatial period in terms of pixels / cycle.
period = 1 ./ sfp; 
% translate drifting speed into 'pixels per frame'
% i.e, (pix/cyc) * (cyc/sec) * (sec/frame)
shiftperframe = period .* tempoFreq * ( 1 / pRefRate );
% initial phase shift in terms of pixels.
% phaseInPixels = (phi0/360) * period; 
phaseInPixels = 0; 
driftingPixels = phaseInPixels ;
%totoal frames 
framesTotal = ceil((trialDuration * pRefRate));

diskSize = max([2*stimSizeX, 2*stimSizeY]);
%visible size of the grating. make it odd so that grating is symm around
%the center
visibleSize = 2* round(diskSize /2) + 1 ;
%texture size of the grating -- half of width
texSize = (visibleSize - 1)/2;

%rect size of texture
patchRect = [0 0 visibleSize-1 visibleSize-1];
% %stim center rect for alignment
cenRect = [stimCenter(1)-1 stimCenter(2)-1 stimCenter(1)+1 stimCenter(2)+1];
% centerX = scrCenter(1) + stimCenter(1);
% centerY = scrCenter(2) + stimCenter(2);
% centerX = scrCenter(1) + 0;
% centerY = scrCenter(2) + 0;
% cenRect = [centerX-1 centerY-1 centerX+1 centerY+1];
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

mask = ones(2*texSize +1, 2*texSize +1,2) * bgColorVal;
[X,Y] = meshgrid(-1*texSize : 1*texSize, -1*texSize : 1*texSize);
alphaBlend = WHITE * (sqrt(X.^2 + Y.^2) > diskSize/2);
mask(:,:,2)= alphaBlend;

maskTex = Screen('MakeTexture',pWin,mask);
alpha = maskTex;


trialNumber = 0;
idxTexture = 0;
frames = 0;
waitDuration = flashFrames / pRefRate;

kcodeESC = KbName('ESCAPE');
%tell client to begin mirroring stim.
if ~isempty(rfmCtrlConn)
    if (pnet(rfmCtrlConn,'status')>0)
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',1);
    end
end

%stim parameters updated by client.
stimUpdated = false;

rfmStimPar.stopRunning = false; %start the listening loop
rfmStimPar.pauseRunning = true; %make the loop wait for the start command from client.

isRunning = true;

% [kDown,secs,keyCode,deltaSecs] = KbCheck;
% isRunning = (~strcmp(keyCode,kcodeESC) & ~rfmStimPar.stopRunning & ~isempty(rfmCtrlConn));

timeStamps = zeros(1,500);
driftPixs = zeros(1,500);

while isRunning 
    
    %trialNumber = trialNumber + 1 ;
    
    while (rfmStimPar.pauseRunning)
        rfmGetTCPIPData; %check for paramters sent from main control.
        pause(0.01);
    end

    %rfmGetTCPIPData;
    
    stimUpdated = false;    
%     %update the stim paramter if changed on client side.
%     if rfmStimPar.Stim.DimX ~= stimSizeX
%         stimSizeX = rfmStimPar.Stim.DimX;
%         stimUpdated = true;
%     end
%     if rfmStimPar.Stim.DimY ~=stimSizeY
%         stimSizeY = rfmStimPar.Stim.DimY;
%         stimUpdated = true;
%     end
%     if rfmStimPar.Stim.Orientation ~= stimOrient
%         stimOrient = rfmStimPar.Stim.Orientation;
%         stimUpdated = true;
%     end
%     if rfmStimPar.Stim.PosX ~= stimCenter(1)
%         stimCenter(1) = rfmStimPar.Stim.PosX;
%         stimUpdated = true;
%     end
%     if rfmStimPar.Stim.PosY ~= stimCenter(2)
%         stimCenter(2) = rfmStimPar.Stim.PosY;
%         stimUpdated = true;
%     end
%     if rfmStimPar.Stim.RefreshFrames ~= flashFrames
%         flashFrames = rfmStimPar.Stim.RefreshFrames;
%         waitDuration = flashFrames / pRefRate;
%         %stimUpdated = true;
%     end
%     
%     if trialDuration ~=  rfmStimPar.Stim.('TrialDuration')
%         trialDuration = rfmStimPar.Stim.('TrialDuration'); 
%     end
%     if trialRepetition ~= rfmStimPar.Stim.('TrialRepetition')
%         trialRepetition = rfmStimPar.Stim.('TrialRepetition');
%     end
%     if interTrialDuration ~= rfmStimPar.Stim.('InterTrialDuration')
%         interTrialDuration = rfmStimPar.Stim.('InterTrialDuration'); 
%     end 
%     
%     if rfmStimPar.Stim.('SpatialFreq') ~= spatialFreq
%         spatialFreq = rfmStimPar.Stim.('SpatialFreq');
%         stimUpdated = true;
%     end
%     
%     if rfmStimPar.Stim.('TempoFreq') ~= tempoFreq
%         tempoFreq = rfmStimPar.Stim.('TempoFreq');
%         stimUpdated = true;
%     end
%     
%     if rfmStimPar.Stim.('Orientation') ~= stimOrient
%         stimOrient = rfmStimPar.Stim.('Orientation');
%         %stimUpdated = true;
%     end
%             
%     %reset the stim position
%     if stimUpdated
%         sfp = spatialFreq * (atan(scrPixSize/scrEyeDistance)*180/pi);
%         %spatial period in terms of pixels / cycle.
%         period = 1 / sfp;
%         % translate drifting speed into 'pixels per frame'
%         % i.e, (pix/cyc) * (cyc/sec) * (sec/frame)
%         shiftperframe = period * tempoFreq * ( 1 / pRefRate );
%         % initial phase shift in terms of pixels.
%         % phaseInPixels = (phi0/360) * period;
%         phaseInPixels = 0;
%         driftingPixels = phaseInPixels ;
%         %totoal frames
%         framesTotal = ceil((trialDuration * pRefRate));
%         
%         diskSize = max([2*stimSizeX, 2*stimSizeY]);
%         %visible size of the grating. make it odd so that grating is symm around
%         %the center
%         visibleSize = 2* round(diskSize /2) + 1 ;
%         %texture size of the grating -- half of width
%         texSize = (visibleSize - 1)/2;
% 
% 
%         %rect size of texture
%         patchRect = [0 0 visibleSize-1 visibleSize-1];
%         %stim center rect for alignment
%         cenRect = [stimCenter(1)-1 stimCenter(2)-1 stimCenter(1)+1 stimCenter(2)+1];
%         %position the dstRect to the stim center.
%         dstRect = CenterRect(patchRect,cenRect);
% 
%         %create one single static grating image.
%         x = meshgrid(-texSize : texSize+ceil(period) , 1);
%         y = meshgrid(1 ,-texSize : texSize+ceil(period));
% 
%         if sinWave
%             %compute sin grating
%             grating = GRAY + (WHITE-GRAY)*sin(2*pi*sfp*x);
%         else
%             %otherwise square wave.
%             grating = GRAY + (WHITE-GRAY)*square(2*pi*sfp*x);
%         end
% 
%         gratingTex = Screen('MakeTexture',pWin,grating);
%         texture = gratingTex;
% 
%         mask = ones(2*texSize+1, 2*texSize+1,2) * bgColorVal;
%         [X,Y] = meshgrid(-1*texSize : 1*texSize, -1*texSize : 1*texSize);
%         alphaBlend = WHITE * (sqrt(X.^2 + Y.^2) > diskSize/2);
%         mask(:,:,2)= alphaBlend;
% 
%         maskTex = Screen('MakeTexture',pWin,mask);
%         alpha = maskTex;
% 
%     end
%            
%     if rfmStimPar.Stim.InvColor
%         bgColorVal = ~(bgColorVal/WHITE)*WHITE;
%         bgColor = bgColorVal * [1 1 1];
%         stimColorVal = ~(stimColorVal/WHITE)*WHITE;
%         stimColor = stimColorVal * [ 1 1 1];
%         Screen('FillRect',pWin,bgColor);
%         rfmStimPar.Stim.InvColor = false;
%     end
    
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
    %Screen('DrawTexture',pWin,alpha,patchRect,dstRect,90+stimOrient);
    %Screen('Flip',pWin); %flip at every vbl
    vbl = Screen('Flip',pWin);
    
    frames = frames + 1; %count number of flipped textures(per flashFrames).
    
    %check if there is frame skip.
    if frames <= 500
        timeStamps(frames)=vbl;
        driftPixs(frames)=driftingPixels;
    end
    
    if ~(rfmStimPar.Stim.Static)
        driftingPixels = driftingPixels + shiftperframe ;
    else
      
    end
    
        
    if frames > framesTotal %go over one repeat of trial
        trialNumber = trialNumber + 1;
        frames = 0;
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
save(fn);
    




