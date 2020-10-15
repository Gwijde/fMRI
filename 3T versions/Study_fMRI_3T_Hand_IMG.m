%Script Study 1 (Version 0)                                               %
%Gwijde Maegherman 31/08/2017                                             %
%Based largely on code from various designs,including Basic V1 and V2     %
%Based in part on code by Dan Kennedy-Higgins and others (unknown)        %
%
%Changelog Study_fMRI_3T
%   - Changes made for 3T version
%   - USB_trigger replaced with keyboard press ("1" - triggerKeys [76, 28])
%   - getkeydown has been specified further to expect responseKeys only
%   - first 5 triggers are not experimental scans - to be discarded
%   - TESTING remains as variable but makes virtually no difference
%
%
%Changelog Study_fMRI
%   - Changes made for fMRI version of experiment: added trigger code where
%   relevant
%
%Changelog Study1.35_B
%   - Specifically uses no SRT task, whereas A uses a tone-SRT task and C
%   uses an aba choice task
%
%Changelog Study1.35:
%   - Various bug fixes and comment cleanup
%Changelog Study1.3:
%   - Added Practice Task and integrated it
%Changelog Study1.2:
%   - Added AudSRT and VisSRT
%   - Changed testLists to include AudSRT and VisSRT
%   - Changed response for when no key is pressed (now -999)
%   - Changed main loop to run 8 times, and added testBlocks 8 (AudSRT) and
%   9 (VisSRT)
%Changelog Study1.1:
%   - Changed a few things so the files can actually be located (issue with
%   filesep)
%   - Changed how file is svaed (issued with remaining taskCat resolved
%
%Changelog Study1.0:
%   - Initial release, most code taken from Basic_V2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What this code does:
%   - Runs a practice task and a main task
%   - Both tasks consist of 4 different types of task
%       1) (Auditory Simple Reaction Time - not used in version B)
%       2) (Visual Simple Reaction Time - not used in version B)
%       3) Hand Laterality Task
%       4) Auditory Imagery Task


%% Preamble

close all;
clear all;
clc;

%% Set TMS/MRI parameters here

TESTING = 1;                                                                   % Set to 1 if testing, set to 0 if real fMRI.
REST = 15000;                                                                  % Length of fixation post-block

%% Define Cogent variables and general preparatory tasks
if TESTING == 0
    config_keyboard(100, 1, 'nonexclusive');                                   % Keyboard configurations - 100 = max. number of recorded key reads, 1 = timing resolution in mseconds, nonexclusive = allows keyboard control in other programs
    config_display(1, 5, [0,0,0], [1,1,1], 'Helvetica', 32, 4, 0, 4);          % Cogent window configuration - 1 = full screen, 3 = 1024x768, [0.5,0.5,0.5] = background colour, Helvetica, 32 = font type, font size
    config_sound(1, 16, 22050, 100);                                           % Cogent sound configurations - 1 = mono, 16 = number of bits, 22050 = number of samples per second, 100 = number of possible buffers)
elseif TESTING == 1
    config_keyboard(100, 1, 'nonexclusive');                                   % Keyboard configurations - 100 = max. number of recorded key reads, 1 = timing resolution in mseconds, nonexclusive = allows keyboard control in other programs
    config_display(1, 5, [0,0,0], [1,1,1], 'Helvetica', 32, 4, 0, 4);          % Cogent window configuration - 1 = full screen, 3 = 1024x768, [0.5,0.5,0.5] = background colour, Helvetica, 32 = font type, font size
    config_sound(1, 16, 22050, 100);     % Cogent sound configurations - 1 = mono, 16 = number of bits, 22050 = number of samples per second, 100 = number of possible buffers)
end


%% Setup experiment by asking basic input info
stimFolder = strcat('stimuli',filesep);
info = cell(32,10);                                                       % Creates a cell array called "info" which eventually records all relevant information from each test session
trial = 1;  

% Ask subject name
subjName = '';                                                             % This creates the variable subjName as an empty variable
while isequal(subjName,'');
    subjName = input('Subject name? (1,2,3,4,5,6)', 's');                  % This allows you to enter the specific identification to be used for participants (generally Year,Month,Day,Initial e.g. 170220DKH)
end
config_log( ['logs\fMRI_' subjName '_Hand_IMG.log'] );

% Determine subject folder
subjFolder = '';                                                           % As above this line simply creates a variable called 'subjFolder' which is an empty variable for the time being
folderName = '';
while isequal(subjFolder,'')
    if isequal(folderName,'')
        folderName = strcat('subjects/',subjName);                         % This creates a 'subjects' folder (if not already in existence) and moves the above created subjFolder variable into this folder and renames it with the specific subject ID as entered on line 40.
    end
    if exist(folderName,'dir')
        folderName = strcat(folderName,'_1');                              % If the subject folder name already exists then this line of code simply adds a '_1' to end of the name and creates a new folder e.g. is 170220DKH already exists then this line will create a new folder called 160929DKHd. This avoids the risk of data being overwritten and lost.
        subjFolder = '';
    else
        mkdir(folderName)
        subjFolder = folderName;
    end
end


testCondition = 2;
subjNum = str2num(subjName);
listyList = subjNum;


listList = num2str(listyList);                                             % Converts entered listyList variable into string
mainList = strcat('stimlists',filesep,listList,'.xlsx');                   % mainList depends on user input                            

%% Begin Main Experiment
start_cogent;

%First waitsound takes longer (see manual), so play an empty wav here
loadsound(strcat(stimFolder,'empty.wav'),1);
playsound(1);
waitsound(1);

%Set up key maps
keys = getkeymap;                                                      % getkeymap command outputs a list of codes assigned to each key by cogent
controlKeys = [keys.Space keys.Escape keys.L keys.R];                  % Define key codes for space and escape for controlling program (also now includes pedals)
responseKeys = [keys.Left keys.Right 7 8 34 35 21 22];                   % Define response keys ONLY
triggerKeys = [76 28];                                                 % Define trigger from Scanner (Keyboard press '1', 28=row, 76=numpad) 

% Main Task
[num] = xlsread(mainList);                                             % Use main user input for list

% Visual Task
frame = strcat(stimFolder,'framehandIMG.jpeg');
welcome = strcat(stimFolder,'welcomehandIMG.jpeg');
fixcross = strcat(stimFolder,'fixcrosshandIMG.jpeg');
thanks = strcat(stimFolder,'thankshandIMG.jpeg');
breakimg = strcat(stimFolder,'breakhandIMG.jpeg');
extension = 'handIMG.jpeg';  

%Display welcome frame and explanation of study
clearpict(1);                                                          % Clear buffer 1         
clearpict(2);                                                          % Clear buffer 2
A = loadpict(frame);                                                   % Puts frame.jpg in a MATLAB matrix specified by A
preparepict(A,1);                                                      % Puts image A in middle of buffer 1
B = loadpict(welcome);
preparepict(B,2);                                                      % Puts image B in middle of buffer 2
drawpict(1);                                                           % Display frame only for 200ms
wait(400);
drawpict(2);                                                           % Display welcome + frame forever
waitkeydown(inf, controlKeys);                                         % Wait forever ('inf') until one of the control keys is pressed
                                                           
t0 = drawpict( 1 );                                                    % draw frame                                            
if TESTING == 1                                                        % scanner sits and waits
  for i = 1:5
      waitkeydown(inf,triggerKeys);                                    % wait for scanner to send trigger 5 times, these get discarded
  end    
  t0 = time;
else
  for i = 1:5
      waitkeydown(inf,triggerKeys);                                    % wait for scanner to send trigger 5 times, these get discarded
  end    
  t0 = time;
end
logstr = sprintf('Start experiment:\t%d\t%s', t0);
logstring( logstr ); % Log the item

% Main Loop begins here
for a = 1:32
    % If new block starting, log string
    if a == 1 || a == 9 || a == 17 || a == 25
        logstr = sprintf('Start block:\t%d\t%s', time);
        logstring( logstr ); % Log the item
    end
        
    % Creates variable containing the value of the first-column cell in string format (for strcat, info)
    imageNum = num2str(num(a,1));
    % Takes the trial number i and derives the stimulus image filename
    stimImage = strcat(stimFolder,imageNum,extension);                        
    % Takes the trial number and derives correct response key (for info)
    stimCorrect = num2str(num(a,2));
   % Takes the trial number and derives jitter
    jitter =(num(a,3));    

    % Clear buffer 3
    clearpict(3);                                                      
    clearpict(4);
    % Puts fixation cross in a MATLAB matrix specified by C
    C=loadpict(fixcross);
    % Puts image C in middle of buffer 3
    preparepict(C,3); 
    % Display fixation cross for 1000ms
    drawpict(3);                                                       
    wait(1000);                                                               
    clearkeys;    
    % Puts stimulus in a MATLAB matrix specified by S
    S=loadpict(stimImage);
    % Puts stimulus image in middle of buffer 4
    preparepict(S,4);                                              
    
    % Draws stimulus and gets time, log string of stim presentation
    t0 = drawpict(4);
    logstr = sprintf('Stim number: %s',imageNum);
    logstring( logstr ); % Log the item
    
    % Wait for response
    waitkeydown(5000, responseKeys);                                 
    
    drawpict(1);
    wait(jitter);

    [ k, t ,n] = getkeydown(responseKeys);
    % Log the time at which response was received
    logstr = sprintf('Response time:\t%d\t%s',t);
    logstring( logstr ); % Log the item
    key = num2str(k);

    % This calculates reaction time data. The time at which participants responded minus the time at which the strings appeared on screen
    rt = t - t0;                                                       
    logstr = sprintf('Reaction time:\t%d\t%s',rt);
    logstring( logstr ); % Log the item

    %% The aftermath: this section records some of the relevant information into a cell array named 'info'. 
    %  The information contained in the variable to the right of the equals sign is entered into the cell array named 'info' on the row which corresponds to the trial number and in the colum defined by the number inside the brackets {trial, 1} for example would be column
    
    info{trial,1} = 'Hand';                                            % Records the taskCategory (0 = audio, 1 = hand, 2 = face)
    info{trial,2} = 'Imagery';                                         % If taskCategory is audio, records roundLeft (1 = rounded left, 2 = stretched left)
    info{trial,3} = a;                                                 % Records trial number
    info{trial,4} = num(a,1);                                          % Records the image number for the stimulus displayed
    info{trial,5} = stimCorrect;                                       % Records the correct answer regardless of keypress
    info{trial,6} = k;                                                 % Records participant response
    if strcmp(stimCorrect,k) == 1                                      % Assigns value of 1 to variable acc(uracy) if stimCorrect matches key pressed     
        acc = 1;
    elseif strcmp(stimCorrect,k) == 0                                  % Assigns value of 0 to variable acc(uracy) if stimCorrect does not match key pressed
        acc = 0;
    elseif strcmp('-999',k) == 1
            acc = -999;
    end
    info{trial,8} = acc;                                               % Records accuracy
    info{trial,9} = rt;                                                % Records the amount of time it took the participant to respond 
    info{trial,10} = jitter;

    %End of trial - check if a break is needed
    if a == 8 || a == 16 || a == 24
        clearpict(3);
        B = loadpict(breakimg);
        preparepict(B,3);
        t0 = drawpict(3);
        logstr = sprintf('Rest starts at:\t%d\t%s', t0);
        logstring( logstr ); % Log the item
        if TESTING == 1                                                  % Scanner waits for next trial
            waituntil(t0 + REST);
        else
            waituntil(t0 + REST - 2000);
            waitkeydown(inf,triggerKeys);
        end
        
    end
    
    trial = trial + 1;                                                 % Adds one to the value of the variable 'trial'. This ensures the data already written in the cell array 'info' is not overwritten on each trial but add to the next row in the cell array.


end

%% The grand finale

    clearpict(1);
    A=loadpict(thanks);                                                % Loads thank you image into buffer
    preparepict(A,1);
    drawpict(1);                                                       % Say Thanks!
    wait(4000)
    if TESTING == 1
        wait(1000);
    else
        wait( 3000 );
    end
    %%
    save(strcat(subjFolder,'/info','_',listList,'Hand_IMG','.mat'),('info'));         % This saves the created cell array named 'info' into each participants individually created folder.
    xlswrite(strcat(subjFolder,'_',listList,'Hand_Imagery'),info);   
    %%
    stop_cogent;                                                       % Stop Cogent module
    
% End Experiment