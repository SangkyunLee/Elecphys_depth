function ms_addpath(pFolder,varargin)
% function ms_addpath(pFolder,'param1',val1,'param2',val2,...)
% MS 2009-06-25
%
% This function will find all subfolders within the given folder and
% addpath to all of them.
% Optional inputs:
% 'excludeDir' - cell array of folder names that you do not want to add path to.

args.excludeDir = ''; % either a string or a cell array of strings
args = parseVarArgs(args,varargin{:});
addpath(ms_genpath(pFolder,'excludeDir',args.excludeDir));

