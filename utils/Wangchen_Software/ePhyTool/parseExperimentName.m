function s = parseExperimentName(f)
%parse the data file name into subfolder names structured with experiment conditions 
%f : stimulation/raw data file name
%s : returned struct.

%
s = struct('filename',[],...
           'base',[],...
           'subject',[],...
           'exp',[],...
           'date',[],...
           'time',[],...
           'etc',[]);
       
%data file name
s.filename = f;
%
[fd,fn,fext] = fileparts(f);
%seperator postions
sp = regexpi(fd,'\\');
%find the seperator before the date.
mx = regexpi(fd,'\\201[1-9]-[A-Z]{3}-[0-9]{2}\','start');

if isempty(mx) ; return; end

m = find(sp==mx);
%
s.date = fd(sp(m)+1 : sp(m+1)-1);
%
if length(sp)>m+1 %path contains 'etc' subfolder 
    s.time = fd(sp(m+1)+1 : sp(m+2)-1);
    s.etc  = fd(sp(m+2)+1 : end);
else
    s.time = fd(sp(m+1)+1 : sp(m+1)+8);
end

s.exp = fd(sp(m-1)+1 : sp(m)-1);
s.subject = fd(sp(m-2)+1 : sp(m-1)-1);
s.base = fd(1 : sp(m-2)-1);

%change empty field to string type
if isempty(s.etc) 
    s.etc = '';
end




       