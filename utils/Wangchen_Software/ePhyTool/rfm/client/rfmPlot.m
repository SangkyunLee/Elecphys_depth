function varargout = rfmPlot(varargin)
% RFMPLOT M-file for rfmPlot.fig
%      RFMPLOT, by itself, creates a new RFMPLOT or raises the existing
%      singleton*.
%
%      H = RFMPLOT returns the handle to a new RFMPLOT or the handle to
%      the existing singleton*.
%
%      RFMPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RFMPLOT.M with the given input arguments.
%
%      RFMPLOT('Property','Value',...) creates a new RFMPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rfmPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rfmPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rfmPlot

% Last Modified by GUIDE v2.5 12-Mar-2010 13:37:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rfmPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @rfmPlot_OutputFcn, ...
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


% --- Executes just before rfmPlot is made visible.
function rfmPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rfmPlot (see VARARGIN)

global Mouse;
import java.awt.Robot;
Mouse = Robot;
% Choose default command line output for rfmPlot
handles.output = hObject;
%reset figure units.
set(hObject,'Units','pixels');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rfmPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rfmPlot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_rfbStatus_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rfbStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rfbStatus as text
%        str2double(get(hObject,'String')) returns contents of edit_rfbStatus as a double


% --- Executes during object creation, after setting all properties.
function edit_rfbStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rfbStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimStatus_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimStatus as text
%        str2double(get(hObject,'String')) returns contents of edit_StimStatus as a double


% --- Executes during object creation, after setting all properties.
function edit_StimStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Mouse;
s=get(gcf,'selectiontype');
s=lower(s);
if isequal(s,'open')
    set(gcf,'Pointer','crosshair');
    %find the cursor in the screen coordinates.
    rect = get(hObject,'Position')
    axp = get(gca,'Position')
    Mouse.mouseMove(rect(1)+axp(1),rect(2)+axp(2))
    Mouse.mouseMove(1,1)
    %p=get(gcf,'currentpoint');
    %fprintf('currentpoint [%d,%d]\n',p(1),p(2));
elseif isequal(s,'alt')
    set(gcf,'Pointer','arrow');
end

%save cursor
guidata(hObject,handles);

% --- Executes on button press in pushbutton_mPause.
function pushbutton_mPause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_mStop.
function pushbutton_mStop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_mRun.
function pushbutton_mRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('run pushed \n');

