
%calculate standard csd from lfp files for tetrode recording in root directory
%


%load the depth data variable 'tetDepth' 
depthFile = 'W:\data\Wangchen\Acute Experiment Excel Log\tetrode_depth.mat';
expID = 1;
exptype ='FlashingBar'
depthInfo = get_seslist(depthFile, expID,exptype);



Ndep = length(depthInfo);
Ntet = 24;


d = rdir(fullfile(rootdir,'**\LFP_all.mat'));
LFP = cell(Ndep,Ntet);
onset = cell(Ndep,1);
for i = 1 : Ndep
    expDate = [depthInfo(i).date,'\',depthInfo(i).time];
    for j = 1 : length(d)
        lfpFile = d(j).name;
        if ~isempty(strfind(lfpFile,expDate))            
            Mat= load(lfpFile);
            LFP(i,:) =Mat.data(:)';
            stimData = load(fullfile(fileparts(lfpFile),'stimData.mat'));
            onset{i} = stimData.stimData.Onsets; 
        end
    end
end
tets = Mat.Att.tetrodes;
Fs= Mat.Att.Fs;
t0_msec = Mat.Att.t0;
cutoff =2;
filter = filterFactory.createHighpass(1,...
    cutoff(1), Fs ,'attenuation',60);
cf = struct(filter);
cf = cf.filt; 


for i = tets
    erp1 = cell(Ndep,1);
    erp2 = erp1;
    for j = 1 : Ndep
        x = LFP{j,i};
        x = filtfilt(cf,1,x);

        lfp_data.data = x;
        lfp_data.Att.Fs = Fs;
         lfp_data.Att.t0 = t0_msec;
        [erp1{j},erp_time,~,erp2{j}]  = ...
            getlfpERP(lfp_data,onset{j},[-0.05 0.4],[-0.05 0.02]);           
    end
    
    erp1 = cell2mat(erp1);
    erp2 = cell2mat(erp2);
    
    erp = 0.5*(erp1+erp2);

    % figure; plot(erp_time,pot1')
    % figure; plot(erp_time,pot2')
    figure; plot(erp_time,erp1')
    method = 'kernel';
    el_pos =Depth(:,i);
    [CSD,pos] = getCSD(erp2,el_pos, method);
    figure; imagesc(erp_time,pos,CSD)
    
end



%% --------------------------------------


% k = 0;
% %find the flashingbar experiments in records
% for i = 1 : length(tetDepth)
%     if strcmp(tetDepth(i).exp,'FlashingBar') && ~isempty(strfind(tetDepth(i).date,expToken))
%         k = k + 1;
%         F(k) = tetDepth(i);
%     end
% end
% 
% 
% %search the 'target' files to locate the data subfolders.
% d = rdir(fullfile(rootdir,'**\LFP_tt*.mat'));
% lfp_files = cell(length(F),24);
% for i = 1 : length(F)
%     expDate = [F(i).date,'\',F(i).time];
%     for j = 1 : length(d)
%         lfpFile = d(j).name;
%         if ~isempty(strfind(lfpFile,expDate))
%             [fpath,fname,fext]=fileparts(lfpFile);
%             tid = str2num(fname(7:end));
%             lfp_files{i,tid} = lfpFile;
%         end
%     end
% end
% 
% lfp_data = cell(length(F),24);
% erp_data = lfp_data;
% erp_data2 = lfp_data;
% 
% 
% %method = 'delta'; %'standard'
% %method = 'standard'; %'standard'
% method = 'kernel';
% 
% %
% 
% 
% tets = 1:24;
% cutoff =1;
% filter = filterFactory.createHighpass(0.5,...
%     cutoff(1), Fs ,'attenuation',30);
% cf = struct(filter);
% cf = cf.filt; 
% 
% % fvtool(cf,'Color','White');
% % N = 500;                               % Filter order
% % Fr = [0 59 60 61 Fs/2]/(Fs/2);  % Frequency vector
% % A = [1 1  0  1 1];                % Magnitude vector
% % S = { 'n' 'n' 's' 'n' 'n'};
% % cf2 = firgr(N,Fr,A,S);
% % fvtool(cf,'Color','White');
% 
% % wo = 60/(Fs/2);  bw = wo/35;
% % [b,a] = iirnotch(wo,bw);
% % fvtool(b,a);
% 
% %load stimulus event timestamps
% for i = tets
%     erp1 = cell(length(F),1);
%     erp2 = erp1;
%     for j = 1 : length(F)
%         %load the lfp data
%         if ~isempty(lfp_files{j,i})            
%             lfp_data = load(lfp_files{j,i});
%             load(fullfile(fileparts(lfp_files{j,i}),'stimData.mat'));
%             x = lfp_data.data;
%             %x = filtfilt(cf,1,x);
%             x = filtfilt(cf2,1,x);
%             lfp_data.data = x;
% 
%             [erp1{j},erp_time,~,erp2{j}]  = ...
%                 getlfpERP(lfp_data,stimData.Onsets,[-0.05 0.2],[-0.05 0.02]);
%             
% %             [erp_data{j,i},erp_time,~,erp_data2{j,i}]  = ...
% %                 getlfpERP(lfp_data{j,i},stimData.Onsets,[0.3 0.55],[-0.05 0.02]);
%         end
%     end
%     
%     erp1 = cell2mat(erp1);
%     erp2 = cell2mat(erp2);
%     
%     erp = 0.5*(erp1+erp2);
% 
%     % figure; plot(erp_time,pot1')
%     % figure; plot(erp_time,pot2')
%     figure; plot(erp_time,erp1')
% end
% 
% x = cell2mat(erp_data2(:,1));
% 
% 
% 
% save('tet1.mat','pot1','pot2','pot3')
% % saveFolder = fullfile(fileparts(depthFile),'Depth_iCSD',method);
% % if ~exist(saveFolder,'dir'); mkdir(saveFolder); end
% 
% D = cat(1,F.depth); %tetrode depth matrix in um
% csd_data = cell(1,length(tets));
% 
% for i = tets
%     el_pos = D(:,i);
%     erpMat = cell2mat(erp_data(:,i));
%     if all(el_pos==-1); continue; end
%     
%     %exclude the bad recording (9th) for tt12 on Oct2011
%     if i ==12 && expID ==1
%         el_pos(9) = [];
%         erpMat(9,:) = [];
%     end
%     
%     %remove the recordings at negative depth 
%     neg = find(el_pos < 0) ; 
%     for nn = 1 : length(neg)
%         fprintf('exp%d,tet%d,recording%d has negative depth %f\n',expID,i,neg(nn),el_pos(neg(nn)));
%     end
%     
%     el_pos(neg)=[];
%     erpMat(neg,:)=[];
%     
%     %
%     %---------------- Plot ERP (spaced) -------------------------------
%     h = plot_erp(erpMat,erp_time,el_pos);%plot scaled and layed out erps
%     figure(h);
%     title(['ERP tetrode',num2str(i)]);    
%     savePlotAsPic(h,fullfile(saveFolder,sprintf('ERP_%s_tt%d.png',expToken,i)));
%     close(h);
%     %--------------- Plot ERP (overlay) -------------------------------
%     h = plot_erps(erpMat,erp_time,el_pos); %plot raw/overlaid erp 
%     figure(h);
%     title(['ERP tetrode',num2str(i)]);    
%     savePlotAsPic(h,fullfile(saveFolder,sprintf('ERPRaw_%s_tt%d.png',expToken,i)));
%     close(h);    
%     
%     %---------------Compute CSD --------------------------------------
%      %return csd matrix and updated electrode positions.
%     [csd_data{i},el_pos] = getCSD(erpMat,el_pos,method); %need column vector for depth.
%    
%     %-------------- Plot CSD ---------------------------------------
%     if isempty(csd_data{i}); continue; end %skip the empty dataset.
%     h = plot_csd(csd_data{i},erp_time,el_pos);
%     figure(h);
%     title(['CSD tetrode',num2str(i)]);    
%     savePlotAsPic(h,fullfile(saveFolder,sprintf('%cCSD_%s_tt%d.png',method(1),expToken,i)));
%     close(h);
%     
% end
% 
% 
% function [CSD,pos] = getCSD(erpMat,el_pos, method)
% %erp_data : event-related potential matrix (depth recordings x times)
% %el_pos   : column vector of electrode position
% %method   : csd computation method
% 
% CSD = []; pos = [];
% %d = D(1:end,tid); % tetrode depth vector
% if all(el_pos == -1); return; end
% [nrec,npts] = size(erpMat);
% %average the erp over recordings made at same depth. 
% [uni_pos, uni_pid1] = unique(el_pos,'first');
% [uni_pos, uni_pid2] = unique(el_pos,'last');
% %
% nuq = length(uni_pos); %unique number of depth
% pot = zeros(nuq,npts);
% 
% for i = 1 : nuq
%     pot(i,:) = mean(erpMat(uni_pid1(i):uni_pid2(i),:),1);
% end
% 
% [CSD,pos] = iCSD(pot,uni_pos,method); 
% 
% 
% 
% 
% 
% %



