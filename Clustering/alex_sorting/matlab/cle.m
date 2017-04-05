function cle(varargin)
% Clears all except the passed variables.
% AE 2005-05-15

vars = evalin('caller','who');
for i = 1:length(vars)
	if isempty(strmatch(vars{i},varargin,'exact'))
		evalin('caller',sprintf('clear %s',vars{i}))
	end
end

