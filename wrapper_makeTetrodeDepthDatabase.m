%% I generate this script from wangchen's old matlab command history
% To generate depth information from all tetrodes and sesssions, wangchen
% ran 'makeTetrodeDepthDatabase.m'.
% but the script was not complete.
% Therefore, I generate this wrapper script to reproduce his result and
% validate his process and analysis 2017-03-22



xls_path ='W:\data\Wangchen\Acute Experiment Excel Log\';
ses_xls{1} = 'Acute_Oct18_2011_ttshow_tetrodeDepth.mat';
ses_xls{2} = 'Acute_Feb15_2012_ttshow_tetrodeDepth.mat';
ses_xls{3} = 'Acute_Nov12_2012_ttshow_tetrodeDepth.mat';

complete_sessions={1:9,1:9,1:12};
ttdeps = cell(3,1);
for iexp =1 :3
    fullfn = fullfile(xls_path, ses_xls{iexp});
    load(fullfn)

    n = length(tet);
    nsession = max(tet(1).turnStop);
    ttdep = -1*ones(nsession,24);
    for i = 1 : n
        if ~isempty(strfind(tet(i).id,'tt'))
            id = str2double(tet(i).id(3:end));
        else
            continue;
        end
        if isempty(tet(i).turnStop >0)
            continue;
        end
        %find the depths per tet
        K = tet(i).turnStop>0;
        ttdep(tet(i).turnStop(K),id) = tet(i).turnDepth(K);
    end
    ttdeps{iexp}=ttdep(complete_sessions{iexp},:);
end






ttdeps = cell2mat(ttdeps);

rootdir='W:\data\Wangchen\CEREBUS\DataFile\CerebusData\acute_raw'

makeTetrodeDepthDatabase

% Then he trimmed out some redundant experiment (particularly)
% from tetDepth (structure array n=121) 
% 37:) SpontaneousActivity	2011-Oct-22	10-58-09
% 38:) SpontaneousActivity	2011-Nov-01	19-18-30
% the final data were saved in tetrode_depth.mat and
% tetrode_depth_redundencyCorrected.mat
% both files contain the same results









%%
% sesExp = cell2mat(complete_sessions)
% for i = 1 : length(sid)
%     fprintf('%d, %d:) %s\t%s\t%s\n',i,sesExp(i),tet(sid(i)).exp,tet(sid(i)).date,tet(sid(i)).time);
% end
% 
% 
% tx =a.tetDepth;
% 
% for i = 1 : length(tx)
%     fprintf('%d:) %s\t%s\t%s\n',i,tx(i).exp,tx(i).date,tx(i).time);
% end
% 
% 
% tx1 =a.tetDepth;
% tx2=b.tetDepth;
% tx3=c.tetDepth;
% 
% fnname = fieldnames(tx1(1))
% CX = NaN*ones(length(tx1),length(fnname));
% for i = 1 : length(tx1)
%     for ifn = 1 : length(fnname)
%         if ischar(tx1(i).(fnname{ifn}))
%             m1 = tx1(i).(fnname{ifn});
%             %m2 = tx2(i).(fnname{ifn});
%             m3 = tx3(i).(fnname{ifn});
%         else
%             m1 = num2str(tx1(i).(fnname{ifn}));
%             %m2 = num2str(tx2(i).(fnname{ifn}));
%             m3 = num2str(tx3(i).(fnname{ifn}));
%         end
%         m = strcmp(m1,m3);
%             
% %             m = strcmp(tx1(i).(fnname{ifn}),tx2(i).(fnname{ifn})) + ...
% %                 strcmp(tx1(i).(fnname{ifn}),tx3(i).(fnname{ifn})) + ...
% %                 strcmp(tx2(i).(fnname{ifn}),tx3(i).(fnname{ifn}));
%             
%             
%         CX(i,ifn)=m;
%     end
%         
% end
