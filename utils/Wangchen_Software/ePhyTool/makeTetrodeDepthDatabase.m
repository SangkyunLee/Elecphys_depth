%struct to store tetrode depth for all recordings 
tet = struct('subject',[],...
    'exp',[],...
    'date',[],...
    'time',[],...
    'tetrode',[],...
    'depth',[]);

targetFile = '*.ns5';
%search the 'target' files to locate the data subfolders.
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));

% fp = fopen('c:\work\openModelDataError.txt','w+');
%
k = 0; 

beforeDate = '2011-Oct-01\01-01-01'; 
beforeDateNum = datenum(beforeDate,'yyyy-mmm-dd\HH-MM-SS'); %skip data before the set date.

for i = 1 : length(d)
     
    fname = d(i).name;
    p = parseExperimentName(fname);
    if datenum([p.date,'\',p.time],'yyyy-mmm-dd\HH-MM-SS') < beforeDateNum ; 
%         fprintf('%s %s\n',p.date,p.time); 
        continue; 
    end
    if strcmp(p.exp,'GratingExperiment'); continue; end
    k = k + 1;
    tet(k).subject = p.subject;
    tet(k).exp     = p.exp;
    tet(k).date    = p.date;
    tet(k).time    = p.time;
    
end

dv = zeros(1,length(tet));

for i = 1 : length(tet)
    dv(i) = datenum([tet(i).date,'\',tet(i).time],'yyyy-mmm-dd\HH-MM-SS');
end

[dv,dvi]=sort(dv);

tet = tet(dvi);



%find the bad/cancaled recordings by notes (some can't be identified by
%redundency). 
bad(1).exp = 'SquareMappingExperiment';
bad(1).date= '2011-Oct-22';
bad(1).time= '09-44-47';      %last recording on 1st exp. not complete

bad(2).exp = 'SquareMappingExperiment';
bad(2).date= '2012-Feb-17';
bad(2).time= '07-09-01';      %cannceled b/c IV line fix 

bad(3).exp = 'NormGrating';
bad(3).date= '2012-Feb-17';
bad(3).time= '07-39-08';      %

bad(4).exp = 'NormGrating';
bad(4).date= '2012-Nov-13';
bad(4).time= '17-36-11';      %early termination

bad(5).exp = 'FlashingBar';
bad(5).date= '2011-Nov-01';
bad(5).time= '19-48-18';      %early termination

bad(6).exp = 'NormLuminance';
bad(6).date= '2011-Oct-22';
bad(6).time= '11-37-39';      %last session on 1st. 


x = [];
for i = 1 : length(tet)
    for j = 1 : length(bad)
        if strcmpi(tet(i).exp,bad(j).exp) && strcmpi(tet(i).date,bad(j).date) && strcmpi(tet(i).time,bad(j).time)
            fprintf('found %s %s %s\n',bad(j).exp,bad(j).date,bad(j).time);
            x = [x i];
        end
    end
end

%find bad recordings by redundency.
%x = [];
for i = 1 : length(tet)
    if i > 1 
        if strcmp(tet(i).exp,tet(i-1).exp)
            x = [x i-1];
        end
    end
end

x = unique(x); %remove multiple matches.

for i = 1 : length(x)
    %fprintf('%d: %s\t%s\t%s\n',i, tet(x(i)).exp,tet(x(i)).date,tet(x(i)).time);
end

tet(x) = [];

%fprintf('%s\t%s\t%s\t%s\n','SquareMap','NormGrating','NormLum','FlashingBar');

% for i = 1 : length(tet)
%     if i+3 <= length(tet)
%         if strcmpi(tet(i).exp,'SquareMappingExperiment') && strcmpi(tet(i+3).exp,'FlashingBar')
%             x = [x i:i+3];
%         end
%     end 
% end

for i = 1 : length(tet)
    fprintf('%d:) %s\t%s\t%s\n',i,tet(i).exp,tet(i).date,tet(i).time);
end

%flashinbar omitted for last recording after 2012-Feb-19	01-48-00.

tt = tet; 
    
%start index of the sessions
sid = [];

for i = 1 : length(tt)
    if strcmpi(tt(i).exp,'SquareMappingExperiment')
        sid = [sid i];
    end
end


for k = 1 : length(sid)
    session_start = sid(k);
    if k < length(sid)
        session_end = sid(k+1);
    else
        session_end = length(tt);
    end
    
    for i = session_start : session_end 
        tt(i).tetrode = [1 : 24];
        tt(i).depth   = ttdeps(k,:);     %convert cell array ttdeps into matrix array in workspace beforehand 
    end
end

tetDepth = tt;

save(fullfile(pwd,'tetrode_depth.mat'), 'tetDepth');
    

    