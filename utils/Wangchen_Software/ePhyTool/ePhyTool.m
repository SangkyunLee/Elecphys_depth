function varargout = ePhyTool(varargin)
%print out help content for eTool
%
%
%

% Check for multiple versions of ePhyTool in path
ePhyToolPath = which('ePhyTool','-ALL');
if size(ePhyToolPath,1) > 1
    disp('WARNING: There are multiple ePhyTool functions in the path. Use which ePhyTool -ALL for more information.');
    ePhyToolPath = ePhyToolPath(1);
end

ePhyToolPath = fileparts(ePhyToolPath{1});
varargout{1} = ePhyToolPath; %return the path to eTool