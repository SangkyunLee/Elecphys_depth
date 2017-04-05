function writetxt2excel(fn)
%write rate/sta summary txt to excel file
%
%

inputfileDataCell = importdata(fn, ' ',200);
lastJunkIDX = find(~cellfun(@isempty, strfind(inputfileDataCell, '%')) == 1, 1, 'last');
%save the raw data
inputfileDataCell_raw = inputfileDataCell;

inputfileDataCell(1:lastJunkIDX) = [];
inputfileDataCellParsed = regexp(inputfileDataCell, ' ', 'split');
% if size(inputfileDataCellParsed, 2) == 1
%     inputfileDataCellParsed = regexp(inputfileDataCell, '\s+', 'split');
% end

s1 = {'1)Exp Date-YY','2)Exp Date-MM','3)Exp Date-DD', '4)Exp Time-HH', '5)Exp Time-MM','6)Exp Time-SS',...
    '7)Contrast-L', '8)Contrast-H','9)Channel', '10)Unit', '11)Spontaneous rate',... 
    '12)Adaptation Time@Low', '13)Steady Rate@Low', '14)Initial Rate@Low',  '15)R2@Low','16)average of Standard Error@Low',... 
    '17)Adaptation Time@High','18)Steady Rate@High','19)Initial Rate@High', '20)R2@High','21)average of Standard Error@High'};

s2 = {'1)Exp Date-YY','2)Exp Date-MM','3)Exp Date-DD', '4)Exp Time-HH', '5)Exp Time-MM','6)Exp Time-SS',...
    '7)Contrast-L', '8)Contrast-H','9)Channel', '10)Unit',...
    '11)Peak Time@Low','12)Peak Amp@Low','13)Peak Width@Low','14)Valley Time@Low','15)Valley Amp@Low','16)Valley Width@Low',...
    '11)Peak Time@High','12)Peak Amp@High','13)Peak Width@High','14)Valley Time@High','15)Valley Amp@High','16)Valley Width@High'};

data = cell2mat(inputfileDataCellParsed);
xlswrite(strrep(fn,'.m','.xls'),data);

%if ~isempty(regexpi(fn,'sta')) && size(inputfileDataCellParsed,2)==length(s2)
    

