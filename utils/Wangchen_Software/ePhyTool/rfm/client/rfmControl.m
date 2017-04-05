function varargout = rfmControl(varargin)
% RFMCONTROL M-file for rfmControl.fig
%      RFMCONTROL, by itself, creates a new RFMCONTROL or raises the existing
%      singleton*.
%
%      H = RFMCONTROL returns the handle to a new RFMCONTROL or the handle to
%      the existing singleton*.
%
%      RFMCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RFMCONTROL.M with the given input arguments.
%
%      RFMCONTROL('Property','Value',...) creates a new RFMCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rfmControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rfmControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rfmControl

% Last Modified by GUIDE v2.5 30-Apr-2010 12:13:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rfmControl_OpeningFcn, ...
                   'gui_OutputFcn',  @rfmControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rfmControl is made visible.
function rfmControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rfmControl (see VARARGIN)

% global rfmPar rfmWSCK;
global Mouse;
import java.awt.Robot;
Mouse = Robot;

global rfmPar;
% Choose default command line output for rfmControl
handles.output = hObject;

set(hObject,'Visible','off');
%reset units
set(hObject,'Units','pixels');
%find the screen size
ScrSiz = get(0,'ScreenSize');
rfmPar.ScreenSize = ScrSiz;

rfmCtrlPos = get(hObject,'Position');
%bring it to the leftmost 
rfmCtrlPos(1) = 1;
set(hObject,'Position',rfmCtrlPos);

%initialize the GUI with rfmPar/rfmWSCK.
handles = rfmControl_initGUI(handles);

%close if left open from last crash.
try 
    if rfmPar.useNSP
         cbmex('close'); 
    end
catch
end

%load the cerebus library.
try 
    %lasterr
    if rfmPar.useNSP
        addpath(rfmPar.rfmPath);
        cbmex('open');
        rfmStimPar.startNSPTime=cbmex('time');
    end
catch
    %disable NSP 
    lasterr
    fprintf('error loading cbmex library. recording disabled\n');
    rfmPar.useNSP = false;
end


set(hObject,'Visible','on');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rfmControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = rfmControl_updateGUI(handles)
%update the paramlist from global variables.
%update the gui elements upon the stim selection from popup-menu.
global rfmPar rfmStimPar

%update paramlist
%--------------------------------------------------
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
rfmPar.StimParamsList2{6} = struct('Name','RefreshOnFrames StepSize(dRF)',...
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

%--------------------------------------------------

StimParamsListLen1 = length(rfmPar.StimParamsList1);
StimParamsName1 = cell(1,StimParamsListLen1);
for i = 1 : StimParamsListLen1
    StimParamsName1{i} = rfmPar.StimParamsList1{i}.('Name');
end

set(handles.popupmenu_StimParamsList1,'String',StimParamsName1);
set(handles.popupmenu_StimParamsList1,'Value',1);

set(handles.edit_StimDimPosVar1,'String',rfmPar.StimParamsList1{1}.('Var1'));
set(handles.edit_StimDimPosVal1,'String',rfmPar.StimParamsList1{1}.('Val1'));
set(handles.edit_StimDimPosVar2,'String',rfmPar.StimParamsList1{1}.('Var2'));
set(handles.edit_StimDimPosVal2,'String',rfmPar.StimParamsList1{1}.('Val2'));

StimParamsListLen2 = length(rfmPar.StimParamsList2);
StimParamsName2 = cell(1,StimParamsListLen2);
for i = 1 : StimParamsListLen2
    StimParamsName2{i} = rfmPar.StimParamsList2{i}.('Name');
end
set(handles.popupmenu_StimParamsList2,'String',StimParamsName2);
set(handles.popupmenu_StimParamsList2,'Value',1);

set(handles.edit_StimPVar1,'String',rfmPar.StimParamsList2{1}.('Var1'));
set(handles.edit_StimPVal1,'String',rfmPar.StimParamsList2{1}.('Val1'));

set(handles.checkbox_StimStatic,'Value',rfmPar.Stim{1}.('Static'));
set(handles.checkbox_StimTrackCursor,'Value',rfmPar.Stim{1}.('TrackCursor'));

%use disk for grating shape.
if rfmPar.StimIdx ==2
    rfmPar.StimDimPosValChgSyn = true;
    set(handles.checkbox_measureTC,'Value',rfmStimPar.measureTC);
    set(handles.edit_mtcStart,'String',rfmStimPar.mtcStart);
    set(handles.edit_mtcStepsize,'String',rfmStimPar.mtcStepsize);
    set(handles.edit_mtcEnd,'String',rfmStimPar.mtcEnd);
end

set(handles.checkbox_StimDimPosValChgSyn,'Value',rfmPar.StimDimPosValChgSyn);
set(handles.checkbox_useNSP,'Value',rfmPar.useNSP);

%get the list of the r.f.b parameters 
rfbParamsListLen1 = length(rfmPar.rfbParamsList1);
rfbParamsName1 = cell(1,rfbParamsListLen1);
for i = 1 : rfbParamsListLen1 
    rfbParamsName1{i} = rfmPar.rfbParamsList1{i}.('Name');
end
set(handles.popupmenu_rfbParamsList1,'String',rfbParamsName1);
set(handles.popupmenu_rfbParamsList1,'Value',1);

set(handles.edit_rfbDimPosVar1,'String',rfmPar.rfbParamsList1{1}.('Var1'));
set(handles.edit_rfbDimPosVal1,'String',rfmPar.rfbParamsList1{1}.('Val1'));
set(handles.edit_rfbDimPosVar2,'String',rfmPar.rfbParamsList1{1}.('Var2'));
set(handles.edit_rfbDimPosVal2,'String',rfmPar.rfbParamsList1{1}.('Val2'));

rfbParamsListLen2 = length(rfmPar.rfbParamsList2);
rfbParamsName2 = cell(1,rfbParamsListLen2);
for i = 1 : rfbParamsListLen2 
    rfbParamsName2{i} = rfmPar.rfbParamsList2{i}.('Name');
end
set(handles.popupmenu_rfbParamsList2,'String',rfbParamsName2);
set(handles.popupmenu_rfbParamsList2,'Value',1);

set(handles.edit_rfbPVar1,'String',rfmPar.rfbParamsList2{1}.('Var1'));
set(handles.edit_rfbPVal1,'String',rfmPar.rfbParamsList2{1}.('Val1'));

set(handles.edit_ChID,'String',rfmPar.ChSets{1}.('ChID'));
set(handles.checkbox_rfbVisible,'Value',rfmPar.ChSets{1}.('Visible'));
set(handles.checkbox_rfbTrackCursor,'Value',rfmPar.ChSets{1}.('TrackCursor'));
set(handles.edit_rfbRange,'String',num2str(rfmPar.rfbRange));

set(handles.checkbox_rfbDimPosValChgSyn,'Value',rfmPar.rfbDimPosValChgSyn);

set(handles.checkbox_useNSP,'Value',rfmPar.useNSP);

%initialize all the fields...
set(handles.edit_ServerAddress,'String',rfmPar.RemoteHost);
set(handles.edit_ServerPort,'String',rfmPar.RemotePort);

function handles = rfmControl_initGUI(handles)

global rfmPar;

%get the list length of stimulus type and setup stimulus list
StimListLen = length(rfmPar.Stim);
StimType = cell(1,StimListLen);
for i = 1 : StimListLen
    StimType{i} = rfmPar.Stim{i}.('Name');
end
set(handles.popupmenu_StimulusList,'String',StimType);
set(handles.popupmenu_StimulusList,'Value',rfmPar.StimIdx);

handles = rfmControl_updateGUI(handles);


% --- Outputs from this function are returned to the command line.
function varargout = rfmControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_ServerAddress_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ServerAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ServerAddress as text
%        str2double(get(hObject,'String')) returns contents of edit_ServerAddress as a double


% --- Executes during object creation, after setting all properties.
function edit_ServerAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ServerAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ServerPort_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ServerPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ServerPort as text
%        str2double(get(hObject,'String')) returns contents of edit_ServerPort as a double


% --- Executes during object creation, after setting all properties.
function edit_ServerPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ServerPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Connect.
function pushbutton_Connect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmWSCK rfmStimPar;
global hStatusBar;

if (isempty(rfmWSCK))
    rfmWSCK=actxcontrol('MSWinsock.Winsock.1',[0 0 100 100],0,{'DataArrival' 'rfmTCPIPDataFromServer'});
else
    if (rfmWSCK.State~=0)
        rfmWSCK.Close;
        pause(0.5);
    end;
end;
set(hStatusBar,'String', [' Connecting to ' rfmPar.RemoteHost ':' num2str(rfmPar.RemotePort) ' ...']);
rfmWSCK.RemoteHost=rfmPar.RemoteHost;
rfmWSCK.RemotePort=rfmPar.RemotePort;
rfmWSCK.Connect;
pause(0.1);

%check if remote server up running
if rfmWSCK.State~=7 %not connected
    %load the server via ssh
    if isempty(rfmPar.userPwd)
        sshcmd = sprintf('%s\\putty -ssh -l %s %s -m %s',rfmPar.puttyPath,...
            rfmPar.userID, rfmPar.RemoteHost,rfmPar.runScript);
    else
        sshcmd = sprintf('%s\\putty -ssh -l %s -pw %s %s -m %s',rfmPar.puttyPath,...
            rfmPar.userID,rfmPar.userPwd,rfmPar.RemoteHost,rfmPar.runScript);
    end

    sshcmd = [sshcmd ' &'];
    system(sshcmd);
    pause(0.5);
    waittime = 0;
    %
    %fprintf('testing if server alive....\n');
    %take user input
    [svr]=input('Press Y when rfmTCPIPServer ready => ','s'); 
    if ~strcmpi(svr,'y')
        fprintf('server not ready\n');
        %error('...');
    end
        
    while true    
        rfmWSCK.Connect; 
        pause(0.1);
        
        if rfmWSCK.State==7
            fprintf('----------rfmTCPIPServer loaded--------------\n');
            break;
        else
            pause(1);
            waittime = waittime + 1;
            fprintf('Attempts %d s / %d s .....\n',waittime, 100);
            if waittime > 100; fprintf('Loading Server Timeout\n'); break; end
        end
    end
end                

%now the server should be up running or connection time out.

if (rfmWSCK.State==7)
    %rfmWSCK.SendData(['clear functions;' char(10)]);  % Will close all existing PNet connections ...
    fns=fieldnames(rfmStimPar);
    for i=1:length(fns)
        fn=fns{i};
        if (~isstruct(rfmStimPar.(fn)))
            disp(['Sending ' fn ' ...']);
            if (isnumeric(rfmStimPar.(fn))) | (islogical(rfmStimPar.(fn)))
                if (length(rfmStimPar.(fn))>1) % The field is an array
                    rfmWSCK.SendData(['rfmStimPar.' fn '=[' num2str(rfmStimPar.(fn)) '];' char(10)]);
                else        % The field is a single value
                    rfmWSCK.SendData(['rfmStimPar.' fn '=' num2str(rfmStimPar.(fn)) ';' char(10)]);
                end;
            else
                rfmWSCK.SendData(['rfmStimPar.' fn '=''' rfmStimPar.(fn) ''';' char(10)]);
            end;
        else
            fnss=fieldnames(rfmStimPar.(fn));
            for j=1:length(fnss)
                fns1=fnss{j};
                disp(['Sending ' fn '.' fns1 ' ...']);
                if (isnumeric(rfmStimPar.(fn).(fns1))) | (islogical(rfmStimPar.(fn).(fns1)))
                    if (length(rfmStimPar.(fn).(fns1))>1) % The field is an array
                        rfmWSCK.SendData(['rfmStimPar.' fn '.' fns1 '=[' num2str(rfmStimPar.(fn).(fns1)) '];' char(10)]);
                    else        % The field is a single value
                        rfmWSCK.SendData(['rfmStimPar.' fn '.' fns1 '=' num2str(rfmStimPar.(fn).(fns1)) ';' char(10)]);
                    end;
                else
                    rfmWSCK.SendData(['rfmStimPar.' fn '.' fns1 '=''' rfmStimPar.(fn).(fns1) ''';' char(10)]);
                end;
            end;
        end;
    end;
    set(hStatusBar,'String', [' Connected to ' rfmPar.RemoteHost ':' num2str(rfmPar.RemotePort)]);
else
    disp('Could not connect to the remote computer');
    set(hStatusBar,'String', [' Could not connect to ' rfmPar.RemoteHost ':' num2str(rfmPar.RemotePort)]);
end;

% --- Executes on button press in pushbutton_Pause.
function pushbutton_Pause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmWSCK rfmStimPar;
global hStatusBar;

try
    rfmWSCK.SendData(['rfmStimPar.stopRunning=false;rfmStimPar.pauseRunning=true;' char(10)]);
end;

rfmStimPar.pauseRunning = true;
rfmPar.pauseRunning = rfmStimPar.pauseRunning;
set(hStatusBar,'String', ' Paused.');

%update the timer
try stop(rfmPar.stimTimer); end;

% --- Executes on button press in pushbutton_Stop.
function pushbutton_Stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmWSCK rfmStimPar;
global hStatusBar

set(hStatusBar,'String', ' Stopped.');

try
    rfmWSCK.SendData(['rfmStimPar.stopRunning=true;rfmStimPar.pauseRunning=false;' char(10)]);
end
rfmStimPar.stopRunning = true;
rfmStimPar.pauseRunning = false;
rfmPar.stopRunning = rfmStimPar.stopRunning;
rfmPar.pauseRunning = rfmStimPar.stopRunning;
rfmStimPar.taskDone = false;

if rfmPar.useNSP
    cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,0);
end

%update the timer
try stop(rfmPar.stimTimer);end;



% --- Executes on button press in pushbutton_Run.
function pushbutton_Run_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar rfmWSCK rfmStimPar;
global hStatusBar; 

%generate folder info.
    folder = rfmPar.NSPDataFolder;
    folder.date = datestr(now,'yyyy-mmm-dd');
    folder.time = datestr(now,'HH-MM-SS');
    datafile = fullfile(folder.base,folder.subject,folder.exp,folder.date,...
        folder.time,rfmPar.NSPFileName);
    rfmPar.NSPDataFile = datafile;
    rfmPar.NSPDataFolder = folder;
    
    %set folder info in rfmStimPar to be sent over to mac
    rfmStimPar.NSPDataFolder = rfmPar.NSPDataFolder;
    
%send to server.    
if (~isempty(rfmWSCK))
    if (rfmWSCK.State==7)
        if (rfmStimPar.pauseRunning)
            rfmWSCK.SendData(['rfmStimPar.pauseRunning=false;' char(10)]);
            rfmStimPar.stopRunning = false;
            rfmStimPar.pauseRunning = false;
        else
            rfmStimPar.stopRunning = false;
            rfmStimPar.pauseRunning = false;
            rfmStimPar.block=0;
            disp(['Running ' rfmStimPar.currentTask '.m on server ...']);
            rfmWSCK.SendData([rfmStimPar.currentTask ';' char(10)]);
            pause(0.6);
            % Send all information stored in "rfmStimPar" structure
            fns=fieldnames(rfmStimPar);
            for i=1:length(fns)
                fn=fns{i};
                if (~isstruct(rfmStimPar.(fn)))
                    disp(['Sending ' fn ' ...']);
                    if (isnumeric(rfmStimPar.(fn))) | (islogical(rfmStimPar.(fn)))
                        if (length(rfmStimPar.(fn))>1) % The field is an array
                            rfmWSCK.SendData(['rfmStimPar.' fn '=[' num2str(rfmStimPar.(fn)) '];' char(10)]);
                        else        % The field is a single value
                            rfmWSCK.SendData(['rfmStimPar.' fn '=' num2str(rfmStimPar.(fn)) ';' char(10)]);
                        end;
                    else
                        rfmWSCK.SendData(['rfmStimPar.' fn '=''' rfmStimPar.(fn) ''';' char(10)]);
                    end;
                else
                    fnss=fieldnames(rfmStimPar.(fn));
                    for j=1:length(fnss)
                        fns1=fnss{j};
                        disp(['Sending ' fn '.' fns1 ' ...']);
                        if (isnumeric(rfmStimPar.(fn).(fns1))) | (islogical(rfmStimPar.(fn).(fns1)))
                            if (length(rfmStimPar.(fn).(fns1))>1) % The field is an array
                                rfmWSCK.SendData(['rfmStimPar.' fn '.' fns1 '=[' num2str(rfmStimPar.(fn).(fns1)) '];' char(10)]);
                            else        % The field is a single value
                                rfmWSCK.SendData(['rfmStimPar.' fn '.' fns1 '=' num2str(rfmStimPar.(fn).(fns1)) ';' char(10)]);
                            end;
                        else
                            rfmWSCK.SendData(['rfmStimPar.' fn '.' fns1 '=''' rfmStimPar.(fn).(fns1) ''';' char(10)]);
                        end;
                    end;
                end;
            end;
        end;
        set(hStatusBar,'String', ' Running...');
    end;
end;

if rfmPar.stopRunning
    %reset task flags
    rfmPar.taskLoaded = false;
    rfmPar.taskDone = false;
    
    %bring up the file-storage app only if not open.
    
    if rfmPar.useNSP
%         folder = rfmPar.NSPDataFolder;
%         datafile = fullfile(folder.base,folder.subject,folder.exp,folder.date,...
%                 folder.time,rfmPar.NSPDataFile);
            
        cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,0);
    end
    handles = mirrorDisplay(hObject,eventdata,handles);
    
else
    %resume from pause state and start the timer.
    try 
        start(rfmPar.stimTimer);
    end
end


function handles = mirrorDisplay(hObject,eventdata,handles)
%notify the rfmPlot window to mirror the display on remote host.
%handles = mirrorDisplay(handles);

global rfmPar rfmStimPar rfmWSCK;

%do some initialization, and then start the timer to update the stim.
hStimWindow = handles.StimWindow ;
set(gcf,'CurrentAxes',hStimWindow);

if ~isempty(rfmWSCK)
        %wait for the remote mac to notify the task has been loaded.
        while(~rfmStimPar.taskLoaded);
            %fprintf('taskLoaded ? %d\n',rfmStimPar.taskLoaded);
            pause(0.1);
        end
        
            
        %after taskLoaded, start recording on NSP
        if rfmPar.useNSP
            %bring up the file application in case it's not openned.
            %cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,0);
            %start recording after file-app openned.
            %update folder for new trial 
            cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,1);
            
        end
end

redrawScreen(hObject,eventdata,handles);

switch rfmStimPar.Stim.('Name')
    case 'Bar'
        %create the timer object to refresh the stimulus.
        stimTimer = timer('TimerFcn',{@flashStim},...
                'Period',((rfmStimPar.Stim.RefreshOnFrames+rfmStimPar.Stim.RefreshOffFrames) / rfmPar.ScrRefRate),...
                'ExecutionMode','fixedRate');
    case 'Grating'
        stimTimer = timer('TimerFcn',{@moveStim},...
                'Period',0.5,...
                'ExecutionMode','fixedRate');
end
            
rfmPar.stimTimer = stimTimer;            
                
start(rfmPar.stimTimer);

function redrawScreen(hObject,eventdata,handles)

global rfmPar rfmStimPar

redrawStim;
redrawRFB;

function moveStim(hObject,eventdata,handles)

global rfmPar rfmStimPar rfmWSCK;
global hStatusBar;

% % don't move the stimulus.
% % try %if hStim is not alive.
% %     isStimVisible = rfmStimPar.Stim.('Visible');
% %     isStimStatic = rfmStimPar.Stim.('Static');
% % 
% %     if isStimVisible && ~isStimStatic
% %         %move the stim obj --- loop through the image sequence.
% %         if strcmp(get(rfmPar.hStim,'Visible'),'on')
% %             imgIdx = get(rfmPar.hStim,'userdata');
% %             imgIdx = imgIdx + 1;
% %             if imgIdx > 4
% %                 imgIdx = 1;
% %             end
% %             set(rfmPar.hStim,'CData',rfmPar.StimImgs{imgIdx});
% %             set(rfmPar.hStim,'userdata',imgIdx);
% %             drawnow;
% %         else
% %             
% %         end
% %     end
% % 
% % end

if ~isempty(rfmWSCK)
        %check if taskLoaded off.
        if(rfmStimPar.taskDone)
            %stop the timer.
            stop(rfmPar.stimTimer);
            set(hStatusBar,'String','Stopped');
            rfmStimPar.stopRunning = true;
            rfmStimPar.pauseRunning = false;
            rfmPar.stopRunning = rfmStimPar.stopRunning;
            rfmPar.pauseRunning = rfmStimPar.stopRunning;
            rfmStimPar.taskDone = false;
            %stop recording
            if rfmPar.useNSP
                %cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,0);
                fprintf('Trial ends. Stop Cerebus Recording.\n');
                cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,0);
                %cbmex('trialconfig',0);
            end

        end
end


function flashStim(hObject,eventdata,handles)

global rfmPar rfmStimPar rfmWSCK;
global hStatusBar;
%
try %if hStim is not alive.
    isStimVisible = rfmStimPar.Stim.('Visible');
    isStimStatic = rfmStimPar.Stim.('Static');

    if isStimVisible && ~isStimStatic
        %flip the stim obj.
        if strcmp(get(rfmPar.hStim,'Visible'),'on')
            set(rfmPar.hStim,'Visible','off');
            drawnow;
        else
            set(rfmPar.hStim,'Visible','on');
            drawnow;
        end
    end

end

if ~isempty(rfmWSCK)
        %check if taskLoaded off.
        if(rfmStimPar.taskDone)
            %stop the timer.
            stop(rfmPar.stimTimer);
            set(hStatusBar,'String','Stopped');
            rfmStimPar.stopRunning = true;
            rfmStimPar.pauseRunning = false;
            rfmPar.stopRunning = rfmStimPar.stopRunning;
            rfmPar.pauseRunning = rfmStimPar.stopRunning;
            rfmStimPar.taskDone = false;
            if rfmPar.useNSP
                cbmex('fileconfig',rfmPar.NSPDataFile,rfmPar.NSPDataComm,0);
                %cbmex('trialconfig',0);
            end

        end
end


function redrawStim

global rfmPar rfmStimPar

if rfmPar.isStimChg %redraw stim matrix if parameters changed.
    
switch rfmStimPar.Stim.('Name')
    case 'Bar'
        vert = [0 0 0;
            0 1 0;
            1 1 0;
            1 0 0];
        %%shift vert center to (000)
        vert = vert - repmat([1/2 1/2 0],4,1); 
        scale = [rfmStimPar.Stim.('DimX')*2 rfmStimPar.Stim.('DimY')*2 1;
            rfmStimPar.Stim.('DimX')*2 rfmStimPar.Stim.('DimY')*2 1;
            rfmStimPar.Stim.('DimX')*2 rfmStimPar.Stim.('DimY')*2 1;
            rfmStimPar.Stim.('DimX')*2 rfmStimPar.Stim.('DimY')*2 1];
        %face = [ 1 2 3 4];
        stim = vert .* scale;
        stim = stim + repmat([rfmStimPar.Stim.('PosX') rfmStimPar.Stim.('PosY') 0],4,1); %shift to stim Center
        rfmPar.('StimObj') = stim;
        %handle to the stim obj.
        %delete the previous obj.
        try delete(rfmPar.hStim); end
        
        rfmPar.hStim = patch('Faces',[1 2 3 4],'Vertices',rfmPar.('StimObj'),...
           'FaceColor',rfmStimPar.Stim.('Color'));
       
        rotate(rfmPar.hStim,[0 0 1],rfmStimPar.Stim.('Orientation'),...
           [rfmStimPar.Stim.('PosX'),rfmStimPar.Stim.('PosY'),0]);
        
    case 'Grating'
        dim = [rfmStimPar.Stim.('DimX'),rfmStimPar.Stim.('DimY')]; 
        loc = [rfmStimPar.Stim.('PosX'),rfmStimPar.Stim.('PosY')];
        %number of cycles per pixel.
        sfp = rfmStimPar.Stim.('SpatialFreq')*...
            (atan((1*rfmStimPar.ScrPixSize)/rfmStimPar.ScrEyeDistance)*180/pi);
        phase = 0;
        %keep consistent with what's being used in actual grating stimulus.
        orient = (90+rfmStimPar.Stim.('Orientation'))*pi/180;
        for i = 1 : 4
            phase = phase + 2*pi/4;
            [x,y,gratingImg] = rfmDrawGrating(dim,loc,sfp,phase,orient);
            rfmPar.StimImgs{i} = gratingImg;
        end
        
        rfmPar.('StimObj') = rfmPar.StimImgs{1};
        
        try delete(rfmPar.hStim); end
        hold on;
        rfmPar.hStim = pcolor(x,y,rfmPar.('StimObj'));set(rfmPar.hStim,'Visible','off'); shading flat;colormap(bone);
        set(rfmPar.hStim,'userdata',1);
        %avoid flicker
        %set(rfmPar.hStim,'erasemode','xor');
        hold off;
        set(rfmPar.hStim,'Visible','on');
end

%reset rfmPar.isStimChg.
rfmPar.isStimChg = false;

else
    return;
end

function redrawRFB

global rfmPar

if rfmPar.isRFBChg %redraw RFB if parameters changed.
    i = rfmPar.ChID;
    %
    uobjX = [rfmPar.circleX rfmPar.vCrossX rfmPar.hCrossX -rfmPar.vCrossX -rfmPar.hCrossX];
    uobjY = [rfmPar.circleY rfmPar.vCrossY rfmPar.hCrossY -rfmPar.vCrossY -rfmPar.hCrossY];
    
    %scale
    x = rfmPar.ChSets{i}.('DimX')*uobjX;
    y = rfmPar.ChSets{i}.('DimY')*uobjY;
    %rotation
    t = 2*pi*rfmPar.ChSets{i}.('Orientation')/360;
    xr = cos(t)*x - sin(t)*y;
    yr = cos(t)*y + sin(t)*x;
    %translation
    xt = xr + rfmPar.ChSets{i}.('PosX');
    yt = yr + rfmPar.ChSets{i}.('PosY');
    %delete the previously drawn object.
    try
        delete(rfmPar.ChSets{i}.('hCircle'));
        delete(rfmPar.ChSets{i}.('hLabel'));
    end
    
    hold on;
    
    rfmPar.ChSets{i}.('hCircle') = plot(xt,yt,'-',...
            'Color',rfmPar.ChSets{i}.('Color'),'LineWidth',2,'Visible','on');
    
    [xmax,xp] = max(xt);
    xLabel = xmax;
    yLabel = yt(xp);
    
    rfmPar.ChSets{i}.('hLabel')= text(xLabel,yLabel,...
        ['\color[rgb]{',num2str(rfmPar.ChSets{i}.('Color')),'}',' \leftarrow ',num2str(rfmPar.ChSets{i}.('ChID'))],...
        'Visible','on');

    %turn off all circles first.
    for j = 1 : (rfmPar.ChTN+1)
       set(rfmPar.ChSets{j}.('hCircle'),'Visible','off');
       set(rfmPar.ChSets{j}.('hLabel'),'Visible','off');
    end
        
    %set visible to selected multi-ch RFB. skip if empty. 
    for j = 1 : length(rfmPar.rfbRange)
        if rfmPar.rfbRange(j) == i; continue; end;
       set(rfmPar.ChSets{rfmPar.rfbRange(j)}.('hCircle'),'Visible','on','LineStyle',':','LineWidth',1); 
       set(rfmPar.ChSets{rfmPar.rfbRange(j)}.('hLabel'),'Visible','on'); 
    end
    
    %set active circle on.
    set(rfmPar.ChSets{i}.('hCircle'),'Visible','on');
    set(rfmPar.ChSets{i}.('hLabel'),'Visible','on'); 
    
    hold off;
    
  %reset rfmPar.isStimChg
rfmPar.isRFBChg = false;

else
    return;
end
        
% --- Executes on selection change in listbox_Stimulus.
function listbox_Stimulus_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Stimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_Stimulus contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Stimulus


% --- Executes during object creation, after setting all properties.
function listbox_Stimulus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Stimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_StimulusList.
function popupmenu_StimulusList_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_StimulusList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_StimulusList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_StimulusList

global rfmPar rfmStimPar;

%copy the current stimPar to rfmPar before switching to new selection.
rfmPar.Stim{rfmPar.StimIdx} = rfmStimPar.Stim;

rfmPar.StimIdx = get(hObject,'Value');
actStimList = get(hObject,'String');
actStimName = actStimList{rfmPar.StimIdx};

%update the rfmStimPar
rfmStimPar.Stim = rfmPar.Stim{rfmPar.StimIdx};


switch actStimName
    case 'Bar'
        rfmPar.currentTask = 'rfmBar';
        
    case 'Grating'
        rfmPar.currentTask = 'rfmGrating';
end

rfmStimPar.currentTask = rfmPar.currentTask;

handles = rfmControl_updateGUI(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_StimulusList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_StimulusList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_rfbShow.
function pushbutton_rfbShow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar;

rfmPar.rfbRange = eval(['[',get(handles.edit_rfbRange,'String'),']']);

try
    %hide all first.
    if isempty(rfmPar.rfbRange)
        for i = 1 : rfmPar.ChTN+1
            if i == rfmPar.ChID; continue; end;
            rfmPar.ChSets{rfmPar.rfbRange(i)}.('Visible') = false;
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hCircle'),'Visible','off');
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hLabel'),'Visible','off');
        end
    else %show the ones in the list
        for i = 1 : length(rfmPar.rfbRange)
            rfmPar.ChSets{rfmPar.rfbRange(i)}.('Visible') = true;
            %set the drawed object visible
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hCircle'),'Visible','on');
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hLabel'),'Visible','on');
        end
    end
end

rfmPar.isRFBChg = true;
redrawScreen(hObject,eventdata,handles);

function edit_rfbRange_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbRange as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbRange as a double

%global rfmPar;

%rfmPar.rfbRange = eval(['[',get(hObject,'String'),']']);

% --- Executes during object creation, after setting all properties.
function edit_rfbRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rfbEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbEnd as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbEnd as a double


% --- Executes during object creation, after setting all properties.
function edit_rfbEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_chIDUp.
function pushbutton_chIDUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chIDUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar;

rfmPar.ChID = rfmPar.ChID + 1; 
if rfmPar.ChID > rfmPar.ChTN + 1
    rfmPar.ChID = 1; %roll back to 1
end
%set visible to active RFB.
rfmPar.ChSets{rfmPar.ChID}.('Visible')=true;
set(handles.edit_ChID,'String',rfmPar.ChID);
set(handles.checkbox_rfbVisible,'Value',rfmPar.ChSets{rfmPar.ChID}.('Visible'));
set(handles.checkbox_rfbTrackCursor,'Value',rfmPar.ChSets{rfmPar.ChID}.('TrackCursor'));

%update the parameter fields.
%simulate the popupmenu click action.
popupmenu_rfbParamsList1_Callback(handles.popupmenu_rfbParamsList1,eventdata,handles);
popupmenu_rfbParamsList2_Callback(handles.popupmenu_rfbParamsList2,eventdata,handles);

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_chIDDown.
function pushbutton_chIDDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chIDDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global rfmPar;

rfmPar.ChID = rfmPar.ChID - 1; 
if rfmPar.ChID == 0
    rfmPar.ChID = rfmPar.ChTN + 1; %roll back to max.
end

rfmPar.ChSets{rfmPar.ChID}.('Visible')=true;
set(handles.edit_ChID,'String',rfmPar.ChID);
set(handles.checkbox_rfbVisible,'Value',rfmPar.ChSets{rfmPar.ChID}.('Visible'));
set(handles.checkbox_rfbTrackCursor,'Value',rfmPar.ChSets{rfmPar.ChID}.('TrackCursor'));

%update the parameter fields.
%simulate the popupmenu click action.
popupmenu_rfbParamsList1_Callback(handles.popupmenu_rfbParamsList1,eventdata,handles);
popupmenu_rfbParamsList2_Callback(handles.popupmenu_rfbParamsList2,eventdata,handles);

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_Exit.
function pushbutton_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmStimPar; 

if ~rfmStimPar.stopRunning
    errordlg('Stop Stimulus Before Exit','Stimulus Still Running','modal');
else
    %close two handles.
    close(gcf);
    try delete(rfmPar.stimTimer); end;
    %save two rfmPar onto
    savedTime = datestr(now,'mmm-dd-yyyy_HH-MM-SS');
    savedPath = pwd;
    savedFile = fullfile(savedPath,'data',['rfm_',savedTime,'.mat']);
    %mkdir(fileparts(savedFile));
    %save(savedFile,'rfmPar','rfmStimPar');
    
end

try
    if rfmPar.useNSP
        rfmStimPar.endNSPTime=cbmex('time');
        cbmex('close');
    end
    
catch
    lasterr
end

try
    %rmpath(rfmPar.rfmPath);
catch
end


% --- Executes on selection change in popupmenu_rfbParamsList1.
function popupmenu_rfbParamsList1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_rfbParamsList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_rfbParamsList1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_rfbParamsList1

global rfmPar;

actObjIdx = get(hObject,'Value');
%update the StimParamsList1
valList = {'Val1','Val2'};
varList = {'Var1','Var2'};
varObjList = {'rfbDimPosVar1','rfbDimPosVar2'};
valObjList = {'rfbDimPosVal1','rfbDimPosVal2'};
nval = length(valList);

switch actObjIdx 
    case 1 % Dimension
        fn = {'DimX','DimY'};
    case 2
        fn = {'DimDX','DimDY'};
    case 3
        fn = {'PosX', 'PosY'};
    case 4
        fn = {'PosDX','PosDY'};
end

for i = 1 : nval
    rfmPar.rfbParamsList1{actObjIdx}.(valList{i}) = rfmPar.ChSets{rfmPar.ChID}.(fn{i});
    gObj = findobj('Tag',['edit_' varObjList{i}]);
    set(gObj,'String',rfmPar.rfbParamsList1{actObjIdx}.(varList{i}));
    gObj = findobj('Tag',['edit_' valObjList{i}]);
    set(gObj,'String',rfmPar.rfbParamsList1{actObjIdx}.(valList{i}));
end

% --- Executes during object creation, after setting all properties.
function popupmenu_rfbParamsList1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_rfbParamsList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_rfbVisible.
function checkbox_rfbVisible_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rfbVisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rfbVisible

global rfmPar
rfmPar.ChSets{rfmPar.ChID}.('Visible') = get(hObject,'Value');
rfmPar.isRFBChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in checkbox_rfbTrackCursor.
function checkbox_rfbTrackCursor_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rfbTrackCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rfbTrackCursor



function edit_rfbDimPosVar1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbDimPosVar1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbDimPosVar1 as a double


% --- Executes during object creation, after setting all properties.
function edit_rfbDimPosVar1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rfbDimPosVal1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbDimPosVal1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbDimPosVal1 as a double

global rfmPar;

actObjIdx = get(handles.popupmenu_rfbParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimX'; 
    case 2 %Dim Stepsize
        fn = 'DimDX';
    case 3 %Position
        fn = 'PosX'; 
    case 4 %Pos Stepsize
        fn = 'PosDX';
end

rfmPar.ChSets{rfmPar.ChID}.(fn) = str2num(get(hObject,'String'));

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit_rfbDimPosVal1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rfbDimPosVar2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbDimPosVar2 as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbDimPosVar2 as a double


% --- Executes during object creation, after setting all properties.
function edit_rfbDimPosVar2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rfbDimPosVal2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbDimPosVal2 as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbDimPosVal2 as a double

global rfmPar;

actObjIdx = get(handles.popupmenu_rfbParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimY'; 
    case 2 %Dim Stepsize
        fn = 'DimDY';
    case 3 %Position
        fn = 'PosY';
    case 4 %Pos Stepsize
        fn = 'PosDY';
end

rfmPar.ChSets{rfmPar.ChID}.(fn) = str2num(get(hObject,'String'));

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function edit_rfbDimPosVal2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbDimPosVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_rfbDimPosVal1Inc.
function pushbutton_rfbDimPosVal1Inc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbDimPosVal1Inc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar ;

actObjIdx = get(handles.popupmenu_rfbParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimX';  dfn = 'DimDX';
        fnS = 'DimY'; dfnS = 'DimDY';
        
    case 2 %Dim Stepsize
        fn = 'DimDX';  dfn = 'constStepSize';
        fnS = 'DimDY'; dfnS = dfn;
        
    case 3 %Position
        fn = 'PosX';   dfn = 'PosDX';
        fnS= 'PosY';   dfnS= 'PosDY';
    case 4 %Pos Stepsize
        fn = 'PosDX';  dfn = 'constStepSize';
        fnS = 'PosDY'; dfnS = dfn;
        
end

if ~rfmPar.rfbDimPosValChgSyn
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) + rfmPar.ChSets{rfmPar.ChID}.(dfn);
    set(handles.edit_rfbDimPosVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    %sendTCPIPData(fn);
else
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) + rfmPar.ChSets{rfmPar.ChID}.(dfn);
    set(handles.edit_rfbDimPosVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    rfmPar.ChSets{rfmPar.ChID}.(fnS) = rfmPar.ChSets{rfmPar.ChID}.(fnS) + rfmPar.ChSets{rfmPar.ChID}.(dfnS);
    set(handles.edit_rfbDimPosVal2,'String',rfmPar.ChSets{rfmPar.ChID}.(fnS));
%     fn0 = {fn,fnS};
%     sendTCPIPData(fn0);
end

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_rfbDimPosVal1Dec.
function pushbutton_rfbDimPosVal1Dec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbDimPosVal1Dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar ;

actObjIdx = get(handles.popupmenu_rfbParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimX';  dfn = 'DimDX';
        fnS = 'DimY'; dfnS = 'DimDY';
     
    case 2 %Dim Stepsize
        fn = 'DimDX';  dfn = 'constStepSize';
        fnS = 'DimDY'; dfnS = dfn;
        
    case 3 %Position
        fn = 'PosX';   dfn = 'PosDX';
        fnS= 'PosY';   dfnS= 'PosDY';
  
    case 4 %Pos Stepsize
        fn = 'PosDX';  dfn = 'constStepSize';
        fnS = 'PosDY'; dfnS = dfn;
        
end

if ~rfmPar.rfbDimPosValChgSyn
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) - rfmPar.ChSets{rfmPar.ChID}.(dfn);
    rfmPar.ChSets{rfmPar.ChID}.(fn) = max(rfmPar.ChSets{rfmPar.ChID}.(fn),rfmPar.ChSets{rfmPar.ChID}.(dfn));
    set(handles.edit_rfbDimPosVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    %sendTCPIPData(fn);
else
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) - rfmPar.ChSets{rfmPar.ChID}.(dfn);
    rfmPar.ChSets{rfmPar.ChID}.(fn) = max(rfmPar.ChSets{rfmPar.ChID}.(fn),rfmPar.ChSets{rfmPar.ChID}.(dfn));
    set(handles.edit_rfbDimPosVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    rfmPar.ChSets{rfmPar.ChID}.(fnS) = rfmPar.ChSets{rfmPar.ChID}.(fnS) - rfmPar.ChSets{rfmPar.ChID}.(dfnS);
    rfmPar.ChSets{rfmPar.ChID}.(fnS) = max(rfmPar.ChSets{rfmPar.ChID}.(fnS),rfmPar.ChSets{rfmPar.ChID}.(dfnS));
    set(handles.edit_rfbDimPosVal2,'String',rfmPar.ChSets{rfmPar.ChID}.(fnS));
%     fn0 = {fn,fnS};
%     sendTCPIPData(fn0);
end

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_rfbDimPosVal2Dec.
function pushbutton_rfbDimPosVal2Dec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbDimPosVal2Dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar ;

actObjIdx = get(handles.popupmenu_rfbParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimY';  dfn = 'DimDY';
        fnS = 'DimX'; dfnS = 'DimDX';
    case 2 %Dim Stepsize
        fn = 'DimDY';  dfn = 'constStepSize';
        fnS = 'DimDX'; dfnS = dfn;    
    case 3 %Position
        fn = 'PosY';   dfn = 'PosDY';
        fnS= 'PosX';   dfnS= 'PosDX';
    case 4 %Pos Stepsize
        fn = 'PosDY';  dfn = 'constStepSize';
        fnS = 'PosDX'; dfnS = dfn;
        
end

if ~rfmPar.rfbDimPosValChgSyn
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) - rfmPar.ChSets{rfmPar.ChID}.(dfn);
    rfmPar.ChSets{rfmPar.ChID}.(fn) = max(rfmPar.ChSets{rfmPar.ChID}.(fn),rfmPar.ChSets{rfmPar.ChID}.(dfn));
    set(handles.edit_rfbDimPosVal2,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    %sendTCPIPData(fn);
else
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) - rfmPar.ChSets{rfmPar.ChID}.(dfn);
    rfmPar.ChSets{rfmPar.ChID}.(fn) = max(rfmPar.ChSets{rfmPar.ChID}.(fn),rfmPar.ChSets{rfmPar.ChID}.(dfn));
    set(handles.edit_rfbDimPosVal2,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    rfmPar.ChSets{rfmPar.ChID}.(fnS) = rfmPar.ChSets{rfmPar.ChID}.(fnS) - rfmPar.ChSets{rfmPar.ChID}.(dfnS);
    rfmPar.ChSets{rfmPar.ChID}.(fnS) = max(rfmPar.ChSets{rfmPar.ChID}.(fnS),rfmPar.ChSets{rfmPar.ChID}.(dfnS));
    set(handles.edit_rfbDimPosVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fnS));
%     fn0 = {fn,fnS};
%     sendTCPIPData(fn0);
end

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_rfbDimPosVal2Inc.
function pushbutton_rfbDimPosVal2Inc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbDimPosVal2Inc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar ;

actObjIdx = get(handles.popupmenu_rfbParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimY';  dfn = 'DimDY';
        fnS = 'DimX'; dfnS = 'DimDX';
        
    case 2 %Dim Stepsize
        fn = 'DimDY';  dfn = 'constStepSize';
        fnS = 'DimDX'; dfnS = dfn;
        
    case 3 %Position
        fn = 'PosY';   dfn = 'PosDY';
        fnS= 'PosX';   dfnS= 'PosDX';
    case 4 %Pos Stepsize
        fn = 'PosDY';  dfn = 'constStepSize';
        fnS = 'PosDX'; dfnS = dfn;
        
end

if ~rfmPar.rfbDimPosValChgSyn
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) + rfmPar.ChSets{rfmPar.ChID}.(dfn);
%    rfmPar.ChSets{rfmPar.ChID}.(fn) = max(rfmPar.ChSets{rfmPar.ChID}.(fn),rfmPar.ChSets{rfmPar.ChID}.(dfn));
    set(handles.edit_rfbDimPosVal2,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    %sendTCPIPData(fn);
else
    rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) + rfmPar.ChSets{rfmPar.ChID}.(dfn);
%    rfmPar.ChSets{rfmPar.ChID}.(fn) = max(rfmPar.ChSets{rfmPar.ChID}.(fn),rfmPar.ChSets{rfmPar.ChID}.(dfn));
    set(handles.edit_rfbDimPosVal2,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));
    rfmPar.ChSets{rfmPar.ChID}.(fnS) = rfmPar.ChSets{rfmPar.ChID}.(fnS) + rfmPar.ChSets{rfmPar.ChID}.(dfnS);
%    rfmPar.ChSets{rfmPar.ChID}.(fnS) = max(rfmPar.ChSets{rfmPar.ChID}.(fnS),rfmPar.ChSets{rfmPar.ChID}.(dfnS));
    set(handles.edit_rfbDimPosVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fnS));
%     fn0 = {fn,fnS};
%     sendTCPIPData(fn0);
end

rfmPar.isRFBChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in checkbox_rfbDimPosValChgSyn.
function checkbox_rfbDimPosValChgSyn_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rfbDimPosValChgSyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rfbDimPosValChgSyn
global rfmPar;
rfmPar.rfbDimPosValChgSyn = get(hObject,'Value');


% --- Executes on selection change in popupmenu_rfbParamsList2.
function popupmenu_rfbParamsList2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_rfbParamsList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_rfbParamsList2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_rfbParamsList2

global rfmPar rfmStimPar;

actObjIdx = get(hObject,'Value');
%update the StimParamsList1
valList = {'Val1'};
varList = {'Var1'};
varObjList = {'rfbPVar1'};
valObjList = {'rfbPVal1'};
nval = length(valList);

switch actObjIdx 
    case 1 % Orientation
        fn = {'Orientation'};
    case 2
        fn = {'OrientationStepSize'};
    
end

for i = 1 : nval
    rfmPar.rfbParamsList2{actObjIdx}.(valList{i}) = rfmPar.ChSets{rfmPar.ChID}.(fn{i});
    gObj = findobj('Tag',['edit_' varObjList{i}]);
    set(gObj,'String',rfmPar.rfbParamsList2{actObjIdx}.(varList{i}));
    gObj = findobj('Tag',['edit_' valObjList{i}]);
    set(gObj,'String',rfmPar.rfbParamsList2{actObjIdx}.(valList{i}));
end

% --- Executes during object creation, after setting all properties.
function popupmenu_rfbParamsList2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_rfbParamsList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rfbPVar1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbPVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbPVar1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbPVar1 as a double


% --- Executes during object creation, after setting all properties.
function edit_rfbPVar1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbPVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rfbPVal1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbPVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbPVal1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbPVal1 as a double

global rfmPar;

actObjIdx = get(handles.popupmenu_rfbParamsList2,'Value');
switch actObjIdx
    case 1 %Orientation
        fn = 'Orientation'; 
    case 2 %O.Stepsize
        fn = 'OrientationStepSize'; 
    
end

rfmPar.ChSets{rfmPar.ChID}.(fn) = str2num(get(hObject,'String'));

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function edit_rfbPVal1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbPVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_rfbPValInc.
function pushbutton_rfbPValInc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbPValInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar ;

actObjIdx = get(handles.popupmenu_rfbParamsList2,'Value');
switch actObjIdx
    case 1 %Orientation
        fn = 'Orientation';  dfn = 'OrientationStepSize';
        
    case 2 %Orientation Stepsize
        fn = 'OrientationStepSize'; dfn = 'constStepSize';
end


rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) + rfmPar.ChSets{rfmPar.ChID}.(dfn);
set(handles.edit_rfbPVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));

rfmPar.isRFBChg = true;

% --- Executes on button press in pushbutton_rfbPValDec.
function pushbutton_rfbPValDec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbPValDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar ;

actObjIdx = get(handles.popupmenu_rfbParamsList2,'Value');
switch actObjIdx
    case 1 %Orientation
        fn = 'Orientation';  dfn = 'OrientationStepSize';
        
    case 2 %Orientation Stepsize
        fn = 'OrientationStepSize'; dfn = 'constStepSize';
end

rfmPar.ChSets{rfmPar.ChID}.(fn) = rfmPar.ChSets{rfmPar.ChID}.(fn) - rfmPar.ChSets{rfmPar.ChID}.(dfn);
set(handles.edit_rfbPVal1,'String',rfmPar.ChSets{rfmPar.ChID}.(fn));

rfmPar.isRFBChg = true;



function edit_ChID_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ChID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ChID as text
%        str2double(get(hObject,'String')) returns contents of edit_ChID as a double

global rfmPar;

rfmPar.ChID = str2num(get(hObject,'String'));
%update the display
rfmPar.ChSets{rfmPar.ChID}.('Visible') = true;
set(handles.checkbox_rfbVisible,'Value',rfmPar.ChSets{rfmPar.ChID}.('Visible'));
set(handles.checkbox_rfbTrackCursor,'Value',rfmPar.ChSets{rfmPar.ChID}.('TrackCursor'));
%update the parameter fields.
%simulate the popupmenu click action.
popupmenu_rfbParamsList1_Callback(handles.popupmenu_rfbParamsList1,eventdata,handles);
popupmenu_rfbParamsList2_Callback(handles.popupmenu_rfbParamsList2,eventdata,handles);

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit_ChID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ChID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_rfbHide.
function pushbutton_rfbHide_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rfbHide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar;

rfmPar.rfbRange = eval(['[',get(handles.edit_rfbRange,'String'),']']);

try
    %hide all first.
    if isempty(rfmPar.rfbRange)
        for i = 1 : rfmPar.ChTN+1
            if i == rfmPar.ChID; continue; end;
            rfmPar.ChSets{rfmPar.rfbRange(i)}.('Visible') = false;
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hCircle'),'Visible','off');
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hLabel'),'Visible','off');
        end
    else %show the ones in the list
        for i = 1 : length(rfmPar.rfbRange)
            rfmPar.ChSets{rfmPar.rfbRange(i)}.('Visible') = false;
            %set the drawed object visible
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hCircle'),'Visible','off');
            set(rfmPar.ChSets{rfmPar.rfbRange(i)}.('hLabel'),'Visible','off');
        end
    end
end

rfmPar.isRFBChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_CoCenterStim.
function pushbutton_CoCenterStim_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CoCenterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%move the center of the active RFB to the stim center.

global rfmPar rfmStimPar;

rfmPar.ChSets{rfmPar.ChID}.('PosX') = rfmStimPar.Stim.('PosX');
rfmPar.ChSets{rfmPar.ChID}.('PosY') = rfmStimPar.Stim.('PosY');

rfmPar.isRFBChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in checkbox_StimStatic.
function checkbox_StimStatic_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_StimStatic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_StimStatic
global rfmPar rfmStimPar;

fn = 'Static';
rfmStimPar.Stim.(fn) = get(hObject,'Value');

sendTCPIPData(fn);

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in checkbox_StimTrackCursor.
function checkbox_StimTrackCursor_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_StimTrackCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_StimTrackCursor
global rfmPar rfmStimPar;

fn = 'TrackCursor';
rfmStimPar.Stim.(fn) = get(hObject,'Value');

sendTCPIPData(fn);

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);


% --- Executes on button press in checkbox_StimCoCenterRFB.
function checkbox_StimCoCenterRFB_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_StimCoCenterRFB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_StimCoCenterRFB
global rfmPar rfmStimPar;

rfmStimPar.Stim.('CoCenterRFB')= get(hObject,'Value');


% --- Executes on button press in pushbutton_CoCenterRFB.
function pushbutton_CoCenterRFB_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CoCenterRFB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%move the stim center to the RFB.
global rfmPar rfmStimPar;

rfmStimPar.Stim.('PosX') = rfmPar.ChSets{rfmPar.ChID}.('PosX');
rfmStimPar.Stim.('PosY') = rfmPar.ChSets{rfmPar.ChID}.('PosY');

%update remote host
sendTCPIPData({'PosX','PosY'});

rfmPar.isStimChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_StimShow.
function pushbutton_StimShow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar rfmStimPar;

rfmStimPar.Stim.('Visible')= true;

% --- Executes on button press in pushbutton_StimHide.
function pushbutton_StimHide_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimHide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar rfmStimPar;

rfmStimPar.Stim.('Visible')= false;

% --- Executes on selection change in popupmenu_StimParamsList1.
function popupmenu_StimParamsList1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_StimParamsList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_StimParamsList1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_StimParamsList1

global rfmPar rfmStimPar;

actObjIdx = get(hObject,'Value');
%update the StimParamsList1
valList = {'Val1','Val2'};
varList = {'Var1','Var2'};
varObjList = {'StimDimPosVar1','StimDimPosVar2'};
valObjList = {'StimDimPosVal1','StimDimPosVal2'};
nval = length(valList);

switch actObjIdx 
    case 1 % Dimension
        fn = {'DimX','DimY'};
    case 2
        fn = {'DimDX','DimDY'};
    case 3
        fn = {'PosX', 'PosY'};
    case 4
        fn = {'PosDX','PosDY'};
end

for i = 1 : nval
    rfmPar.StimParamsList1{actObjIdx}.(valList{i}) = rfmStimPar.Stim.(fn{i});
    gObj = findobj('Tag',['edit_' varObjList{i}]);
    set(gObj,'String',rfmPar.StimParamsList1{actObjIdx}.(varList{i}));
    gObj = findobj('Tag',['edit_' valObjList{i}]);
    set(gObj,'String',rfmPar.StimParamsList1{actObjIdx}.(valList{i}));
end
        
        

% --- Executes during object creation, after setting all properties.
function popupmenu_StimParamsList1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_StimParamsList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_StimParamsList2.
function popupmenu_StimParamsList2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_StimParamsList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_StimParamsList2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_StimParamsList2
global rfmPar rfmStimPar;

actObjIdx = get(hObject,'Value');
%update the StimParamsList1
valList = {'Val1'};
varList = {'Var1'};
varObjList = {'StimPVar1'};
valObjList = {'StimPVal1'};
nval = length(valList);

switch actObjIdx 
    case 1 % Orientation
        fn = {'Orientation'};
    case 2
        fn = {'OrientationStepSize'};
    case 3 %refresh frames -- number of frames white/black stim stays on.
        fn = {'RefreshOnFrames'};
    case 4
        fn = {'RefreshOnFramesStepSize'};
    case 5 %refresh frames -- number of frames white/black stim stays on.
        fn = {'RefreshOffFrames'};
    case 6
        fn = {'RefreshOffFramesStepSize'};
    case 7
        fn = {'TrialDuration'}; 
    case 8
        fn = {'TrialDurationStepSize'}; 
    case 9
        fn = {'TrialRepetition'}; 
    case 10
        fn = {'TrialRepetitionStepSize'}; 
    case 11
        fn = {'InterTrialDuration'}; 
    case 12
        fn = {'InterTrialDurationStepSize'}; 
    case 13
        fn = {'SpatialFreq'};
    case 14
        fn = {'SpatialFreqStepSize'};
    case 15
        fn = {'TempoFreq'};
    case 16
        fn = {'TempoFreqStepSize'};
    
end

for i = 1 : nval
    rfmPar.StimParamsList2{actObjIdx}.(valList{i}) = rfmStimPar.Stim.(fn{i});
    gObj = findobj('Tag',['edit_' varObjList{i}]);
    set(gObj,'String',rfmPar.StimParamsList2{actObjIdx}.(varList{i}));
    gObj = findobj('Tag',['edit_' valObjList{i}]);
    set(gObj,'String',rfmPar.StimParamsList2{actObjIdx}.(valList{i}));
end

set(handles.checkbox_measureTC,'Value',false);

if any ((actObjIdx == [1,11,13]) & (rfmStimPar.mtcType == [1,2,3]))
    set(handles.checkbox_measureTC,'Value',rfmStimPar.measureTC);
end

set(handles.edit_mtcStart,'String',rfmStimPar.mtcStart);
set(handles.edit_mtcStepsize,'String',rfmStimPar.mtcStepsize);
set(handles.edit_mtcEnd,'String',rfmStimPar.mtcEnd);


% --- Executes during object creation, after setting all properties.
function popupmenu_StimParamsList2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_StimParamsList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimDimPosVal1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimDimPosVal1 as text
%        str2double(get(hObject,'String')) returns contents of edit_StimDimPosVal1 as a double
global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimX'; 
    case 2 %Dim Stepsize
        fn = 'DimDX';    
    case 3 %Position
        fn = 'PosX'; 
    case 4 %Pos Stepsize
        fn = 'PosDX';
end

rfmStimPar.Stim.(fn) = str2num(get(hObject,'String'));
sendTCPIPData(fn);

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit_StimDimPosVal1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimDimPosVar2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimDimPosVar2 as text
%        str2double(get(hObject,'String')) returns contents of edit_StimDimPosVar2 as a double


% --- Executes during object creation, after setting all properties.
function edit_StimDimPosVar2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimDimPosVal2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimDimPosVal2 as text
%        str2double(get(hObject,'String')) returns contents of edit_StimDimPosVal2 as a double


global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimY'; 
    case 2 %Dim Stepsize
        fn = 'DimDY';
    case 3 %Position
        fn = 'PosY'; 
    case 4 %Pos Stepsize
        fn = 'PosDY';
end

rfmStimPar.Stim.(fn) = str2num(get(hObject,'String'));
sendTCPIPData(fn);

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit_StimDimPosVal2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%send params to server.
function sendTCPIPData(fieldName)

global rfmWSCK;
global rfmStimPar; %need to retrieve value from rfmStimPar.

if iscell(fieldName) %cell array of strings.
    s = length(fieldName); %length of cell string.
else %single string.
    if ischar(fieldName)
        fieldName = { fieldName };
        s = 1;
    end
end
if (~isempty(rfmWSCK))
    try
       
        for i = 1 : s
           fn = fieldName{i};
           rfmWSCK.SendData(['rfmStimPar.Stim.' fn '=' num2str(eval(['rfmStimPar.Stim.' fn])) ';']);
        end
          rfmWSCK.SendData(char(10));
    end
end

%callback to changes in the dim/pos/orientation fields.
function updateGuiObject(hObject,fieldName,handles)

global rfmPar rfmStimPar;


% --- Executes on button press in pushbutton_StimDPVal1Inc.
function pushbutton_StimDPVal1Inc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimDPVal1Inc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimX';  dfn = 'DimDX';
        fnS = 'DimY'; dfnS = 'DimDY';
    case 2 %Dim Stepsize
        fn = 'DimDX';  dfn = 'constStepSize';
        fnS = 'DimDY'; dfnS = dfn;    
    case 3 %Position
        fn = 'PosX';   dfn = 'PosDX';
        fnS= 'PosY';   dfnS= 'PosDY';
    
    case 4 %Pos Stepsize
        fn = 'PosDX';  dfn = 'constStepSize';
        fnS = 'PosDY'; dfnS = dfn;
        
end

if ~rfmPar.StimDimPosValChgSyn
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) + rfmStimPar.Stim.(dfn);
    set(handles.edit_StimDimPosVal1,'String',rfmStimPar.Stim.(fn));
    sendTCPIPData(fn);
else
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) + rfmStimPar.Stim.(dfn);
    set(handles.edit_StimDimPosVal1,'String',rfmStimPar.Stim.(fn));
    rfmStimPar.Stim.(fnS) = rfmStimPar.Stim.(fnS) + rfmStimPar.Stim.(dfnS);
    set(handles.edit_StimDimPosVal2,'String',rfmStimPar.Stim.(fnS));
    fn0 = {fn,fnS};
    sendTCPIPData(fn0);
end

rfmPar.isStimChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_StimDPVal1Dec.
function pushbutton_StimDPVal1Dec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimDPVal1Dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimX';  dfn = 'DimDX';
        fnS = 'DimY'; dfnS = 'DimDY';
    case 2 %Dim Stepsize
        fn = 'DimDX';  dfn = 'constStepSize';
        fnS = 'DimDY'; dfnS = dfn;    
    case 3 %Position
        fn = 'PosX';   dfn = 'PosDX';
        fnS= 'PosY';   dfnS= 'PosDY';
    
    case 4 %Pos Stepsize
        fn = 'PosDX';  dfn = 'constStepSize';
        fnS = 'PosDY'; dfnS = dfn;
        
end

if ~rfmPar.StimDimPosValChgSyn
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) - rfmStimPar.Stim.(dfn);
    rfmStimPar.Stim.(fn) = max(rfmStimPar.Stim.(fn), rfmStimPar.Stim.(dfn));
    set(handles.edit_StimDimPosVal1,'String',rfmStimPar.Stim.(fn));
    sendTCPIPData(fn);
else
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) - rfmStimPar.Stim.(dfn);
    rfmStimPar.Stim.(fn) = max(rfmStimPar.Stim.(fn), rfmStimPar.Stim.(dfn));
    set(handles.edit_StimDimPosVal1,'String',rfmStimPar.Stim.(fn));
    
    rfmStimPar.Stim.(fnS) = rfmStimPar.Stim.(fnS) - rfmStimPar.Stim.(dfnS);
    rfmStimPar.Stim.(fnS) = max(rfmStimPar.Stim.(fnS), rfmStimPar.Stim.(dfnS));
    set(handles.edit_StimDimPosVal2,'String',rfmStimPar.Stim.(fnS));
    fn0 = {fn,fnS};
    sendTCPIPData(fn0);
end

rfmPar.isStimChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_StimDPVal2Dec.
function pushbutton_StimDPVal2Dec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimDPVal2Dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimY';  dfn = 'DimDY';
        fnS = 'DimX'; dfnS = 'DimDX';
    case 2 %Dim Stepsize
        fn = 'DimDY';  dfn = 'constStepSize';
        fnS = 'DimDX'; dfnS = dfn;    
    case 3 %Position
        fn = 'PosY';   dfn = 'PosDY';
        fnS= 'PosX';   dfnS= 'PosDX';
    
    case 4 %Pos Stepsize
        fn = 'PosDY';  dfn = 'constStepSize';
        fnS = 'PosDX'; dfnS = dfn;
        
end

if ~rfmPar.StimDimPosValChgSyn
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) - rfmStimPar.Stim.(dfn);
    rfmStimPar.Stim.(fn) = max(rfmStimPar.Stim.(fn), rfmStimPar.Stim.(dfn));
    set(handles.edit_StimDimPosVal2,'String',rfmStimPar.Stim.(fn));
    sendTCPIPData(fn);
else
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) - rfmStimPar.Stim.(dfn);
    rfmStimPar.Stim.(fn) = max(rfmStimPar.Stim.(fn), rfmStimPar.Stim.(dfn));
    set(handles.edit_StimDimPosVal2,'String',rfmStimPar.Stim.(fn));
    
    rfmStimPar.Stim.(fnS) = rfmStimPar.Stim.(fnS) - rfmStimPar.Stim.(dfnS);
    rfmStimPar.Stim.(fnS) = max(rfmStimPar.Stim.(fnS), rfmStimPar.Stim.(dfnS));
    set(handles.edit_StimDimPosVal1,'String',rfmStimPar.Stim.(fnS));
    fn0 = {fn,fnS};
    sendTCPIPData(fn0);
end

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_StimDPVal2Inc.
function pushbutton_StimDPVal2Inc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimDPVal2Inc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList1,'Value');
switch actObjIdx
    case 1 %Dimension
        fn = 'DimY';  dfn = 'DimDY';
        fnS = 'DimX'; dfnS = 'DimDX';
    case 2 %Dim Stepsize
        fn = 'DimDY';  dfn = 'constStepSize';
        fnS = 'DimDX'; dfnS = dfn;    
    case 3 %Position
        fn = 'PosY';   dfn = 'PosDY';
        fnS= 'PosX';   dfnS= 'PosDX';
    
    case 4 %Pos Stepsize
        fn = 'PosDY';  dfn = 'constStepSize';
        fnS = 'PosDX'; dfnS = dfn;
        
end

if ~rfmPar.StimDimPosValChgSyn
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) + rfmStimPar.Stim.(dfn);
%    rfmStimPar.Stim.(fn) = max(rfmStimPar.Stim.(fn), rfmStimPar.Stim.(dfn));
    set(handles.edit_StimDimPosVal2,'String',rfmStimPar.Stim.(fn));
    sendTCPIPData(fn);
else
    rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) + rfmStimPar.Stim.(dfn);
%    rfmStimPar.Stim.(fn) = max(rfmStimPar.Stim.(fn), rfmStimPar.Stim.(dfn));
    set(handles.edit_StimDimPosVal2,'String',rfmStimPar.Stim.(fn));
    
    rfmStimPar.Stim.(fnS) = rfmStimPar.Stim.(fnS) + rfmStimPar.Stim.(dfnS);
%    rfmStimPar.Stim.(fnS) = max(rfmStimPar.Stim.(fnS), rfmStimPar.Stim.(dfnS));
    set(handles.edit_StimDimPosVal1,'String',rfmStimPar.Stim.(fnS));
    fn0 = {fn,fnS};
    sendTCPIPData(fn0);
end

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in checkbox_StimDimPosValChgSyn.
function checkbox_StimDimPosValChgSyn_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_StimDimPosValChgSyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_StimDimPosValChgSyn
global rfmPar;
rfmPar.StimDimPosValChgSyn = get(hObject,'Value');

function edit_StimDimPosVar1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimDimPosVar1 as text
%        str2double(get(hObject,'String')) returns contents of edit_StimDimPosVar1 as a double


% --- Executes during object creation, after setting all properties.
function edit_StimDimPosVar1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimDimPosVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimPVar1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimPVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimPVar1 as text
%        str2double(get(hObject,'String')) returns contents of edit_StimPVar1 as a double


% --- Executes during object creation, after setting all properties.
function edit_StimPVar1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimPVar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimPVal1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimPVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimPVal1 as text
%        str2double(get(hObject,'String')) returns contents of edit_StimPVal1 as a double

global rfmPar rfmStimPar;

actObjIdx = get(handles.popupmenu_StimParamsList2,'Value');
switch actObjIdx
    case 1 %Orientation
        fn = 'Orientation'; 
    case 2 %O.Stepsize
        fn = 'OrientationStepSize';
    case 3 %refresh frames -- number of frames white/black stim stays on.
        fn = 'RefreshOnFrames';
    case 4
        fn = 'RefreshOnFramesStepSize';
    case 5 %refresh frames -- number of frames white/black stim stays on.
        fn = 'RefreshOffFrames';
    case 6
        fn = 'RefreshOffFramesStepSize';
    case 7
        fn = 'TrialDuration'; dfn = 'TrialDurationStepSize';
    case 8
        fn = 'TrialDurationStepSize'; dfn = 'constStepSize';
    case 9
        fn = 'TrialRepetition'; dfn = 'TrialRepetitionStepSize';
    case 10
        fn = 'TrialRepetitionStepSize'; dfn = 'constStepSize';
    case 11
        fn = 'InterTrialDuration'; dfn = 'InterTrialDurationStepSize';
    case 12
        fn = 'InterTrialDurationStepSize'; dfn = 'constStepSize';
    case 13
        fn = 'SpatialFreq'; dfn = 'SpatialFreqStepSize';
    case 14
        fn = 'SpatialFreqStepSize'; dfn = 'constStepSize';
    case 15
        fn = 'TempoFreq'; dfn = 'TempoFreqStepSize';
    case 16
        fn = 'TempoFreqStepSize'; dfn = 'constStepSize';
    
end

%eval the string. --- orient/freq may be set in a list.
%rfmStimPar.Stim.(fn) = str2num(get(hObject,'String'));
%if  fn== 1 || fn == 11 || fn == 13
    rfmStimPar.Stim.(fn) = eval(get(hObject,'String'));
%end
sendTCPIPData(fn);

rfmPar.isStimChg = true;
redrawScreen(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit_StimPVal1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimPVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_StimPValInc.
function pushbutton_StimPValInc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimPValInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList2,'Value');
switch actObjIdx
    case 1 %Orientation
        fn = 'Orientation';  dfn = 'OrientationStepSize';
        
    case 2 %Orientation Stepsize
        fn = 'OrientationStepSize'; dfn = 'constStepSize';
    case 3 %refresh frames -- number of frames white/black stim stays on.
        fn = 'RefreshOnFrames'; dfn = 'RefreshOnFramesStepSize';
    case 4
        fn = 'RefreshOnFramesStepSize'; dfn = 'constStepSize';
    case 5 %refresh frames -- number of frames white/black stim stays on.
        fn = 'RefreshOffFrames'; dfn = 'RefreshOffFramesStepSize';
    case 6
        fn = 'RefreshOffFramesStepSize'; dfn = 'constStepSize';
    case 7
        fn = 'TrialDuration'; dfn = 'TrialDurationStepSize';
    case 8
        fn = 'TrialDurationStepSize'; dfn = 'constStepSize';
    case 9
        fn = 'TrialRepetition'; dfn = 'TrialRepetitionStepSize';
    case 10
        fn = 'TrialRepetitionStepSize'; dfn = 'constStepSize';
    case 11
        fn = 'InterTrialDuration'; dfn = 'InterTrialDurationStepSize';
    case 12
        fn = 'InterTrialDurationStepSize'; dfn = 'constStepSize';   
        case 13
        fn = 'SpatialFreq'; dfn = 'SpatialFreqStepSize';
    case 14
        fn = 'SpatialFreqStepSize'; dfn = 'constStepSize';
    case 15
        fn = 'TempoFreq'; dfn = 'TempoFreqStepSize';
    case 16
        fn = 'TempoFreqStepSize'; dfn = 'constStepSize';
end

rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) + rfmStimPar.Stim.(dfn);
set(handles.edit_StimPVal1,'String',rfmStimPar.Stim.(fn));
sendTCPIPData(fn);

rfmPar.isStimChg = true;

redrawScreen(hObject,eventdata,handles);

% --- Executes on button press in pushbutton_StimPValDec.
function pushbutton_StimPValDec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimPValDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar rfmStimPar ;

actObjIdx = get(handles.popupmenu_StimParamsList2,'Value');
switch actObjIdx
    case 1 %Orientation
        fn = 'Orientation';  dfn = 'OrientationStepSize';
        
    case 2 %Orientation Stepsize
        fn = 'OrientationStepSize'; dfn = 'constStepSize';
    case 3 %refresh frames -- number of frames white/black stim stays on.
        fn = 'RefreshOnFrames'; dfn = 'RefreshOnFramesStepSize';
    case 4
        fn = 'RefreshOnFramesStepSize'; dfn = 'constStepSize';
    case 5 %refresh frames -- number of frames white/black stim stays on.
        fn = 'RefreshOffFrames'; dfn = 'RefreshOffFramesStepSize';
    case 6
        fn = 'RefreshOffFramesStepSize'; dfn = 'constStepSize';
    case 7
        fn = 'TrialDuration'; dfn = 'TrialDurationStepSize';
    case 8
        fn = 'TrialDurationStepSize'; dfn = 'constStepSize';
    case 9
        fn = 'TrialRepetition'; dfn = 'TrialRepetitionStepSize';
    case 10
        fn = 'TrialRepetitionStepSize'; dfn = 'constStepSize';
    case 11
        fn = 'InterTrialDuration'; dfn = 'InterTrialDurationStepSize';
    case 12
        fn = 'InterTrialDurationStepSize'; dfn = 'constStepSize';
    case 13
        fn = 'SpatialFreq'; dfn = 'SpatialFreqStepSize';
    case 14
        fn = 'SpatialFreqStepSize'; dfn = 'constStepSize';
    case 15
        fn = 'TempoFreq'; dfn = 'TempoFreqStepSize';
    case 16
        fn = 'TempoFreqStepSize'; dfn = 'constStepSize';
end

rfmStimPar.Stim.(fn) = rfmStimPar.Stim.(fn) - rfmStimPar.Stim.(dfn);
set(handles.edit_StimPVal1,'String',rfmStimPar.Stim.(fn));
sendTCPIPData(fn);

rfmPar.isStimChg = true;

redrawScreen(hObject,eventdata,handles);


% --- Executes on button press in checkbox_rfbCoCenterStim.
function checkbox_rfbCoCenterStim_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rfbCoCenterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rfbCoCenterStim



function edit_rfmCtrlStatus_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfmCtrlStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfmCtrlStatus as text
%        str2double(get(hObject,'String')) returns contents of edit_rfmCtrlStatus as a double


% --- Executes during object creation, after setting all properties.
function edit_rfmCtrlStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfmCtrlStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hStatusBar;

%hStatusBar = handles.edit_rfmCtrlStatus;
hStatusBar = hObject;

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global rfmPar rfmStimPar;
rfmPar.stopRunning = true;
rfmPar.pauseRunning = false;

rfmStimPar.stopRunning = rfmPar.stopRunning;
rfmStimPar.pauseRunning = rfmPar.pauseRunning;


% --- Executes on button press in checkbox_useNSP.
function checkbox_useNSP_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_useNSP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_useNSP
global rfmPar

rfmPar.useNSP = get(hObject,'Value');

% --- Executes on button press in pushbutton_StimInvColor.
function pushbutton_StimInvColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimInvColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmStimPar rfmWSCK

fn = 'InvColor';
rfmStimPar.Stim.(fn) = true;

sendTCPIPData(fn);

rfmStimPar.Stim.(fn) = false;



function edit_stimWindowStatus_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stimWindowStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stimWindowStatus as text
%        str2double(get(hObject,'String')) returns contents of edit_stimWindowStatus as a double


% --- Executes during object creation, after setting all properties.
function edit_stimWindowStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stimWindowStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function StimWindow_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to StimWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Mouse;
global rfmPar rfmStimPar;
s=lower(get(gcf,'selectiontype'));

if (rfmPar.cursorInStim) %stim window active
    if isequal(s,'normal')
        %if tractcursor mode off
        if ~rfmStimPar.Stim.('TrackCursor')
            %move stim center to cursor position.
            p = get(gcf,'CurrentPoint');
            %update the stim position in screen coordinates.
            x = ((p(1)-rfmPar.AxesPosition(1))/rfmPar.AxesPosition(3))*rfmPar.ScrHRes;
            y = ((p(2)-rfmPar.AxesPosition(2))/rfmPar.AxesPosition(4))*rfmPar.ScrVRes;
            rfmStimPar.Stim.('PosX')=round(x);
            rfmStimPar.Stim.('PosY')=round(rfmPar.ScrVRes-y);
            %update the remote host
            sendTCPIPData({'PosX','PosY'});
            rfmPar.isStimChg = true;
            redrawScreen(hObject,eventdata,handles);
        end
    elseif isequal(s,'alt') %right click to exit
        fprintf('right clicked\n');
        set(gcf,'Pointer','arrow');
        rfmPar.cursorInStim = false;
        %test
        %fprintf('Quit Cursor Tracking\n');
    else %nothing on double click
    end
else %stim window inactive -- only change upon double-click
    if isequal(s,'open')
        %find the cursor in the screen coordinates.
        rect = get(gcf,'Position'); %updates gcf position if figure moved.
        %axp = get(gca,'Position');
        axp = rfmPar.AxesPosition;
        %find the stimCenter in terms of pixel position.
        stimPosX = rfmStimPar.Stim.('PosX');
        stimPosY = rfmStimPar.Stim.('PosY');
        stimPixX = (stimPosX / rfmPar.ScrHRes) * rfmPar.AxesPosition(3);
        stimPixY = (stimPosY / rfmPar.ScrVRes) * rfmPar.AxesPosition(4);
        %find the (stimPixX,stimPixY) in system screen coordinates.
        x = stimPixX + axp(1) + rect(1);
        y = rfmPar.ScreenSize(4) - ((rfmPar.AxesPosition(4) - stimPixY) + axp(2) + rect(2));

        set(gcf,'Pointer','crosshair');
        Mouse.mouseMove(x,y);
        pause(0.00001); %allow cursor position to be updated after mousemove.
        %p=get(gcf,'currentpoint');
        %fprintf('currentpoint in gcf [%d,%d]\n',p(1),p(2));

        rfmPar.cursorInStim = true;
    end
        
end


% --- Executes during object creation, after setting all properties.
function pushbutton_Exit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfmPar rfmStimPar;

if rfmPar.cursorInStim
        p = get(gcf,'CurrentPoint');
        %mouse click selection
        ms = get(gcf,'selectiontype');
        %update the stim position in screen coordinates.
        x = ((p(1)-rfmPar.AxesPosition(1))/rfmPar.AxesPosition(3))*rfmPar.ScrHRes;
        y = ((p(2)-rfmPar.AxesPosition(2))/rfmPar.AxesPosition(4))*rfmPar.ScrVRes;
        x = round(x);
        y = round(rfmPar.ScrVRes-y);
        %update the info bar
        s = sprintf('Cursor [%d,%d]',x,y);
        set(handles.edit_stimWindowStatus,'String',s);
    if rfmStimPar.Stim.('TrackCursor')
        
        rfmStimPar.Stim.('PosX')=x;
        rfmStimPar.Stim.('PosY')=y;
        
        %update remote host
        sendTCPIPData({'PosX','PosY'});
        
        rfmPar.isStimChg = true;
        redrawScreen(hObject,eventdata,handles);
    end
    % right click to quit cursor tracking
    if strcmpi(ms,'alt')
        rfmPar.cursorInStim = false;
        set(gcf,'Pointer','arrow');
        fprintf('quit tracking\n');
    end
end
        


% --- Executes during object creation, after setting all properties.
function StimWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate StimWindow

global rfmPar;

rfmPar.AxesPosition = get(gca,'Position');
stimWindowRatio = rfmPar.AxesPosition(3)/rfmPar.AxesPosition(4);

%axes pannel ratio was set at 1920/1200. mark the max region corresponding
%to the screen resolution of the remote mac machine.
try
    rfmPar.stimWindowWidth = rfmPar.ScrHRes;
catch
    rfmPar.stimWindowWidth = 1920;
end

try
    rfmPar.stimWindowHeight = rfmPar.ScrVRes;
catch
    rfmPar.stimWindowHeight = 1200;
end

stimMonitorRatio = rfmPar.stimWindowWidth / rfmPar.stimWindowHeight ;

x=linspace(0,rfmPar.stimWindowWidth-1,100);
y=linspace(0,rfmPar.stimWindowHeight-1,100);
hold on;
plot(x,zeros(size(x)),'y');
plot(x,rfmPar.stimWindowHeight*ones(size(x)),'y');
plot(zeros(size(y)),y,'y');
plot(rfmPar.stimWindowWidth*ones(size(y)),y,'y');

axis equal; 

if stimMonitorRatio >= stimWindowRatio % oversize width
    %use full width of stimulus plot pannel.
    
    xlim([0,rfmPar.stimWindowWidth]);
else
    ylim([0,rfmPar.stimWindowHeight]);
end
 
hold off;


%make RFB objects.
hold on;
for i = 1 : (rfmPar.ChTN+1)
    
     %unit object coordinates (circle + cross)
    uobjX = [rfmPar.circleX rfmPar.vCrossX rfmPar.hCrossX -rfmPar.vCrossX -rfmPar.hCrossX];
    uobjY = [rfmPar.circleY rfmPar.vCrossY rfmPar.hCrossY -rfmPar.vCrossY -rfmPar.hCrossY];
    %scale
    x = rfmPar.ChSets{i}.('DimX')*uobjX;
    y = rfmPar.ChSets{i}.('DimY')*uobjY;
%     
%     %scale
%     x = rfmPar.ChSets{i}.('DimX')*rfmPar.circleX;
%     y = rfmPar.ChSets{i}.('DimY')*rfmPar.circleY;
%     %rotation
    t = 2*pi*rfmPar.ChSets{i}.('Orientation')/360;
    xr = cos(t)*x - sin(t)*y;
    yr = cos(t)*y + sin(t)*x;
    %translation
    xt = xr + rfmPar.ChSets{i}.('PosX');
    yt = yr + rfmPar.ChSets{i}.('PosY');
    
    rfmPar.ChSets{i}.('hCircle')=plot(xt,yt,':','Color',rfmPar.ChSets{i}.('Color'),...
        'LineWidth',1,'Visible','off');
    %label the circle
    [xmax,xp] = max(xt);
    xLabel = xmax;
    yLabel = yt(xp);
    rfmPar.ChSets{i}.('hLabel')= text(xLabel,yLabel,...
                ['\color[rgb]{',num2str(rfmPar.ChSets{i}.('Color')),'}',' \leftarrow ',num2str(rfmPar.ChSets{i}.('ChID'))],...
         'Visible','off');
    
end
hold off;

% --- Executes during object creation, after setting all properties.
function pushbutton_StimDPVal1Inc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimDPVal1Inc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_Run_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_StimStatic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_StimStatic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_StimTrackCursor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_StimTrackCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_StimCoCenterRFB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_StimCoCenterRFB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_StimShow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_StimHide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimHide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_StimInvColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_StimInvColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_ResetOutline.
function pushbutton_ResetOutline_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ResetOutline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global rfmPar

circleCP = zeros(rfmPar.ChTN,2);

for i = 1 : rfmPar.ChTN
    circleCP(i,:) = [rfmPar.ChSets{i}.('PosX') rfmPar.ChSets{i}.('PosY')];
end

a = circleCP'; b = a;
d = rfmDistance(a,b);
[maxDist,maxDistIdx] = max(d);
[maxDistSubx,maxDistSuby]=ind2sub(size(d),maxDistIdx(1));
outDim = maxDist(1)/2 + (max([rfmPar.ChSets{maxDistSubx}.('DimX'),rfmPar.ChSets{maxDistSubx}.('DimY')])+...
    max([rfmPar.ChSets{maxDistSuby}.('DimX'),rfmPar.ChSets{maxDistSuby}.('DimY')])/2);
outDim = round(outDim);
outCP =[(rfmPar.ChSets{maxDistSubx}.('PosX')+rfmPar.ChSets{maxDistSuby}.('PosX'))/2,...
    (rfmPar.ChSets{maxDistSubx}.('PosY')+rfmPar.ChSets{maxDistSuby}.('PosY'))/2];
outCP = round(outCP);

rfmPar.ChSets{rfmPar.ChTN+1}.('DimX')=outDim;
rfmPar.ChSets{rfmPar.ChTN+1}.('DimY')=outDim;
rfmPar.ChSets{rfmPar.ChTN+1}.('PosX')=outCP(1);
rfmPar.ChSets{rfmPar.ChTN+1}.('PosY')=outCP(2);

%append the outline to the display list.
dispListStr = (get(handles.edit_rfbRange,'String'));
if isempty(dispListStr)
    dispList = rfmPar.ChTN + 1;
    set(handles.edit_rfbRange,'String',num2str(rfmPar.ChTN+1));
else
    dispList = eval(['[',dispListStr,']']);
    if ~any(dispList==(rfmPar.ChTN+1))
        set(handles.edit_rfbRange,'String',[dispListStr,',',num2str(rfmPar.ChTN+1)]);
    end
    dispList = union(dispList,rfmPar.ChTN+1);
end

rfmPar.rfbRange = dispList;

% hStimWindow = handles.hStimWindow;
% set(gcf,'CurrentAxes',hStimWindow);

%rebuid object
try
    delete(rfmPar.ChSets{rfmPar.ChTN+1}.('hCircle'));
    delete(rfmPar.ChSets{rfmPar.ChTN+1}.('hLabel'));
end

i = rfmPar.ChTN + 1;

    uobjX = [rfmPar.circleX rfmPar.vCrossX rfmPar.hCrossX -rfmPar.vCrossX -rfmPar.hCrossX];
    uobjY = [rfmPar.circleY rfmPar.vCrossY rfmPar.hCrossY -rfmPar.vCrossX -rfmPar.hCrossX];
    
    %scale
    x = rfmPar.ChSets{i}.('DimX')*uobjX;
    y = rfmPar.ChSets{i}.('DimY')*uobjY;
    
%     %scale
%     x = rfmPar.ChSets{i}.('DimX')*rfmPar.circleX;
%     y = rfmPar.ChSets{i}.('DimY')*rfmPar.circleY;
%     %rotation
    t = 2*pi*rfmPar.ChSets{i}.('Orientation')/360;
    xr = cos(t)*x - sin(t)*y;
    yr = cos(t)*y + sin(t)*x;
    %translation
    xt = xr + rfmPar.ChSets{i}.('PosX');
    yt = yr + rfmPar.ChSets{i}.('PosY');

hold on;
    
    rfmPar.ChSets{i}.('hCircle') = plot(xt,yt,'-',...
            'Color',rfmPar.ChSets{i}.('Color'),'LineWidth',2,'Visible','off');
    
    [xmax,xp] = max(xt);
    xLabel = xmax;
    yLabel = yt(xp);
    
    rfmPar.ChSets{i}.('hLabel')= text(xLabel,yLabel,...
        ['\color[rgb]{',num2str(rfmPar.ChSets{i}.('Color')),'}',' \leftarrow ',num2str(rfmPar.ChSets{i}.('ChID'))],...
        'Visible','off');
    
hold off;

rfmPar.isRFBChg = true;
redrawScreen(hObject,eventdata,handles);


function d = rfmDistance(a,b)
% DISTANCE - computes Euclidean distance matrix
%
% E = distance(A,B)
%
%    A - (DxM) matrix 
%    B - (DxN) matrix
%
% Returns:
%    E - (MxN) Euclidean distances between vectors in A and B
%
%
% Description : 
%    This fully vectorized (VERY FAST!) m-file computes the 
%    Euclidean distance between two vectors by:
%
%                 ||A-B|| = sqrt ( ||A||^2 + ||B||^2 - 2*A.B )
%
% Example : 
%    A = rand(400,100); B = rand(400,200);
%    d = distance(A,B);

% Author   : Roland Bunschoten
%            University of Amsterdam
%            Intelligent Autonomous Systems (IAS) group
%            Kruislaan 403  1098 SJ Amsterdam
%            tel. (+31)20-5257524  (+31)20-5257524 
%            bunschot@wins.uva.nl
% Last Rev : Oct 29 16:35:48 MET DST 1999
% Tested   : PC Matlab v5.2 and Solaris Matlab v5.3
% Thanx    : Nikos Vlassis

% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.

if (nargin ~= 2)
   error('Not enough input arguments');
end

if (size(a,1) ~= size(b,1))
   error('A and B should be of same dimensionality');
end

aa=sum(a.*a,1); bb=sum(b.*b,1); ab=a'*b; 
d = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab));



function edit_mtcStart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mtcStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mtcStart as text
%        str2double(get(hObject,'String')) returns contents of edit_mtcStart as a double
global rfmStimPar

rfmStimPar.mtcStart = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_mtcStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mtcStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mtcStepsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mtcStepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mtcStepsize as text
%        str2double(get(hObject,'String')) returns contents of edit_mtcStepsize as a double

global rfmStimPar

rfmStimPar.mtcStepsize = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_mtcStepsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mtcStepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mtcEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mtcEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mtcEnd as text
%        str2double(get(hObject,'String')) returns contents of edit_mtcEnd as a double

global rfmStimPar

rfmStimPar.mtcEnd = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit_mtcEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mtcEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_measureTC.
function checkbox_measureTC_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_measureTC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_measureTC

global rfmStimPar

setState = get(hObject,'Value');

actObjIdx = get(handles.popupmenu_StimParamsList2,'Value');

switch actObjIdx
    case 1
        %update the measurement type
        rfmStimPar.mtcType = 1;
        rfmStimPar.measureTC = setState;
    case 11
            %update the measurement type
        rfmStimPar.mtcType = 2;
        rfmStimPar.measureTC = setState;
    case 13
            %update the measurement type
        rfmStimPar.mtcType = 3;
        rfmStimPar.measureTC = setState;
    otherwise
        %disable for other params.
        set(hObject,'Value',false);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


