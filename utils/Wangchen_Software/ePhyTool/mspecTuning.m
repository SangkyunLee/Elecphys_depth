function h = mspecTuning(t,s)

n = length(s); %number of channels.

fields = fieldnames(s);
verify = {'data','id'};

for i = 1 : length(verify)
    if isempty(strmatch(verify{i},fields,'exact'))
        fprintf('mspecTuning : require field ''%s'' in the struct \n',verify{i});
        return;
    end
end

dim = ndims(s(1).data);
siz = size(s(1).data);
samples = siz(3);
if isempty(t); t= 1:samples; end;

%n = length(s); %number of channels.

plt = 1;

%save params in packed struct and set in userdata of slider handle.
sta = struct('ndims',dim,'samples',samples,'channels',n,'plot',plt,...
    'time',t,'array',s,...
    'firstcall',true);

fullscreen = get(0,'ScreenSize');
%full screen figure;
h = figure('Name','STA Viewer',...
        'Position',[20 fullscreen(4)*0.1 fullscreen(3)-20 fullscreen(4)*0.8]);

set(gcf,'doublebuffer','on');%avoid flickering while updating plot
% Generate constants for use in uicontrol initialization
pos=get(gca,'position');
% This will create a slider which is just underneath the axis
% but still leaves room for the axis labels above the slider
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.03];

% Creating Uicontrol of time-slice slider
hs = uicontrol('Parent',gcf,...
    'style','slider',...
    'units','normalized','position',Newpos,...
    'tag','time_slider'...
    );

set(hs,'userdata',sta); %save sta to handle
set(hs,'callback',@mspecSTAViewer);
%save old value of slider
setappdata(0,'mspecSTA_slider',get(hs,'value'));
setappdata(0,'mspecSTA_index',1);
%init the plot.
mspecSTAViewer(hs,[],guidata(h));

function mspecSTAViewer(hObject,eventdata,handles)

sta = get(hObject,'userdata');

%number of channels
n = sta.channels;
%cerebus map
global cmap
%
if ~exist('cmap','var') || isempty(cmap)
%     %preset 24ch view.
%     pc = 6;
%     %pr = 4;
%     pr = ceil(n/pc);
%     pn = pr*pc;
    nCol = 6;
    nRow = 4;
    nChan = nCol * nRow;
   
else
    nCol = max(cmap(:,1))+1;
    nRow = max(cmap(:,2))+1;
    nChan = length(cmap(:,3));
    
end
%range of slider values.
xmin = get(hObject,'min');
xmax = get(hObject,'max');
%slider position.
sv = get(hObject,'value');

switch sta.plot
    case 0
        %no plot
        return;
    case 1 %1d plot
        if sta.firstcall %plot once only
            for i = 1 : n
                elecID = sta.array(i).id;
                %
                mapID = find(cmap(:,3)==elecID);
                %
                rowID = nRow - cmap(mapID,2);
                %
                colID = cmap(mapID,1) + 1;
                subplot(nRow,nCol,mapID);
                %plot(sta.array(i).data);
                %mark the maximum location ?
                siz=size(sta.array(i).data);
                sort_units = siz(2);
                
                for j = 1 : sort_units
                    mfr = squeeze(sta.array(i).data(1,j,:));
                    vfr = squeeze(sta.array(i).data(2,j,:));
                    [my,mx]=max(mfr);
                    plot(sta.time,mfr,'bs-',...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor',[.49 1 .63],...
                        'MarkerSize',3);
                    hold on;
                    plot(mx,my,'ro');
                end
                title(sprintf('Ch%d',sta.array(i).id));
            end
            sta.firstcall = false; %reset the flag.
            set(hObject,'userdata',sta);
        end
    case 2
        %index in sta time sequence
        idx = round(1 + sta.samples*(sv - xmin)/(xmax-xmin));
        %old position
        osv = getappdata(0,'mspecSTA_slider');
        %old index
        oidx = getappdata(0,'mspecSTA_index');
        %sliding direction
        if sv > osv
            %index in sta sampling time sequence.
            if idx <= oidx; idx = idx + 1; end %move at least 1 pos up
            idx = min(idx,sta.samples);
        else
            if idx >= oidx; idx = idx - 1; end %at least 1 pos down
            idx = max(1,idx);
        end
        %nearest slider value corresonding to idx
        nsv = xmin + (idx-1)*(xmax-xmin)/(sta.samples-1);
        nsv = min(nsv,xmax);
        set(hObject,'value',nsv); %set slider in position.
        setappdata(0,'mspecSTA_slider',nsv);
        setappdata(0,'mspecSTA_index',idx);
        
        dotNumX = size(sta.array(1).data,1);
        dotNumY = size(sta.array(1).data,2);
        
        [x,y] = ndgrid(1:dotNumX,dotNumY:-1:1);
                
        for i = 1 : n
                elecID = sta.array(i).id;
                %
                mapID = find(cmap(:,3)==elecID);
                %
                rowID = nRow - cmap(mapID,2);
                %
                colID = cmap(mapID,1) + 1;
                subplot(nRow,nCol,mapID);
%             subplot(pr,pc,i);
            
            %I,J are index into screen coordiante array, i.e, x towards
            %right, y goes downwards.
            [maxV,maxI]=max(sta.array(i).data(:,:,idx));
            [maxV,maxJ]=max(maxV);
            maxI = maxI(maxJ);
            [minV,minI]=min(sta.array(i).data(:,:,idx));
            [minV,minJ]=min(minV);
            minI = minI(minJ);

            %shown in view-coordinates (x-right,y-up)
            pcolor(x,y,(sta.array(i).data(:,:,idx)));axis image;
            hold on;
            plot(minI+0.5,dotNumY-minJ+1-0.5,'ko');plot(maxI+0.5,dotNumY-maxJ+1-0.5,'wo');
            title(sprintf('Ch%d,Slice%d,Max(%d,%d),Min(%d,%d)',sta.array(i).id,idx,...
                maxI,dotNumY-maxJ+1,minI,dotNumY-minJ+1));
            %mark the min/max location
            hold off;

        end
end
        
    
