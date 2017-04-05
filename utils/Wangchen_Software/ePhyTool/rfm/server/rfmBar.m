global rfmStimPar rfmCtrlConn;

%
BLACK = 0 ;
WHITE = 255;
%by default, primary display is set to 0. 
pScreen = 0;
GRAY = (BLACK+WHITE)/2;
%set background color
bgColorVal = GRAY ; 
bgColor = bgColorVal * [1 1 1];

%set up the timer.
timer.size = 10*6;
timer.color = {0*[1 1 1],255*[1 1 1]};
timer.state = false; 


Screen('CloseAll');
%open window 
pWin = Screen('OpenWindow',pScreen, bgColor);
pause(0.2);
HideCursor;
%refresh rate from primary screen
pRefRate = Screen('NominalFrameRate',pWin);
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

try stimSizeX = rfmStimPar.Stim.('DimX');catch stimSizeX = 100; end
try stimSizeY = rfmStimPar.Stim.('DimY'); catch stimSizeY = 100; end
try stimOrient = rfmStimPar.Stim.('Orientation'); catch stimOrient=0;end
try stimCenter = [rfmStimPar.Stim.('PosX') rfmStimPar.Stim.('PosY')];catch stimCenter = scrCenter; end;
try RefreshOnFrames = rfmStimPar.Stim.('RefreshOnFrames'); catch RefreshOnFrames =60; end
try RefreshOffFrames = rfmStimPar.Stim.('RefreshOffFrames'); catch RefreshOffFrames =60; end
try trialDuration = rfmStimPar.Stim.('TrialDuration'); catch trialDuration = Inf; end;
try trialRepetition = rfmStimPar.Stim.('TrialRepetition'); catch trialRepetition = 1 ; end;
try interTrialDuration = rfmStimPar.Stim.('InterTrialDuration'); catch interTrialDuration = 0.1; end 

%original stim texture rect 
stimTexRect = [0 0 2*stimSizeX 2*stimSizeY];
%source rect 
stimSrcRect = CenterRect(stimTexRect,pRect);
%initial position
stimPos = [ stimCenter(1) - stimSizeX stimCenter(2) - stimSizeY ...
    stimCenter(1) + stimSizeX stimCenter(2) + stimSizeY ];

%setup the texture for drawing bar.
stimRectMatrix = stimColorVal * ones(2*stimSizeY+1,2*stimSizeX+1);
stimTexture = Screen('MakeTexture',pWin,stimRectMatrix);
%inversed color stim 
stimRectMatrixInv = (WHITE-stimColorVal) * ones(size(stimRectMatrix));
stimTextureInv = Screen('MakeTexture',pWin,stimRectMatrixInv);
%stim texture to show
stimShowTex = {stimTexture,stimTextureInv};
stimShowTexIdx = 1;

trialNumber = 0;

idxTexture = 0;

% flashFrames = RefreshOnFrames + RefreshOffFrames;
% waitDuration = flashFrames / pRefRate;

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

%isRunning = true;

[kDown,secs,keyCode,deltaSecs] = KbCheck;
isRunning = (~strcmp(keyCode,kcodeESC) & ~rfmStimPar.stopRunning & ~isempty(rfmCtrlConn));

while isRunning 
    
    %trialNumber = trialNumber + 1 ;
    
    while (rfmStimPar.pauseRunning)
        rfmGetTCPIPData; %check for paramters sent from main control.
        pause(0.2);
    end
    rfmGetTCPIPData;
    
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
    if rfmStimPar.Stim.Orientation ~= stimOrient
        stimOrient = rfmStimPar.Stim.Orientation;
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
    if rfmStimPar.Stim.RefreshOnFrames ~= RefreshOnFrames
        RefreshOnFrames = rfmStimPar.Stim.RefreshOnFrames;
        stimUpdated= true;
%         flashFrames = rfmStimPar.Stim.RefreshFrames;
%         waitDuration = flashFrames / pRefRate;
%         %stimUpdated = true;
    end
     if rfmStimPar.Stim.RefreshOffFrames ~= RefreshOffFrames
        RefreshOffFrames = rfmStimPar.Stim.RefreshOffFrames;
        stimUpdated= true;
    end
    
    if trialDuration ~=  rfmStimPar.Stim.('TrialDuration')
        trialDuration = rfmStimPar.Stim.('TrialDuration'); 
    end
    if trialRepetition ~= rfmStimPar.Stim.('TrialRepetition')
        trialRepetition = rfmStimPar.Stim.('TrialRepetition');
    end
    if interTrialDuration ~= rfmStimPar.Stim.('InterTrialDuration')
        interTrialDuration = rfmStimPar.Stim.('InterTrialDuration'); 
    end 

        
    %reset the stim position
    if stimUpdated 
        stimPos = [ stimCenter(1) - stimSizeX stimCenter(2) - stimSizeY ...
            stimCenter(1) + stimSizeX stimCenter(2) + stimSizeY ];
    end
           
    if rfmStimPar.Stim.InvColor
        %keep the background unchanged.
        %bgColorVal = ~(bgColorVal/WHITE)*WHITE;
        %bgColor = bgColorVal * [1 1 1];
        %bar flips color
        stimColorVal = (~(stimColorVal/WHITE))*WHITE;
        stimColor = stimColorVal * [ 1 1 1];
        %flip 1 and 2
        stimShowTexIdx = 3-stimShowTexIdx; 
        Screen('FillRect',pWin,bgColor);
        rfmStimPar.Stim.InvColor = false;
    end
    
    if idxTexture == 0
        %Screen('FillRect',pWin,bgColor);
        timer.state =~ timer.state; 
        vbl=Screen('Flip',pWin);%get the intial timestamp for flip
        t0 = GetSecs;
    end
    %------------------------Stimulus Presentation-------------------------
    
%   vbl = Screen('Flip',pWin,vbl + flashFrames/pRefRate);
    %if set static, don't flip to the inversed color patch.
    t = GetSecs;
    if ~(rfmStimPar.Stim.Static)
        %if t-t0 >= waitDuration
               stimShowTexIdx = ~(stimShowTexIdx-1)+1;
        %       t0 = t;
        %end
    else
%         stimShowTexIdx = 1; %make it visible when set static.
    end
    
    if ~rfmStimPar.Stim.('Static')
        %flash timer when in flashing mode.
        timer.state =~ timer.state; 
        Screen('FillRect',pWin,timer.color{timer.state+1},[0 0 timer.size timer.size]); 
    end
    
    Screen('DrawTexture',pWin,stimShowTex{stimShowTexIdx},stimSrcRect,stimPos,stimOrient);
        
    %if track-cursor mode enabled, flip at every vbl
    if rfmStimPar.Stim.('TrackCursor')
        vbl=Screen('Flip',pWin); %flip at every vbl
    else
        if stimShowTexIdx==1
            vbl = Screen('Flip',pWin,vbl + RefreshOffFrames/pRefRate);
        else
            vbl = Screen('Flip',pWin,vbl + RefreshOnFrames/pRefRate);
        end
    end

    idxTexture = idxTexture + 1; %count number of flipped textures(per flashFrames).
    if t-t0 >= trialDuration %go over one repeat of trial
        trialNumber = trialNumber + 1;
        idxTexture = 0;
        try
            pnet(rfmCtrlConn,'printf', 'trialNumber=%d;',trialNumber);
        end
        pause(interTrialDuration);
    end
    %
    %----------------------------------------------------------------------
    
    %check for quit condition
    [kDown,secs,keyCode,deltaSecs] = KbCheck;
    isRunning = (~strcmp(keyCode,kcodeESC) & ~rfmStimPar.stopRunning & ~isempty(rfmCtrlConn));
    
    if trialNumber >= trialRepetition
        isRunning = false;
    end

end

%Screen('CloseAll');
Screen('FillRect',pWin,bgColorVal);
% %draw timer square in black
% Screen('FillRect',pWin,timer.colors{1},[0 0 timer.size timer.size]);
%
vbl = Screen('Flip',pWin);

Screen('closeall');

pause(0.2);
if ~isempty(rfmCtrlConn)
    if (pnet(rfmCtrlConn,'status')>0)
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskLoaded=%d;',0);
        pnet(rfmCtrlConn,'printf','rfmStimPar.taskDone=%d;',1);
    end
end

    




