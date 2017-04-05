function [ h ] = mspecViewer(t,neurons,v)
% % function [ h ] = mspecViewer(t,s,msg,plt)
% % Usage h = mspecViewer(t,s,msg,plt) with specified x values
% %       h = mspecViewer(s,msg,plt) will use indices of y as x variable  
% %t   - struct array of x values, or 2d matrix. optional. index will be used
% %      as x values instead if not specified.
% %s   - struct array of y values
% %msg - struct array of strings to show in info pannel
% %plt - string telling the plot type,e.g,'Orientation Tuning'
% t -- time elements. indices will be used if empty.

% ??
plt = v.plot;

%% call mspecSTA to display multi-ch data (sta or firing rate,etc)
switch lower(plt)
    case 'tuning'
        %h = mspecTuning(t,neurons);
        %h = mspecTuning(t,neurons);
        h = mspecSTA(t,neurons,v); %with 'neurons' struct
    case {'sta','sta_fit'}
        h = mspecSTA(t,neurons,v);
end

% % name = sprintf('%s : %s','Multi-Ch Spectrum Viewer',plt);
% % set(h,'name',name);
% % 
% % pos = get(h,'Position');
% % 
% % %handle to info pannel - inherit to h so that it closes with h.
% % hip = figure('Name',['Info Panel : ',plt],...
% %     'Position',[pos(1) pos(2) pos(3)/3 pos(4)],...
% %     'MenuBar','none',...
% %     'ToolBar','none',...
% %     'Color',[0.7 0.7 1]);
% % 
% % axis off;
% % 
% % %raise the figure for gca?
% % figure(hip);
% % 
% % % pos_gcf = get(gcf,'Position');
% % pos_gca = get(gca,'Position');
% % pos_listbox = bsxfun(@times,pos_gca,[0.6 0.6 1.1 1.1]);
% % %Creating Uicontrol of list-box
% % hlb = uicontrol('Parent',hip,...
% %     'style','listbox',...
% %     'units','normalized','position',pos_listbox,...
% %     'tag','info_pannel',...
% %     'backgroundcolor',[0.9 0.9 0.9]...
% %     );
% % 
% % close(hip);


% % n = length(v.message);
% % str = strvcat(plt,' '); %insert a blank line
% % for i = 1 : n
% %     str = strvcat(str,msg(i).string);
% % end

%set(hlb,'String',v.message);


