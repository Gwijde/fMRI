%% To be changed in scripts if things don't work out

% Add to version log

%Changelog Study_fMRI_3T
%   - Changes made for 3T version
%   - USB_trigger replaced with keyboard press ("1" - triggerKeys [76, 28])
%   - getkeydown has been specified further to expect responseKeys only
%   - first 5 triggers are not experimental scans - to be discarded
%   - TESTING remains as variable but makes virtually no difference
%
%


%REMOVE from lines 59 (if TESTING = 1)
USB = config_triggers

%ADD to keymap (line 115 and POSSIBLY line 138):
triggerKeys = [76 28];                                                 % Define trigger from Scanner (Keyboard press '1', 28=row, 76=numpad)  
responseKeys = [keys.Left keys.Right 7 8 34 35 21 22];                   % Define response keys ONLY
%Right before main loop starts, checks for TESTING, but testing doesn't
%matter anymore since you just press the '1' key now... 
%REPLACE 
if TESTING == 1                                                        % scanner sits and waits
  waituntil(t0+1000);
  t0 = time;
else
  wait_for_trigger(1, USB);
  t0 = time;
end
%WITH
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

% Line 199ish - getkeydown could now read trigger as last key pressed, so
% specify it must be a response key by ADDING

[ k, t ,n] = getkeydown(responseKeys);

% At end of trial state (line 238ish)
%REPLACE
wait_for_trigger(1,USB)
%WITH
waitkeydown(inf,triggerKeys);


