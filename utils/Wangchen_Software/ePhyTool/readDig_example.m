

NEV = openNEV(filename,'read','nowave','nowrite'); %read the entire data without waveforms
stimItv = (2/60); %stimulus frames in sec.(or read it from struct params.stimFrames)
minItv = 0.8 * stimItv ; %threshold for interval filter function ISI. 
timestamps = getDigEvents(NEV,minItv); %onsets of stimulus frames.