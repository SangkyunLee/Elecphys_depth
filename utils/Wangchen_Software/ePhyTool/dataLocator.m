function varargout = dataLocator(varargin)
% DATALOCATOR M-file for dataLocator.fig
%      DATALOCATOR, by itself, creates a new DATALOCATOR or raises the existing
%      singleton*.
%
%      H = DATALOCATOR returns the handle to a new DATALOCATOR or the handle to
%      the existing singleton*.
%
%      DATALOCATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATALOCATOR.M with the given input arguments.
%
%      DATALOCATOR('Property','Value',...) creates a new DATALOCATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dataLocator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dataLocator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataLocator

% Last Modified by GUIDE v2.5 02-May-2010 15:39:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataLocator_OpeningFcn, ...
                   'gui_OutputFcn',  @dataLocator_OutputFcn, ...
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


% --- Executes just before dataLocator is made visible.
function dataLocator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dataLocator (see VARARGIN)

% Choose default command line output for dataLocator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%reset result 
setappdata(0,'dataLocator_result',[]);

% UIWAIT makes dataLocator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dataLocator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_matDataFolder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_matDataFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_matDataFolder as text
%        str2double(get(hObject,'String')) returns contents of edit_matDataFolder as a double


% --- Executes during object creation, after setting all properties.
function edit_matDataFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_matDataFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%find the folder struct from previous run
folder = getappdata(0,'dataLocator_folder');

i = 1; 
if isempty(folder)
    foldername = pwd;
else
    foldername = fullfile(folder(i).base,folder(i).subject,folder(i).exp,folder(i).date,folder(i).time,folder(i).etc);   
end

set(hObject,'String',foldername,'horizontalalignment','right');

%update file numbers
%find the files in the directory
files = dir(fullfile(foldername,'*.mat'));
%update file numbers
set(findobj('Tag','edit_matFiles'),'String',num2str(length(files)));


function edit_nexDataFolder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nexDataFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nexDataFolder as text
%        str2double(get(hObject,'String')) returns contents of edit_nexDataFolder as a double


% --- Executes during object creation, after setting all properties.
function edit_nexDataFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nexDataFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%find the folder struct from previous run
folder = getappdata(0,'dataLocator_folder');

i = 2; 
if isempty(folder)
    foldername = pwd;
else
    foldername = fullfile(folder(i).base,folder(i).subject,folder(i).exp,folder(i).date,folder(i).time,folder(i).etc);   
end

set(hObject,'String',foldername,'horizontalalignment','right');

%find the files in the directory
files = dir(fullfile(foldername,'*.nex'));
%update file numbers
set(findobj('Tag','edit_nexFiles'),'String',num2str(length(files)));


function edit_nevDataFolder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nevDataFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nevDataFolder as text
%        str2double(get(hObject,'String')) returns contents of edit_nevDataFolder as a double


% --- Executes during object creation, after setting all properties.
function edit_nevDataFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nevDataFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%find the folder struct from previous run
folder = getappdata(0,'dataLocator_folder');

i = 3; 
if isempty(folder)
    foldername = pwd;
else
    foldername = fullfile(folder(i).base,folder(i).subject,folder(i).exp,folder(i).date,folder(i).time,folder(i).etc);   
end

set(hObject,'String',foldername,'horizontalalignment','right');

%find the files in the directory
files = dir(fullfile(foldername,'*.nev'));
%update file numbers
set(findobj('Tag','edit_nevFiles'),'String',num2str(length(files)));


% --- Executes on button press in pushbutton_matData.
function pushbutton_matData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_matData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

matdir = get(findobj('Tag','edit_matDataFolder'),'String');

newdir = uigetdir(matdir);

if newdir == 0
    %data file not chosen
else
    %update matdir
    matdir = newdir;
    %find the files in the directory
    files = dir(fullfile(matdir,'*.mat'));
    n = length(files);
    %update file numbers
    set(findobj('Tag','edit_matFiles'),'String',num2str(n));
    %update folder name
    set(findobj('Tag','edit_matDataFolder'),'String',matdir);
    
    %update the nex folder
    files = dir(fullfile(matdir,'*.nex'));
    n = length(files);
    set(findobj('Tag','edit_nexFiles'),'String',num2str(n));
    set(findobj('Tag','edit_nexDataFolder'),'String',matdir,'horizontalalignment','right');
end

% --- Executes on button press in pushbutton_nexData.
function pushbutton_nexData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nexData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_nevData.
function pushbutton_nevData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nevData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nevdir = get(findobj('Tag','edit_nevDataFolder'),'String');

newdir = uigetdir(nevdir);

if newdir == 0
    %data file not chosen
else
    %update matdir
    nevdir = newdir;
    %find the files in the directory
    files = dir(fullfile(nevdir,'*.nev'));
    n = length(files);
    %update file numbers
    set(findobj('Tag','edit_nevFiles'),'String',num2str(n));
    %update folder name
    set(findobj('Tag','edit_nevDataFolder'),'String',nevdir,'horizontalalignment','right');
end

% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%parse the selected folders
matFolder = get(findobj('Tag','edit_matDataFolder'),'String');
nexFolder = get(findobj('Tag','edit_nexDataFolder'),'String');
nevFolder = get(findobj('Tag','edit_nevDataFolder'),'String');
%file index
files = get(findobj('Tag','edit_fileIndex'),'String');
%add 'etc' field. sorted nev by O.S may be saved in the subfolder specified
%by 'etc' and may be accessed by STA and tuning analysis problem.
folder = struct('base',[],'subject',[],'exp',[],'date',[],'time',[],'etc',[]);
folder(1:3) = struct(folder);

s = {matFolder,nexFolder,nevFolder};

for i = 1 : length(s)
    parts = regexp(s{i},'\\','split');
    pes = parts{end};
    lastpart = length(parts);
    %check the length of chars '=8' and first char numeric for 'time'
    if length(pes)==8 && ~isempty(str2num(pes(1))) ...
            && ~isempty(str2num(pes(end))) && strmatch(pes(3),'-')
        %no subfoler for 'etc'
        folder(i).etc = [];
    else
        folder(i).etc = pes;
        lastpart = lastpart -1;
    end
    folder(i).time = parts{lastpart};
    folder(i).date = parts{lastpart-1};
    folder(i).exp  = parts{lastpart-2};
    folder(i).subject = parts{lastpart-3};
    %base
    for j = 1 : (lastpart - 4)
        if j == 1 ; folder(i).base = parts{j}; continue; end
        folder(i).base = [folder(i).base,'\',parts{j}];
    end
end

err = false;
% checklist = {'subject','exp','date'}; %add 'time' after modify the data collection program
checklist = {'subject','exp','date','time'}; 
%check consistency
checkfun = inline('strcmp(x,y) && strcmp(x,z)');
for i = 1 : length(checklist)
    err = ~checkfun(folder(1).(checklist{i}),folder(2).(checklist{i}),folder(3).(checklist{i}));
    if err; break; end
end

% %turn off the consistency check on folder names.
% err = false;

ret = [];
%pop up a err message
if err
    msg = 'Data Folder Mismatch:';
    fields = fieldnames(folder);
    msg = sprintf('\n%s\n\n\tStimulation',msg);
    for i = 1 : length(fields)
        msg = sprintf('%s\nfolder.%s = %s',msg,fields{i},folder(1).(fields{i}));
    end
    msg = sprintf('%s\n\n\tCerebusData ---',msg);
    for i = 1 : length(fields)
        msg = sprintf('%s\nfolder.%s = %s',msg,fields{i},folder(3).(fields{i}));
    end
    
    warndlg(msg);
    
else
    ret = struct;
    ret.folder = folder;
    ret.fileindex = files;
    %disable another call
    set(hObject,'Enable','off');
    %save the folder info into global var
    setappdata(0,'dataLocator_folder',folder);
end

%return the callback and notify the main script loading dataLocator
setappdata(0,'dataLocator_result',ret);

return    
        


    




function edit_fileIndex_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fileIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fileIndex as text
%        str2double(get(hObject,'String')) returns contents of edit_fileIndex as a double
if ~isempty(eval(get(hObject,'String')))
    %reset selOption 
    set(findobj('Tag','checkbox_selOption'),'Value',false);
end

% --- Executes during object creation, after setting all properties.
function edit_fileIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fileIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_selOption.
function checkbox_selOption_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_selOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_selOption
h = findobj('Tag','edit_fileIndex');
if get(hObject,'Value')
    set(h,'String','[]');
else
    set(h,'String','1');
end
    

function edit_matFiles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_matFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_matFiles as text
%        str2double(get(hObject,'String')) returns contents of edit_matFiles as a double


% --- Executes during object creation, after setting all properties.
function edit_matFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_matFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nexFiles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nexFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nexFiles as text
%        str2double(get(hObject,'String')) returns contents of edit_nexFiles as a double


% --- Executes during object creation, after setting all properties.
function edit_nexFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nexFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nevFiles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nevFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nevFiles as text
%        str2double(get(hObject,'String')) returns contents of edit_nevFiles as a double


% --- Executes during object creation, after setting all properties.
function edit_nevFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nevFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%setappdata(0,'dataLocator_result',[]);
%close fig
close(findobj('Type','Figure','Name','dataLocator'));

% --- Executes during object creation, after setting all properties.
function checkbox_selOption_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_selOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Value',true);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

setappdata(0,'dataLocator_result',[]);

