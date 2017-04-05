function [ output_args ] = rfmCleanupParams( input_args )
%CLEANUPPARAMS Summary of this function goes here
%  Detailed explanation goes here
load par

fns=fieldnames(par);

searchfor='edit';
searchlen=length(searchfor);

for i=1:length(fns)
    fn=fns{i};
    if length(fn) >= length(searchfor)
        if (strcmp(fn(1:searchlen),searchfor))
            par=rmfield(par,fn);
        end;
    end;
end;

save par;