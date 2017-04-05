function h = staircase(x,y,opt,h)
%plot the stair case
%

if nargin < 3
    opt = '';
end

if nargin < 4 || nargin <3
    h = figure('name','staircase plot');
end

figure(h);
hold on;

%make time series
ts = timeseries(y,x);
ts = ts.setinterpmethod('zoh');
plot(ts,opt);


    
    
