function plotResponseFigures(chan,neurons,s,t_SETS,StimImage,state,saveToDir)

%points to remove for plotting response function. 1 for most, 2 for oct
%11th
if ~isempty(regexp(s.matFolder,'Oct-11'))
    np = 2;
else
    np = 1;
end

neurons1 = plotPPDFigs(chan,neurons,s,t_SETS,StimImage,'adapt');
neurons2 = plotPPDFigs(chan,neurons,s,t_SETS,StimImage,'steady');

fdir = fullfile(saveToDir,'Analysis');

% fdir = fullfile(s.nevFolder,'2013','singleUnit','Analysis');
if exist(fdir,'dir')~=7 ; mkdir(fdir); end

n        = length(neurons);
recChan  = zeros(1,n);
%nBlocks  = getTrialParams(s,'nBlocks');
%stimTime = getTrialParams(s,'stimulusTime');
%tBlock   = stimTime/(nBlocks*2);             %time of each contrast block.

for i = 1 : n
    recChan(i) = neurons{i}.channel;
end

if isempty(chan); chan = recChan; end 
%find channel indices in 'neurons'
chanIdx = zeros(size(chan));
for i = 1 : length(chan)
    chanIdx(i) = find(chan(i)==recChan);
end

for k = 1 : length(chan)
    i = chanIdx(k);
    chID = chan(k);
    for j = 1 : length(neurons{i}.clusters)
        unitID = neurons{i}.clusters{j}.id;
        if unitID == 255 ; continue; end

        x1_a = neurons1{i}.clusters{j}.class{1}.member{1}.response.x ;
        xe1_a= neurons1{i}.clusters{j}.class{1}.member{1}.response.xe;
        y1_a = neurons1{i}.clusters{j}.class{1}.member{1}.response.y ;
        ye1_a = neurons1{i}.clusters{j}.class{1}.member{1}.response.ye;
        
        p1_a = neurons1{i}.clusters{j}.class{1}.member{1}.response.p ;
        
        x2_a = neurons1{i}.clusters{j}.class{1}.member{2}.response.x ;
        xe2_a = neurons1{i}.clusters{j}.class{1}.member{2}.response.xe ;
        y2_a = neurons1{i}.clusters{j}.class{1}.member{2}.response.y;
        ye2_a = neurons1{i}.clusters{j}.class{1}.member{2}.response.ye ;
        
        p2_a = neurons1{i}.clusters{j}.class{1}.member{2}.response.p ;

        x1_s = neurons2{i}.clusters{j}.class{1}.member{1}.response.x ;
        xe1_s= neurons2{i}.clusters{j}.class{1}.member{1}.response.xe;
        y1_s = neurons2{i}.clusters{j}.class{1}.member{1}.response.y ;
        ye1_s = neurons2{i}.clusters{j}.class{1}.member{1}.response.ye;
        
        p1_s = neurons2{i}.clusters{j}.class{1}.member{1}.response.p ;
        
        x2_s = neurons2{i}.clusters{j}.class{1}.member{2}.response.x ;
        xe2_s = neurons2{i}.clusters{j}.class{1}.member{2}.response.xe ;
        y2_s = neurons2{i}.clusters{j}.class{1}.member{2}.response.y;
        ye2_s = neurons2{i}.clusters{j}.class{1}.member{2}.response.ye ;

        p2_s = neurons2{i}.clusters{j}.class{1}.member{2}.response.p ;
        h = figure('name','Response Function (H/L)'); hold on;
        
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        errorbar(x2_a(1:end-np)/xe1_s, y2_a(1:end-np)/max(y2_a(1:end-np)), ye2_a(1:end-np)/max(y2_a(1:end-np)),'k<:'); %high contrast response fun adapt
        %errorbar(x1_s/xe1_s, y1_s/max(y1_s), ye1_s/max(y1_s),'bs-'); %low contrast response fun steady
        errorbar(x2_s(1:end-np)/xe1_s, y2_s(1:end-np)/max(y2_s(1:end-np)), ye2_s(1:end-np)/max(y2_s(1:end-np)),'ks-'); %high contrast response fun steady
        
        %plot(x1_s/xe1_s, p1_s/max(p1_s), 'b.-'); %effective stimulus histgram low c
        %plot(x2_s/xe1_s, p2_s/max(p2_s), 'r.-');
        %smooth the distribution
        dx0 = x2_s/xe1_s; 
        dy0 = p2_s/max(p2_s);
        
        dx1 = linspace(dx0(1),dx0(end-1),5*length(dx0));
        dy1 = smooth(interp1(dx0,dy0,dx1));
        %plot
        plot(dx1,dy1,'k.-');
        
        xlabel('Effective Stimulus','fontsize',12); ylabel('R/Rm,P/Pm','fontsize',12);
        %title(sprintf('Response Function ch%d unit%d',chID,unitID));
        legend('Ra(H)','Rs(H)','P(H)',2);

        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
        yrange = ylim;
        yrange(1) = 0;
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.15)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        
        set(gca,'YTick',[0:0.5:1],'YTickLabel',{'0','0.5','1'});
                
        fn = fullfile(fdir,sprintf('Response_Normalized_Full_HighContrast_ch%d_unit%d.png',chID,unitID));
        savePlot(h,fn);
        %close(h);
        saveas(h,strrep(fn,'png','fig'));
        close(h);
        
        h = figure('name','UnNormalized Response Function (H/L)'); hold on;
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        errorbar(x2_a(1:end-np)/xe1_s, y2_a(1:end-np), ye2_a(1:end-np),'k<:'); %high contrast response fun adapt
        %errorbar(x1_s/xe1_s, y1_s, ye1_s,'bs-'); %low contrast response fun steady
        errorbar(x2_s(1:end-np)/xe1_s, y2_s(1:end-np), ye2_s(1:end-np),'ks-'); %high contrast response fun steady
        
        %plot(x1_s/xe1_s, p1_s/max(p1_s), 'b.-'); %effective stimulus histgram low c
        %plot(x2_s/xe1_s, p2_s/max(p2_s), 'r.-');

        xlabel('Effective Stimulus','fontsize',12); ylabel('Rate(Hz)','fontsize',12);
        %title(sprintf('Response Function ch%d unit%d',chID,unitID));
        legend('Ra(H)','Rs(H)',2);

        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        yrange = ylim;
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.15)]);
        
        fn = fullfile(fdir,sprintf('Response_unNormalized_HighContrast_Full_ch%d_unit%d.png',chID,unitID));
        savePlot(h,fn);
        %close(h);
        saveas(h,strrep(fn,'png','fig'));
        close(h);
        
        h = figure('name','Response Function (H/L)'); hold on;
        
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        %errorbar(x2_a/xe1_s, y2_a/max(y2_a), ye2_a/max(y2_a),'r<:'); %high contrast response fun adapt
        errorbar(x1_s(1:end-np)/xe1_s, y1_s(1:end-np)/max(y1_s(1:end-np)), ye1_s(1:end-np)/max(y1_s(1:end-np)),'bs-'); %low contrast response fun steady
        errorbar(x2_s(1:end-np)/xe1_s, y2_s(1:end-np)/max(y2_s(1:end-np)), ye2_s(1:end-np)/max(y2_s(1:end-np)),'rs-'); %high contrast response fun steady
        
        %plot(x1_s/xe1_s, p1_s/max(p1_s), 'b.-'); %effective stimulus histgram low c
        %plot(x2_s/xe1_s, p2_s/max(p2_s), 'r.-');
        
        dx0 = x1_s/xe1_s; 
        dy0 = p1_s/max(p2_s);
        dx1 = linspace(dx0(1),dx0(end-1),5*length(dx0));
        dy1 = smooth(interp1(dx0,dy0,dx1));
        %plot
        dx0 = x2_s/xe1_s; 
        dy0 = p2_s/max(p2_s);
        
        dx2 = linspace(dx0(1),dx0(end-1),5*length(dx0));
        dy2 = smooth(interp1(dx0,dy0,dx2));
        
        plot(dx1,dy1,'b.-');
        plot(dx2,dy2,'r.-');
        
        xlabel('Effective Stimulus','fontsize',12); ylabel('R/Rm,P/Pm','fontsize',12);
        %title(sprintf('Response Function ch%d unit%d',chID,unitID));
        legend('Rs(L)','Rs(H)','P(L)','P(H)',2);

        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        yrange = ylim;
        yrange(1) = 0;
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.15)]);
        
        set(gca,'YTick',[0:0.5:1],'YTickLabel',{'0','0.5','1'});
        
        fn = fullfile(fdir,sprintf('Response_Normalized_Full_ch%d_unit%d.png',chID,unitID));
        savePlot(h,fn);
        %close(h);
        saveas(h,strrep(fn,'png','fig'));
        close(h);
        
        save(fullfile(fdir,sprintf('neurons_ch%d_unit%d.mat',chID,unitID))); %save temp matlab data. 
    end
    
    %save 
     
    
end

function savePlot(h,fn)
%
export_style = hgexport('readstyle','powerpoint');
export_style.Format = 'png';

figure(h);
set(gcf,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ;hgexport(gcf,fn,export_style); end
%close(h);

