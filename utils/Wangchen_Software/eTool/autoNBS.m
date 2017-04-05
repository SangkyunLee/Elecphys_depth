% Example 2: Run 6 sequences TRAINS, with decreased interval times from
% each train to the following one.
%
% step 1: connect the PC to Master-8
% Step 2: switch to paradigm 4, set channel 2 to the TRAIN mode, and set the time parameters of channel 2
% Step 3: Loop 6 times. each time decrease the interval of channel 2 by 10 msec.
%                Trigger channel 2 and wait 1000 msec before triggering the next TRAIN
%------------------------------------

%This is a sample for declaring variables.
cmTrain = 2;


timeout = 1;
%step 1: Connect the PC to Master-8 first. Connect return true on success connection.

Master8=actxserver ('AmpiLib.Master8'); %Create COM Automation server
if ~(Master8.Connect),
    h=errordlg('Can''t connect to Master8!', 'Error');
    uiwait(h,timeout);
    delete(Master8); %Close COM
    return;
end;
%------------------------------------


%Step 2: Switch to paradigm 4, clear this paradigm, set channel 2 to the TRAIN mode
% Set D2=200 usec., M2 = 8 pulses per train, and first I2=100 msec.

nLoops = 30; 
trainInterval = 20; 
D2 = 100e-6; %duration of the pulse
M2 = 50;     %number of pulses
I2=10e-3;    %cycle duration 

Master8.ChangeParadigm( 5);		  %switch to paradigm #4
%Master8.ClearParadigm;				%clear present paradigm (#4)
Master8.ChangeChannelMode( 2, cmTrain);		%set channel 2 to the TRAIN mode
Master8.SetChannelDuration( 2, D2);         %D2 = 100 usec
Master8.SetChannelM( 2, M2);			 %M2 = 8 pulses per train
%------------------------------------


% Step 3: Loop 6 times. each time decrease the interval of channel 2 by 10 msec.
%                Trigger channel 2 and wait 1000 msec before triggering the next TRAIN

h=msgbox('start', 'Message');
uiwait(h);

h_waitbar = waitbar( 0, 'Loop');



for i=0:1:nLoops-1	,                       %loop 6 times
    waitbar( i/6); % show bar
	%x=I2-i*10e-3;
    x = I2;
	Master8.SetChannelInterval( 2, x);		%I2 decreased by 10 msec
	Master8.Trigger( 2);                    %trigger channel 2
    fprintf('Sending Train %d \n', i+1);
	pause (trainInterval);
%pause for 1 sec before the next train
	%NOTE: the PC clock is not very accurate.
	%For accurate timing you must do it by a channel of Master-8
end;
delete(h_waitbar);

h=msgbox('done. click here to exit' , 'Message');
uiwait(h);
%------------------------------------

%Remember  to free memory by close/delete the COM
Master8.connected=0;
delete(Master8);
% -------------------


