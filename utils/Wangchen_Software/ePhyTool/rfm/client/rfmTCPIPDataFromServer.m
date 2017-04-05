function recvdData = rfmTCPIPDataFromServer( varargin )
% TCPIPDataFromServer Summary of this function goes here
% Detailed explanation goes here
% In order for this function to work, a patch has to be applied to Matlab
% Here's the url for the patch:
% http://www.mathworks.com/support/solutions/data/33520.shtml
%
global rfmWSCK rfmPar rfmStimPar;

%rfmStimPar fields will be evaluated.

rfmWSCK=varargin{1};
%nbytes=varargin{3};
recvdData='';
%[rd recvdData]=GetData(wsck,recvdData);    % Works
%[rd recvdData]=wsck.GetData(recvdData);     % Doesn't work
[rd recvdData]=invoke(rfmWSCK,'GetData',recvdData);   % Works
% Data comes as a Matlab command string, for instance 'par.eccentricity=10;'
try
    if (~isempty(recvdData))
        disp(['New data from TCPIP server : ',recvdData]);
        try
            eval(recvdData);
        catch
            lasterr
        end;
        % Add here controls that you want to be updated when new info comes from the PsychToolbox computer
        try
            %             set(CPHandles.currentBlock,'String',num2str(rfmPar.block));
            %             set(CPHandles.currentTarDir,'String',num2str(rfmPar.tarDir));
            %             set(CPHandles.currentTarEcc,'String',num2str(rfmPar.tarEcc));
            if rfmStimPar.taskDone
                %send back the cerebus timestamp of sync to client.
                fn = 'syncTime';
                rfmWSCK.SendData(['rfmStimPar.' fn '=' num2str(rfmStimPar.(fn)) ';' char(10)]);
                %rfmStimPar.syncTime = cbmex('time');
                %fprintf('cbmex time :%f\n',rfmStimPar.syncTime);
            end
        catch 
            lasterr
        end;
    end;
catch
    disp(lasterr);
end;
