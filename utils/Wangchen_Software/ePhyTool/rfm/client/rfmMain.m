%function rfmMain
%
%The OnlineMappingRF function works to map the receptive field geomatry in a coarse fashion.
%Dual-display will be needed to show the stimulus and the outlining field boundary, i.e,
%stimulus pattern (circular dot/squre(bar)) is shown in the secondary monitor. The field 
%outline,along with stimulus pattern is shown in the primary monitor. The user may adjust the
%dimensions and position of stimulus and field outline by keyboard inputs and mouse movement. 
%
%Wangchen Wang 2009, Baylor College of Medicine.

global rfmPar;

try

%use bar as stimulus
allStimTypes = {'bar','grating'};
%set default type to bar
stimType = 1 ;
%draw dots for rings. use square
dotType = 0;
%
BLACK = 0 ;
WHITE = 255;

%by default, primary display is set to 0. 
pScreen = 0;

%set background color
bgColorVal = BLACK ; 
bgColor = bgColorVal * [1 1 1];

%open window 
pWin = Screen('OpenWindow',pScreen, bgColor);

%refresh rate from primary screen
pRefRate = Screen('NominalFrameRate',pWin);
pRect = Screen('rect',pWin);
%screen Text Size
scrTextSize = Screen('TextSize',pWin);

%screen sizes
scrWidth = pRect(3) - pRect(1) ;
scrHeight = pRect(4) - pRect(2) ;
%inner-square size of screen
scrSquare = min(scrWidth, scrHeight);
%screen center
scrCenter = [mean(pRect([1,3])) mean(pRect([2,4]))];

%maximum overall dimension of stimulus, i.e., solid dot / bar
maxStimSize = fix(scrSquare / 2) ;

%stim color
stimColorVal = WHITE ; 
stimColor = stimColorVal * [ 1 1 1 ];
%the initial size of stimulus in half width.
stimSizeX0 = fix(maxStimSize/2) ;
stimSizeY0 = stimSizeX0+100;
%stim orientation.
stimOrient = 0;
stimCenter = scrCenter ;
%original stim rect 
stimTexRect = [0 0 2*stimSizeX0 2*stimSizeY0];
%source rect 
stimSrcRect = CenterRect(stimTexRect,pRect);

% %make texture for stim
% subx = 1 : (2*stimSizeX0+1);
% suby = 1 : (2*stimSizeY0+1);
% x = subx - stimSizeX0 ;
% y = suby - stimSizeY0;
% 
% [X,Y] = meshgrid(x,y);

stimRectMatrix = stimColorVal * ones(2*stimSizeY0+1,2*stimSizeX0+1);
stimTexture = Screen('MakeTexture',pWin,stimRectMatrix);
%inversed color stim 
stimRectMatrixInv = (WHITE-stimColorVal) * ones(size(stimRectMatrix));
stimTextureInv = Screen('MakeTexture',pWin,stimRectMatrixInv);

%stim texture to show
stimShowTex = {stimTexture,stimTextureInv};
stimShowTexIdx = 1;

%inital stim size for display
stimSizeX = 8;
stimSizeY = stimSizeX;


%width of receptive field outline (rect or circle)
outlineWidth = 4 ; 
%outline color, set a shadow constrast to background
outlineColorVal = mod(bgColorVal + 20 , 256) ; 
outlineColor = outlineColorVal * [ 1 1 1 ];

%initial size of the receptive field outline to make texture.
outlineSize = maxStimSize - 2*outlineWidth ; 
%center of outline
outlineCenter = scrCenter;
%horiz and vert dimensions -- major/minor axes length of ellipse
outHorDim = outlineSize;
outVrtDim = outlineSize;
%ellipse orientation
outlineOrient = 0;
% 
%set the horiz and vert dimensions for initial rings display
ringHorDim = 120;
ringVrtDim = 120;

%-------------------------------------------------------------------------
%use drawdots to show circle for outline.
NOP = 600;

THETA=linspace(0,2*pi,NOP);
RHO=ones(1,NOP);
[circleX,circleY] = pol2cart(THETA,RHO);

circleMatrix = [circleX*ringHorDim;circleY*ringVrtDim];

outlineMatrix = [circleX*outHorDim;circleY*outVrtDim];

nChannels = 24;
%creat outlines for cells in each channel.
circleArrayDim = cell(1,nChannels);
circleCenter = cell(1,nChannels);
%circle matrix array
circleArray = cell(1,nChannels);
circleColor = cell(1,nChannels);
circleShowStatus = cell(1,nChannels);
%if ring is gonna stay on screen to show.
circleStayStatus = cell(1,nChannels);
%circle orientation.
circleOrient = cell(1,nChannels);
%ring positions.
circlePos = cell(1,nChannels);
%put center position in vector form.
circleCP = zeros(nChannels,2);

%show all rings
isAllCircleVisible = false;

for i = 1 : nChannels
    circleArrayDim{i} = [ringHorDim ringVrtDim];
   % circleCenter{i} = outlineCenter;
    circleArray{i} = circleMatrix;
    if isAllCircleVisible
        circleShowStatus{i} = true;
    else
        circleShowStatus{i} = false;
    end
    
    %no stay on screen
    circleStayStatus{i} = false;
    
    circleOrient{i} = 0;
    
    if i < fix(nChannels/3)
        circleColor{i} = [i*255/(nChannels/3) 10 10];
        circleCenter{i} = outlineCenter + [mod(i-1,fix(nChannels/3))*10 0];
    elseif i < fix(nChannels*2/3)
        circleColor{i} = [10 (i-nChannels/3)*255/(nChannels/3) 10];
        circleCenter{i} = outlineCenter + [mod(i-1,fix(nChannels/3))*10 30];
    else
        circleColor{i} = [10 10 (i-nChannels*2/3)*255/(nChannels/3)];
        circleCenter{i} = outlineCenter + [mod(i-1,fix(nChannels/3))*10 60];
    end
end

%active control for arrow keys.'ring','stim'--loop through
%channels.
activeCtrl = 'ring';
%index of active ring.
activeRingIdx = 1;
circleShowStatus{activeRingIdx} = true;

%draw stim and interact with user input
outlinePos = [ outlineCenter(1)-outHorDim outlineCenter(2)-outVrtDim ...
    outlineCenter(1)+outHorDim outlineCenter(2)+outVrtDim];

circlePos{activeRingIdx} = [ circleCenter{activeRingIdx}(1)-circleArrayDim{activeRingIdx}(1) ...
    circleCenter{activeRingIdx}(2)-circleArrayDim{activeRingIdx}(2)...
    circleCenter{activeRingIdx}(1)+circleArrayDim{activeRingIdx}(1) ...
    circleCenter{activeRingIdx}(2)+circleArrayDim{activeRingIdx}(2)];

stimPos = [ stimCenter(1) - stimSizeX stimCenter(2) - stimSizeY ...
    stimCenter(1) + stimSizeX stimCenter(2) + stimSizeY ];

%set all the rings to the same central position.
for i = 1 : nChannels
    if i == activeRingIdx; continue; end;
    circlePos{i} = circlePos{activeRingIdx};
end

%select active control by Fn keys
%select F13 to control ring property. In combo with PageUp/Down, loop
%through channels.
kcodeCtrlCircle = KbName('F13');
%select stim (major changes: change sizes and flash rate,orientation etc)
kcodeCtrlStim = KbName('F14');
%changes: change orientation of stim/circles.
kcodeIncOrient = KbName('Home');

kcodeDecOrient = KbName('End');
% %loop through channels.
% kcodeCtrlChan = KbName('F16');

%toggle visible status of current channels(circles)
kcodeShowCurCircle = KbName('p');
%toggle all channels visible status
kcodeShowAllCircle = KbName('u');
%toggle visible status of outline enclosing all rings 
kcodeShowOutline = KbName('a');
%initialize the computation of the joint-outbound of all circles,ie.outline
%shape.
kcodeJointOutline = KbName('j');


%decrease horizontal dimension of the outline
kcodeDecHorDim = KbName('LeftArrow');
%increase h dim
kcodeIncHorDim = KbName('RightArrow');
%decrease vertical dim
kcodeDecVrtDim = KbName('DownArrow');
%increase v dim
kcodeIncVrtDim = KbName('UpArrow');

%decrease brightness of outline
kcodeDecOleColor = KbName('x');
%increase
kcodeIncOleColor = KbName('z');
%set the center of outline to that of stimulus
kcodeCoCenter = KbName('RightControl');

%resize,co-center,reorient (outline/ring) /stim to match the other party
kcodeMatchInside = KbName('RightGUI');

%toggle show status of ring/outline/stimulus.
kcodeToggleShow = KbName('RightShift');

%toggle b/w static/flash of stimulus 
kcodePauseFlash = KbName('0)');

%increase step size. shift modifier is not used for the sake of simplicity
kcodeIncStepSize = KbName('=+');
%decrease step size. i.e,stim/outline/orientation incremental size
kcodeDecStepSize = KbName('-_');

%toggle the stepsize control mode (dimension size vs orientation)
kcodeToggleStepSize = KbName('DELETE');

%change stimlus *Step* size
kcodeStimStepSize = cell(1,9);

numKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};

for i = 1 : 9
    kcodeStimStepSize{i} = KbName(numKeys{i});
end

% %switch stim types (bar/square/dots)
% kcodeSwitchStim = KbName('Tab');

%toggle the color of background/stimColor
kcodeToggleColor = KbName('Tab');

%quit stim
kcodeEscape = KbName('ESCAPE');

%toggle mouse cursor
kcodeToggleCursor = KbName('LeftControl');
%show help menu
kcodeHelpMenu = KbName('F1');
%show dimensions status report
kcodeStatusReport = KbName('F2');
%speed up flash rate / loop through channels.
kcodeRaceUp = KbName('PageUp');
%slow down flash rate of stim
kcodeRaceDown = KbName('PageDown');

%outline status
strOutlineState = {'Hiden','Shown'};
strStimState    = {'Hiden','Shown'};
strMouseState   = {'Still','Moving'};
strCircleState  = {'Stay Off', 'Stay On'};
strDimAngState  = {'Dimension','Orientation'};

%set two string cell. make sure they are of correct size.
strHelp = cell(1,23);
strPos  = cell(1,12);

%
strHelp{1} = 'Control Mode -->';
strHelp{2} = ' ';
strHelp{3} = '1) F1 : Help Menu';
strHelp{4} = '2) F2 : Status Report';
strHelp{5} = '3) F13 : Ring/Outline';
strHelp{6} = '4) F14 : Stimulus';
strHelp{7} = '5) ESC : Exit !';

strHelp{8} = ' ';

strHelp{9} = 'Functional Keys -->';

strHelp{10} = '1) R/L Arrow : (+)/(-) X Dim';
strHelp{11} = '2) U/D Arrow : (+)/(-) Y Dim'; 
strHelp{12} = '3) - / =     : (-)/(+) Dim/Ang StepSize';
strHelp{13} = '4) Delete   : Ctrl Dim/Ang StepSize';
strHelp{14} = '5) PgUp/PgDn: (+/-) Ring ID/Flash Rate';
strHelp{15} = '6) 0         : Pause/Resume Stim Flash';
strHelp{15+1} = '7) a         : Outline (On/Off)';
strHelp{16+1} = '8) j         : Redo Outline (On/Off)';
strHelp{17+1} = '9) z/x       : Outline (+)/(-) Color';
strHelp{18+1} = '10) R Shift   : Ring/Stim Display (On/Off)';
strHelp{19+1} = '11) R Ctrl    : Follow Ring/Stim';
strHelp{20+1} = '12) R Cmd     : Match Ring/Stim';
strHelp{21+1} = '13) L Ctrl   : Cursor Tracking (On/Off)';
strHelp{22+1} = '14) Tab      : Toggle Bg/Fg Color';

nHelps = length(strHelp);
helpMenu = 'Help On Key Functions';

for i = 1 : 4
    helpMenu = sprintf('%s\n%s',helpMenu,strHelp{i});
end

%flag of loop
isRunning = true;

%flag of stimulus presence
isStimShown = true;

%flag of outline presence
isOutlineShown = false;

%flag of keyboard input
isKeyDown = false;

%flag of mouse click
isMouseDown = false;

%flag of mouse cursor
isCursorShown = true;
%request cursor to show
isCursorRequested = true;

%flag of mouse movement. 
isMouseMoved = false;

%flag of showing help menu
isHelpRequested = true;
%flag of showing status report
isReportRequested = false;
%flag of clear text
isClearRequested = false;

%-/+ stepsize mode switch.
isOrientStepSize = false;
%

% lastMX = scrCenter(1);
% lastMY = scrCenter(2);

%step size to change outline
outlineStepSize = 10;
%step size to change stimulus
stimStepSize = 1; 
%step size to change orientation. 
stimOrientStepSize = 2;
%circle orient step size.
outlineOrientStepSize = 2;
%number of frames for flash
flashFrames = 60;
%stored flash rate
lastFlashRate = 0;

for i = 1 : nChannels
    
    if ~circleShowStatus{i}
        continue;
    end

    Screen('DrawDots',pWin,...
        circleArray{i},1,circleColor{i},circleCenter{i},dotType);
end
    
    if isOutlineShown
       Screen('DrawDots',pWin,...
           outlineMatrix,1,outlineColor,outlineCenter,dotType);
    end
       
    if isStimShown
        %     Screen('DrawDots',pWin,stimMatrix,1,stimColor,stimCenter,dotType);
        Screen('DrawTexture',pWin,stimShowTex{stimShowTexIdx},stimSrcRect,stimPos,stimOrient);
    end
    
    Screen('Flip',pWin);
    
    startRun = true;
    
    %index of frames looping through 2*flashFrames.
    %flash color b/w first half period and 2nd half
    idxFrames = 0 ;  

    while isRunning

        [kDown, secs, keyCode, deltaSecs] = KbCheck;
        
        %[clicks,x,y,whichButton] = GetClicks([windowPtrOrScreenNumber][, interclickSecs])
        
        [mx,my,mButtons] = GetMouse;
        
        %init last mouse position.
        if startRun  
            lastMX = mx;
            lastMY = my;
            flashColorVal = stimColorVal;
            %reset flag
            startRun = false;
        end
        
        if mx ~= lastMX || my ~= lastMY
            isMouseMoved = true;
            lastMX = mx ;
            lastMY = my ;
        else
            isMouseMoved = false;
        end
        
        %find the keyboard/mouse input status
        if kDown
            isKeyDown = true;
        else
            isKeyDown = false;
        end
        
        if any(mButtons)
            isMouseDown = true;
        else
            isMouseDown = false;
        end
        

         if isMouseDown
            %wait for the release of mouse button press
            tmpB = mButtons;
            while any(tmpB); [mx,my,tmpB]=GetMouse;end;
         end
        
        
         if isKeyDown

             %keycode of pressed key.
             kcodePress = find(keyCode);

             %wait for key press released.
             while KbCheck; continue; end ;

             %-----------------------------------
             %process keyboard input if pressed.
             switch kcodePress
                 
                 case kcodeCtrlCircle
                     activeCtrl = 'ring';
                 case kcodeCtrlStim
                     activeCtrl = 'stim';
                     
                 case kcodePauseFlash
                     if flashFrames ~= 0
                         t = flashFrames;
                         flashFrames = 0;
                         lastFlashRate = t;
                     else %restore the last flash rate
                         flashFrames = lastFlashRate;
                         lastFlashRate = 0;
                     end
                     
                 case kcodeShowOutline
                     isOutlineShown = ~isOutlineShown;
                     
                 case kcodeShowCurCircle %'p'
                     %make current ring stay on screen
                     circleStayStatus{activeRingIdx} = ~circleStayStatus{activeRingIdx};
                     %if not stay on screen, hide the current ring.                    
                     circleShowStatus{activeRingIdx} = circleStayStatus{activeRingIdx};
                     
                 case kcodeShowAllCircle %'u'
                     sss=circleShowStatus{activeRingIdx};
                     
                     %toggle visible state of all rings.
                     isAllCircleVisible = ~isAllCircleVisible;
                     
                     for j = 1 : nChannels
                         if isAllCircleVisible
                            circleShowStatus{j} = true;
                            
                         else
                            circleShowStatus{j} = false;
                            
                         end
                     end
                     
                     %activeRing status set true.
                     circleShowStatus{activeRingIdx}=sss;
                     
                     
                 case kcodeJointOutline
                     %compute the shape of outline enclosing all circles.
                     
                     if isOutlineShown

                         for i = 1 : nChannels
                             circleCP(i,:) = circleCenter{i};
                         end
                         a = circleCP';
                         b = a;
                         aa=sum(a.*a,1); bb=sum(b.*b,1); ab=a'*b;
                         d = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab));

                         [maxDist,maxDistIdx] = max(d);
                         
                         [maxDistSubx,maxDistSuby]=ind2sub(size(d),maxDistIdx(1));
                         
                         %center dim + radius of both circles.                   
                         outHorDim = maxDist(1)/2 + max(circleArrayDim{maxDistSubx})+max(circleArrayDim{maxDistSuby});
                         outHorDim = round(outHorDim);
                         outVrtDim = outHorDim;
                         
                         outlineCenter = (circleCenter{maxDistSubx}+circleCenter{maxDistSuby})/2;
                         outlineCenter = round(outlineCenter);

                         %update outline matrix
                         t = 2*pi*outlineOrient/360;
                         %outlineMatrix = [circleX*outHorDim;circleY*outVrtDim];
                         x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                         y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                         outlineMatrix=[x1;y1];
                     
                     end

                     
                 case kcodeDecOrient
                     %decrease orientation
                     switch activeCtrl
                         case 'ring'
                             if isOutlineShown
                                 outlineOrient = outlineOrient - outlineOrientStepSize;
                                 %update outline matrix
                                 t = 2*pi*outlineOrient/360;
                                 %outlineMatrix = [circleX*outHorDim;circleY*outVrtDim];
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];
                                 %outlineMatrix = [cos(t) -sin(t); sin(t) cos(t)]*outlineMatrix;
                             else
                                 circleOrient{activeRingIdx}=circleOrient{activeRingIdx} - outlineOrientStepSize;
                                 t = 2*pi*circleOrient{activeRingIdx}/360;
                                  x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                        - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                  y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                        + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];

                             end
                         case 'stim'
                             stimOrient = stimOrient - stimOrientStepSize;
                           
                             
                     end
                     
                 case kcodeIncOrient
                     
                      switch activeCtrl
                         case 'ring'
                             if isOutlineShown
                                 outlineOrient = outlineOrient + outlineOrientStepSize;
                                 t = 2*pi*outlineOrient/360;
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];
                             else
                                 circleOrient{activeRingIdx}=circleOrient{activeRingIdx} + outlineOrientStepSize;
                                  t = 2*pi*circleOrient{activeRingIdx}/360;
                                  x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                        - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                  y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                        + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];
 
                             end
                         case 'stim'
                             stimOrient = stimOrient + stimOrientStepSize;
                          
                     end
                     
                 case kcodeDecStepSize
                     
                     switch activeCtrl
                         case 'ring'
                             
                             %orient or dim
                             if isOrientStepSize
                                 if outlineOrientStepSize < 2
                                     continue;
                                 end
                                 outlineOrientStepSize = outlineOrientStepSize -1;
                             else %change dim step size
                                                    
                                 if outlineStepSize < 2
                                       continue;
                                 end
                                    outlineStepSize = outlineStepSize - 1 ;
                             end 
                     
                         case 'stim'
                             
                             if isOrientStepSize
                                 if stimOrientStepSize < 2
                                     continue;
                                 end
                                 stimOrientStepSize = stimOrientStepSize -1;
                             else %dim step size
                             
                                 if stimStepSize < 2
                                    continue;
                                 end
                             
                                   stimStepSize = stimStepSize - 1;
                             end
                      
                     end

                 case kcodeIncStepSize
                     switch activeCtrl
                         case 'ring'

                           %orient or dim
                             if isOrientStepSize
                                 if outlineOrientStepSize > 20
                                     continue;
                                 end
                                 outlineOrientStepSize = outlineOrientStepSize + 1;
                             else %change dim step size
                                                    
                                 if outlineStepSize > 200
                                       continue;
                                 end
                                    outlineStepSize = outlineStepSize + 1 ;
                             end 

                         case 'stim'
                              if isOrientStepSize
                                 if stimOrientStepSize > 20
                                     continue;
                                 end
                                 stimOrientStepSize = stimOrientStepSize +1;
                             else %dim step size
                             
                                 if stimStepSize > 200
                                    continue;
                                 end
                             
                                   stimStepSize = stimStepSize + 1;
                             end

                     end
                        
                     
                 case kcodeToggleStepSize %use del to switch dim/ori mode
                     
                     isOrientStepSize = ~isOrientStepSize;


                 case kcodeStimStepSize

                     for j = 1 : length(kcodeStimStepSize)
                         
                         if kcodeStimStepSize{j}==kcodePress
                             stimStepSize = j ;
                         end
                     end
                     
        
                                         
                 case kcodeRaceUp
                     switch activeCtrl
                         case 'ring'
                             %loop through channels
                             if circleStayStatus{activeRingIdx}
                                 circleShowStatus{activeRingIdx}=true;
                             else
                                 circleShowStatus{activeRingIdx}=false;
                             end
                             activeRingIdx = activeRingIdx + 1;
                             if activeRingIdx > nChannels
                                 activeRingIdx = 1;
                             end
                             circleShowStatus{activeRingIdx}=true;
                         case 'stim'
                             %speed up flash rate.
                             if flashFrames <= 5
                                 %reduce the step size at fast end
                                 flashFrames = flashFrames - 1;
                                 if flashFrames < 1; flashFrames = 1;end;
                             else
                                 flashFrames = flashFrames - 5;
                             end
                     end

                 case kcodeRaceDown
                     switch activeCtrl
                         case 'ring'
                             %loop through channels
                             if circleStayStatus{activeRingIdx}
                                 circleShowStatus{activeRingIdx}=true;
                             else
                                 circleShowStatus{activeRingIdx}=false;
                             end
                             
                             activeRingIdx = activeRingIdx - 1;
                             if activeRingIdx < 1
                                 activeRingIdx = nChannels;
                             end
                             
                             circleShowStatus{activeRingIdx}=true;
                             
                         case 'stim'
                             if flashFrames > 60*60*5
                                 flashFrames = 60*60*5;
                             elseif flashFrames < 5
                                 flashFrames = flashFrames + 1;
                             else
                                 flashFrames = flashFrames + 5;
                             end
                     end


                 case kcodeDecHorDim
                     
                     switch activeCtrl
                         case 'ring'
                             if isOutlineShown
                                 %check out-of-bound condition
                                 if outHorDim <= outlineStepSize
                                     continue;
                                 end
                                 
                                 outHorDim = outHorDim - outlineStepSize ;
                                 %update circle outline
                                 t = 2*pi*outlineOrient/360;
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];
                             else

                                 %decrease active ring hor dim
                                 %check boundary condition
                                 if circleArrayDim{activeRingIdx}(1) <= outlineStepSize
                                     continue;
                                 end
                                 circleArrayDim{activeRingIdx}(1) = circleArrayDim{activeRingIdx}(1) - outlineStepSize;
                                 %update active ring
                                  t = 2*pi*circleOrient{activeRingIdx}/360;
                                  x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                        - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                  y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                        + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];
                             end


                         case 'stim'
                             if stimSizeX <= stimStepSize
                                 continue;
                             end

                             stimSizeX = stimSizeX - stimStepSize ;

                     end %activeCtrl switch
 
                 case kcodeIncHorDim

            
%                      circleMatrix = [circleX*outHorDim;circleY*outVrtDim];

                    switch activeCtrl
                         case 'ring'
                             if isOutlineShown
                                 %loop through out-of-bound condition
                                 outHorDim = outHorDim + outlineStepSize ;

%                                  if outHorDim > outlineSize
%                                      outHorDim = outlineSize;
%                                  end

                                 %update outline
                                 t = 2*pi*outlineOrient/360;
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];

                             else %do on active ring
                                 circleArrayDim{activeRingIdx}(1) = circleArrayDim{activeRingIdx}(1) + outlineStepSize;
                                 %increase active ring hor dim
                                 %check boundary condition
                                 if circleArrayDim{activeRingIdx}(1) > outlineSize
                                     circleArrayDim{activeRingIdx}(1) = outlineSize;
                                 end


                                 %update active ring
                                 t = 2*pi*circleOrient{activeRingIdx}/360;
                                 x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                     - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                 y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                     + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];
                             end

                         case 'stim'
%                              if stimSizeX > stimSizeX
%                                  continue;
%                              end

                             stimSizeX = stimSizeX + stimStepSize ;

                         
                     end %activeCtrl switch
                     
                     
                 case kcodeDecVrtDim

                     switch activeCtrl
                         case 'ring'
                             if isOutlineShown
                                 if outVrtDim <= outlineStepSize
                                     continue;
                                 end

                                 outVrtDim = outVrtDim - outlineStepSize ;
                                 %update circle outline
                                 t = 2*pi*outlineOrient/360;
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];
                             else
                                 %decrease active ring hor dim
                                 %check boundary condition
                                 if circleArrayDim{activeRingIdx}(2) <= outlineStepSize
                                     continue;
                                 end
                                 circleArrayDim{activeRingIdx}(2) = circleArrayDim{activeRingIdx}(2) - outlineStepSize;
                                 %update active ring
                                 %update active ring
                                 t = 2*pi*circleOrient{activeRingIdx}/360;
                                 x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                     - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                 y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                     + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];
                             end

                          
                         case 'stim'
                             if stimSizeY <= stimStepSize
                                 continue;
                             end

                             stimSizeY = stimSizeY - stimStepSize ;

                     end %activeCtrl switch

                 case kcodeIncVrtDim

                     switch activeCtrl
                         case 'ring'
                             
                             if isOutlineShown
                                 %loop through out-of-bound condition
                                 outVrtDim = outVrtDim + outlineStepSize ;
%                                  if outVrtDim > outlineSize
%                                      outVrtDim = outlineSize;
%                                  end
                                 %update circle outline
                                 t = 2*pi*outlineOrient/360;
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];

                             else

                                 %increase active ring hor dim
                                 %check boundary condition
                                 circleArrayDim{activeRingIdx}(2) = circleArrayDim{activeRingIdx}(2) + outlineStepSize;
                                 if circleArrayDim{activeRingIdx}(2) > outlineSize
                                     circleArrayDim{activeRingIdx}(2) = outlineSize;
                                 end
                                 
                                 %update active ring
                                 t = 2*pi*circleOrient{activeRingIdx}/360;
                                 x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                     - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                 y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                     + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];
                             end

                         case 'stim'
                             
                             stimSizeY = stimSizeY + stimStepSize ;

                     end %activeCtrl switch

                 case kcodeDecOleColor

                     outlineColorVal = outlineColorVal - 1;
                     outlineColorVal = mod(outlineColorVal,256);
                     outlineColor = outlineColorVal * [1 1 1];

                 case kcodeIncOleColor

                     outlineColorVal = outlineColorVal + 1;
                     outlineColorVal = mod(outlineColorVal,256);
                     outlineColor = outlineColorVal * [1 1 1];
                     
                 case kcodeCoCenter
                        if isOutlineShown
                            outlineCenter = stimCenter;
                        else
                            circleCenter{activeRingIdx}=stimCenter;
                            if ~circleShowStatus{activeRingIdx}; circleShowStatus{activeRingIdx}=true; end; 
                        end
                     
                 case kcodeMatchInside

                     switch activeCtrl
                         case 'ring' %resize the ring to match stim

                             if isOutlineShown
                                 %resize outline to cover stimulus
                                 outHorDim = round(sqrt(2)*stimSizeX) + 2;
                                 outVrtDim = round(sqrt(2)*stimSizeY) + 2;
                                 outlineOrient = stimOrient;
                                 %update circle outline
                                 t = 2*pi*outlineOrient/360;
                                 x1 = cos(t)*circleX*outHorDim - sin(t)*circleY*outVrtDim;
                                 y1 = cos(t)*circleY*outVrtDim + sin(t)*circleX*outHorDim;
                                 outlineMatrix=[x1;y1];

                                 %co-center
                                 outlineCenter = stimCenter;
                                 %SetMouse(stimCenter(1),stimCenter(2),pWin);
                                 % present the outline
                                 %if ~isOutlineShown; isOutlineShown = true; end;
                             else
                                 circleArrayDim{activeRingIdx}(1)=round(sqrt(2)*stimSizeX) + 2;
                                 circleArrayDim{activeRingIdx}(2)=round(sqrt(2)*stimSizeY) + 2;

                                 circleCenter{activeRingIdx}=stimCenter;
                                 circleOrient{activeRingIdx} = stimOrient;

                                 %update active ring
                                 t = 2*pi*circleOrient{activeRingIdx}/360;
                                 x1 = cos(t)*circleX*circleArrayDim{activeRingIdx}(1)...
                                     - sin(t)*circleY*circleArrayDim{activeRingIdx}(2);
                                 y1 = cos(t)*circleY*circleArrayDim{activeRingIdx}(2)...
                                     + sin(t)*circleX*circleArrayDim{activeRingIdx}(1);
                                 circleArray{activeRingIdx} = [x1;y1];

                             end

                         case 'stim'
                             if isOutlineShown
                                 stimSizeX = round(outHorDim/sqrt(2));
                                 stimSizeY = round(outVrtDim/sqrt(2));
                                 stimOrient = outlineOrient;
                                 stimCenter = outlineCenter;
                             else
                                 stimSizeX = round(circleArrayDim{activeRingIdx}(1)/sqrt(2));
                                 stimSizeY = round(circleArrayDim{activeRingIdx}(2)/sqrt(2));
                                 stimOrient = circleOrient{activeRingIdx};
                                 stimCenter = circleCenter{activeRingIdx};
                             end

                     end %switch of activeCtrl
                     
                 case kcodeToggleShow
                     
                     switch activeCtrl
                         case 'ring'
                             if isOutlineShown
                                 isOutlineShown = ~isOutlineShown;
                             else
                                 %toggle active ring.
                                 circleShowStatus{activeRingIdx} = ~(circleShowStatus{activeRingIdx});
                             end
                             
                         case 'stim'
                             isStimShown = ~isStimShown;
                     end

                 case kcodeToggleColor
                     %toggle stim color b/w blk and wht
                     stimColorVal = ~(stimColorVal/WHITE)*WHITE;
                     stimColor = ~(stimColor/WHITE)*WHITE;
                                
                     bgColorVal = ~(bgColorVal/WHITE)*WHITE;
                     bgColor = ~(bgColor/WHITE)*WHITE;
                     
                     outlineColorVal = 256 - outlineColorVal;
                     outlineColor = outlineColorVal*[1 1 1];
                    
                     %refill the screen with inverted color
                     Screen('FillRect',pWin,bgColor);
                     
                 case kcodeToggleCursor
                     %
                     isCursorRequested = ~isCursorRequested;
                     if ~isCursorRequested
                         %move cursor to stim if hide
                         SetMouse(stimCenter(1),stimCenter(2),pWin);
                     end
                     
                 case kcodeHelpMenu
                     isHelpRequested = ~isHelpRequested;
%                      %invert the other requests
                     if isHelpRequested
                         isReportRequested = ~isHelpRequested;
                     end
                     
                 case kcodeStatusReport
                     isReportRequested = ~isReportRequested;
                     
                     if isReportRequested
                         isHelpRequested = ~isReportRequested;
                     end
                     
               
                 case kcodeEscape
                     isRunning = false;
%                      continue;

                 otherwise
                     %not support key functions.
                
             end

         else
             %kcodePress = [] ;

         end

        
        %click to toggle cursor on when in off status. 
        if ~isCursorShown && isMouseDown
            isCursorRequested = true;
        end
        
        %update stim and outline position depending on the cursor state.
        %cursor on : update only when mouse clicks.
        %cursor off: update with mouse position.i.e, stim tracks mouse
        
        %find the cursor state
        if isCursorShown
            %move circles / stim by click.
            if isMouseDown
                switch activeCtrl
                    case 'ring'
                        if isOutlineShown
                            outlineCenter = [mx my];
                        else
                            if circleShowStatus{activeRingIdx} %update if visible
                                circleCenter{activeRingIdx}= [mx my];
                            end
                        end
                    case 'stim'
                        if isStimShown %update if visible                             
                            stimCenter = [mx my];
                        end
                end
            end  % MouseCheck
            
            
        else %move around with cursor
            if isMouseMoved
                switch activeCtrl
                    case 'ring'
                        if isOutlineShown
                            outlineCenter = [ mx my];
                        else
                             if circleShowStatus{activeRingIdx} %update if visible
                                circleCenter{activeRingIdx}= [mx my];
                             end
                        end
                    case 'stim'
                        if isStimShown
                            stimCenter = [mx my];
                        end
                end
            end %check mouse.
        end
      
        
        %update outlinePos since both key and mouse could change it.
        outlinePos = [ outlineCenter(1)-outHorDim outlineCenter(2)-outVrtDim ...
            outlineCenter(1)+outHorDim outlineCenter(2)+outVrtDim ];
        
        circlePos{activeRingIdx} = [ circleCenter{activeRingIdx}(1)-circleArrayDim{activeRingIdx}(1) ...
            circleCenter{activeRingIdx}(2)-circleArrayDim{activeRingIdx}(2)...
            circleCenter{activeRingIdx}(1)+circleArrayDim{activeRingIdx}(1) ...
            circleCenter{activeRingIdx}(2)+circleArrayDim{activeRingIdx}(2)];
        
        %update stim rect
        stimPos = [ stimCenter(1) - stimSizeX stimCenter(2) - stimSizeY ...
            stimCenter(1) + stimSizeX stimCenter(2) + stimSizeY ];
      
        
        strPos{1} = sprintf('1) Outline State-->%s',strOutlineState{isOutlineShown+1});
        strPos{2} = sprintf('Center=[%-3d %-3d] Dim=[%-3d %-3d @%d] Ang=[%-3d @%d] Color=%d',...
            outlineCenter(1),outlineCenter(2),outHorDim,outVrtDim,outlineStepSize,...
            outlineOrient,outlineOrientStepSize,outlineColorVal);
        strPos{3} = sprintf('2) Stimulus State-->%s',strStimState{isStimShown+1});
        strPos{4} = sprintf('Center=[%-3d %-3d] Dim=[%-3d %-3d @%d] Ang=[%-3d @%d]',...
            stimCenter(1),stimCenter(2),2*stimSizeX+1,2*stimSizeY+1,stimStepSize,stimOrient,stimOrientStepSize);
        strPos{5} = sprintf('3) Mouse State-->');
        strPos{6} = sprintf('Mouse=[%-3d %-d]',mx,my);
         strPos{7} = sprintf('4) Active Channel id=[%d]-->%s,%s',activeRingIdx,...
               strOutlineState{circleShowStatus{activeRingIdx}+1},strCircleState{circleStayStatus{activeRingIdx}+1});
        strPos{8} = sprintf('Center=[%-3d %-3d] Dim=[%-3d %-3d @%d] Ang=[%-3d @%d]',circleCenter{activeRingIdx}(1),...
            circleCenter{activeRingIdx}(2),circleArrayDim{activeRingIdx}(1),circleArrayDim{activeRingIdx}(2),...
            outlineStepSize,circleOrient{activeRingIdx},outlineOrientStepSize);
        
        strPos{9} = sprintf('5) Refresh Frames = %d',flashFrames);
        strPos{10} = ' ';
        strPos{11} = sprintf('6) StepSize Ctrl--> %s', strDimAngState{isOrientStepSize+1});
        strPos{12} = sprintf('Control Target-> %s',activeCtrl);
        
        if isHelpRequested
            s = strHelp;
        elseif isReportRequested
            s = strPos;
        else
            s = [];
        end

        if isOutlineShown

             Screen('DrawDots',pWin,...
           outlineMatrix,1,outlineColor,outlineCenter,dotType);

        end 
        
        for i = 1 : nChannels
            if circleShowStatus{i}
                Screen('DrawDots',pWin,...
                    circleArray{i},1,circleColor{i},circleCenter{i},dotType);
                %draw labels for each channel
                if i ~= activeRingIdx
                    Screen('DrawText',pWin,int2str(i),circlePos{i}(1),circlePos{i}(2),repmat(~(bgColorVal/WHITE)*WHITE,3,1));
                else
                    Screen('DrawText',pWin,int2str(i),circlePos{i}(1),circlePos{i}(2),[WHITE 0 0]);
                end
            end
 
        end
        
        if isStimShown
            idxFrames = idxFrames + 1 ;
            idxFrames = mod(idxFrames, flashFrames);
            %invert color when num of displayed frames reach flashFrames
            if idxFrames == 0
                %flashColorVal = ~(flashColorVal/WHITE)*WHITE; 
                stimShowTexIdx = ~(stimShowTexIdx -1) + 1;
            end
         
            Screen('DrawTexture',pWin,stimShowTex{stimShowTexIdx},stimSrcRect,stimPos,stimOrient);

        end
        
        for i = 1 : length(s)
        
            Screen('DrawText',pWin,s{i},5,1+i*round(scrTextSize*(1+1/2)),repmat(~(bgColorVal/WHITE)*WHITE,3,1));
        
        end
        
        if isCursorRequested && ~isCursorShown 
                ShowCursor([],pWin); 
                isCursorShown = true;
                            
        elseif ~isCursorRequested && isCursorShown
                HideCursor; 
                isCursorShown = false;
        else
            %remains as same.
        end
        
        Screen('Flip',pWin);
  
    end

    Screen('CloseAll');
    %save workspace
    fn = sprintf('~/stimulation/OnlineMappingRF_data/OnlineMappingRF_%s.mat',datestr(now,'dd-mmm-yyyy_HH:MM:SS'));
    fn0 = sprintf('~/stimulation/OnlineMappingRF_new.mat');
    save(fn);
    %save one copy as the most recent data.
    save(fn0);

catch
    Screen('CloseAll');
    error(lasterror);

end

