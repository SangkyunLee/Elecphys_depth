function varargout = viewChamberCenter(varargin)
% VIEWCHAMBERCENTER M-file for viewChamberCenter.fig
%      VIEWCHAMBERCENTER, by itself, creates a new VIEWCHAMBERCENTER or raises the existing
%      singleton*.
%
%      H = VIEWCHAMBERCENTER returns the handle to a new VIEWCHAMBERCENTER or the handle to
%      the existing singleton*.
%
%      VIEWCHAMBERCENTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWCHAMBERCENTER.M with the given input arguments.
%
%      VIEWCHAMBERCENTER('Property','Value',...) creates a new VIEWCHAMBERCENTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewChamberCenter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewChamberCenter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewChamberCenter

% Last Modified by GUIDE v2.5 28-Jul-2010 18:41:16

% Begin initialization code - DO NOT EDIT

% Mani Subramaniyan 2009-06-26
% Note that a lot of the functions in this gui are not related to the function this gui performs
% since I copied and modified another gui to create this one. Sorry about that.


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewChamberCenter_OpeningFcn, ...
                   'gui_OutputFcn',  @viewChamberCenter_OutputFcn, ...
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


% --- Executes just before viewChamberCenter is made visible.
function viewChamberCenter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewChamberCenter (see VARARGIN)

% Choose default command line output for viewChamberCenter
handles.output = hObject;
% handles.fileDir = 'Y:\structural\Ben\052407\Raw\head^Tolias\2007-05-24\204522-xxBX052407_3\007-AVERAGE';
handles.fileDir = getLocalPath('Y:\structural');
% handles.point = [300 365 4*12];
% set(handles.locX,'String',num2str(300));
% set(handles.locY,'String',num2str(365));
% set(handles.locZ,'String',num2str(12));
% handles.radius = 10;
% set(handles.chamberRadius,'String',num2str(10));
% handles.seeItOutSide = false;
% % Update handles structure
handles.mmPerPixelX = 0.25; 
handles.mmPerPixelY = 0.25; 
handles.mmPerPixelZ = 1; 
handles.isChamberOnLeft = false;
handles.isChamberOnRight = true;
handles.isLeftIsRight = true;

set(handles.leftIsRight,'Value',handles.isLeftIsRight);
set(handles.chamberOnLeft,'Value',handles.isChamberOnLeft);
set(handles.chamberOnRight,'Value',handles.isChamberOnRight);

set(handles.millimeterPerPixelX,'String',num2str(handles.mmPerPixelX))
set(handles.millimeterPerPixelY,'String',num2str(handles.mmPerPixelY))
set(handles.millimeterPerPixelZ,'String',num2str(handles.mmPerPixelZ))
guidata(hObject, handles);

% UIWAIT makes viewChamberCenter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewChamberCenter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectImageDir.
function selectImageDir_Callback(hObject, eventdata, handles)
% hObject    handle to selectImageDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dn = uigetdir(getLocalPath('Y:\structural\'),'select a Folder');
% fn and pn value will be zero if the user cancels the dialog.
if dn~=0
    handles.fileDir = dn;    
end
guidata(hObject, handles);



function TopSliceNumber_Callback(hObject, eventdata, handles)
% hObject    handle to TopSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TopSliceNumber as text
%        str2double(get(hObject,'String')) returns contents of TopSliceNumber as a double
handles.TopSliceNumber = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function TopSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TopSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BottomSliceNumber_Callback(hObject, eventdata, handles)
% hObject    handle to BottomSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BottomSliceNumber as text
%        str2double(get(hObject,'String')) returns contents of BottomSliceNumber as a double
handles.BottomSliceNumber = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function BottomSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BottomSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadImages.
function loadImages_Callback(hObject, eventdata, handles)
% hObject    handle to loadImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[foo topSliceNum] = fileparts(handles.topSliceFile);
[foo bottomSliceNum fileExtn] = fileparts(handles.bottomSliceFile);

handles.fileExtension = fileExtn;
handles.fileNameLength = length(topSliceNum);
handles.top = str2double(topSliceNum(end-1:end));
handles.bottom= str2double(bottomSliceNum(end-1:end));
handles.filePrefix = topSliceNum(1:end-2);
sn = sign(handles.top - handles.bottom);
% slices = handles.TopSliceNumber:sn:handles.BottomSliceNumber;
slices = handles.bottom:sn:handles.top;
handles.sliceOrderBottomToTop = slices;
handles.im = loadSet(handles);
guidata(hObject,handles)

% --- Executes on button press in skullExtraction.
function skullExtraction_Callback(hObject, eventdata, handles)
% hObject    handle to skullExtraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

top = handles.TopSliceNumber;
bottom = handles.BottomSliceNumber;
im = handles.im;
mid = round(abs(top-bottom)/2);
th = thresh_tool(im(:,:,mid));

handles.skull = extractSkull(handles,th);
guidata(hObject,handles)

% --- Executes on slider movement.
function selectTh_Callback(hObject, eventdata, handles)
% hObject    handle to selectTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

top = handles.TopSliceNumber;
bottom = handles.BottomSliceNumber;
mid = round(abs(top-bottom)/2);

forHist = handles.im(:,:,mid);
forHist = double(forHist(:));
axes(handles.cdataHistogram)
hist(double(forHist),200);

mini = min(forHist);
maxi = max(forHist);

th = mini + (maxi-mini)*get(hObject,'Value');

handles.finalBrain = polishBrain(handles,th);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function selectTh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in closeImage.
function closeImage_Callback(hObject, eventdata, handles)
% hObject    handle to closeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.closedMask = im2uint16(imclose(handles.currentMask,strel('disk',15)));
showMontage((handles.closedMask),handles.currentSlice);
guidata(hObject,handles)

% --- Executes on slider movement.
function removeAir_Callback(hObject, eventdata, handles)
% hObject    handle to removeAir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

top = handles.TopSliceNumber;
bottom = handles.BottomSliceNumber;
mid = round(abs(top-bottom)/2);

forHist = handles.im(:,:,mid);
forHist = double(forHist(:));
% axes(handles.cdataHistogram)
% hist(double(forHist),200);

mini = min(forHist);
maxi = max(forHist);

th = mini + (maxi-mini)*get(hObject,'Value');

[handles.outside handles] = mapOutAir(handles,th);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function removeAir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to removeAir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in passToSkullExtraction.
function passToSkullExtraction_Callback(hObject, eventdata, handles)
% hObject    handle to passToSkullExtraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.toSkull = handles.outside;
guidata(hObject,handles)


function bigObjects_Callback(hObject, eventdata, handles)
% hObject    handle to bigObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bigObjects as text
%        str2double(get(hObject,'String')) returns contents of bigObjects as a double


% --- Executes during object creation, after setting all properties.
function bigObjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bigObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on slider movement.
function selectedSliceNumber_Callback(hObject, eventdata, handles)
sliderVal = get(hObject,'Value');
handles.currentSliceNumber = ceil(((length(handles.sliceOrderBottomToTop)*sliderVal)));
if handles.currentSliceNumber==0
    handles.currentSliceNumber = 1;
end
showCurrentSlice(handles,handles.currentSlice);
set(handles.punchedSliceNumber,'String',num2str(handles.currentSliceNumber));
guidata(hObject,handles)
% --- Executes during object creation, after setting all properties.
function selectedSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectedSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function punchedSliceNumber_Callback(hObject, eventdata, handles)
% hObject    handle to punchedSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentSliceNumber = str2double(get(hObject,'String'));
% set(handles.selectedSliceNumber,'Value',handles.currentSliceNumber);
showCurrentSlice(handles,handles.currentSlice);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function punchedSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to punchedSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in seeitHere.
function seeitHere_Callback(hObject, eventdata, handles)
axes(handles.finalImage);
D = handles.finalBrain;
D(D~=20000) = 5;
Ds = smooth3(D);
% Cut hole:
point = handles.point;
radius = handles.radius*4;
[X Y Z] = meshgrid((1:size(D,2)),(1:size(D,1)),4*(1:size(D,3)));
R = sqrt((X-point(1)).^2 + (Y-point(2)).^2 + (Z-point(3)).^2);
Ds(R>(radius-2) & R < radius) = 10000;


hiso = patch(isosurface(Ds,5,'verbose'),...
 'FaceColor',[1,.75,.65],...
 'EdgeColor','none');
daspect([1 1 0.25])
lightangle(45,30); 
set(gcf,'Renderer','zbuffer'); lighting phong
% isonormals(Ds,hiso)
set(hiso,'SpecularColorReflectance',0,'SpecularExponent',50)
view(118,52)


% --- Executes on slider movement.
function brainTh_Callback(hObject, eventdata, handles)
% hObject    handle to brainTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sv = 10 + 500*get(hObject,'Value');
handles.bth = sv;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function brainTh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brainTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function chamberRadius_Callback(hObject, eventdata, handles)
% hObject    handle to chamberRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chamberRadius as text
%        str2double(get(hObject,'String')) returns contents of chamberRadius as a double
handles.radius = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function chamberRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chamberRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function locX_Callback(hObject, eventdata, handles)
% hObject    handle to locX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of locX as text
%        str2double(get(hObject,'String')) returns contents of locX as a double
handles.point(1) = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function locX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to locX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function locY_Callback(hObject, eventdata, handles)
% hObject    handle to locY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of locY as text
%        str2double(get(hObject,'String')) returns contents of locY as a double
handles.point(2) = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function locY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to locY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function locZ_Callback(hObject, eventdata, handles)
% hObject    handle to locZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of locZ as text
%        str2double(get(hObject,'String')) returns contents of locZ as a double
handles.point(3) = 4*str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function locZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to locZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in extractTheBrain.
function extractTheBrain_Callback(hObject, eventdata, handles)
handles.brain = extractBrain(handles);
guidata(hObject,handles);


% --- Executes on button press in saveBrainAs.
function saveBrainAs_Callback(hObject, eventdata, handles)
% hObject    handle to saveBrainAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('*.mat','Save Brain As');
b = handles.finalBrain;
save(fullfile(path,file),'b');


% --- Executes on button press in loadBrain.
function loadBrain_Callback(hObject, eventdata, handles)
% hObject    handle to loadBrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.mat','Select a Brain file');
if file~=0
f = load(fullfile(path,file));
fi = fields(f);
handles.brainData = f.(fi{:});
handles.finalBrain = handles.brainData.data;
guidata(hObject,handles);
showMontage(handles.finalBrain,handles.currentSlice)
end





% Sub-Functions:
%==========================================================================
function im = loadSet(handles,varargin)
% Load the files
nFiles = length(handles.sliceOrderBottomToTop);
% patStr = ['%0.' num2str(handles.fileNameLength) 'd' handles.fileExtension];
for iFile = 1:nFiles
    imageFile = [handles.filePrefix num2str(handles.sliceOrderBottomToTop(iFile)) handles.fileExtension];
%     imageFile = sprintf(patStr,handles.sliceOrderBottomToTop(iFile));
    fname = fullfile(handles.fileDir,imageFile);
    switch handles.fileExtension
        case {'.png','.jpg','.jpeg','.gif','.tiff','.tif'}
            imdata = imread(fname);
            if handles.isLeftIsRight
                im(:,:,iFile) = fliplr(imdata(:,:,1));
            else
                im(:,:,iFile) = imdata(:,:,1);
            end
        case {'.ima','.dcm','.IMA','.DCM'}
            imdata = double(dicomread(fname));
            imdata = uint8(imdata*double(intmax('uint8'))/max(max(imdata)));
            
            if handles.isLeftIsRight
                im(:,:,iFile) = fliplr(imdata(:,:,1));
            else
                im(:,:,iFile) = imdata(:,:,1);
            end
    end
        a = waitbar(iFile/nFiles);
end
close(a)

handles.currentIm = im;
showMontage(im,handles.originalMontage)

%--------------------------------------------------------------------------
function showMontage(im,axisHandle)
for i = 1:size(im,3)
    im2(:,:,1,i) = im(:,:,i);
end
axes(axisHandle)
cla
montage(im2);

%--------------------------------------------------------------------------
function brain = extractBrain(handles)

% skull = cleanUpForSteffan(handles.skull);
mk = im2uint16(imclose(handles.currentMask,strel('disk',15)));
skullFilled = imfill(mk,4,'holes');
brainMask = skullFilled & ~mk;
brainMask = bwlabeln(brainMask);

% pick biggest connected region
r = regionprops(brainMask);
area = [r.Area];
[foo idx] = max(area);
brainMask = brainMask == idx;

brain = handles.im;
brain(~brainMask) = 0;
showMontage(brain,handles.currentSlice)

function [airmap handles] = mapOutAir(handles,th)

% map out air around animal
airmap = handles.im;
L = bwlabeln(airmap < th,6);

stats = regionprops(L,'Area');
A = [stats.Area];
biggest = find(A==max(A));
outside = (L==biggest);
airmap(outside) = uint16(60000);
showMontage(airmap,handles.currentSlice)
[s ind] = sort(A,'descend');
handles.objectsOfInt = ind(1:6);
set(handles.bigObjects,'String',mat2str(s(1:8)));
handles.L = L;


% --- Executes on button press in seeItOutside.
function seeItOutside_Callback(hObject, eventdata, handles)
% hObject    handle to seeItOutside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

D = handles.finalBrain;
D(D~=20000) = 5;
Ds = smooth3(D);
% Cut hole:
point = handles.point;
radius = handles.radius*4;
[X Y Z] = meshgrid((1:size(D,2)),(1:size(D,1)),4*(1:size(D,3)));
R = sqrt((X-point(1)).^2 + (Y-point(2)).^2 + (Z-point(3)).^2);
Ds(R>(radius-2) & R < radius) = 10000;

% Mark the fundus
% Get the coordinates for brain surface penetration points for reaching the
% fundus of lunate sulcus.
absSliceNum = handles.brainData.sliceOrderOfData;
absFundusSliceNum = [handles.brainData.v2FundusNormals.sliceNum];
[c1 z] = intersect(absSliceNum,absFundusSliceNum); 
x = [handles.brainData.v2FundusNormals.x];
y = [handles.brainData.v2FundusNormals.y];

figure
hiso = patch(isosurface(Ds,5),...
 'FaceColor',[1,.75,.65],...
 'EdgeColor','none');
daspect([1 1 0.25])
lightangle(45,30); 
set(gcf,'Renderer','zbuffer'); lighting phong
% isonormals(Ds,hiso)
set(hiso,'SpecularColorReflectance',0,'SpecularExponent',50)
% view(118,52)
view(125,30)
hold on
plot3(x,y,z,'r.','MarkerSize',10);



function MedioLateralDist_Callback(hObject, eventdata, handles)
% hObject    handle to MedioLateralDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.medioLateralDistance = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function MedioLateralDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MedioLateralDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AnterioPosteriorDist_Callback(hObject, eventdata, handles)
% hObject    handle to AnterioPosteriorDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.anterioPosteriorDistance = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function AnterioPosteriorDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnterioPosteriorDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function showCurrentSlice(handles,axisHandle)
imMatrix = handles.im(:,:,handles.currentSliceNumber);
if get(handles.seeOutsideRadioButton,'Value')
    figure(12345)
else
    axes(handles.currentSlice)
end
imshow(imMatrix);



function millimeterPerPixelX_Callback(hObject, eventdata, handles)
% hObject    handle to millimeterPerPixelX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of millimeterPerPixelX as text
%        str2double(get(hObject,'String')) returns contents of millimeterPerPixelX as a double

handles.mmPerPixelX = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function millimeterPerPixelX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to millimeterPerPixelX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function millimeterPerPixelY_Callback(hObject, eventdata, handles)
% hObject    handle to millimeterPerPixelY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of millimeterPerPixelY as text
%        str2double(get(hObject,'String')) returns contents of millimeterPerPixelY as a double

handles.mmPerPixelY = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function millimeterPerPixelY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to millimeterPerPixelY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function millimeterPerPixelZ_Callback(hObject, eventdata, handles)
% hObject    handle to millimeterPerPixelZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of millimeterPerPixelZ as text
%        str2double(get(hObject,'String')) returns contents of millimeterPerPixelZ as a double

handles.mmPerPixelZ = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function millimeterPerPixelZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to millimeterPerPixelZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectFrankfurtZeroPoint.
function selectFrankfurtZeroPoint_Callback(hObject, eventdata, handles)
% hObject    handle to selectFrankfurtZeroPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.currentSlice)
[x y] = ginput(1);
handles.frankfurtZeroXYpixels = [x y];
locStr = sprintf('%d,',(round([x y])));
locStr = locStr(1:end-1);
set(handles.displayFrankfurtZeroPoint,'String',locStr);
handles.frankfurtZeroSliceNumber = handles.currentSliceNumber;
guidata(hObject,handles)


% --- Executes on button press in showChamberCenter.
function showChamberCenter_Callback(hObject, eventdata, handles)
% hObject    handle to showChamberCenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xy = handles.frankfurtZeroXYpixels;
if get(handles.seeOutsideRadioButton,'Value')
    figure(12345)
else
    axes(handles.currentSlice)
end
if handles.isChamberOnLeft
    cx = xy(1) - handles.medioLateralDistance * (1/handles.mmPerPixelX);
    cy = xy(2) + handles.anterioPosteriorDistance * (1/handles.mmPerPixelY);
    hold on;
    plot(cx,cy,'go','MarkerFaceColor','g','MarkerSize',5)
    chamberCenter(1,[1 2]) = [cx cy];
end
if handles.isChamberOnRight
    cx = xy(1) + handles.medioLateralDistance * (1/handles.mmPerPixelX);
    cy = xy(2) + handles.anterioPosteriorDistance * (1/handles.mmPerPixelY);
    hold on;
    plot(cx,cy,'go','MarkerFaceColor','g','MarkerSize',5)
    if handles.isChamberOnLeft
        chamberCenter(2,[1 2]) = [cx cy];
    else
        chamberCenter(1,[1 2]) = [cx cy];
    end
end
locStr = sprintf('%d,',(round(chamberCenter)));
locStr = locStr(1:end-1);
set(handles.displayChamberCenterLoc,'String',locStr);

% --- Executes on button press in leftIsRight.
function leftIsRight_Callback(hObject, eventdata, handles)
% hObject    handle to leftIsRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of leftIsRight
 handles.isLeftIsRight = get(hObject,'Value');
 guidata(hObject,handles);


% --- Executes on button press in chamberOnLeft.
function chamberOnLeft_Callback(hObject, eventdata, handles)
% hObject    handle to chamberOnLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chamberOnLeft
 handles.isChamberOnLeft = get(hObject,'Value');
 guidata(hObject,handles)

% --- Executes on button press in chamberOnRight.
function chamberOnRight_Callback(hObject, eventdata, handles)
% hObject    handle to chamberOnRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chamberOnRight
 handles.isChamberOnRight = get(hObject,'Value');
 guidata(hObject,handles)



function displayFrankfurtZeroPoint_Callback(hObject, eventdata, handles)
% hObject    handle to displayFrankfurtZeroPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayFrankfurtZeroPoint as text
%        str2double(get(hObject,'String')) returns contents of displayFrankfurtZeroPoint as a double


% --- Executes during object creation, after setting all properties.
function displayFrankfurtZeroPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayFrankfurtZeroPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function displayChamberCenterLoc_Callback(hObject, eventdata, handles)
% hObject    handle to displayChamberCenterLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayChamberCenterLoc as text
%        str2double(get(hObject,'String')) returns contents of displayChamberCenterLoc as a double


% --- Executes during object creation, after setting all properties.
function displayChamberCenterLoc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayChamberCenterLoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectBottomImageSlice.
function SelectBottomImageSlice_Callback(hObject, eventdata, handles)
% hObject    handle to SelectBottomImageSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileName = uigetfile('*.*','Select Bottom Image File',handles.fileDir);
% fn and pn value will be zero if the user cancels the dialog.
if fileName ~=0
    handles.bottomSliceFile = fileName;  
    set(handles.BottomSliceNumber,'String',fileName);
end
guidata(hObject, handles);


% --- Executes on button press in selectTopImageSlice.
function selectTopImageSlice_Callback(hObject, eventdata, handles)
% hObject    handle to selectTopImageSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileName = uigetfile('*.*','Select Top Image File',handles.fileDir);
% fn and pn value will be zero if the user cancels the dialog.
if fileName ~=0
    handles.topSliceFile = fileName;
    set(handles.TopSliceNumber,'String',fileName);
end
guidata(hObject, handles);


% --- Executes on button press in selAndDispCustomImageButton.
function selAndDispCustomImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to selAndDispCustomImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[fileName pathName] = uigetfile('*.*','Select Bottom Image File',getLocalPath('y:\structural\'));
if get(handles.seeOutsideRadioButton,'Value')
    figure(12345)
else
    axes(handles.currentSlice)
end
imageData = imread(fullfile(pathName,fileName));
if handles.leftIsRight
    imageData = fliplrn(imageData);
end
imshow(imageData);


% --- Executes on button press in seeOutsideRadioButton.
function seeOutsideRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to seeOutsideRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of seeOutsideRadioButton


