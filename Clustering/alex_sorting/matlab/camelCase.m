function str = camelCase( str )
% convert compound words from underscore delimters to CamelCase 
% Examples:
%   'hello world' --> 'hello world'
%   '__hello_world' --> 'HelloWorld'

str = regexprep( str, '_+(\w)', '${upper($1)}')