%Test_PlotTuningCurve
%test mulit ch plotting of tunning curve

% s = struct('data',[],'id',[]);
% msg = struct('string','');
% 
% for i = 1 : 10
%     x = sort(rand(1,100));
%     y = linspace(0,1,8);
%     [s(i).data] = calSpikeRate(x,y);
%     s(i).id   = i;
%     [my,mx] = max(s(i).data);
%     msg(i).string = sprintf('Ch%2d : peak=(%.3f,%.3f)', s(i).id , bin(mx),my);
% end
% 
% h = mplotTuningCurve(s,msg);