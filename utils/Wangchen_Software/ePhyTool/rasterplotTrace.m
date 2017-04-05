function handle=rasterplotTrace(t,handle)
%
%t: data points. in numerical array or cell. 
%

if nargin < 2
    handle = figure('name','rasterplot');
end

%figure(handle);

if ~iscell(t)
     [nrow,ncol]=size(t);
%     if nrow > ncol
%         t = t';
%         [nrow,ncol]=size(t);
%     end
    t1 = cell(1,nrow);
    for i = 1 : nrow
        t1{i} = t(i,:);
    end
    t = t1;
    clear t1;
else
    nrow = length(t);
end

gmax = 0;
gmin = 0;
%find the max/min
for i = 1 : length(t)
    tmax = max(t{i});
    tmin = min(t{i});
    if tmax > gmax ; gmax = tmax; end
    if tmin < gmin ; gmin = tmin; end
end

%normalize the matrix to [0 1].
for i = 1 : length(t)
    t{i} = (t{i} - gmin)/(gmax - gmin);
end


        
        
        

hold on;

colors = {'k','b','r','g','m'};

tickSpace = .7; %vertical space bw adjacent traces.
tickHeight = 0;
baseline0 = 0;



baseline = baseline0;
for i = 1 : nrow
    npt = length(t{i});
    cid = mod(i,length(colors));
    if cid ==0; cid = length(colors); end;
    %tickColor = colors{cid};
     tickColor = 'k';
%     for j = 1 : npt
%         x = repmat(t{i}(j),1,2);
%         y = [0 tickHeight] + baseline;
%         plot(x,y,tickColor);
%     end
    
    %x = t{i};
    baseline = baseline0 + (i-1) *(tickHeight + tickSpace);
    y = t{i} + baseline;
    plot(y,tickColor);
    
end

%ylim([0 baseline*1.2]);
        

