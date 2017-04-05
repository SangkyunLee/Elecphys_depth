function [ output_args ] = rfmTCPIPServer( input_args )
% TCPIPServer(port) - creates a TCPIP server socket
% on the specified TCPIP port (default is 7864)
% and waits for Matlab commands to be sent over the 
% network from the client.
%  
% Sample command strings:
%   'MyScript;'   - runs MyScript.m from the current directory
%                   or Matlab path
%   'MyFun(x,y);' - invokes MyFun function
%   'global a;'   - sets variable a to have global visibility
%   'a=7;'        - sets variable a to 7
% 
% Data can be passed to other scripts and functions by declaring
% variables as global, then changing their values.
%
%
%  AB 12-3-03
% (C) 2003, FHC Inc
%

global rfmStimPar;

global rfmCtrlConn;

STATUS_FREE       = -1;
STATUS_NOCONNECT  = 0;
STATUS_TCP_SOCKET = 1;
STATUS_IO_OK      = 5;
STATUS_UDP_CLIENT = 6;
STATUS_UDP_SERVER = 8;
STATUS_CONNECT    = 10;
STATUS_TCP_CLIENT = 11;
STATUS_TCP_SERVER = 12;
STATUS_UDP_CLIENT_CONNECT = 18;
STATUS_UDP_SERVER_CONNECT = 19;

if (nargin)==0
    serverSocket = 7864;
else
    serverSocket = input_args{1};
end;

try 
    LocalHost = char(java.net.InetAddress.getLocalHost.toString);
catch
    LocalHost = 'Mac';
end

disp(sprintf('\n[%s] : Listening on port: %d\n',LocalHost,serverSocket));

while true
    clear functions;        % To force reloading functions that are updating while server is running.
    %pnet('closeall');      % This is redundant with 'clear functions'
    SockConn=pnet('tcpsocket',serverSocket);
    socketClosed = false;
    while (~socketClosed)
        rfmCtrlConn = pnet(SockConn,'tcplisten','noblock');
        %disp(rfmCtrlConn);
        if (rfmCtrlConn~=-1)
            while (pnet(rfmCtrlConn,'status')==STATUS_TCP_SERVER)   % Loop while connected ...
                %disp(pnet(rfmCtrlConn,'status'));
                strCommand=pnet(rfmCtrlConn,'readline','noblock');
                %disp(strCommand);
                if (~isempty(strCommand))
                    disp(['Executing ' strCommand]);
                    try 
                        eval(strCommand);
                    catch
                        if (pnet(rfmCtrlConn,'status')==STATUS_TCP_SERVER)
                            pnet(rfmCtrlConn,'printf','disp(''ERROR : %s'');',strrep(lasterr,'''','"'));
                        end;
                        disp(lasterr);
                    end;
                else
                    %disp('No data ...');pause(0.5);
                    %pause(0.1);
                    pause(0.01);
                end;
            end;
            %disp(pnet(rfmCtrlConn,'status'));
            pnet(rfmCtrlConn,'close');
            socketClosed = true;
        end;
        %disp('Listening ...');pause(0.5);
        %pause(0.1);
        pause(0.01);
    end;
end;
pnet('closeall');
