% FlashingBar expriments have a following protocol
% barColors: [255 0 128]
% barDurations: [1 0 4]
% I check CSD at the first flash (stimonset) and the second flash(i.e.,
% 1sec after the stim onset)
% then average them

rootdir = 'W:\data\Wangchen\CEREBUS\DataFile\CerebusData\acute'
fig_dir = '../figures/analysis/CSD';


csd = CSD(rootdir,'LFP_all.mat',[],1,'FlashingBar');
csd = csd.genHPF([1 2], 'attenuation',60);
csd = csd.applyfilt;
twin =[-0.02 0.3];
twin0 = [-0.02 0.02];




depth=csd.get('depth');
method='kernel'

%% ------------ get CSD from the 1st flash ERP
[ERP, ERPtime] = csd.getERP(twin, twin0);
MAP = csd.getCSD(ERP,depth,ERPtime{1}, method);  
 axispar=struct('FontSize',6,'YTick',[0 500 1000 1500])
 for i = 1:24
     if ~isempty(MAP(i).CSD)
         csdmap =MAP(i).CSD;
         y = MAP(i).pos;
         x = MAP(i).time;
         figure(i); %         
         imagesc(x,y,csdmap);     
         hold on;
         plot(zeros(size(depth,1),1)',depth(:,i)','*w','MarkerSize',6);
         if ~isdir(fig_dir)
             mkdir(fig_dir)
         end
         savefigure(i,fullfile(fig_dir,sprintf('exp%d_tt%d_ERP1',expID,i)),axispar)
         
     end
 end
 
 %% ------------ get CSD from the 2nd flash ERP
 close all
 [ERP1, ERPtime1] = csd.getERP(twin+1, twin0+1);
 MAP = csd.getCSD(ERP1,depth,ERPtime1{1}, method);  
 axispar=struct('FontSize',6,'YTick',[0 500 1000 1500])
 for i = 1:24
     if ~isempty(MAP(i).CSD)
         csdmap =MAP(i).CSD;
         y = MAP(i).pos;
         x = MAP(i).time;
         figure(i); %         
         imagesc(x,y,csdmap);     
         hold on;
         plot(zeros(size(depth,1),1)',depth(:,i)','*w','MarkerSize',6);
         if ~isdir(fig_dir)
             mkdir(fig_dir)
         end
         savefigure(i,fullfile(fig_dir,sprintf('exp%d_tt%d_ERP2',expID,i)),axispar)
         
     end
 end
 
 %% avg ERP
 close all
 
 avgERP = cell(1,length(ERP));
 for i=1:length(ERP)
     avgERP{i} = 0.5*(ERP1{i}+ERP{i});
 end
 
 
 MAP = csd.getCSD(avgERP,depth,ERPtime{1}, method);  
 axispar=struct('FontSize',6,'YTick',[0 500 1000 1500]);
 for i = 1:24
     if ~isempty(MAP(i).CSD)
         csdmap =MAP(i).CSD;
         y = MAP(i).pos;
         x = MAP(i).time;
         figure(i); %         
         imagesc(x,y,csdmap);     
         hold on;
         plot(zeros(size(depth,1),1)',depth(:,i)','*w','MarkerSize',6);
         if ~isdir(fig_dir)
             mkdir(fig_dir)
         end
         savefigure(i,fullfile(fig_dir,sprintf('exp%d_tt%d_ERPavg',expID,i)),axispar)
         
     end
 end
 