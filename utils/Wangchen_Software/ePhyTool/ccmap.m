function cf = ccmap(fn)
%convert the blackrock cmap file from 4-column to 5-column format.
%the additional 5th column is for the electrode label 'Elec#'. 
%the electrode number '#' represents the display index in spike pannel (row-wise).
%in the case of linear probe, the '#' will be equivalent to the site index of physical
%location for the electrodes along the probe.
%the 4-column cmap file is used in Central for online data aquisition.
%the 5-column cmap file is used with NPMK class function for data anlaysis

mapfileDataCell = importdata(fn, ' ', 200);
lastJunkIDX = find(~cellfun(@isempty, strfind(mapfileDataCell, '//')) == 1, 1, 'last') + 1;
%save the raw data
mapfileDataCell_raw = mapfileDataCell;

mapfileDataCell(1:lastJunkIDX) = [];
mapfileDataCellParsed = regexp(mapfileDataCell, '\t', 'split');
if size(mapfileDataCellParsed, 2) == 1
    mapfileDataCellParsed = regexp(mapfileDataCell, '\s+', 'split');
end

%require 5-th column to be non-whitespace.
if size(mapfileDataCellParsed{1},2) == 5 && ~isempty(mapfileDataCellParsed{1}{5}) %return if 5-column already
    disp('cmap labelled already');
    cf = fn; 
    return;
end

[fpath,fname,fext] = fileparts(fn);
fname = [fname,'_withLabel'];
cf = fullfile(fpath,[fname,fext]);
fp = fopen(cf,'w');
%write back the comments lines
for i = 1 : lastJunkIDX
    fprintf(fp,'%s\r\n',mapfileDataCell_raw{i,1});
end
%write back the data lines
obj = struct;
for i = 1:size(mapfileDataCellParsed, 1)
    obj.Column(i) = str2num(mapfileDataCellParsed{i,:}{1});
    obj.Row(i)    = str2num(mapfileDataCellParsed{i,:}{2});
    obj.Bank(i)   = mapfileDataCellParsed{i,:}{3}-'@';
    obj.Pin(i)    = str2num(mapfileDataCellParsed{i,:}{4});
    obj.ElectNum(i) = i;
    %for Central/Spike Sorting programes to use.
%     fprintf(fp,'%d\t%d\t%c\t%d\tElec%d\r\n',obj.Column(i),obj.Row(i),obj.Bank(i)+'@',...
%         obj.Pin(i),obj.ElectNum(i));
    %print the electrode channel for fredy to read (not for Central to use!) 
    fprintf(fp,'%d\t%d\t%c\t%d\tElec%d\r\n',obj.Column(i),obj.Row(i),obj.Bank(i)+'@',...
        obj.Pin(i)+(obj.Bank(i)-1)*32,obj.ElectNum(i));
%     ElectNum      = str2num(mapfileDataCellParsed{i,:}{5}(5:end));
%     if isempty(ElectNum)
%         obj.ElecNum(i) = str2num(mapfileDataCellParsed{i,:}{5}(2:end-4));
%     else
%         obj.ElecNum(i) = ElectNum;
%     end
%     obj.ChanNum(i)  = (obj.Bank(i) - 1) * 32 + obj.Pin(i);
%     try
%         obj.Label{i}    = mapfileDataCellParsed{i,:}{5};
%     catch
%         disp('e');
%     end
end

fclose(fp);
