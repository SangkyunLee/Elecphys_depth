function [frx,fry,fre,scx,scy,sce,scArray] = getAptFiringRate(t,e,x,nb_sum,nb_exc)
%get adaptation rate by calculating the numbers in fine bins and then
%average over multiple bins. this allows to exclude the spikes near transition with small
%window while calculate the spike rates with large bins.
%
%t: spike timestamps
%e: event onsets
%x: time series of rate histgram
%nb_sum : number of bins in x to sum up
%nb_exc : number of bins in x to exclude at beginning of x
%frx    : time bins of firing rate 
%fry    : fring rate
%fre    : standard error
%scx    : time bins of spike counts
%scy    : spike counts
%sce    : standard error of spike counts
%scArray: spike counts array(row: bins, columns: events)

%number of events
ne = length(e);
bin = x(2)-x(1);

%spike counts per event
H = peta(t,e,x);
%'coarse' spike counts --- summed over multiple bins.
S = csum(H,nb_sum,nb_exc);
%
nw = ones(1,length(x));
%
%number of fine bins summed 
nFB = csum(nw, nb_sum, nb_exc);
%summed fine bin size for each point of spike counts 
sBinSize = nFB * bin ;
%

%
frx = x(1 : nb_sum : end);
scx = frx;
%spike counts averaged over events 
scy = sum(S,1)/ne ;
sce = std(S,0,1)/sqrt(ne);
%firing rate over events
fry = scy./sBinSize;
fre = sce./sBinSize;

%spike count array
scArray = S;


