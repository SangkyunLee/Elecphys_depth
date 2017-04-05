function varargout = posCalculator(varargin)
% POSCALCULATOR M-file for posCalculator.fig
%      POSCALCULATOR, by itself, creates a new POSCALCULATOR or raises the existing
%      singleton*.
%
%      H = POSCALCULATOR returns the handle to a new POSCALCULATOR or the handle to
%      the existing singleton*.
%
%      POSCALCULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POSCALCULATOR.M with the given input arguments.
%
%      POSCALCULATOR('Property','Value',...) creates a new POSCALCULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before posCalculator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to posCalculator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help posCalculator

% Last Modified by GUIDE v2.5 19-Aug-2011 11:36:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @posCalculator_OpeningFcn, ...
                   'gui_OutputFcn',  @posCalculator_OutputFcn, ...
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


% --- Executes just before posCalculator is made visible.
function posCalculator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to posCalculator (see VARARGIN)

% Choose default command line output for posCalculator
handles.output = hObject;

%initialize the parameter fields by input arg
if ~isempty(varargin)
    handles.input = varargin{1};
else
    handles.input = [];
end

handles = init_gui(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes posCalculator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = init_gui(handles)

if isempty(handles.input)
    return;
end

posStr = handles.input;

obj = cell(1,2);
obj{1} = {'RFStimX','RFStimY','RFStimW','RFStimH'};
obj{2} = {'StimScrX','StimScrY','StimScrW','StimScrH'};
% obj{3} = {'RFScrX','RFScrY','RFScrW','RFScrH'};

%dot(square) size in pixels.
h1 = findobj('Tag','edit_RFStimDotPixels');

fields = {'x','y','w','h','dotsize'};

for i = 1 : length(obj)
    for j = 1 : length(fields)-1
        obj_h = findobj('Tag',['edit_',obj{i}{j}]);
        set(obj_h,'String',num2str(posStr(i).(fields{j})));
    end
end

set(h1,'String',num2str(posStr(1).dotPixels));

%dot(square) size in pixels.
h1 = findobj('Tag','edit_ScrTarDistance');




% --- Outputs from this function are returned to the command line.
function varargout = posCalculator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_RFStimX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFStimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFStimX as text
%        str2double(get(hObject,'String')) returns contents of edit_RFStimX as a double


% --- Executes during object creation, after setting all properties.
function edit_RFStimX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFStimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFStimY_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFStimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFStimY as text
%        str2double(get(hObject,'String')) returns contents of edit_RFStimY as a double


% --- Executes during object creation, after setting all properties.
function edit_RFStimY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFStimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFStimW_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFStimW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFStimW as text
%        str2double(get(hObject,'String')) returns contents of edit_RFStimW as a double


% --- Executes during object creation, after setting all properties.
function edit_RFStimW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFStimW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFStimH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFStimH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFStimH as text
%        str2double(get(hObject,'String')) returns contents of edit_RFStimH as a double


% --- Executes during object creation, after setting all properties.
function edit_RFStimH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFStimH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFStimDotPixels_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFStimDotPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFStimDotPixels as text
%        str2double(get(hObject,'String')) returns contents of edit_RFStimDotPixels as a double


% --- Executes during object creation, after setting all properties.
function edit_RFStimDotPixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFStimDotPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimScrX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimScrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimScrX as text
%        str2double(get(hObject,'String')) returns contents of edit_StimScrX as a double


% --- Executes during object creation, after setting all properties.
function edit_StimScrX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimScrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimScrY_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimScrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimScrY as text
%        str2double(get(hObject,'String')) returns contents of edit_StimScrY as a double


% --- Executes during object creation, after setting all properties.
function edit_StimScrY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimScrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimScrW_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimScrW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimScrW as text
%        str2double(get(hObject,'String')) returns contents of edit_StimScrW as a double


% --- Executes during object creation, after setting all properties.
function edit_StimScrW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimScrW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StimScrH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StimScrH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StimScrH as text
%        str2double(get(hObject,'String')) returns contents of edit_StimScrH as a double


% --- Executes during object creation, after setting all properties.
function edit_StimScrH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StimScrH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFScrX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFScrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFScrX as text
%        str2double(get(hObject,'String')) returns contents of edit_RFScrX as a double


% --- Executes during object creation, after setting all properties.
function edit_RFScrX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFScrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFScrY_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFScrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFScrY as text
%        str2double(get(hObject,'String')) returns contents of edit_RFScrY as a double


% --- Executes during object creation, after setting all properties.
function edit_RFScrY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFScrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFScrW_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFScrW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFScrW as text
%        str2double(get(hObject,'String')) returns contents of edit_RFScrW as a double


% --- Executes during object creation, after setting all properties.
function edit_RFScrW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFScrW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RFScrH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RFScrH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RFScrH as text
%        str2double(get(hObject,'String')) returns contents of edit_RFScrH as a double


% --- Executes during object creation, after setting all properties.
function edit_RFScrH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RFScrH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pos = struct('x',0,'y',0,'w',0,'h',0);
label = {'x','y','w','h'};
pos(2) = pos(1);
pos(3) = pos(1);

obj = cell(1,3);
obj{1} = {'RFStimX','RFStimY','RFStimW','RFStimH'};
obj{2} = {'StimScrX','StimScrY','StimScrW','StimScrH'};
obj{3} = {'RFScrX','RFScrY','RFScrW','RFScrH'};

%dot(square) size in pixels.
h1 = findobj('Tag','edit_RFStimDotPixels');
StimDotSize = str2double(get(h1,'String'));

for i = 1 : 3
    if i < 3
        %get field values
        for j = 1 : length(obj{1})
            obj_h = findobj('Tag',['edit_',obj{i}{j}]);
            pos(i).(label{j}) = str2double(get(obj_h,'String'));
        end
    else
        %run calculation
        for j = 1 : length(obj{1})
            obj_h = findobj('Tag',['edit_',obj{i}{j}]);
            %calculate the RF postion on screen.
            if j == 1 || j == 2 % (x,y)
                %stim array center index
                %here width = number of columns
                    c = (1 + pos(1).(label{j+2}))/2;
                %y1 = (1 + pos(1).h)/2;
                pos(i).(label{j}) = (pos(1).(label{j}) - c)*StimDotSize + pos(2).(label{j});
            elseif j == 3 || j == 4 %(w,h)
                pos(i).(label{j}) = pos(1).(label{j}) * StimDotSize;
            end
            %
            pos(i).(label{j}) = round(pos(i).(label{j}));
            set(obj_h,'String',num2str(pos(i).(label{j})));
        end
    end
end

    


% --- Executes on button press in pushbutton_Exit.
function pushbutton_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1);



function edit_ScrTarDistance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ScrTarDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ScrTarDistance as text
%        str2double(get(hObject,'String')) returns contents of edit_ScrTarDistance as a double


% --- Executes during object creation, after setting all properties.
function edit_ScrTarDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ScrTarDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_DotSizeDeg_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DotSizeDeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DotSizeDeg as text
%        str2double(get(hObject,'String')) returns contents of edit_DotSizeDeg as a double


% --- Executes during object creation, after setting all properties.
function edit_DotSizeDeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DotSizeDeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


