function mb(varargin)
% Prints to the command line the variables' sizes in megabytes
%
% usage: mb var1 var2 ...
%
% AE 2005-05-28

if ~nargin
	vars = evalin('caller','who');
else
	vars = varargin;
end

query = sprintf('''%s'',',vars{:});
query = ['whos(' query(1:end-1) ');'];
w = evalin('caller',query);
bytes = [w.bytes] / 2^20;
t = [{w.name}; mat2cell(bytes,1,ones(1,length(bytes)))];
len = max(cellfun('length',t(1,:)));
disp(' ')
fprintf(['%' num2str(len+4) 's: %6.1f Mb\n'],t{:})
disp(' ')
