function [ output_args ] = rfmCtrlPanelCloseReq( varargin )
%CTRLPANELCLOSEREQ Summary of this function goes here
%  Detailed explanation goes here
global par wsck;
if (~isempty(wsck))
    if (wsck.State==7)
        wsck.SendData('par.stopRunning=true');
        pause(0.1);
    end;
    if (wsck.State~=0)
        wsck.Close;
    end;
    wsck.delete;
    wsck=[];
end;
par.stopRunning=true;
disp('Saving Parameters ...');
save par;
disp('Done.');
closereq;
