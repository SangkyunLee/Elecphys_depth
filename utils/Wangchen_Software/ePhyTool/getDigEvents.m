function t = getDigEvents(NEV,x)
%get the timestamps of digital events from NEV struct.
%x: mininum event interval for the ISI filter. 

t = NEV.Data.SerialDigitalIO.TimeStampSec(NEV.Data.SerialDigitalIO.InsertionReason==1);

%filter the events
if nargin > 1
    t = ISIFilter(t,x);
else
    t = ISIFilter(t,0.8*mean(diff(t)));
end
