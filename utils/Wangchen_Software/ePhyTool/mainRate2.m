%compute the adaptation rate histogram for normLuminance after mainLoad
%keep the old structure names temporarily,i.e., use 'sta' to represent firingrate
%checkChannel = cmap(:,3); %use all channels in the map file
nChannels = length(neurons);
checkChannel = zeros(1,nChannels);
for k = 1 : nChannels; checkChannel(k) = neurons{k}.channel; end %use all channels in recording. 
% %checkChannel = [16];  %select channels for the plot.

%
iClass = 1;
gStaMax = -Inf;
gStaMin = Inf;
%delay time before stimulus starts
delayTime = s_SETS.matData.params.delayTime;
%fine time bin to count the spikes 
fBin = 1 ; 
%number of bin to average spike counts
nbs = tBin/fBin ; %2 sec 
%number of bin to exclude at transition
nex = 1 ; % 1 sec exclusion window

for k = 1 : nChannels
    if ~any(checkChannel == neurons{k}.channel); continue; end
    %return a struct  - test the first one
    fprintf('Firing Rate Computation for File[%d], uch[%d]...\n',i,checkChannel(k));
    %compute STA for normlumniance and squaremapping.
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
            %[spikeCount,spikeCountSE,xout] = pePSTH(ts,REF,[0:tBin:tBlock-tBin]);
            %[spikeCount,spikeCountSE,xout_s] = pePSTH(ts,REF,[0:fBin:tBlock-fBin]);  
            [xout,firingRate,firingRateSE,spikeCount,spikeCountSE,sxout,scArray] = getAptFiringRate(ts,REF,[0:fBin:tBlock-fBin],2,1);  
            %
            fitcoeff = expFit(xout',firingRate');
            %
            rateExpFit = fitcoeff(1) + fitcoeff(2)*exp(-fitcoeff(3)*xout);
            %goodness of fit
            SS_tot = sum(firingRate.^2 - (mean(firingRate))^2);
            SS_err = sum((rateExpFit - firingRate).^2);
            %R squre
            R_squre = 1 - SS_err/SS_tot;
            %for plotRateFigs
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.x = xout; %time
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.y = firingRate; %firing rate
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.err = firingRateSE; %firing rate standard error
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.fit.y = rateExpFit; %fit curve
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.fit.coeff = fitcoeff; %firing rate
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.fit.goodness = R_squre; %firing rate
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.counts = sum(spikeCount); %spike counts
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.firingRate.scArray = scArray; %spike counts
            %for plotRateFig
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta = firingRate; %firing rate
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.stc = [];%covariance
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.std = firingRateSE;%error
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.fit = rateExpFit;
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.fitcoeff = fitcoeff;
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.fitgoodness = R_squre;
            neurons{k}.clusters{kk}.class{iClass}.member{mm}.spikes = sum(spikeCount); %total spikes used in computation.
            gStaMax = max([gStaMax max(max(firingRate)) max(max(firingRateSE))]);
            gStaMin = min([gStaMin min(min(firingRate)) min(min(firingRateSE))]);
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


switch expName
    case {'DotMappingExperiment','SquareMappingExperiment'}
        %view option for normluminance
        viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
        viewOption.memberID = 1; %member id, .e.g which contrast
        %option for mapping
        viewOption.clusterID = []; %view specified cluster if viewMUA false
        viewOption.viewUnsortedUnit = false; %flag for plotting unsorted unit
        viewOption.viewMUA = true; %view multi-unit for receptive-field
        viewOption.colorscale = [gStaMin gStaMax]; %color range.

    case {'NormLuminance','NormGrating'}
        %
        viewOption = struct;
        viewOption.plot = 'STA';
        viewOption.plotdim = 1; %plot in 1/2d
        viewOption.message = '';
        viewOption.skip = true; %skip empty data channel for plotting.
        %view option for normluminance
        viewOption.classID = 1; %classifier id, e.g, 1st class = contrast
        viewOption.memberID = 1; %member id, .e.g which contrast
        %option for mapping
        viewOption.clusterID = []; %view specified cluster if viewMUA false
        viewOption.viewUnsortedUnit = true; %flag for plotting unsorted unit
        viewOption.viewMUA = false; %view multi-unit for receptive-field
        %viewOption.colorscale = [gStaMin-0.3*(gStaMax-gStaMin) gStaMax+0.3*(gStaMax-gStaMin)]; %[] for 'auto'.
        viewOption.colorscale = [];
        viewOption.plotSE = true; %plot error data. effective for 1d
        viewOption.plotContour = false; %plot contour. effective for 2d
        viewOption.plotCustom = true; %customize the data plotting
        viewOption.plotCustomType = 'PSTH'; %

end

%concate the two contrast datasets in the 1st struct for the PSTH if
%'plotCustom' is set true.
switch expName
    case {'NormLuminance','NormGrating'}
        if viewOption.plotCustom && strcmp(viewOption.plotCustomType,'PSTH')
            %fit the data to exponential curve.
            for k = 1 : nChannels
                if ~any(checkChannel == neurons{k}.channel); continue; end
                for kk = 1 : length(neurons{k}.clusters)
                    if viewOption.plotCustom
                        if neurons{k}.clusters{kk}.id == 255 ; continue; end
                        x = [xSTA xSTA+tBlock];
                        y = [neurons{k}.clusters{kk}.class{iClass}.member{1}.sta neurons{k}.clusters{kk}.class{iClass}.member{2}.sta];
                        z = [neurons{k}.clusters{kk}.class{iClass}.member{1}.std neurons{k}.clusters{kk}.class{iClass}.member{2}.std];
                        %replace both fields with the concrated value
                        neurons{k}.clusters{kk}.class{iClass}.member{1}.sta = y;
                        neurons{k}.clusters{kk}.class{iClass}.member{2}.sta = y;
                        %replace both fields with the concrated
                        %value.
                        neurons{k}.clusters{kk}.class{iClass}.member{1}.std = z;
                        neurons{k}.clusters{kk}.class{iClass}.member{2}.std = z;
                        %
                        fy = [neurons{k}.clusters{kk}.class{iClass}.member{1}.fit neurons{k}.clusters{kk}.class{iClass}.member{2}.fit];
                        neurons{k}.clusters{kk}.class{iClass}.member{1}.fit = fy;
                        neurons{k}.clusters{kk}.class{iClass}.member{2}.fit = fy;
                    end
                end
                %concate the two contrast datasets.
            end
            xSTA = [xSTA xSTA+tBlock];
        end
end

% % h_STA = mspecViewer(xSTA,neurons,viewOption);
% % %viewOption.memberID = 2;
% % %h_STA = mspecViewer(xSTA,neurons,viewOption);
% % savFigFileName = sprintf('adaptation_plot');
% % savFigFile = fullfile(s.nevFolder,[savFigFileName,'.png']);
% % set(gcf,'PaperPositionMode','auto')
% % % print('-dpng', '-r300', savFigFile);
% % hgexport(gcf,savFigFile,export_style);