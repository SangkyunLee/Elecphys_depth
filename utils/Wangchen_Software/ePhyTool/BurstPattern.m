function MultiSpkPct = BurstPattern(SpikeTrain,BurstDeltaT)

%analynize the spike train burst pattern with given associative time
%deltaT. the percentage array of the multiples is returned. the length of
%the MultiSpkPct indicates the highest order of the multiple in the train.

spklen=length(SpikeTrain);

% BurstPattArr stores 5 columns data for 1.Index
% of the spike within the spike train. 2. Timing of each spike.  3. index of the burst the spike
% belongs to. 4. order of the burst. 5. index of the spike within the burst
% whose index identified by 3.
BurstPattArr = zeros(spklen,5);

%initialize the BurstPattArr.

for i = 1 : spklen    
    BurstPattArr(i,1) = i;
    BurstPattArr(i,2) = SpikeTrain(i);
    %BurstPattArr(i,3) = 0;
    %BurstPattArr(i,4) = 0;
    %BurstPattArr(i,5) = 0;
end

for i = 1 : spklen
    if i == 1
        preSpkIdx = 1;
    end

    curSpkIdx = i;

    spkitv = BurstPattArr(curSpkIdx,2)-BurstPattArr(preSpkIdx,2);

%     if i == 1
%         %spkitv = BurstPattArr(curSpkIdx,2) - 0;
%         spkitv = 0;
%     end

    if spkitv < BurstDeltaT
        %assign to the same burst as the previous one
        BurstPattArr(curSpkIdx,3) = BurstPattArr(preSpkIdx,3);
        BurstPattArr(curSpkIdx,4) = BurstPattArr(preSpkIdx,4)+1;
        BurstPattArr(curSpkIdx,5) = BurstPattArr(preSpkIdx,5)+1;
        
    else
        %assign as the singlet of a new burst.
        BurstPattArr(curSpkIdx,3) = BurstPattArr(preSpkIdx,3) + 1 ;
        BurstPattArr(curSpkIdx,4) = 1;
        BurstPattArr(curSpkIdx,5) = 1 ;
        
    end
    
    if curSpkIdx == 1
        %assign singlet lable to the first spike.
        BurstPattArr(curSpkIdx,3) = 1 ;
        BurstPattArr(curSpkIdx,4) = 1 ;
        BurstPattArr(curSpkIdx,5) = 1 ;

    end
    
    preSpkIdx = curSpkIdx;

end

%the number of bursts identified.
maxBurstN = max(BurstPattArr(:,3));

%set the burst order for each burst. 
for i = 1 : maxBurstN
    %find the index of burst that has burst order i.
    findBurstIdx = find(BurstPattArr(:,3)==i);
    BurstPattArr(findBurstIdx,4) = BurstPattArr(findBurstIdx(end),4);
end

maxBurstOrder = max(BurstPattArr(:,4));

MultiSpkPct = zeros(maxBurstOrder,2);

for i = 1 : maxBurstOrder
    %return a logic index vector (0/1) for finding i-th order in
    %BursPattArr.
    findSpk = ( BurstPattArr(:,4)==i );
    MultiSpkPct(i,1) = i;
    MultiSpkPct(i,2) = sum(findSpk);
end

%calculate the fraction out of the total number of spikes.
MultiSpkPct(:,2) = MultiSpkPct(:,2)/spklen;



    

   
    
    
    


    