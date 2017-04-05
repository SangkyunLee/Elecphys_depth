function varargout = xytransform(varargin)
% XYTRANSFORM M-file for xytransform.fig
%      XYTRANSFORM, by itself, creates a new XYTRANSFORM or raises the existing
%      singleton*.
%
%      H = XYTRANSFORM returns the handle to a new XYTRANSFORM or the handle to
%      the existing singleton*.
%
%      XYTRANSFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XYTRANSFORM.M with the given input arguments.
%
%      XYTRANSFORM('Property','Value',...) creates a new XYTRANSFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before xytransform_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to xytransform_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xytransform

% Last Modified by GUIDE v2.5 05-Sep-2011 01:17:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xytransform_OpeningFcn, ...
                   'gui_OutputFcn',  @xytransform_OutputFcn, ...
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


% --- Executes just before xytransform is made visible.
function xytransform_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to xytransform (see VARARGIN)

% Choose default command line output for xytransform
handles.output = hObject;

handles = init_gui(hObject,eventdata,handles);



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes xytransform wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = xytransform_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- set up the initial values of gui elements
function handles = init_gui(hObject,eventdata,handles)
%
%monitors
%global xyt_par;


xyt_par = struct('str',struct,'val',struct,'Monitors',struct);

Monitors = struct;
Monitors(1).Name = 'Mac LCD';   %
Monitors(1).Size = [52 32]; %Screen's Physical Size in cm
Monitors(1).Resolution = [1920 1200]; %screen resolution in pixel
%Monitors(1).Distance = 57; %screen distance 

Monitors(2).Name = 'CRT';
Monitors(2).Size = [32 24]; %Screen's Physical Size in cm
Monitors(2).Resolution = [640 480]; %screen resolution in pixel
%Monitors(2).Distance = 57; %screen distance 

try
    Monitors(3).Name = 'Current Monitor';
    [Monitors(3).Size(1) Monitors(3).Size(2)] = Screen(0,'DisplaySize');
    Monitors(3).Size = Monitors(3).Size/10; %in centimeter.
    [Monitors(3).Resolution(1) Monitors(3).Resolution(2)] = Screen(0,'WindowSize');
catch
    Monitors(3)=[];
end
%selected monitor
MonitorID = 1;
%
xyt_par.Monitors = Monitors;
xyt_par.MonitorID = MonitorID;

xyt_par.carUnits = 'Degree';
set(findobj('Tag',['gui_carUnits_',xyt_par.carUnits]),'Value',1);

xyt_par.str.md = 57; %monitor distance.
%intial values
xyt_par.str.scrx = Monitors(MonitorID).Resolution(1)/2;
xyt_par.str.scry = Monitors(MonitorID).Resolution(2)/2;
xyt_par.str.scrw = 0;
xyt_par.str.scrh = 0; 

xyt_par.str.carx = 0;
xyt_par.str.cary = 0;
xyt_par.str.carw = 0;
xyt_par.str.carh = 0;
xyt_par.str.care = 0;
%
xyt_par.val.selMonitor = MonitorID;

obj = fieldnames(xyt_par.str);

for i = 1 : length(obj)
    gui_obj = findobj('tag',['gui_',obj{i}]);
    set(gui_obj,'String',eval(['xyt_par.str.',obj{i}]));
end

msg = {};

for i = 1 : length(xyt_par.Monitors)
    msg{i}=xyt_par.Monitors(i).Name;
end

set(findobj('Tag',['gui_selMonitor']),'String',msg);

obj = fieldnames(xyt_par.val);
for i = 1 : length(obj)
    gui_obj = findobj('tag',['gui_',obj{i}]);
    set(gui_obj,'Value',eval(['xyt_par.val.',obj{i}]));
end

%
handles.xyt_par = xyt_par;

%run the callback of monitor selection ?
gui_selMonitor_Callback(handles.gui_selMonitor,[],handles);

handles = redrawPlot(hObject,eventdata,handles);


function handles = redrawPlot(hObject,eventdata,handles)

%global xyt_par;
xyt_par = handles.xyt_par;
%initialize coordinates plots
%can't find object when redrawPlot is called by edit text change.
%hScreenPlot = findobj('tag','gui_screen');
hScreenPlot = handles.gui_screen;
hViewPlot = handles.gui_cartesian;

set(gcf,'CurrentAxes',hScreenPlot);
plot(xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2, xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2,'k+');
hold on;
plot(xyt_par.str.scrx,xyt_par.str.scry,'r+');
hold off;
set(hScreenPlot,'YDir','reverse','XAxisLocation','top',...
    'XLim',[0 xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)],...
    'YLim',[0 xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)],...
    'XTick',[0;xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)],...
    'YTick',[xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)],...
    'XTickLabel',[0;xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)],...
    'YTickLabel',[xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)]);
%set(gca,'XLabel','X','YLabel','Y');
%xlabel('X'); ylabel('Y');

set(gcf,'CurrentAxes',hViewPlot);
plot([-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(1),[0 0],'b-');
hold on;
plot([0 0],[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(2),'b-');
plot([0 0],'k+');
plot(xyt_par.str.carx,xyt_par.str.cary,'r+');
hold off;
set(hViewPlot,'XLim',[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(1),...
    'YLim',[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(2),...
    'XTick',[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(1),...
    'YTick',[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(2),...
    'XTickLabel',[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(1),...
    'YTickLabel',[-1/2 1/2]*xyt_par.Monitors(xyt_par.MonitorID).Resolution(2));
% %set(gca,'XLabel','X','YLabel','Y');
% %xlabel('X'); ylabel('Y');
%save params back to handles
handles.xyt_par = xyt_par;

%gui_selMonitor_Callback(gcbo,[],guidata(gcbo));
%
% xyt_par.gui_carUnits_Pixel = 1; % units defaults to pixel 
% obj = {'gui_carUnits_Pixel'};
% for i = 1 : length(obj)
%     gui_obj = findobj('tag',['gui_',obj{i}]);
%     set(gui_obj,'SelectedObject',eval(['xyt_par.',obj{i}]));
% end


% --- Executes on selection change in gui_selMonitor.
function gui_selMonitor_Callback(hObject, eventdata, handles)
% hObject    handle to gui_selMonitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns gui_selMonitor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gui_selMonitor
xyt_par = handles.xyt_par;
% global xyt_par;
MonitorID = get(hObject,'Value');
var = {'mw','mh','mx','my'};
mw=xyt_par.Monitors(MonitorID).Size(1);
mh=xyt_par.Monitors(MonitorID).Size(2);
mx=xyt_par.Monitors(MonitorID).Resolution(1);
my=xyt_par.Monitors(MonitorID).Resolution(2);

for i = 1 : length(var)
    set(findobj('Tag',['gui_',var{i}]),'String',eval(var{i}));
end

xyt_par.MonitorID = MonitorID;

handles.xyt_par = xyt_par;

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_selMonitor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_selMonitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_md_Callback(hObject, eventdata, handles)
% hObject    handle to gui_md (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_md as text
%        str2double(get(hObject,'String')) returns contents of gui_md as a double
% global xyt_par
xyt_par = handles.xyt_par;

xyt_par.str.md = str2num(get(hObject,'String'));

handles.xyt_par = xyt_par;

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_md_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_md (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_scrx_Callback(hObject, eventdata, handles)
% hObject    handle to gui_scrx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_scrx as text
%        str2double(get(hObject,'String')) returns contents of gui_scrx as a double
handles = scrXYCallback(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_scrx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_scrx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_scry_Callback(hObject, eventdata, handles)
% hObject    handle to gui_scry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_scry as text
%        str2double(get(hObject,'String')) returns contents of gui_scry as a double
handles = scrXYCallback(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_scry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_scry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_carx_Callback(hObject, eventdata, handles)
% hObject    handle to gui_carx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_carx as text
%        str2double(get(hObject,'String')) returns contents of gui_carx as a double
handles = carXYCallback(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_carx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_carx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_cary_Callback(hObject, eventdata, handles)
% hObject    handle to gui_cary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_cary as text
%        str2double(get(hObject,'String')) returns contents of gui_cary as a double

handles = carXYCallback(hObject,eventdata,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_cary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_cary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_scrw_Callback(hObject, eventdata, handles)
% hObject    handle to gui_scrw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_scrw as text
%        str2double(get(hObject,'String')) returns contents of gui_scrw as a double
handles = scrXYCallback(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_scrw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_scrw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_scrh_Callback(hObject, eventdata, handles)
% hObject    handle to gui_scrh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_scrh as text
%        str2double(get(hObject,'String')) returns contents of gui_scrh as a double
handles = scrXYCallback(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_scrh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_scrh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = scrXYCallback(hObject,eventdata,handles)

% global xyt_par;

xyt_par = handles.xyt_par;

obj = get(hObject,'tag');
val = get(hObject,'String');
var = obj(5:end);
eval(['xyt_par.str.',var,'=str2num(val)']);
%update offset
offsetx = xyt_par.str.scrx - xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2;
offsety = xyt_par.str.scry - xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2;

set(findobj('tag','gui_screenoffset'),'string',sprintf('%d , %d',offsetx,offsety));

handles.xyt_par = xyt_par;

handles = redrawPlot(hObject,eventdata,handles);

function gui_carw_Callback(hObject, eventdata, handles)
% hObject    handle to gui_carw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_carw as text
%        str2double(get(hObject,'String')) returns contents of gui_carw as a double

handles = carXYCallback(hObject,eventdata,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_carw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_carw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = carXYCallback(hObject,eventdata,handles)

% global xyt_par;
xyt_par = handles.xyt_par;

obj = get(hObject,'tag');
val = get(hObject,'String');
var = obj(5:end);
%value in pixels
pix = round(dim2pix(str2num(val),xyt_par.carUnits,handles));
eval(['xyt_par.str.',var,'=pix;']);
%update offset
% offsetx = xyt_par.str.scrx - xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2;
% offsety = xyt_par.str.scry - xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2;
% set(findobj('tag','gui_screenoffset'),'string',sprintf('%d , %d',offsetx,offsety));
%update eccentricity
xyt_par.str.care = sqrt(xyt_par.str.carx^2 + xyt_par.str.cary^2);
set(findobj('tag','gui_care'),'String',sprintf('%.3f',pix2dim(xyt_par.str.care,xyt_par.carUnits,handles)));

handles.xyt_par = xyt_par;

handles = redrawPlot(hObject,eventdata,handles);


function gui_carh_Callback(hObject, eventdata, handles)
% hObject    handle to gui_carh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_carh as text
%        str2double(get(hObject,'String')) returns contents of gui_carh as a double

handles = carXYCallback(hObject,eventdata,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_carh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_carh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_care_Callback(hObject, eventdata, handles)
% hObject    handle to gui_care (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_care as text
%        str2double(get(hObject,'String')) returns contents of gui_care as a double


% --- Executes during object creation, after setting all properties.
function gui_care_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_care (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gui_getcar.
function gui_getcar_Callback(hObject, eventdata, handles)
% hObject    handle to gui_getcar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global xyt_par;

xyt_par = handles.xyt_par;
%translate the coordinates in pixels
xyt_par.str.carx = xyt_par.str.scrx - xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2;
xyt_par.str.cary = xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2 - xyt_par.str.scry;
xyt_par.str.carw = xyt_par.str.scrw;
xyt_par.str.carh = xyt_par.str.scrh;
xyt_par.str.care = sqrt(xyt_par.str.carx^2+xyt_par.str.cary^2);
%update the text fields
var = {'carx','cary','carw','carh','care'};
for i = 1 : length(var)
    val = pix2dim(eval(['xyt_par.str.',var{i}]),xyt_par.carUnits,handles);
    switch lower(xyt_par.carUnits)
        case 'pixel'
            set(findobj('tag',['gui_',var{i}]),'String',sprintf('%d',round(val)));
        otherwise
            set(findobj('tag',['gui_',var{i}]),'String',sprintf('%.3f',val));
    end
   
end
%update offset
%update offset
offsetx = xyt_par.str.scrx - xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2;
offsety = xyt_par.str.scry - xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2;

set(findobj('tag','gui_screenoffset'),'string',sprintf('%d , %d',offsetx,offsety));

handles.xyt_par = xyt_par;

handles = redrawPlot(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes on button press in gui_getscr.
function gui_getscr_Callback(hObject, eventdata, handles)
% hObject    handle to gui_getscr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global xyt_par;
xyt_par = handles.xyt_par;
%translate the coordinates in pixels
xyt_par.str.scrx = xyt_par.str.carx + xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2;
xyt_par.str.scry = xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2 - xyt_par.str.cary;
xyt_par.str.scrw = xyt_par.str.carw;
xyt_par.str.scrh = xyt_par.str.carh;
%xyt_par.str.care = sqrt(xyt_par.str.carx^2+xyt_par.str.cary^2);
%update the text fields
var = {'scrx','scry','scrw','scrh'};
for i = 1 : length(var)
    %val = pix2dim(eval(['xyt_par.str.',var{i}]),xyt_par.carUnits);
    set(findobj('tag',['gui_',var{i}]),'String',sprintf('%d',eval(['xyt_par.str.',var{i}])));
end
%compute the offset
%update offset
offsetx = xyt_par.str.scrx - xyt_par.Monitors(xyt_par.MonitorID).Resolution(1)/2;
offsety = xyt_par.str.scry - xyt_par.Monitors(xyt_par.MonitorID).Resolution(2)/2;

set(findobj('tag','gui_screenoffset'),'string',sprintf('%d , %d',offsetx,offsety));

handles.xyt_par = xyt_par;

handles = redrawPlot(hObject,eventdata,handles);

guidata(hObject,handles);

function gui_my_Callback(hObject, eventdata, handles)
% hObject    handle to gui_my (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_my as text
%        str2double(get(hObject,'String')) returns contents of gui_my as a double
% global xyt_par

xyt_par = handles.xyt_par;
xyt_par.Monitors(xyt_par.MonitorID).Resolution(2) = str2num(get(hObject,'String'));

handles.xyt_par = xyt_par;

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_my_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_my (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_mx_Callback(hObject, eventdata, handles)
% hObject    handle to gui_mx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_mx as text
%        str2double(get(hObject,'String')) returns contents of gui_mx as a double

% global xyt_par

xyt_par = handles.xyt_par;
xyt_par.Monitors(xyt_par.MonitorID).Resolution(1) = str2num(get(hObject,'String'));
handles.xyt_par = xyt_par;

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_mx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_mx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_mw_Callback(hObject, eventdata, handles)
% hObject    handle to gui_mw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_mw as text
%        str2double(get(hObject,'String')) returns contents of gui_mw as a double
% global xyt_par

xyt_par = handles.xyt_par;
xyt_par.Monitors(xyt_par.MonitorID).Size(1) = str2num(get(hObject,'String'));
handles.xyt_par = xyt_par;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_mw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_mw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_mh_Callback(hObject, eventdata, handles)
% hObject    handle to gui_mh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_mh as text
%        str2double(get(hObject,'String')) returns contents of gui_mh as a double

% global xyt_par

xyt_par = handles.xyt_par;

xyt_par.Monitors(xyt_par.MonitorID).Size(2) = str2num(get(hObject,'String'));

handles.xyt_par = xyt_par;

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function gui_mh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_mh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gui_xytran_Callback(hObject, eventdata, handles)
% hObject    handle to gui_xytran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_xytran as text
%        str2double(get(hObject,'String')) returns contents of gui_xytran
%        as a double


% --- Executes during object creation, after setting all properties.
function gui_xytran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_xytran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in gui_carUnits.
function gui_carUnits_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in gui_carUnits 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')
    %units conversion
    case 'gui_carUnitPixel'
    case 'gui_carUnitDegree'
    case 'gui_carUnitCM'
end

function y = pix2dim(x,units,handles)

% global xyt_par;
xyt_par = handles.xyt_par;
%pixel size in cm
pixsize = xyt_par.Monitors(xyt_par.MonitorID).Size(2)/xyt_par.Monitors(xyt_par.MonitorID).Resolution(2);
%x1 = x*pixsize; %dimension in cm
switch lower(units)
    case 'pixel'
        y = x;
    case 'degree'
        y = atan(x*pixsize/xyt_par.str.md)*180/pi;
    case 'cm'
        y = x*pixsize;
end

function y = dim2pix(x,units,handles)

% global xyt_par;
xyt_par = handles.xyt_par ;
%pixel size in cm
pixsize = xyt_par.Monitors(xyt_par.MonitorID).Size(2)/xyt_par.Monitors(xyt_par.MonitorID).Resolution(2);
%x1 = x*pixsize; %dimension in cm
switch lower(units)
    case 'pixel'
        y = x;
    case 'degree'
        y = xyt_par.str.md * tan(x*pi/180)/pixsize;
    case 'cm'
        y = xyt_par.str.md * tan(x*pi/180);
end


% --- Executes on button press in gui_carUnits_Pixel.
function gui_carUnits_Pixel_Callback(hObject, eventdata, handles)
% hObject    handle to gui_carUnits_Pixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gui_carUnits_Pixel
handles = carUnitsTransform(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes on button press in gui_carUnits_Degree.
function gui_carUnits_Degree_Callback(hObject, eventdata, handles)
% hObject    handle to gui_carUnits_Degree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gui_carUnits_Degree
handles = carUnitsTransform(hObject,eventdata,handles);

guidata(hObject,handles);

% --- Executes on button press in gui_carUnits_CM.
function gui_carUnits_CM_Callback(hObject, eventdata, handles)
% hObject    handle to gui_carUnits_CM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gui_carUnits_CM
handles = carUnitsTransform(hObject,eventdata,handles);

guidata(hObject,handles);

function handles = carUnitsTransform(hObject,eventdata,handles)

% global xyt_par;

xyt_par = handles.xyt_par;

gui_tag = {'gui_carUnits_Pixel','gui_carUnits_Degree','gui_carUnits_CM'};
gui_string = {'Pixel','Degree','CM'};

for i = 1 : length(gui_tag)
    gui_obj{i} = findobj('Tag',gui_tag{i});
    set(gui_obj{i},'Value',0);
end
%turn on the button selected.
set(hObject,'Value',1);

var = {'carx','cary','carw','carh','care'};
 %update xyt_par 
xyt_par.carUnits = get(hObject,'String');        
%translate units
switch xyt_par.carUnits
    case 'Pixel'
        %
        for i = 1 : length(var)
            set(findobj('tag',['gui_',var{i}]),'String',sprintf('%d',eval(['round(xyt_par.str.',var{i},')'])));
        end
        
        %or update from xyt_par 
        carx = xyt_par.str.carx;
        cary = xyt_par.str.cary;
        carw = xyt_par.str.carw;
        carh = xyt_par.str.carh;
        care = xyt_par.str.care;
%         
%         carx = str2num(get(findobj('tag','gui_carx'),'String'));
%         cary = str2num(get(findobj('tag','gui_cary'),'String'));
%         carw = str2num(get(findobj('tag','gui_carw'),'String'));
%         carh = str2num(get(findobj('tag','gui_carh'),'String'));
%         care = str2num(get(findobj('tag','gui_care'),'String'));
       
    case 'Degree'
        carx = pix2dim(xyt_par.str.carx,'degree',handles);
        cary = pix2dim(xyt_par.str.cary,'degree',handles);
        carw = pix2dim(xyt_par.str.carw,'degree',handles);
        carh = pix2dim(xyt_par.str.carh,'degree',handles);
        care = pix2dim(xyt_par.str.care,'degree',handles);

        for i = 1 : length(var)
            set(findobj('tag',['gui_',var{i}]),'String',sprintf('%.3f',eval(var{i})));
        end
        
    case 'CM'
        carx = pix2dim(xyt_par.str.carx,'cm',handles);
        cary = pix2dim(xyt_par.str.cary,'cm',handles);
        carw = pix2dim(xyt_par.str.carw,'cm',handles);
        carh = pix2dim(xyt_par.str.carh,'cm',handles);
        care = pix2dim(xyt_par.str.care,'cm',handles);

        for i = 1 : length(var)
            set(findobj('tag',['gui_',var{i}]),'String',sprintf('%.3f',eval(var{i})));
        end

end

%
msg = [];

for i = 1 : length(var)
    msg = [msg,sprintf('%s : %.3f %s = %d %s\n',var{i}(end),eval(var{i}),get(hObject,'String'),eval(['round(xyt_par.str.',var{i},')']),'Pixel')];
end
%update xyt_par 
set(findobj('Tag','gui_xytran'),'String',msg);

handles.xyt_par = xyt_par;

function gui_screenoffset_Callback(hObject, eventdata, handles)
% hObject    handle to gui_screenoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_screenoffset as text
%        str2double(get(hObject,'String')) returns contents of gui_screenoffset as a double


% --- Executes during object creation, after setting all properties.
function gui_screenoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_screenoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gui_exit.
function gui_exit_Callback(hObject, eventdata, handles)
% hObject    handle to gui_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

