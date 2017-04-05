function p = ms_genpath(d,varargin)
%GENPATH Generate recursive toolbox path.
%   P = GENPATH returns a new path string by adding
%   all the subdirectories of MATLABROOT/toolbox, including empty
%   subdirectories. 
%
%   P = GENPATH(D) returns a path string starting in D, plus, recursively, all
%   the subdirectories of D, including empty subdirectories.
%   
%   NOTE: GENPATH will not exactly recreate the original MATLAB path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.13.4.4 $ $Date: 2006/10/14 12:24:02 $

%   Modified by Mani Subrmaniyan 2009-06-25
%------------------------------------------------------------------------------

args.excludeDir = '';
args = parseVarArgs(args,varargin{:});



% initialise variables
methodsep = '@';  % qualifier for overloaded method directories
p = '';           % path to be returned

% Generate path based on given root directory
files = dir(d);

if ~isempty(args.excludeDir)
    dirNameArray = {files.name};
    [foo toExcludeInd] = intersect(dirNameArray,args.excludeDir);
    if ~isempty(toExcludeInd)
        files(toExcludeInd) = [];
    end
end

if isempty(files)
  return
end
% keyboard
% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

% Remove '.', '..','.svn'  etc directories

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')          && ...
         ~strcmp( dirname,'..')         && ...
         ~strcmp( dirname,'.svn')       && ...
         ~strncmp( dirname,methodsep,1) && ...
         ~strcmp( dirname,'private')
      p = [p ms_genpath(fullfile(d,dirname),'excludeDir',args.excludeDir)]; % recursive calling of this function.
   end
end


