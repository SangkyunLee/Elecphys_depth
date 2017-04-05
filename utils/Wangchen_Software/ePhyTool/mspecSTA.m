function [ h ] = mspecSTA(t,neurons,v)
% function [ h ] = mspecSTA(t,s)
% Usage : h = msepcSTA(s)
%         h = mspecSTA(t,s)
%multi-ch spectrum view of sta - WW2010
%
% %t - sta time. 2d data matrix.
% %s - struct array of sta computed by doSTA.
% %    s.data: sta data array.
% %    s.id  : sta channel id. 
% %h - return the figure handle
%
% t - sta time elements
% neurons -- data structure with sta computed for each unit 
% v --- view options

h = [];
n = length(neurons); %number of channels.
if n == 0; return; end

% fields = fieldnames(s);
% verify = {'data','id'};
% 
% for i = 1 : length(verify)
%     if isempty(strmatch(verify{i},fields,'exact'))
%         fprintf('mspecSTA : require field ''%s'' in the struct \n',verify{i});
%         return;
%     end
% end

% %dimension of plotting data. 1 for 1d vector; 2 for 2d image. 
% plt = v.plotdim;
%trim neurons structure to 'sta' field, striping off other data fields.
s = neurons;
%
for i = 1 : n
    s{i}.timestamps =[];
    for j = 1 : length(s{i}.clusters)
        s{i}.clusters{j}.timestamps = [];
        for k = 1 : length(s{i}.clusters{j}.class)
            for m = 1 : length(s{i}.clusters{j}.class{k}.member)
                s{i}.clusters{j}.class{k}.member{m}.timestamps = [];
            end
        end
    end
end

%save params in packed struct and set in userdata of slider handle.
sta = struct('channels',n,'plot',v,...
    'time',t,...
    'firstcall',true);
%save s into cell
sta.array{1} = s;

fullscreen = get(0,'ScreenSize');
%full screen figure;
h = figure('Name','STA Viewer',...
        'Position',[20 fullscreen(4)*0.1 fullscreen(3)/2 fullscreen(4)*0.85]);

set(gcf,'doublebuffer','on');%avoid flickering while updating plot
% Generate constants for use in uicontrol initialization
pos=get(gca,'position');
% This will create a slider which is just underneath the axis
% but still leaves room for the axis labels above the slider
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.02];


%pos_pushbutton = bsxfun(@times,Newpos,[0.3 0.3 0.1 0.1]);


% Creating Uicontrol of time-slice slider
hs = uicontrol('Parent',gcf,...
    'style','slider',...
    'units','normalized','position',Newpos,...
    'tag','time_slider'...
    );

%placed above the slider
SliderLabelPos = [pos(1) pos(2)-0.07 pos(3) 0.03];

%slider label
slabel = uicontrol('Parent',gcf,...
    'style','edit',...
    'string','show me',...
    'enable','inactive',...
    'units','normalized','position',SliderLabelPos,...
    'tag','slider_label'...
    );

set(hs,'userdata',sta); %save sta to handle
set(hs,'callback',@mspecSTAViewer);
%save old value of slider
setappdata(0,'mspecSTA_slider',get(hs,'value'));
setappdata(0,'mspecSTA_index',1);

pos_pushbutton = [20 20 50 20];
      
hpb = uicontrol('Parent',gcf,'Style','pushbutton',...
       'tag','saveplot_pb',...
    'position',pos_pushbutton,...
    'String','SavePlot');

%set(hpb,'Callback',@savePlot);
%guidata(hpb,h);
set(hpb,'userdata',sta);
set(hpb,'Callback',{@(hObject,eventdata)savePlot(hpb,[],guidata(h))});

%init the plot.
mspecSTAViewer(hs,[],guidata(h));


function savePlot(hObject,eventdata,handles)
%
global idx; 

h = get(0,'CurrentFigure') ;
sta = get(hObject,'userdata');
v = sta.plot;
%handles was empty ? find it through slider handle
%hpb = findobj(get(hObject,'Parent'),'tag','saveplot_pb');

fn = fullfile(v.saveFolder,sprintf('%s_Lag%.1f_sec.png',v.plot,sta.time(idx)));

export_style = hgexport('readstyle','powerpoint');
export_style.Format = 'png';

figure(h);
set(gcf,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ;hgexport(gcf,fn,export_style); end

h2 = compute_stats(sta,idx);

fn = fullfile(v.saveFolder,sprintf('%s_Lag%.1f_sec_RFCenter.png',v.plot,sta.time(idx)));
figure(h2);
set(gcf,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ;hgexport(gcf,fn,export_style); end

%compute the max/min values from all channels and overlay them in one map.
function h = compute_stats(sta,idx)

global rfchan; %tetrodes to plot r.f centers.

neurons = sta.array{1};

h = figure('name','rf centers'); hold on;

for i = 1 : length(neurons)
    
            ch = neurons{i}.channel;
            if ~isempty(rfchan) && ~any(ch==rfchan)
                continue;
            end

            a = neurons{i}.clusters{1}.class{1}.member{1}.sta(:,:,idx);
            [nx,ny,nt] = size(a);
            [maxa,maxi] = max(a(:));
            [mina,mini] = min(a(:));
            stda = std(a(:));
            avga = mean(a(:));
            if abs(maxa-avga) > abs(mina-avga)
                cen = maxa;
                ceni = maxi;
                color = 'r';
            else
                cen = mina;
                ceni = mini;
                color = 'b';
            end
            %set up some screening
            if abs(cen-avga)< 3*stda; continue; end
            [x,y]= ind2sub([nx,ny],ceni);
            plot(x,y,'+','color',color);
            
            text(x+0.2,y,num2str(ch));
            
            fprintf('%d mean=%f std=%f cen=%f cen-avg/std=%f\n', ch,avga,stda,cen,abs(cen-avga)/stda);
     
end

axis equal;
xlim([1,nx]); ylim([1,ny]);    
set(gca,'YDir','reverse');

function mspecSTAViewer(hObject,eventdata,handles)

global idx; 

sta = get(hObject,'userdata');
%handles was empty ? find it through slider handle
h_slabel = findobj(get(hObject,'Parent'),'tag','slider_label');

%cerebus map array
global cmap
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


%number of channels
n = sta.channels;
%
viewOption = sta.plot;
%view multi-unit-activity. true: draw sta from neurons.sta
%false: draw sta from specified cluster/class/member.
viewMUA = viewOption.viewMUA;
%view neuron cluster id. 
vn = viewOption.clusterID;
%
vc = viewOption.classID;
vm = viewOption.memberID;
%trimmed neurons struct with 'sta' field.
neurons = sta.array{1};
%time points in sta samples
nsamples = length(sta.time);

%line spec 
% lineSpec = {'ks-','bs-','rs-','gs-','ms-','ys-'};
%lineSpec = {'ko','bo','ro','go','mo','yo'};
%lineSpec = {'k-o','b-o','r-o','g-o','m-o','y-o'};
lineSpec = {'k','b','r','g','m','y'};
lineColor = {'k','b','r','g','m','y'};

%non-empty channel id
cid = zeros(1,n);
if viewOption.skip %plot non-empty channels
    for i = 1 : n
        for j = 1 : length(neurons{i}.clusters)
            if isfield(neurons{i}.clusters{j}.class{vc}.member{vm},'sta') && ~isempty(neurons{i}.clusters{j}.class{vc}.member{vm}.sta)
                cid(i) = 1;  
                break;
            end
        end
    end
    pn = length(find(cid>0));
else
    pn = n;
end
 
%range of slider values.
xmin = get(hObject,'min');
xmax = get(hObject,'max');
%slider position.
sv = get(hObject,'value');
%
x = sta.time;

switch viewOption.plotdim
    case 0
        %no plot
        return;
    case 1 %1d plot
        if sta.firstcall %plot once only
                     
            pid = 0;
            for i = 1 : n
                if viewOption.skip && cid(i)==0; continue; end
                pid = pid + 1;
                %
                elecID = neurons{i}.electrode;
                %
                mapID = find(cmap(:,3)==elecID);
                %only plot channles in cmap
                if isempty(mapID); continue; end
                %reverse the row indexing from bottom up to up down.
                rowID = nRow - cmap(mapID,2);
                %
                colID = cmap(mapID,1) + 1;
                %
                subplot(nRow,nCol,mapID);
                
                hold on;
                
                %plot multi-unit activity only 
                if viewMUA
                    %sum up the units
                    data = 0; err =0; 
                    data1 = 0 ; err1 = 0; cc1 = 0;
                    data2 = 0 ; err2 = 0; cc2 = 0;
                    cc = 0; %cluster count
                    for j = 1 : length(neurons{i}.clusters)
                        %invalid spikes by sorting.
                        if neurons{i}.clusters{j}.id == 255 ; continue; end 
                        if ~viewOption.viewUnsortedUnit
                            if neurons{i}.clusters{j}.id == 0 ; continue; end
                        end
                            if (neurons{i}.clusters{j}.class{vc}.member{vm}.spikes>0)
                                data = data + neurons{i}.clusters{j}.class{vc}.member{vm}.sta;
                                err =  err + neurons{i}.clusters{j}.class{vc}.member{vm}.std;
                                cc = cc + 1;
                                %
                                data1 = data1 + neurons{i}.clusters{j}.class{vc}.member{1}.sta;
                                err1 =  err1 + neurons{i}.clusters{j}.class{vc}.member{1}.std;
                                data2 = data2 + neurons{i}.clusters{j}.class{vc}.member{2}.sta;
                                err2 =  err2 + neurons{i}.clusters{j}.class{vc}.member{2}.std;
                            end
                    end
                    
                    if cc>0
                        data = data/cc;
                        err = err/cc;
                        %
                        data1 = data1/cc;
                        err1 = err1/cc;
                        data2 = data2/cc;
                        err2 = err2/cc;
                        
                    end
                    
                    if isempty(data); continue; end %skiped chanel
                    
%                     x = sta.time;
                    y = data;
                    z = err;
                                        
                    [my,mx]=max(abs(y));
                    if viewOption.plotSE
                        %errorbar(sta.time,data,err,lineSpec{1},...
                        %'MarkerEdgeColor','k',...
                        %'MarkerFaceColor',[.49 1 .63],...
                        %'MarkerSize',2);
                        errorbar(x,y,z,lineSpec{1},...
                            'MarkerEdgeColor','k',...
                            'MarkerFaceColor',[.49 1 .63],...
                            'MarkerSize',2);
                    else
%                         plot(sta.time,data,lineSpec{1},...
%                             'MarkerEdgeColor','k',...
%                             'MarkerFaceColor',[.49 1 .63],...
%                             'MarkerSize',2);
                        plot(x,y,lineSpec{1},...
                            'MarkerEdgeColor','k',...
                            'MarkerFaceColor',[.49 1 .63],...
                            'MarkerSize',2);
                    end
                    %plot(sta.time(mx),data(mx),'ro');
                    
                    %plot the fit curve if rate histogram is specified
                    if isfield(viewOption,'plotCustom') && viewOption.plotCustom
                        hold on;
                        %fprintf('plot %d %d\n',i,j);
                        plot(x(1:length(x)/2),neurons{i}.clusters{j}.class{vc}.member{1}.fit(1:length(x)/2),'k');
                        plot(x(length(x)/2+1: end),neurons{i}.clusters{j}.class{vc}.member{1}.fit(length(x)/2 +1: end),'k');
                    end

                    %axis auto;
                    xlim([x(1) x(end)]);
                    if ~isempty(viewOption.colorscale)
                        ylim(viewOption.colorscale);
                    end

                    axis image; axis normal;
                    yl = ylim;
                    xl = xlim;
                    xmd = mean(xl);
                    %yl = yl.* (1+[-1 1]*0.2);
                    if isfield(viewOption,'plotCustom') && viewOption.plotCustom
                        plot([xmd xmd],yl,'r');
                    end
                    xlim(xl);
                    ylim(yl);

                else %plot each cluster

                    %subplot(pr,pc,pid);hold on;
                    for j = 1 : length(neurons{i}.clusters)
                        
                        if neurons{i}.clusters{j}.id == 255 ; continue; end 
                        
                        if ~viewOption.viewUnsortedUnit
                            if neurons{i}.clusters{j}.id == 0 ; continue; end
                        end
                        
                        data = neurons{i}.clusters{j}.class{vc}.member{vm}.sta;
                        if isempty(data); continue; end %skiped channel for analysis
                        err = neurons{i}.clusters{j}.class{vc}.member{vm}.std;

%                         x = sta.time;
                        y = data;
                        z = err;
                        %if isempty(data); continue; end %skiped channel for analysis
                        
                        [my,mx]=max(abs(y));
                        
                        dispID = mod(j,length(lineSpec));
                        if dispID == 0 ; dispID = length(lineSpec); end
                        
                        if viewOption.plotSE
                            errorbar(x,y,z,lineSpec{dispID},...
                                'MarkerEdgeColor','k',...
                                'MarkerFaceColor',[.49 1 .63],...
                                'MarkerSize',2);
                        else
                            plot(x,y,lineSpec{dispID},...
                                'MarkerEdgeColor','k',...
                                'MarkerFaceColor',[.49 1 .63],...
                                'MarkerSize',2);
                        end
                        
                        %plot the fit curve if rate histogram is specified
                        if isfield(viewOption,'plotCustom') && viewOption.plotCustom
                            hold on;
                            %fprintf('plot %d %d\n',i,j);
                            plot(x(1:length(x)/2),neurons{i}.clusters{j}.class{vc}.member{1}.fit(1:length(x)/2),lineColor{dispID});
                            plot(x(length(x)/2+1: end),neurons{i}.clusters{j}.class{vc}.member{1}.fit(length(x)/2 +1: end),lineColor{dispID});
                        end

                        %axis auto;
                        xlim([x(1) x(end)]);
                        if ~isempty(viewOption.colorscale)
                            ylim(viewOption.colorscale);
                        end
                        
                        axis image; axis normal;
                        yl = ylim;
                        xl = xlim;
                        %yl = yl.* (1+[-1 1]*0.2);
                        xmd = mean(xl);
                        if isfield(viewOption,'plotCustom') && viewOption.plotCustom
                            plot([xmd xmd],yl,'r');
                        end
                        xlim(xl);ylim(yl);
                     
                    end
                end
                title(sprintf('%s',neurons{i}.name));
            end
            sta.firstcall = false; %reset the flag.
            set(hObject,'userdata',sta);
            %
            set(h_slabel,'String',sprintf('[%f %f]',x(1),x(end)));
        end
    case 2 %2d plot
        %index in sta time sequence
        idx = round(1 + nsamples*(sv - xmin)/(xmax-xmin));
        %old position
        osv = getappdata(0,'mspecSTA_slider');
        %old index
        oidx = getappdata(0,'mspecSTA_index');
        %sliding direction
        if sv > osv
            %index in sta sampling time sequence.
            if idx <= oidx; idx = oidx + 1; end %move at least 1 pos up
            idx = min(idx,nsamples);
        else
            if idx >= oidx; idx = oidx - 1; end %at least 1 pos down
            idx = max(1,idx);
        end
        %nearest slider value corresonding to idx
        nsv = xmin + (idx-1)*(xmax-xmin)/(nsamples-1);
        nsv = min(nsv,xmax);
        set(hObject,'value',nsv); %set slider in position.
        setappdata(0,'mspecSTA_slider',nsv);
        setappdata(0,'mspecSTA_index',idx);
        
        dotNumX = 0; dotNumY = 0;
        for i = 1 : n
            for j = 1 : length(neurons{i}.clusters)
                data = neurons{i}.clusters{j}.class{vc}.member{vm}.sta;
                if ~isempty(data)
                    dotNumX = size(data,1);
                    dotNumY = size(data,2);
                    break;
                end
            end
            if dotNumX*dotNumY > 0 ; break; end
        end
        
%         [x,y] = ndgrid(1:dotNumX,dotNumY:-1:1);
%         %dots are saved in screen coordinates.  
         xs = 1:dotNumX;
         ys = 1:dotNumY;
                      
        %for i = 1 : pn
        for i = 1 : n
            %
            elecID = neurons{i}.electrode;
            %
            mapID = find(cmap(:,3)==elecID);
            %only plot channels specified in cmap.
            if isempty(mapID); continue; end
            
            rowID = nRow - cmap(mapID,2);
            %
            colID = cmap(mapID,1) + 1;
            %
            subplot(nRow,nCol,mapID);%axis image;
            
            hold on;
            
            fitType = [];

            %subplot(pr,pc,i);
            if viewMUA
                data = neurons{i}.sta;
            else
                data = neurons{i}.clusters{vn}.class{vc}.member{vm}.sta;
                if isfield(neurons{i}.clusters{vn}.class{vc}.member{vm},'fitType')
                    fitType = neurons{i}.clusters{vn}.class{vc}.member{vm}.fitType;
                end
            end
            if isempty(data);continue;end
            %I,J are index into screen coordiante array, i.e, x towards
            %right, y goes downwards.
            [maxV,maxI]=max(data(:,:,idx));
            [maxV,maxJ]=max(maxV);
            maxI = maxI(maxJ);
            [minV,minI]=min(data(:,:,idx));
            [minV,minJ]=min(minV);
            minI = minI(minJ);

            %shown in view-coordinates (x-right,y-up)
%             pcolor(x,y,data(:,:,idx));
%           plot the data(i,j) as in screen coordinates, ie., (i,j)
%           correponds to (x,y).
            %disp('before plot');get(gca,'YDir')
            %data(:,:,idx) = smooth2(data(:,:,idx),2,2);
           imagesc(ys,xs,data(:,:,idx)'); axis image;
        
%             if ~isempty(fitType) && strcmp(fitType{idx},'Gaussian')
%                 
%                 hold on;
%                 datafit = neurons{i}.clusters{vn}.class{vc}.member{vm}.fit{idx};
%                 ra = datafit.sigmax;
%                 rb = datafit.sigmay;
%                 try
%                     ang = datafit.angle; %some fit didn't return angle field ?
%                 catch
%                     ang = 0;
%                 end
%                 x0 = datafit.x0;
%                 y0 = datafit.y0;
%                 C  = 'k';
%                 Nb = 300;
%                 %ellipse(ra,rb,ang,x0,y0,C,Nb);
%                 ellipse(ra,rb,90-ang,x0,y0,C,Nb);
%                 hold off;
%             end
                
            %reverse the Y direction mannually.-- it's odd that 'YDir' was
            %'normal' after the plot. 
            set(gca,'YDir','reverse');
            %set(gca,'XAxisLocation','top');
            %disp('after plot');get(gca,'YDir')
            %show contour lines. 5 grades.
            if viewOption.plotContour
                %contour(x,y,data(:,:,idx),2,'w');
            end
            
            %colormap('bone');
            if ~isempty(viewOption.colorscale)
                %caxis([0 1]); %scaled color value b/w [0 1].
                caxis(viewOption.colorscale);
            end
            hold on;
            %plot(minI+0.5,dotNumY-minJ+1-0.5,'ko');plot(maxI+0.5,dotNumY-maxJ+1-0.5,'wo');
            title(sprintf('%s',neurons{i}.name));
%             fprintf('Ch:%s,Slice%d,Max(%d,%d),Min(%d,%d)\n',neurons{i}.name,idx,...
%                 maxI,dotNumY-maxJ+1,minI,dotNumY-minJ+1);
%             
            sliderStr = sprintf('%s: Slice%d: Lag t=%.3fs,T=[%.3f,%.3f]s',...
                sta.plot.saveFolder,idx,sta.time(idx), sta.time(1),sta.time(end)); 
            
            set(h_slabel,'String',sliderStr);
            
            %mark the min/max location
            hold off;

        end
end
        
    