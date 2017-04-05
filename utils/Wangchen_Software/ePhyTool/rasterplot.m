function handle=rasterplot(t,handle)
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

hold on;

colors = {'k','b','r','g','m'};

tickSpace = 1; %vertical space bw adjacent traces.
tickHeight = 1;
baseline0 = 0.5;

for i = 1 : nrow
    npt = length(t{i});
    cid = mod(i,length(colors));
    if cid ==0; cid = length(colors); end;
    %tickColor = colors{cid};
    tickColor = 'b';
    baseline = baseline0 + (i-1) *(tickHeight + tickSpace);
    
    for j = 1 : npt
        x = repmat(t{i}(j),1,2);
        y = [0 tickHeight] + baseline;
        plot(x,y,tickColor);
    end
    
    
end

ylim([0 baseline*1.2]);
        

