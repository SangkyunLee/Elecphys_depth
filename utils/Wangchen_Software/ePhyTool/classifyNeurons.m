function neurons = classifyNeurons(neurons,trial,session,t_SETS,classifier)
%add class fields in neurons struct for the given classifier.
%if classifier is not specified, create default class field for various
%experiment.

if isfield(session,'raw')
    %expName = session.raw.matData.stim.params.constants.expType;
    params = trial.raw.matData.params;
    constants = session.raw.matData.stim.params.constants;
else
    params = trial.matData.params;
    constants = session.matData.stim.params.constants;
end

expName = constants.expType;

if nargin < 5 %create default classifiers
    switch expName
        case {'DotMappingExperiment' , 'SquareMappingExperiment'}
            classifier = struct('name','unclassified',...
                'variable','none',...
                'values',[]);
            %             %
            %             viewOption = struct;
            %             viewOption.plot = 'STA';
            %             viewOption.plotdim = 2; %plot in 1/2d
            %             viewOption.message = '';
            %             viewOption.skip = true; %skip empty data channel for plotting.
            %             %viewOption.colorscale = [0 1]; %color scale for pcolor. [] for auto
            %
        case {'NormLuminance'}
            classifier = struct('name','Gaussian_Contrast',...
                'variable','contrast',...
                'values',params.contrast);
            %             %'variable' --- variable in 'params' to sort events.
            %             viewOption = struct;
            %             viewOption.plot = 'STA';
            %             viewOption.plotdim = 1; %plot in 1/2d
            %             viewOption.message = '';
            %             viewOption.skip = false; %skip empty data channel for plotting.
            %             %viewOption.colorscale =[];
        case {'NormGrating'}
            classifier = struct('name','Gaussian_Std',...
                'variable','stdOrient',...
                'values',params.stdOrient);
            %             %'variable' --- variable in 'params' to sort events.
            %             viewOption = struct;
            %             viewOption.plot = 'STA';
            %             viewOption.plotdim = 1; %plot in 1/2d
            %             viewOption.message = '';
            %             viewOption.skip = false; %skip empty data channel for plotting.
            %             %viewOption.colorscale =[];
    end
end

% neurons = sortNeurons(neurons,s_SETS,t_SETS,classifier);
neurons = sortNeurons(neurons,trial,t_SETS,classifier);