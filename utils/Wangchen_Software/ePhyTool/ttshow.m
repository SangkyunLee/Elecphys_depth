function varargout = ttshow(varargin)
% TTSHOW M-file for ttshow.fig
%      TTSHOW, by itself, creates a new TTSHOW or raises the existing
%      singleton*.
%
%      H = TTSHOW returns the handle to a new TTSHOW or the handle to
%      the existing singleton*.
%
%      TTSHOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TTSHOW.M with the given input arguments.
%
%      TTSHOW('Property','Value',...) creates a new TTSHOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ttshow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ttshow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ttshow

% Last Modified by GUIDE v2.5 15-May-2013 17:24:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ttshow_OpeningFcn, ...
                   'gui_OutputFcn',  @ttshow_OutputFcn, ...
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


% --- Executes just before ttshow is made visible.
function ttshow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ttshow (see VARARGIN)

% Choose default command line output for ttshow
handles.output = hObject;

%
handles = init(hObject,eventdata,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ttshow wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = init(hObject,eventdata,handles)
%
%
%
global par;
par = struct;
%reference image of monkey V1.
par.refFile = [];
%excel file for actue study with tetrodes 
par.sourceFile = [];
%file to save the display
par.saveFile = [];

%display the reference image (V1 depth).
par.refFile = fullfile(fileparts(mfilename('fullpath')),'Organization_of_V1_of_Alert_Macaques.png');
%hAxis = axes('parent',handles.figure1);
hAxis = handles.gui_reference;
imshow(imread(par.refFile,'png'),'parent',hAxis);
axis off;
axis normal;

%last modified date of the source file
par.sourceLastModified = [];

%timer for reading excel file.
par.RST = timer('Period', 15, 'ExecutionMode','fixedRate');

%defaults
par.YMAX = 2000;
par.YMIN = -10;
par.units = 'um'; %or 'turns'
par.ref = 'inbrain'; %or 'zeroturn'
par.display = 'last'; %or 'all';
par.label = 'increment'; %or 'total'
par.binSize = 250;

handles.par = par;

set(par.RST,'TimerFcn',{@RST_Callback,handles});
%set the default settings
set(findobj('tag','worksheet_index'),'String',num2str(1));
set(findobj('tag','auto_update'),'Value',false);
set(findobj('tag','ymax'),'String',num2str(handles.par.YMAX));
set(findobj('tag','ymin'),'String',num2str(handles.par.YMIN));
set(findobj('tag','binSize'),'String',num2str(handles.par.binSize));
set(findobj('tag',['units_',handles.par.units]),'Value',true);
set(findobj('tag',['ref_',handles.par.ref]),'Value',true);
set(findobj('tag',['display_', handles.par.display]),'Value',true);
set(findobj('tag',['label_',handles.par.label]),'Value',true);

%start(handles.par.RST); %start the timer after the excel file is chosen.
guidata(hObject,handles);

function handles = RST_Callback(obj,event,handles)

%h = gcf;
global par;

%handles.par not updated ?
handles.par = par;

%check the last modified date
if isempty(handles.par.sourceFile)
    return;
end

d = dir(handles.par.sourceFile);

if d.datenum <= handles.par.sourceLastModified
    %fprintf('no update\n');
    return;
else
    par.sourceLastModified = d.datenum;
    %handles.par.sourceLastModified = d.datenum;
end

% h = gcf;
% %simulate the refresh button press
%ttshow('refresh_Callback',findobj(h,'tag','refresh'),[],guidata(findobj(h,'tag','refresh')));

%set the axes and gui handles' handleVisibility to ON.
% http://www.mathworks.com/support/solutions/en/data/1-1A30V/?solution=1-1A
% 30V

%update the handles.par
handles.par = par;

handles = updateDisplay(handles);

%
function handles = updateDisplay(handles)

global par;

warning off MATLAB:xlsread:Mode;
%read the source file
worksheet_index = (get(findobj('tag','worksheet_index'),'String'));
switch worksheet_index
    case '1'
        worksheet = 1;
    case '2'
        worksheet = 'Recording'; %table of depth for the recordings after sorting.
end
%label the last turn in increment
isIncLabeled = get(findobj('tag','label_increment'),'Value');

try
    if worksheet == 1  %read the raw log
        [arr,txt,raw] = xlsread(handles.par.sourceFile,worksheet,'','basic');
    else               %read the sorted log in which the turns are summed for each depth
        [arr,txt,raw] = xlsread(handles.par.sourceFile,worksheet);
    end
catch 
    fprintf('Warning: cannot read sheet #%d in excel file\n',str2num(worksheet_index));
end
%
ttColumnIdx = 'O'-'A';
%row of total turns
ttTotalIdx = 6;
%row of depth
ttDepthIdx = 7;
%row of in brain depth
ttInBrainIdx = 8;
%row of adjustments start.
ttStartIdx = 13;
%turn size 
turnSize = raw{ttDepthIdx,'F'-'A'+1};
%column index for recording session flag
sessionColumnIdx = ttColumnIdx + 30;

%plot the turn adjustments for each tetrodeF
%color code: red for advancement, green for backout
tet = struct('id', [],...
            'depth',[],...
            'turns',[],...
            'turnStop',[],...
            'totalTurns',[],...
            'inBrain',[]);

nTet = 28;        
%24 tts + 4 ref
for i = 1 : nTet
    if i <= 24
        tet(i).id = ['tt',num2str(i)];
    else
        tet(i).id = ['R',num2str(i-24)];
    end
    
    tet(i).depth = raw{ttDepthIdx, ttColumnIdx+i}; %depth in um calcuated wrt in-brain position 
    tet(i).totalTurns = raw{ttTotalIdx,ttColumnIdx+i}; % in turns
    tet(i).inBrain = raw{ttInBrainIdx, ttColumnIdx+i}; % in turns
    tet(i).turns = cell2mat(raw(ttStartIdx:end,ttColumnIdx+i)); %in turns
    tet(i).turnStop = zeros(size(tet(i).turns)); %the flag of turns indicating if it's the stop turn before recording. the number is the recording session index.
    
    %find the stop turn
    sessionIdx = cell2mat(raw(ttStartIdx:end,sessionColumnIdx));
    for j = 1 : length(sessionIdx)
        if ~isnan(sessionIdx(j)) && sessionIdx(j)>0 %j is recording session index
            for k = 1 : j %find the stop turn which is the last turn with index <= j
                if ~isnan(tet(i).turns(j-k+1)) && isreal(tet(i).turns(j-k+1))
                    tet(i).turnStop(j-k+1) = sessionIdx(j);
                    break;
                end
            end
        end
    end
    
    emptyTurn = isnan(tet(i).turns);
    tet(i).turns(emptyTurn) = [];
    tet(i).turnStop(emptyTurn) = [];
    
    %depth of each turn made 
    tet(i).turnDepth = zeros(size(tet(i).turns));
    
    if get(findobj('tag','ref_inbrain'),'Value')
        tet(i).ref = tet(i).inBrain;
    else
        tet(i).ref = 0;
    end
    %scale the 'turns' to 'units'
    if get(findobj('tag','units_um'),'Value')
        tet(i).scale = turnSize;
    else
        tet(i).scale = 1;
    end
end
%
%get the size of pannel
%position = get(handles.gui_display,'Position');

%show the traces of all the adjustments
displayAll = get(findobj('tag','display_all'),'Value');

%show the stop turns before each recording
displaySession = get(findobj('tag','display_session'),'Value');

%show the traces of the last adjustments
displayLast = get(findobj('tag','display_last'),'Value');


axes(handles.gui_display);
cla;

hold off;

YMAX = str2num(get(findobj('tag','ymax'),'String'));
YMIN = str2num(get(findobj('tag','ymin'),'String'));

%
for i = 1 : nTet
    x1 = 0.2 + (i-1); 
    x2 = (i-1) + 0.8 ;
    nTurns = length(tet(i).turns);
    
    for j = 1 : nTurns
        y = tet(i).turns(j);
        if y > 0
            if j == nTurns
                c = {'r','LineWidth',2};
            else
                c = {':','Color',[0 0 0],'LineWidth',1};
            end
        else
            %negative turns are counted wrt the lowest depth.
            if j == nTurns
                c = {'g','LineWidth',2};
            else
                c = {':','Color',[0 1 0],'LineWidth',1};
            end
        end
        
        %calculate the depth in 'units'
        if isnan(tet(i).inBrain)
            y = -1;
        else
            y = (sum(tet(i).turns(1:j))-tet(i).ref) * tet(i).scale;
        end
        
        %the depth of each turn made in specified units.
        tet(i).turnDepth(j) = round(y*turnSize/tet(i).scale);
        
        iDeepestTurn = max(tet(i).turnDepth); %the turn index for the deepest depth.

        if displayAll; id_set = 1 : nTurns; end
        if displaySession; id_set = find(tet(i).turnStop>0); end
        if displayLast ; id_set = iDeepestTurn; end

%         %show all traces or the last two traces.
%         if displayALL || j == nTurns || j == iDeepestTurn
%             plot(linspace(x1,x2,5), ones(1,5)* y, c{:});
%         end
%         
%         if j == nTurns || j == iDeepestTurn || displayALL
        if any(j == id_set)
            plot(linspace(x1,x2,5), ones(1,5)* y, c{:});
            %display the turn value
            if isIncLabeled
                label_value = tet(i).turns(j)*tet(i).scale; %show the incremental size
            else
                label_value = y;  % show the total size.
            end
            
            if y <= YMAX && y >= YMIN
            %if tet(i).scale == 1 %'turn' in units
                %text(x1, y+ YMAX/70, sprintf('%.2f',label_value/tet(i).scale),'FontSize',8);
            %else
                text(x1, y- YMAX/70, sprintf('%d',round(label_value*turnSize/tet(i).scale)),'FontSize',8);
            %end
            end
        end
        
        if i == 1 && j == 1 ; hold on; end
    end
    plot((i-1)*ones(1,5),linspace(YMIN,YMAX,5),'Color',[0.7 0.1 0.1]);
  
end

hold off;

%set the depth range.
xlabel('Tetrodes');
ylabel('Depth');
ylim([YMIN YMAX]);
xlim([0 nTet]);
tickLabels = sprintf([repmat('%d|',1,24),'R1|R2|R3|R4'],1:24);
set(gca,'FontSize',10,'FontWeight','Bold','XTick',[1:nTet]-0.5,'XAxisLocation','top',...
    'YDir','reverse','XTickLabel',tickLabels,'TickLength',[0 2]);

%draw the histogram of tetrodes excluding the reference tetrodes.
d = zeros(1,nTet-4);
for i = 1 : length(d) 
    d(i) = tet(i).depth ;
end

%-----------------------
axes(handles.gui_hist);
cla;
%binSize = 250;
binSize = str2num(get(findobj('tag','binSize'),'String'));

edges = [-binSize:binSize:YMAX*turnSize/tet(1).scale];
%# compute center of bins (used as x-coord for labels)
bins = ( edges(1:end-1) + edges(2:end) ) / 2;
nBins = length(bins);

%# histc
[counts,binIdx] = histc(d, edges);
counts(end-1) = sum(counts(end-1:end));  %# combine last two bins
counts(end) = [];                        %# 
binIdx(binIdx==nBins+1) = nBins;         %# also fix the last bin index

%# plot histogram
bar(edges(1:end-1), counts, 'histc');
%#bar(bins, counts, 'hist')              %# same thing
ylabel('Count'), xlabel('Bins');

%# format the axis
set(gca, 'FontSize',7, ...
    'XLim',[edges(1) edges(end)], ...    %# set x-limit to edges
    'YLim',[0 2*max(counts)], ...        %# expand ylimit to accommodate labels
    'XTick',edges, ...                   %# set xticks  on the bin edges
    'XTickLabel',num2str(edges','%d'));  %'# round to 2-digits

%# add the labels, vertically aligned on top of the bars
hTxt = zeros(nBins,1);                   %# store the handles
for b=1:nBins
    hTxt(b) = text(bins(b), counts(b)+0.25, num2str(find(b==binIdx)), ...
        'FontWeight','bold', 'FontSize',7, 'EdgeColor','red', ...
        'VerticalAlignment','bottom', 'HorizontalAlignment','center');
end

%# set the y-limit according to the extent of the text
extnt = cell2mat( get(hTxt,'Extent') );
mx = max( extnt(:,2)+extnt(:,4) );       %# bottom+height
ylim([0 mx]);

%save tet data in handles
handles.tet = tet;
par.tet = tet;
%------------------------

% hist(handles.gui_hist,d,bins);
% set(gca,'XTickLabel',sprintf([repmat('%d|',1,nbins)], bins));

% --- Outputs from this function are returned to the command line.
function varargout = ttshow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function gui_report_Callback(hObject, eventdata, handles)
% hObject    handle to gui_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gui_report as text
%        str2double(get(hObject,'String')) returns contents of gui_report as a double


% --- Executes during object creation, after setting all properties.
function gui_report_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gui_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global par;

[fileName pathName] = uigetfile('*.xls','Choose Excel Source File (*.xls)...');
excelFileFullPath = [pathName fileName];
if excelFileFullPath==0;
    %clear variables;
    disp('No file was selected.');
    return
end

handles.par.sourceFile = excelFileFullPath;

%update last modified data
d = dir(handles.par.sourceFile);
handles.par.sourceLastModified = d.datenum;

set(findobj('tag','gui_report'),'string',sprintf('%s',excelFileFullPath));

guidata(hObject,handles);

par = handles.par;


% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = updateDisplay(handles);

%if timer is set to auto, start the timer
if strcmpi(get(handles.par.RST,'Running'),'off') && get(findobj('tag','auto_update'),'Value')
    start(handles.par.RST);
end

guidata(hObject,handles);

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%delete the timer
try
    stop(handles.par.RST);
    delete(handles.par.RST);
catch
end

close(gcf);

% --- Executes on button press in auto_update.
function auto_update_Callback(hObject, eventdata, handles)
% hObject    handle to auto_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_update

%set(hObject,'Value',~get(hObject,'Value'));

if get(hObject,'Value')
    %start the timer
    start(handles.par.RST);
else
    stop(handles.par.RST);
end

guidata(hObject,handles);

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.par.sourceFile)
    return;
end

global par;

[pathstr filename ext]=fileparts(handles.par.sourceFile); 

saveFile = fullfile(pathstr,[filename,'_ttshow','.png']);

set(gcf,'PaperPositionMode','auto');

print(gcf,'-r300', '-dpng', saveFile);

fprintf('Screen shot saved in %s\n',saveFile);

%save tetrode depth data
tet = par.tet;

saveTetFile = fullfile(pathstr,[filename,'_ttshow_tetrodeDepth','.mat']);

save(saveTetFile,'tet');

function ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double
%if YMAX/YMIN in um units,update the handles
if get(findobj('tag','units_um'),'Value')
    handles.par.YMAX = str2num(get(hObject,'String'));
    %handles.par.YMIN = YMIN;
end    


% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in units_um.
function units_um_Callback(hObject, eventdata, handles)
% hObject    handle to units_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of units_um

set(findobj('tag','units_turns'),'Value',~get(hObject,'Value'));

h_ymax = findobj('tag','ymax');
h_ymin = findobj('tag','ymin');
if get(hObject,'Value')
    %reset the YMax
    set(h_ymax,'String',num2str(handles.par.YMAX));
    set(h_ymin,'String',num2str(handles.par.YMIN));
end


% --- Executes on button press in units_turns.
function units_turns_Callback(hObject, eventdata, handles)
% hObject    handle to units_turns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of units_turns

set(findobj('tag','units_um'),'Value',~get(hObject,'Value'));

h_ymax = findobj('tag','ymax');
h_ymin = findobj('tag','ymin');
if get(hObject,'Value')
    %reset the YMax
    set(h_ymax,'String',num2str(15));
    set(h_ymin,'String',num2str(-2));
end

% --- Executes on button press in ref_inbrain.
function ref_inbrain_Callback(hObject, eventdata, handles)
% hObject    handle to ref_inbrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ref_inbrain

set(findobj('tag','ref_zeroturn'),'Value',~get(hObject,'Value'));

% --- Executes on button press in ref_zeroturn.
function ref_zeroturn_Callback(hObject, eventdata, handles)
% hObject    handle to ref_zeroturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ref_zeroturn

set(findobj('tag','ref_inbrain'),'Value',~get(hObject,'Value'));

% --- Executes on button press in display_last.
function display_last_Callback(hObject, eventdata, handles)
% hObject    handle to display_last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_last

set(findobj('tag','display_all'),'Value',~get(hObject,'Value'));
set(findobj('tag','display_session'),'Value',~get(hObject,'Value'));

% --- Executes on button press in display_all.
function display_all_Callback(hObject, eventdata, handles)
% hObject    handle to display_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_all

set(findobj('tag','display_last'),'Value',~get(hObject,'Value'));
set(findobj('tag','display_session'),'Value',~get(hObject,'Value'));


function ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double

%if YMAX/YMIN in um units,update the handles
if get(findobj('tag','units_um'),'Value')
    %handles.par.YMAX = YMAX;
    handles.par.YMIN = str2num(get(hObject,'String'));
end    


% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in label_increment.
function label_increment_Callback(hObject, eventdata, handles)
% hObject    handle to label_increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of label_increment

set(findobj('tag','label_total'),'Value',~get(hObject,'Value'));


% --- Executes on button press in label_total.
function label_total_Callback(hObject, eventdata, handles)
% hObject    handle to label_total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of label_total

set(findobj('tag','label_increment'),'Value',~get(hObject,'Value'));


function worksheet_index_Callback(hObject, eventdata, handles)
% hObject    handle to worksheet_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of worksheet_index as text
%        str2double(get(hObject,'String')) returns contents of worksheet_index as a double


% --- Executes during object creation, after setting all properties.
function worksheet_index_CreateFcn(hObject, eventdata, handles)
% hObject    handle to worksheet_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binSize_Callback(hObject, eventdata, handles)
% hObject    handle to binSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binSize as text
%        str2double(get(hObject,'String')) returns contents of binSize as a double

%if YMAX/YMIN in um units,update the handles

handles.par.binSize = str2num(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function binSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in display_session.
function display_session_Callback(hObject, eventdata, handles)
% hObject    handle to display_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_session

set(findobj('tag','display_all'),'Value',~get(hObject,'Value'));
set(findobj('tag','display_last'),'Value',~get(hObject,'Value'));
