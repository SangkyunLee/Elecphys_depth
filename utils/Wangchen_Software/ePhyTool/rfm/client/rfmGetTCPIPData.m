function [ output_args ] = rfmGetTCPIPData( varagin )
% GetTCPIPData
%  Receives over TCPIP data coming from the control panel.
%  Data comes as a string that is evaluated as a Matlab command line
%  using 'eval' function.

global rfmStimPar rfmCtrlConn;
%global rfmCtrlConn;
PNET_ERROR    = -1;

if (~isempty(rfmCtrlConn))
    if (pnet(rfmCtrlConn,'status')>0)
        strCommand=pnet(rfmCtrlConn,'readline','noblock');
        while ((pnet(rfmCtrlConn,'status')>0) & (~isempty(strCommand)))
            try
                disp(['Executing: ',strCommand]);
                eval(strCommand);
            catch
                disp(lasterr);
            end;
            strCommand=pnet(rfmCtrlConn,'readline','noblock');
        end;
    end;
end;
