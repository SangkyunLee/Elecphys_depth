function [ output_args ] = rfmCloseConnection( varargin )
%TCPIPCLOSECONNECTION Summary of this function goes here
%  Detailed explanation goes here

global rfmWSCK;

disp('TCPIP Closing Connection ...');
rfmWSCK=varargin{1};
if (rfmWSCK.State~=0)
    rfmWSCK.Close;
end;
rfmWSCK.Listen;
%wsck.delete;

