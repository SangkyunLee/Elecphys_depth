function plotTuningCurve(stimfile,datafile)
%plot the tuning curve.

if isempty(stimfile)
    % Find out the data file from user
    disp(' ');  % Blank line
    stimfile = input('Data file: ', 's');
else
    %filename = datafile;
end

if isempty(datafile)
    % Find out the data file from user
    disp(' ');  % Blank line
    datafile = input('Data file: ', 's');
else
    %filename = datafile;
end

[timestamps,units,tsr] = cb_getSpikeTrain(datafile);

%load the stim file
s = load(stimfile);

par = s.rfmStimPar;

%number of conditions
nc = length(s.conditionList);
%number of trial repetition
nr = s.trialRepetition;

%list for single trial
cList = s.conditionList;
%find the varing parameter for tuning curve measurment.
if all(sort(cList) == sort(s.conditionArray(1,1:nc)))
    cIdx = 1;
elseif all(sort(cList) == sort(s.conditionArray(2,1:nc)))
    cIdx = 2;
elseif all(sort(cList) == sort(s.conditionArray(3,1:nc)))
    cIdx = 3;
else %will throw error
    cIdx = 0;
end

%do the spike counting.
%align the cerebus and matlab timestamps to the respective reference.
eventT = s.conditionEvent - s.conditionEvent(1,1);
%eventT = eventT + par.syncTime;

%artificial alignment for test.
eventT = eventT + timestamps{1}(1); 

ne = size(eventT,2);
t = zeros(1,2*ne);
for i = 1 : ne
    t(2*i-1) = eventT(1,i);
    t(2*i) = eventT(2,i);
end

maxChID = 24;
nChannel = length(timestamps);
%num of channels to be processed.
nCh = min([maxChID,nChannel]);

for i = 1 : nCh
    %count the spikes for the given timestamps.
    nSpikes(i)={histc(timestamps{i},t)};
    %expunge the spike counts during the inter-condition period.
    nSpikes{i}(2:2:end)=[];
end


%spike counts for each repetition of trial
for i = 1 : nCh
    %sort the conditions for spikecounts 
    rndConList = s.conditionArray(cIdx,:);
    for j = 1 : nr
        [conSorted, idxSorted] = sort(rndConList((j-1)*nc+1:(j-1)*nc+nc));        
        spkPerTrial(i,j) = {nSpikes{i}((j-1)*nc+idxSorted)};
        
    end
    
end

%average spike counts over trials and plot over channels.
for i = 1 : nCh
    
   for j = 1 : nc
       y = 0;
       for k = 1 : nr
            y = y + spkPerTrial{i,k}(j);
       end
       spkPerChannel(i,j)=y;
   end
   
end

spkPerChannel=spkPerChannel/nr;

nPlotColumn = 2;
nPlotRow = round(nCh/2);

figure; hold on;
for i = 1 : nCh
    subplot(nPlotRow,nPlotColumn,i);hold on;
    plot(conSorted,spkPerChannel(i,:),'b-');
    plot(conSorted,spkPerChannel(i,:),'ro');
    %legend(['ch',num2str(i)]);
end

keyboard;   
       
       
   




