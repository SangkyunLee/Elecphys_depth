function runjobs

while true
    
    % find available job
    load jobs
    available = find([jobs.status] == 0, 1);
    if isempty(available)
        return
    end
    jobs(available).status = 1;
    save jobs jobs
    
    % run it
    try
        clus_run_job(jobs(available))
        jobs(available).status = 2;
    catch err
        disp(err)
        jobs(available).status = -1;
    end
    save jobs jobs
    
end
    
