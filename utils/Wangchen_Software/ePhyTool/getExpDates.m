%data directory
a = 'h:\work\data\cerebusData\mice\NormLuminance\';
%
dateFormat = 'yyyy-mmm-dd\HH-MM-SS';
%list the files of all experiments
b = rdir(fullfile(a,'**\*'));
%get the date 
dateArray = zeros(1,length(b));
for i = 1 : length(b)
    %if ~b(i).isdir ; continue; end  % no directory returned
    if length(b(i).name) < length(a)+length(dateFormat) ; continue; end
    dname = b(i).name(length(a)+1 : length(a)+length(dateFormat));
    if isempty(regexpi(dname,'201[1-2]-[A-Z]{3}-[0-9]{2}\','match')); continue; end
    dateArray(i)  = datenum(dname,dateFormat);
end

%get the list of unique ones
dateList = sort(unique(dateArray));
%remove the empty ones
dateList(dateList==0)=[];
%
dateVecArray = zeros(size(dateList,1),6);
for i = 1 : length(dateList)
    dateVecArray(i,:) = datevec(dateList(i));
end
%
dateVecArray = round(dateVecArray); %round to integers
%create the template for depth indexing.
probe = struct;
for i = 1 : length(dateList)
%     probe(i).type = 'standard';
    probe(i).type = 1;         % 1: standard/ 0: edge
    probe(i).spacing = 50; 
    probe(i).reference = 11;    %reference probe to count the depth 
    probe(i).refDepth = 1200 ;     %depth of the reference probe.
end

%write to text file
depthFile = 'c:\work\depthDataBase.txt';
fp = fopen(depthFile,'w+');
fprintf(fp,'%%1~6)Exp Date 7)Probe Type 8)Probe Spacing 9)Probe Ref 10)Ref Depth\r');
for i = 1 : length(dateList)
    fprintf(fp,'\n%4d %2d %2d %2d %2d %2d %d %3d %2d %4d\r',dateVecArray(i,1),dateVecArray(i,2),dateVecArray(i,3),...
        dateVecArray(i,4),dateVecArray(i,5),dateVecArray(i,6),probe(i).type,probe(i).spacing,probe(i).reference,probe(i).refDepth);
end

fclose(fp);

    