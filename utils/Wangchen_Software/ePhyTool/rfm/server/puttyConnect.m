function puttyConnect
%interface function to ssh connection

global rfmStimPar rfmCtrlConn rfmCtrlConn 

try 
     pnet('closeall');
    %if ~exist(input_args,'var'); input_args = []; end;
%     if ~isempty(rfmCtrlConn) && pnet(rfmCtrlConn,'status')<0 %not existing
%         rfmTCPIPServer;
%     else
%         fprintf('rfmTCPIPServer alive already\n');
%     end
     fprintf('starting rfmTCPIPServer...\n');
     rfmTCPIPServer;
     
catch
    %close pnet
    fprintf('Error loading rfmTCPIPServer\n');
    lasterr
    pnet('closeall');
end
