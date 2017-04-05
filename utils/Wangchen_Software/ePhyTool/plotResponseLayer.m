% iExp2 = 7 ; %oct 11th, 
% iCh2 = 44; 

i2 = 1; %remove eff.stim points
iExp2 = 8 ; %oct 31, 
iCh2 = 10; 

iExp1 = 18; %Jul 2nd, layer 2
iCh1 = 2; 

i1 = 1; 

switch iExp1
    case 18
        LayerStr1 = 'L2/3';
    otherwise
        LayerStr1 = '';
end

switch iExp2
    case 7
        LayerStr2 = 'L4';
    case 8
        LayerStr2 = 'L5';
    otherwise
end


clear folder1 folder2;

%plot response function on the same plot
    folder1(1) = s_mat(iExp1);
    folder1(2) = s_mat(iExp1);
    folder1(3) = s_raw(iExp1);
    folder2(1) = s_mat(iExp2);
    folder2(2) = s_mat(iExp2);
    folder2(3) = s_raw(iExp2);
    
    file1 = fullfile(fileparts(folder1(3).filename),'2013','multiUnit','Analysis',sprintf('neurons_ch%d_unit%d.mat',iCh1,0));
    
    file2 = fullfile(fileparts(folder2(3).filename),'2013','multiUnit','Analysis',sprintf('neurons_ch%d_unit%d.mat',iCh2,0));
    
    data1 = load(file1);
    data2 = load(file2);
    
    %plot steady response , low , raw
     h1 = figure('name','Response Function (H) across Layer'); hold on;
        
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        %errorbar(x2_a/xe1_s, y2_a/max(y2_a), ye2_a/max(y2_a),'r<:'); %high contrast response fun adapt
        %errorbar(x1_s(1:end-1)/xe1_s, y1_s(1:end-1)/max(y1_s(1:end-1)), ye1_s(1:end-1)/max(y1_s(1:end-1)),'bs-'); %low contrast response fun steady
        
        xx1 = data1.x2_s(1:end-i1)/data1.xe1_s; 
        yy1 = data1.y2_s(1:end-i1);
        ee1 = data1.ye2_s(1:end-i1);
        
        rx1 = linspace(0,xx1(end),7); %resample the x1 to include 0.
        ry1 = interp1(xx1,yy1,rx1);
        re1 = interp1(xx1,ee1,rx1);
        %base line rate
        y0  = ry1(1);
        
        x1 =  xx1;
        y1 = (yy1 - y0)/(max(yy1)-y0);
        e1 = ee1/(max(yy1)-y0);
        
        xx2 = data2.x2_s(1:end-i2)/data2.xe1_s;
        yy2 = data2.y2_s(1:end-i2);
        ee2 = data2.ye2_s(1:end-i2);
        %
        rx2  = linspace(0,xx2(end),7);
        ry2 = interp1(xx2,yy2,rx2);
        re2 = interp1(xx2,ee2,rx2);
        %
        y0 = ry2(1);
        
        %y2 = interp1(xx2,yy2,x1);
        x2 = xx2;
        y2 = (yy2 - y0)/(max(yy2)-y0);
        e2 = ee2/(max(yy2)-y0);
        %
        y2 = interp1(x2,y2,x1);
        e2 = interp1(x2,e2,x1);
        
        errorbar(x1,y1,e1,'k<-');
        errorbar(x1,y2,e2,'ks:');
           
        %plot(data1.dx1,data1.dy1,'b.-');
        plot(data1.dx2,data1.dy2/max(data1.dy2),'k.-');
        
        xlabel('Effective Stimulus','fontsize',12); ylabel('R/Rm,P/Pm','fontsize',12);title(sprintf('Normalized Response Function Across Layer at HC'));
        legend(sprintf('Rs(H,%s)',LayerStr1),sprintf('Rs(H,%s)',LayerStr2),'P(H)',2);

        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        yrange = ylim;
        
        yrange(1) = 0; 
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.2)]);
        
        set(gca,'YTick',[0:0.5:1],'YTickLabel',{'0','0.5','1'});
        
        fn = fullfile(fileparts(file1),sprintf('Response_Normalized_AcrossLayer_HighC_Exp%d_%d_ch%d_%d.png',iExp1,iExp2,iCh1,iCh2));
        savePlotAsPic(h1,fn);
        %close(h);
        saveas(h1,strrep(fn,'png','fig'));
        close(h1);
        
        h2 = figure('name','raw Response Function (H/L)'); hold on;
        
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        %errorbar(x2_a/xe1_s, y2_a/max(y2_a), ye2_a/max(y2_a),'r<:'); %high contrast response fun adapt
        %errorbar(x1_s(1:end-1)/xe1_s, y1_s(1:end-1)/max(y1_s(1:end-1)), ye1_s(1:end-1)/max(y1_s(1:end-1)),'bs-'); %low contrast response fun steady
        
        
        x1 = data1.x2_s(1:end-i1)/data1.xe1_s; 
        y1 = data1.y2_s(1:end-i1);
        e1 = data1.ye2_s(1:end-i1);
        
        x2 = data2.x2_s(1:end-i2)/data2.xe1_s;
        yy2 = data2.y2_s(1:end-i2);
        y2 = interp1(x2,yy2,x1);
        ee2 = data2.ye2_s(1:end-i2);
        e2 = interp1(x2,ee2,x1);
        
        errorbar(x1,y1,e1,'k<-');
        errorbar(x1,y2,e2,'ks:');
        
%         errorbar(data1.x2_s(1:end-1)/data1.xe1_s, data1.y2_s(1:end-1), data1.ye2_s(1:end-1),'k<-'); %high contrast response fun steady
%         errorbar(data2.x2_s(1:end-1)/data2.xe1_s, data2.y2_s(1:end-1), data2.ye2_s(1:end-1),'ks-'); %high contrast response fun steady
%         
        %plot(x1_s/xe1_s, p1_s/max(p1_s), 'b.-'); %effective stimulus histgram low c
        %plot(x2_s/xe1_s, p2_s/max(p2_s), 'r.-');
%         
%         dx0 = x1_s/xe1_s; 
%         dy0 = p1_s/max(p2_s);
%         dx1 = linspace(dx0(1),dx0(end-1),5*length(dx0));
%         dy1 = smooth(interp1(dx0,dy0,dx1));
%         %plot
%         dx0 = x2_s/xe1_s; 
%         dy0 = p2_s/max(p2_s);
%         
%         dx2 = linspace(dx0(1),dx0(end-1),5*length(dx0));
%         dy2 = smooth(interp1(dx0,dy0,dx2));
        
        %plot(data1.dx1,data1.dy1,'b.-');
        %plot(data1.dx2,data1.dy2,'k.-');
        
        xlabel('Effective Stimulus','fontsize',12); ylabel('Rate(hz)','fontsize',12);title(sprintf('Raw Response Function Across Layer at HC'));
        legend(sprintf('Rs(H,%s)',LayerStr1),sprintf('Rs(H,%s)',LayerStr2),2);

        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        yrange = ylim;
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.1)]);
     
        fn = fullfile(fileparts(file1),sprintf('Response_Raw_AcrossLayer_HighC_Exp%d_%d_ch%d_%d.png',iExp1,iExp2,iCh1,iCh2));
        savePlotAsPic(h2,fn);
        %close(h);
        saveas(h2,strrep(fn,'png','fig'));
        close(h2);
        
    %plot steady response , low , raw
     h3 = figure('name','Response Function (L) across Layer'); hold on;
        
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        %errorbar(x2_a/xe1_s, y2_a/max(y2_a), ye2_a/max(y2_a),'r<:'); %high contrast response fun adapt
        %errorbar(x1_s(1:end-1)/xe1_s, y1_s(1:end-1)/max(y1_s(1:end-1)), ye1_s(1:end-1)/max(y1_s(1:end-1)),'bs-'); %low contrast response fun steady

        xx1 = data1.x1_s(1:end-i1)/data1.xe1_s; 
        yy1 = data1.y1_s(1:end-i1);
        ee1 = data1.ye1_s(1:end-i1);
        
        rx1 = linspace(0,xx1(end),7); %resample the x1 to include 0.
        ry1 = interp1(xx1,yy1,rx1);
        re1 = interp1(xx1,ee1,rx1);
        
        y0 = ry1(1);
        %normalized b/w min and max y = (y-y0)/Dy.
        x1 = xx1;
        y1 = (yy1-y0)/(max(yy1)-y0);
        e1 = ee1/(max(yy1)-y0);
        
        
        xx2 = data2.x1_s(1:end-i2)/data2.xe1_s;
        yy2 = data2.y1_s(1:end-i2);
        %y2 = interp1(x2,yy2,x1);
        ee2 = data2.ye1_s(1:end-i2);
               
        rx2 = linspace(0,xx2(end),7); %resample the x1 to include 0.
        ry2 = interp1(xx2,yy2,rx2);
        re2 = interp1(xx2,ee2,rx2);
        
        y0 = ry2(1);
        %normalized b/w min and max y = (y-y0)/Dy.
        x2 = xx2;
        %y2 = interp1(xx2,yy2,x1);
        y2 = (yy2 - y0)/(max(yy2)-y0);
        e2 = ee2/(max(yy2)-y0);
        
        %
        y2 = interp1(x2,y2,x1);
        e2 = interp1(x2,e2,x1);
        
        errorbar(x1,y1,e1,'k<-');
        errorbar(x1,y2,e2,'ks:');
                
%         errorbar(data1.x1_s(1:end-1)/data1.xe1_s, data1.y1_s(1:end-1)/max(data1.y1_s(1:end-1)), data1.ye1_s(1:end-1)/max(data1.y1_s(1:end-1)),'k<-'); %high contrast response fun steady
%         errorbar(data2.x1_s(1:end-1)/data2.xe1_s, data2.y1_s(1:end-1)/max(data2.y1_s(1:end-1)), data2.ye1_s(1:end-1)/max(data2.y1_s(1:end-1)),'ks-'); %high contrast response fun steady
%         
        %plot(x1_s/xe1_s, p1_s/max(p1_s), 'b.-'); %effective stimulus histgram low c
        %plot(x2_s/xe1_s, p2_s/max(p2_s), 'r.-');
        
%         dx0 = x1_s/xe1_s; 
%         dy0 = p1_s/max(p2_s);
%         dx1 = linspace(dx0(1),dx0(end-1),5*length(dx0));
%         dy1 = smooth(interp1(dx0,dy0,dx1));
%         %plot
%         dx0 = x2_s/xe1_s; 
%         dy0 = p2_s/max(p2_s);
%         
%         dx2 = linspace(dx0(1),dx0(end-1),5*length(dx0));
%         dy2 = smooth(interp1(dx0,dy0,dx2));
        
        plot(data1.dx1,data1.dy1/max(data1.dy1),'k.-');
        %plot(data1.dx2,data1.dy2,'k.-');
        
        xlabel('Effective Stimulus','fontsize',12); ylabel('R/Rm,P/Pm','fontsize',12);title(sprintf('Normalized Response Function Across Layer at LC'));
        legend(sprintf('Rs(L,%s)',LayerStr1),sprintf('Rs(L,%s)',LayerStr2),'P(L)',2);
        
        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        yrange = ylim;
        yrange(1) = 0;
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.1)]);
        
        set(gca,'YTick',[0:0.5:1],'YTickLabel',{'0','0.5','1'});
        
        fn = fullfile(fileparts(file1),sprintf('Response_Normalized_AcrossLayer_LowC_Exp%d_%d_ch%d_%d.png',iExp1,iExp2,iCh1,iCh2));
        savePlotAsPic(h3,fn);
        %close(h);
        saveas(h3,strrep(fn,'png','fig'));
        close(h3);
        
        h4 = figure('name','raw Response Function (H/L)'); hold on;
        
        %errorbar(x1_a/xe1_s, y1_a/max(y1_a), ye1_a/max(y1_a),'b<--'); %low contrast response fun adapt
        %errorbar(x2_a/xe1_s, y2_a/max(y2_a), ye2_a/max(y2_a),'r<:'); %high contrast response fun adapt
        %errorbar(x1_s(1:end-1)/xe1_s, y1_s(1:end-1)/max(y1_s(1:end-1)), ye1_s(1:end-1)/max(y1_s(1:end-1)),'bs-'); %low contrast response fun steady
        
        x1 = data1.x1_s(1:end-i1)/data1.xe1_s; 
        y1 = data1.y1_s(1:end-i1);
        e1 = data1.ye1_s(1:end-i1);
        
        x2 = data2.x1_s(1:end-i2)/data2.xe1_s;
        yy2 = data2.y1_s(1:end-i2);
        y2 = interp1(x2,yy2,x1);
        ee2 = data2.ye1_s(1:end-i2);
        e2 = interp1(x2,ee2,x1);
       
        errorbar(x1,y1,e1,'k<-');
        errorbar(x1,y2,e2,'ks:');
%         
%         errorbar(data1.x1_s(1:end-1)/data1.xe1_s, data1.y1_s(1:end-1), data1.ye1_s(1:end-1),'k<-'); %high contrast response fun steady
%         errorbar(data2.x1_s(1:end-1)/data2.xe1_s, data2.y1_s(1:end-1), data2.ye1_s(1:end-1),'ks-'); %high contrast response fun steady
%         
        %plot(x1_s/xe1_s, p1_s/max(p1_s), 'b.-'); %effective stimulus histgram low c
        %plot(x2_s/xe1_s, p2_s/max(p2_s), 'r.-');
%         
%         dx0 = x1_s/xe1_s; 
%         dy0 = p1_s/max(p2_s);
%         dx1 = linspace(dx0(1),dx0(end-1),5*length(dx0));
%         dy1 = smooth(interp1(dx0,dy0,dx1));
%         %plot
%         dx0 = x2_s/xe1_s; 
%         dy0 = p2_s/max(p2_s);
%         
%         dx2 = linspace(dx0(1),dx0(end-1),5*length(dx0));
%         dy2 = smooth(interp1(dx0,dy0,dx2));
        
        %plot(data1.dx1,data1.dy1,'b.-');
        %plot(data1.dx2,data1.dy2,'k.-');
        
        xlabel('Effective Stimulus','fontsize',12); ylabel('Rate(hz)','fontsize',12);title(sprintf('Raw Response Function Across Layer at LC'));
        legend(sprintf('Rs(L,%s)',LayerStr1),sprintf('Rs(L,%s)',LayerStr2),2);

        xrange = xlim;
        %show the postive half
        xlim([0 xrange(2)]);
%         xlim([max([esh_low_bin(1)/effs_std_low esh_high_bin(1)/effs_std_high]) xrange(2)]);
        %xlim([min([x1_s(1)/xe1_s x2_s(1)/xe1_s]) max([x1_s(end)/xe1_s x2_s(end)/xe1_s])]);
        yrange = ylim;
        ylim([yrange(1) yrange(1)+(diff(yrange)*1.1)]);

        fn = fullfile(fileparts(file1),sprintf('Response_Raw_AcrossLayer_LowC_Exp%d_%d_ch%d_%d.png',iExp1,iExp2,iCh1,iCh2));
        savePlotAsPic(h4,fn);
        %close(h);
        saveas(h4,strrep(fn,'png','fig'));
        close(h4);
        
