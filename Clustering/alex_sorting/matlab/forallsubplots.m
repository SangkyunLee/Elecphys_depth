function forallsubplots(varargin)
% forallsubplots(param1,val1,param2,val2,...)
%
% Selects every subplot of the current figure
% and executes Command.
%
% can be used for aligning axis!!!

for a = get(gcf,'Children')';
	set(a,varargin{:})
end

% Written by Kenneth D. Harris 
% This software is released under the GNU GPL
% www.gnu.org/copyleft/gpl.html
% any comments, or if you make any extensions
% let me know at harris@axon.rutgers.edu
