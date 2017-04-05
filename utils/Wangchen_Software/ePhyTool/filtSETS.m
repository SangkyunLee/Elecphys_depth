function [ s ] = filtSETS(s,ch,minISI,marker)
%filter the Stim-Event-TimeStamp for input struct. The timestamps for extra
%pulse triggered by screen flickering will be rmoved by ISIFilter.
%
%s - struct array
%ch - event entry index for digital channel record. usually it's 1 

if ~isstruct(s); error('struct array expected'); end

if nargin < 4
    marker = 'open';
end

for i = 1 : length(s)
    t = s(i).nevData.events{ch}.timestamps;
    t = ISIFilter(t,minISI);
    s(i).nevData.events{ch}.timestamps = t;
    if strcmpi(marker,'close') %both ON/OFF onset are timestamped
        s(i).nevData.events{ch}.timestamps = t(1:2:end); %ON onset
        s(i).nevData.events{ch+1}.name = 'Offset';
        s(i).nevData.events{ch+1}.data = t; %save the full set for both ON/OFF onset timestamps.
        s(i).nevData.events{ch+1}.timestamps = t(2:2:end);%OFF onset
    end
end


    