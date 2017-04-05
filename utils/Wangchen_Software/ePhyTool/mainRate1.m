%compute the adaptation rate histogram for normLuminance after mainLoad
%
checkChannel = cmap(:,3); %use all channels in the map file
%checkChannel = [16];  %select channels for the plot.
nChannels = length(neurons);
%
iClass = 1;
gStaMax = -Inf;
gStaMin = Inf;
%delay time before stimulus starts
delayTime = s_SETS.matData.params.delayTime;

for k = 1 : nChannels
    if ~any(checkChannel == neurons{k}.channel); continue; end
    %return a struct  - test the first one
    fprintf('Compute Firing Rate for chan[%d]...\n',k);
    %
    for kk = 1 : length(neurons{k}.clusters)
        %compute the spontaneous firing rate for each cluster
        neurons{k}.clusters{kk}.basefr = length(find(neurons{k}.clusters{kk}.timestamps<delayTime))/delayTime;
        %e.g, mm=2 for 'low' and 'high' contrast for guassian luminance.
        for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
            ts = neurons{k}.clusters{kk}.class{iClass}.member{mm}.timestamps;
            ts = ts';
            if mm == 1
                REF = lowConOnsets;
            else
                REF = highConOnsets;
            end
            [spikeCount,spikeCountSE,xout] = pePSTH(ts,REF,[0:tBin:tBlock-tBin]);
            %append 'sta' to neurons.
            firingRate = spikeCount/tBin;
            firingRateSE = spikeCountSE/tBin;
            %
            fitcoeff = expFit(xout',firingRate');
            %
            rateExpFit = fitcoeff(1) + fitcoeff(2)*exp(-fitcoeff(3)*xout);
            %
%             neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = firingRate; %firing rate
%             neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = [];%covariance
%             neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = firingRateSE;%error
%             neurons{k}.clusters{kk}.class{iClass}.member{mm}.fit = rateExpFit;
%             neurons{k}.clusters{kk}.class{iClass}.member{mm}.fitcoeff = fitcoeff;
%             neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = sum(spikeCount); %total spikes used in computation.
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate = struct;
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.x = xout; %time scale
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.y = firingRate;
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.error = firingRateSE; %standard error
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.fit = rateExpFit; %exponential fit to adaption rate
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.fitcoeff = fitcoeff;%baseline,amplitude,time constant
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.spikes = sum(spikeCount); %total spikes used in computation;
            gStaMax = max([gStaMax max(max(firingRate)) max(max(firingRateSE))]);
            gStaMin = min([gStaMin min(min(firingRate)) min(min(firingRateSE))]);
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.adaptationRate.ylim = [gStaMin,gStaMax];
        end
    end
    xSTA = xout;
    %generate average profile for multi-unit activity.
    data = zeros(size(xSTA));
    Nspk = 0;
    for kk = 1 : length(neurons{k}.clusters)
        %exclude the unsorted unit
        if neurons{k}.clusters{kk}.id == 0 ; continue; end
        if neurons{k}.clusters{kk}.id == 255 ; continue; end
        for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
            Nspk = Nspk + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes);
            try
                data = data + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta)*(neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes);
            catch
                %sta returns '[]' for channels having no spikes
                %data = data + 0;
            end
        end
    end
    if Nspk > 0 ; data = data / Nspk; end
    %multi-unit profile of sta
    neurons{k}.sta = data;
end