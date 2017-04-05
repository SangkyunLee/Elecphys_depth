function [A,B] = peth(t,e,x)
%peri-event time histogram
%
%t : timestamps of spikes
%e : timestamps of events 
%x : time vector of histogram
%A,B : spike counts average and standard error
%

%number of events
n = length(e);
%
m = length(x); 
%
H = peta(t,e,x);
%average spike counts per event 
A = sum(H,1)/n ;
%standard error
B = std(H,0,1)/sqrt(n) ;


