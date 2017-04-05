classdef CSD
    properties
        depth; % [npos x 1]        
        LFP;%
        
    end
    properties (Access = private)
        LFPraw; %cellarray {npos, ntet} 
        LFPAtt = struct('Fs',[],...
            'tets',[],...
            't0_msec',[]); % LFP attribute
        depthInfo;
        Ndep;        
        Ntet = 24;        
        stimonset; % stim onset {npos,1}
        flt_coeff; % highpass filter coefficient

    end
    
    methods
        function self = CSD(rootdir,datafn, depthFile, expID, exptype)

            self.depthInfo = get_seslist(depthFile, expID,exptype);
            d = rdir(fullfile(rootdir,'**',datafn));
            self.Ndep = length(self.depthInfo);
            self.depth = zeros(self.Ndep, self.Ntet);
            
            self.LFPraw = cell(self.Ndep, self.Ntet);
            self.stimonset = cell(self.Ndep,1);
            for i = 1 : self.Ndep
                expDate = fullfile(self.depthInfo(i).date,self.depthInfo(i).time);
                for j = 1 : length(d)
                    lfpFile = d(j).name;
                    if ~isempty(strfind(lfpFile,expDate))            
                        Mat= load(lfpFile);
                        self.LFPraw(i,:) =Mat.data(:)';
                        stimfile =fullfile(fileparts(lfpFile),'stimData.mat');
                        stimData = load(stimfile);
                        fprintf('stimData: %s loaded.\n', stimfile);
                        self.stimonset{i} = stimData.stimData.Onsets; 
                    end
                end
                self.depth(i,:)=self.depthInfo(i).depth;
            end
            self.LFPAtt.Fs = Mat.Att.Fs;
            self.LFPAtt.tets = Mat.Att.tetrodes;
            self.LFPAtt.t0_msec = Mat.Att.t0;
            

        end % end of CSD
        
        
        function self = genHPF(self,cutoff, varargin)
            %function self = genHPF(cutoff, varargin)
            % generate filter coffiecients
            
            newargin = cell(length(varargin)+3,1);
            newargin{1} = cutoff(1);
            newargin{2} = cutoff(2);
            newargin{3} = self.LFPAtt.Fs;
            newargin(4:end)=varargin;
            
            filter = filterFactory.createHighpass(newargin{:});
            
            cf = struct(filter);
            cf = cf.filt; 
            self.flt_coeff =cf;            
        end % end of genHPF
        
        function self = applyfilt(self)
            %function self = applyfilt
            % apply filtering
            cf = self.flt_coeff;
            if isempty(cf)
                error('filter should be created\n');
            end
            
            tets = self.LFPAtt.tets;            
            self.LFP = cell(self.Ndep,self.Ntet);
            for itet = tets
                for idep = 1: self.Ndep
                    x = self.LFPraw{idep,itet};
                    self.LFP{idep,itet} = filtfilt(cf,1,x);
                end
            end
        end % end of applyfilt
        
        function [ERP, ERPtime] = getERP(self,  twin, twin0)
            % function self = getERP(self,  twin, twin0)
            % get ERP in the given time twin(sec)
            % twin0: time window (sec) for baseline
            
            ERP = cell(1,self.Ntet);
            ERPtime = cell(1,self.Ntet);
            lfp_data.Att.Fs = self.LFPAtt.Fs;
            lfp_data.Att.t0 = self.LFPAtt.t0_msec;
            tetsel = self.LFPAtt.tets;
            
            for itet = tetsel
                erpi = cell(self.Ndep,1);
                for idep = 1: self.Ndep            
                    
                    onset = self.stimonset{idep};
                    lfp_data.data = self.LFP{idep,itet};
                    
                    [erpi{idep},erp_time]  = ...
                        getlfpERP(lfp_data,onset,twin,twin0);                    
                end
                ERP{itet} = cell2mat(erpi);    
                ERPtime{itet} = erp_time;
            end
            
        end % end of getERP
        
        
        
        function out = get(self,fld)
            out = self.(fld);
        end
        
        
    end
    
    methods (Static)
        function MAP = getCSD(ERP, depth,sampletime, method)
            % function map = getCSD(ERP, depth,sampletime, method)
            % ERP: {1, nchannel}, ERP{i}: [ndepth x Ntimesample]
            % depth: [Ndepth x nchannel]
            % sampletime: [1 x Nsampletime]
            % method: 'kernel'
            
            if nargin==3,
                method = 'kernel';
            end
            Nch = length(ERP);
            MAP = struct('CSD',[],'pos',[],'time',[]);
            MAP = repmat(MAP,[Nch 1]);
            
            
            
            for ich = 1 : Nch
                erp = ERP{ich};
                [CSD, pos]=getCSD(erp,depth(:,ich),method);
                MAP(ich).CSD =CSD;
                MAP(ich).pos = pos;
                MAP(ich).time = sampletime;
            end
        end
    end
end
        
        