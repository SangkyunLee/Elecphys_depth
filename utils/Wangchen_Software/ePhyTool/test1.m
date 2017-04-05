t = stimData.Timestamps;
dt = diff(t);
out = find(abs(dt - mean(dt))>0.5*1/60);
nplot = min([12,length(out)]);
figure; hold on;
for i = 1 : nplot
    subplot(3,4,i);
    %find the time in the ptd data
    p = round(t(out(i))*30000);
    y = PTD.data(p-3000 : p+3000);
    x = (p-3000 : p+3000)/30000; 
    plot(x,y);
    hold on;
    plot(t(out(i)),mean(y),'r+');
end
    
    