function r = getTrialParams(s,p)
%return the param value in trial struct

if isfield(s,'raw')
    r = s.raw.matData.params.(p);
else
    r = s.matData.params.(p);
end
