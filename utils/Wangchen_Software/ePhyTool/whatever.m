i = 2; 
figure('name',a{i}); hold on;
 
 ar_L2 = mean(layer(2).result.rate(2).y);
 ar_L2e = ste(layer(2).result.rate(2).y);
 n2 = size(layer(2).result.rate(2).y,1);
 
 
 ar_L45 = mean([layer(3).result.rate(2).y; layer(4).result.rate(2).y]);
 ar_L45e = ste([layer(3).result.rate(2).y; layer(4).result.rate(2).y]);
 
 ar_L4 = mean([layer(3).result.rate(2).y]);
 ar_L4e= ste([layer(3).result.rate(2).y]);
 
 n4 = size(layer(3).result.rate(2).y,1);
 
 ar_L5 = mean([layer(4).result.rate(2).y]);
 ar_L5e= ste([layer(4).result.rate(2).y]);
 n5 = size(layer(4).result.rate(2).y,1);
 
 
 errY = [ar_L2e; ar_L4e; ar_L5e];
 Y = [ar_L2; ar_L4; ar_L5];
 barwitherr(errY,Y);
 set(gca,'XTick',[1 2 3],'XTickLabel',{'L2/3','L4','L5/6'});
 legend('LC','HC');
 %legend('Supragranular','Granular','Infragranular');
 ylabel('Time(s)','fontsize',12);
 xlabel('Cortical Layer','fontsize',12);
 title('Layer Dependence of Adaptation Time');
 text(1,Y(1),sprintf('Supragranular,n=%d',n2));
 text(2,Y(2),sprintf('Granular,n=%d',n4));
 text(3,Y(3),sprintf('Infragranular,n=%d',n5));
 
 
%   y = randn(3,4);         % random y values (3 groups of 4 parameters) 
%     errY = 0.1.*y;          % 10% error
%     barwitherr(errY, y);    % Plot with errorbars
%  
%     set(gca,'XTickLabel',{'Group A','Group B','Group C'})
%     legend('Parameter 1','Parameter 2','Parameter 3','Parameter 4')
%     ylabel('Y Value')
%  
%  

%initial vs steady rate

iniRate = struct;
staRate = struct; 
j = 1; 
for i = 2 : 4
    iniRate(j).y = [layer(i).result.rate(4).y(:,2)];
    staRate(j).y = [layer(i).result.rate(3).y(:,2)];
    j = j + 1; 
end

figure('name','scatterplot ini rate vs steady rate'); hold on;
plot(staRate(1).y,iniRate(1).y,'kx','MarkerFaceColor',[0 0 0],'MarkerSize',7);
plot(staRate(2).y,iniRate(2).y,'go','MarkerSize',6);
plot(staRate(3).y,iniRate(3).y,'rs','MarkerSize',6);

xlabel('Steady Rate (hz)','fontsize',12);
ylabel('Initial Rate (hz)','fontsize',12);
legend('Supragranular','Granular','Infragranular',4);

xrange = xlim;
yrange = ylim;
hold on;
plot(linspace(0,yrange(end),100), linspace(0,yrange(end),100),'b.');
axis equal
xlim([0 yrange(2)]);
ylim([0 yrange(2)]);
