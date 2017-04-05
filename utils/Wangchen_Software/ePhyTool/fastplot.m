%d1 = double(NSx.Data);
Fs = 30000;
d = d1';
d = d(end-Fs*10 : end , 1:end-1);

%process the last 10s

n = size(d,2);
t = cell(1,n);
w = cell(1,n);
y = cell(1,n);

[t1,w1,y1] = spikeDetection1(d,Fs);

% for i = 1 : n
%     [t1,w1,y1] = spikeDetection1(d(i,:),30000);
%     t{i} = t1;
%     w{i} = w1;
%     y{i} = y1;
% end
% 
