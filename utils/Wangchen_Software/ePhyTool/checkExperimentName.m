function p = checkExperimentName(r,s)
%check if the structs of stimulation and raw data match up
%

if strcmp(r.subject,s.subject) && strcmp(r.exp,s.exp) && strcmp(r.date,s.date) && strcmp(r.time,s.time)
    %fprintf('stim and raw data are from same experiment\n');
    p = true;
else
    %fprintf('stim and raw data dont match ! \n');
    p = false;
end