% ScenesEventRelated fMRI scanning script for BOLD5000
%
% This script takes in pre-deteremined image lists and images and shows
% the corresponding images in the right order. The timings for image presentation
% are all pre-determined and included below in the script. 
%
% Please visit our website BOLD5000.org for dataset details and news & releases.
%
% Author: Nadine Chang (nchang1@cs.cmu.edu)
% Date: 09/06/18

clear all; clc; sca;
Screen('Preference','VisualDebugLevel', 0); %suppress splash screen

% Input experiment information

prompt = {'Subject ID', 'Session', 'Run', 'At scanner?'};

cur_dir = pwd;

title = 'Input the information';
lineNo = 1;

answer = inputdlg(prompt, title, lineNo);

SubjID = char(answer(1,:))
SessionID = str2num(char(answer(2,:)))
RunID = str2num(char(answer(3,:)))
atScanner = str2num(char(answer(4,:)))

scanstart = fix(clock); % gets date

% seed randperm
s = RandStream('mt19937ar','Seed',sum(100*clock));
RandStream.setGlobalStream(s);

% create Subj Dir
DirName = sprintf('%s/Subject_Data/sub-%s/ses-%s/func',cur_dir, SubjID, num2str(SessionID));
if ~exist(DirName)
    mkdir(DirName);
end

output_file_base = sprintf('%s/sub-%s_ses-%s_run%s_5000scenes',DirName,SubjID, num2str(SessionID), num2str(RunID))

% create datafile
output_filename = [output_file_base, '.tsv'];
if ~exist(output_filename)
    fid = fopen(output_filename, 'w');
else
    error('The outputfile already exists.');
end

% establish keys to use
KbName('UnifyKeyNames');


if atScanner == 1
    Advance = KbName('2@');
    key1 = 12; %% R index finder
    key2 = 13; %% R middle finder
    key3 = 14; %% R ring finder
else
    Advance = 31;
    key1 = 12; %% R index finder
    key2 = 13; %% R middle finder
    key3 = 14; %% R ring finder
end


HideCursor;

% set up windows
AssertOpenGL;
Screen('Preference','VisualDebugLevel',0);
Screen('Preference', 'SkipSyncTests', 1);
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = [192 192 192];

bkgdColor = gray;
textColor = black;
[w, WindowRect] =Screen('OpenWindow', screenNumber);
ifi = Screen('GetFlipInterval', w);
slack = ifi / 2;

%get / display screen
Screen(w,'FillRect', black);%gray
%always writes to an offscreen buffer window ? flip to see changes  made
Screen('Flip', w);
% set font; display text
Screen('TextFont',w, 'Times');
Screen('TextSize',w, 18);
DrawFormattedText(w, 'Preloading images...', 'center', 'center', white);
Screen('Flip', w);

%% experimental setting

stimDuration = 10;
AllTrials = 37;

StartFixTime = 6;
EndFixTime = 12;

% save non-event information in json
output_info.MatlabVersion = version;
output_info.Begin = datestr(now);
output_info.SubjID = SubjID;
output_info.RunNumber = RunID;
output_info.AllTrials = AllTrials;
output_info.ScreenResolution = {WindowRect(3), WindowRect(4)};
json_filename = strcat(output_file_base, '.json');
j = jsonencode(output_info);
json_file = fopen(json_filename, 'wt');
fprintf(json_file, '%s', j);
fclose(json_file);

% starting output file

fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n', ...
        'onset', 'duration', 'Subj','Sess', 'Run','Trial', 'ImgName', ...
        'ImgType', 'StimOn(s)', 'StimOff(s)', 'Response');

% Load Pictures

data_root = ['Subject_Img_Lists/Subj' num2str(str2num(SubjID), '%02d') '/Sess' num2str(SessionID, '%02d')]
info_name = [data_root '/Subj' num2str(str2num(SubjID), '%02d') '_sess' ...
            num2str(SessionID, '%02d') '_run' num2str(RunID, '%02d') '.mat']

% load images and the corresponding images' names
load(info_name)
load('all_imgs.mat')
load('all_img_names.mat')
img_idxs = [];
t = all_img_names(:,1);
all_img_names_array = string(t);
t1 = cur_img_names(:,1);
cur_img_names_array = string(t1);

t2 = cur_img_names(:,2);
cur_img_types_array = string(t2);

% assign indices for image names
for i = 1:max(size(cur_img_names))
    idx = find(strcmp(all_img_names_array, cur_img_names_array(i)));
    img_idxs = [img_idxs idx];
end

% checks on loaded images
assert(max(size(img_idxs)) == max(size(cur_img_names)),'size of cur img names and img idxs not the same' )
assert(max(size(img_idxs)) == AllTrials, 'size of cur img names and # imgs per trail not the same' ) 


% Setup fixation cross

fixation_dark=repmat(black,30,30);
fixation_dark(14:17,:)=white;
fixation_dark(:,14:17)=white;

%%% The Main Session %%%

%%% Pre Block Start %%%
% instructions 

Screen('TextSize',w,30);
Screen('TextFont',w, 'Arial');
Screen(w,'FillRect',black)

instr1 = ['Please keep your eyes focused on the middle of the screen at all times.'...
        ' \n\n ...You will see pictures of scenes and objects. \n\n' ...
        'Please press the right index key for like, middle for neutral,' ...
        'ring finger for dislike. Please respond after the image is shown.'];
DrawFormattedText(w,instr1, 'center', 'center', white);
Screen('Flip',w);
WaitSecs(5);

instr2 =sprintf('Please remember to be as still as possible. \n\n We will begin shortly now.');
DrawFormattedText(w,instr2, 'center', 'center', white);
Screen('Flip',w);
WaitSecs(2);

Screen(w,'FillRect', black);%gray
Screen('PutImage',w,fixation_dark);
Screen('Flip',w);

% wait for scanner to give trigger to indicate we're scanning
fprintf(sprintf('\n\n waiting for trigger \n\n'));
if atScanner == 1
    keyCodes(1:256) = 0;
    while ~keyCodes(51)
        [keyPressed, secs, keyCodes] = KbCheck;
    end
else
    fprintf(sprintf('\n\n waiting for trigger , not at scanner\n\n'));
    KbWait
end%% post trigger


ListenChar(2)

%%% Get Start Time %%%
%%%%%%%%%%%%%%%RUN STARTS%%%%%%%%%%%%%%%
RunStartTime = GetSecs;
fprintf(sprintf('\n\n GOT SYNC! EXPERIMENT STARTED!\n\n'));

Screen('PutImage',w,fixation_dark);
% the start of the run.
Screen('Flip',w);

WaitSecs(StartFixTime);

stimDuration = 1;
waitDuration = 9;


%%% Block Loop %%%
% Block for showing all stimuli in order
for trialNum = 1:AllTrials

    keyCodes(1:256) = 0;     
    resp = 0;
     
    %%%%%%%%%TRIAL STARTS%%%%%%%%%
    TrialOnset = GetSecs - RunStartTime;
    
    % Get image name by matching up indices
    cur_idx = img_idxs(trialNum);
    img = all_imgs{cur_idx};
    imgName = all_img_names{cur_idx,1};
    imgType_all = all_img_names{cur_idx,2};  % name without rep_
    imgType = cur_img_types_array(trialNum);    % name with rep
    assert(contains(imgType, imgType_all)); % check that the name is correct and matching
    
    % image is shown
    Screen('PutImage',w,img);
    
    % calculate the amount of time to show image
    StimEndTime = RunStartTime + StartFixTime + (trialNum * stimDuration) + ((trialNum-1)*waitDuration)- slack;
    TrialEndTime = StimEndTime + waitDuration;
    
    Screen('Flip',w);
    
    StimOnset = GetSecs;
    StimTimeStamp = StimOnset - RunStartTime;
    
    recentKeyCodes = keyCodes;
    respTime = 0;

    while (GetSecs < StimEndTime)
    end
    
    Screen(w,'FillRect', black);%gray
    
    Screen('PutImage',w,fixation_dark);
    Screen('Flip',w);
    Offset = GetSecs;
    OffTimeStamp = Offset - RunStartTime;
    
    % check for user input 
    while (GetSecs < TrialEndTime)
        if sum(double(keyCodes(key1)))==0 && sum(double(keyCodes(key2)))==0 && sum(double(keyCodes(key3)))==0
            [keyPressed, secs, keyCodes] = KbCheck;
            respTime = GetSecs - TrialOnset - RunStartTime;
        end 
    end
    
    % match the user response to our output
    if (keyCodes(key1))
        resp = 1;
    elseif (keyCodes(key2))
        resp = 2;
    elseif (keyCodes(key3))
        resp = 3;
    end
    
    if resp ==0
        respTime = 0;
    end
    
    % print + save to file session, run, trial information 
    fprintf(fid, '%.4f\t%.4f\t%s\t%d\t%d\t%d\t%s\t%s\t%.4f\t%.4f\t%d\t%.4f\n',...
        StimTimeStamp, OffTimeStamp - StimTimeStamp, SubjID, SessionID, RunID, trialNum, ...
        imgName, imgType, StimTimeStamp, OffTimeStamp, resp, respTime);
    fprintf('%s\t%d\t%d\t%d\t%s\t%s\t%.4f\t%.4f\t%d\t%.4f\n',...
        SubjID, SessionID, RunID, trialNum, imgName, imgType, StimTimeStamp, OffTimeStamp, resp, respTime);
end

% Run end fixation shown
WaitSecs(EndFixTime);

% Run concluded
instr = sprintf('You have finished this run.\n The experimenter will be with you shortly. Thank you!');

DrawFormattedText(w,instr, 'center','center',white);
Screen('Flip',w);

WaitSecs(5);

fclose('all');
Screen('CloseAll');


