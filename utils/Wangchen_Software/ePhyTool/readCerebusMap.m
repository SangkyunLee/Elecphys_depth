function cmap = readCerebusMap(fn)
%read in the cerebus electrode mapping files and return the map struct.
%
%

%config file full name.
fid = fopen(fn,'r');

i=0;

if fid < 0 
    error('Cannot Open Cerebus Map File %s',fn);
    return;
end

%save each line into cell array.
while true
    rl = fgetl(fid);
    if ~ischar(rl) ; break ; end;
    i = i + 1;
    %put the line into cell array.
    cLines{i} = rl;
end

fclose(fid);
%
n = length(cLines);

textline = 0;
%row,column,electrode number
cmap = zeros(n,3);

for i = 1 : n
    rl = cLines{i};
    
    %skip empty or blank lines.
    if isempty(rl) || ~isempty(regexp(rl,'^ *$'))
        continue;
    end 
   
    %if the 1st non-space char is '//', skip the line. i.e. comment line.
    if  ~isempty(regexp(rl,'^ *//'))
        fprintf('%s\n',rl); %print the comments on cmd window.
        continue; %skip the comment line parsing and continue to the next line.
    end
   
    if textline == 0 %skip the first line.
        textline = textline + 1;
        fprintf('%s\n',rl);
        continue;
    end
        %split the line into two fields. result contained in cell array
        spl = regexp(rl, '[ \t]', 'split');
        %skip the format check.
%         if length(spl)~=4  %invalid line
%             %spl
%             error('%s -- %s','invalid line format',rl);
%         end
    %silly way to remove whitespace.
    ws = [];
    for j = 1 : length(spl)
        if strcmp(spl{j},'')
            ws = [ws j];
        end
    end
    spl(ws)=[];
    cmap(textline,1) = str2num(spl{1});
    cmap(textline,2) = str2num(spl{2});
    %electrode ID
%     cmap(textline,3) = str2num(spl{4}) + (strtrim(spl{3})-'A')*32;

    % the 4-th column always has the bank id for both format      
    if length(spl)==4
        cmap(textline,3) = str2num(spl{4}) + (strtrim(spl{3})-'A')*32;
    else %5-column format. the 4th column has the actual electrode id 
        cmap(textline,3) = str2num(spl{4});
    end
    
    textline = textline + 1;
    
end

if n > textline-1
    cmap(textline:n, :) = [];
end
