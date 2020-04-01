function CheckerboardExperiment

% This code aims to reproduce stimuli used in MEG experiment in a following
% article:
%
% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.
%
% Dependency:
% This code requires following MATLAB toolbox:
% Psychtoolbox-3: http://psychtoolbox.org/
% 
% Hiromasa Takemura, NICT CiNet BIT
%
% Note: We removed some functions related to Gamma correction in order to
% reduce dependency. Gamma correction of the original experiment has been
% performed by using Mcalibrator2 (for Gamma correction): https://github.com/hiroshiban/Mcalibrator2

% Clear the workspace
close all;
clear all;
sca;

expinfo.subject = input('Enter subject ID...  \n','s');
expinfo.session = input('Enter session number...  \n','s');
expinfo.datetime = input('Enter Dates...  \n','s');

expinfo.savelog = ['CheckerboardMEG_' num2str(expinfo.subject) '_'  num2str(expinfo.session) '_' num2str(expinfo.datetime) '.mat'];

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
%Screen('Preference', 'SkipSyncTests', 1)
oldPriority=Priority(1);
% Setting parameters
fix_r       = 0.2; % radius of fixation point (deg)
v_dist              = 24;   % viewing distance (cm)
mon_width   = 16;   % horizontal dimension of viewable screen (cm)

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Push Key Information
KbName('UnifyKeyNames');
spaceKey = KbName('space');
quitProgKey   = KbName('ESCAPE');
Key_t    = KbName('t'); % MRI
Key_Pc  = KbName('DownArrow');
Key_mri  = KbName('b'); % MRI

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,...
    grey, [], 32, 2, [], [], kPsychNeed32BPCFloat);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);
framerate = round(1/ifi);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Screen resolution in Y
screenYpix = windowRect(4);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Number of white/black circle pairs
rcycles = 4;

% Set the stimulus position
stimpos{1} = [(xCenter-370) (yCenter - 370) (xCenter-74) (yCenter-74)];
stimpos{2} = [(xCenter-370) (yCenter + 74) (xCenter-74) (yCenter+370)];
stimpos{3} = [(xCenter+74) (yCenter - 370) (xCenter+370) (yCenter-74)];
stimpos{4} = [(xCenter+74) (yCenter + 74) (xCenter+370) (yCenter+370)];

% Set Rect position for a reference
rect_upright = [windowRect(3)-50 windowRect(4)-80 windowRect(3) windowRect(4)-40];
rect_updown = [windowRect(3)-50 windowRect(4)-40 windowRect(3) windowRect(4)];

% ITI set: 1-1.25s
ITI = repmat([framerate*1:1:framerate*1.5],1,5);
ITIorder = randperm(length(ITI));
ITIrand = ITI(ITIorder);

% Calculate Number of frames in total
nTrials = 4; % 12 repetition for each condition
numPosition = 4;
stimulusperiod = 0.5; % 500 ms presentation

% Define stimulus position
for trindice = 1:nTrials
    stimposindice(:,trindice) = randperm(4);
    if trindice > 1
        if stimposindice(4,(trindice-1)) == stimposindice(1,trindice);
            stimposindice(1:2,trindice) = flipud(stimposindice(1:2,trindice));
        end
    else
    end
end

% Assign contrast
for contrastind = 1:numPosition
    contrastorder(:,contrastind) = randperm(nTrials);
end

% Define contrast
contrast_effect = [0.65 1]; % contrast 30% 100%

% Define number of Frames
nFrames = stimulusperiod*numPosition*framerate*nTrials + sum(ITIrand(1:(numPosition*nTrials)))+1;

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (screenYpix - 1): xylim,...
    -xylim: 2 * xylim / (screenYpix - 1): xylim);

inc=white-grey;

% Frequency of the checkerboard
freq_pixel = length(x)/4;

mlength = size(x,1);
startnumber_m = randperm(mlength);
startnumber_m2 = randperm(mlength);

mblack_x = zeros(mlength,1);
mblack_y = zeros(mlength,1);

for i = 1:mlength
    if mod((i+startnumber_m(1)),freq_pixel) < freq_pixel*0.5
        mblack_x(i) = 1;
    end
    if mod((i+startnumber_m2(1)),freq_pixel) < freq_pixel*0.5
        mblack_y(i) = 1;
    end
end

m = zeros(size(x));
contrast_num = mod(contrastorder(1,stimposindice(1 ,1)),2) + 1;

m(find(mblack_x),find(mblack_y)) = contrast_effect(contrast_num);
m(find(mblack_x==0),find(mblack_y==0)) = contrast_effect(contrast_num);
m(find(mblack_x),find(mblack_y==0)) = 1 - contrast_effect(contrast_num);
m(find(mblack_x==0),find(mblack_y)) = 1 - contrast_effect(contrast_num);

circle = x.^2 + y.^2 <= xylim^2;
checks = circle .* m + grey * ~circle;

% Now we make this into a PTB texture
radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);

% We are going to draw four textures to show how a black and white texture
% can be color modulated upon drawing
yPos = yCenter;
xPos = linspace(screenXpixels * 0.2, screenXpixels * 0.8, 4);

% Define the destination rectangles for our spiral textures. Each scaled by
% 50x
[s1, s2] = size(checkerboard);
baseRect = [0 0 s1 s2] .* 50;
dstRects = nan(4, 4);
for i = 1:4
    dstRects(:, i) = CenterRectOnPointd(baseRect, xPos(i), yPos);
end

% Set pre-trial period
pre_wait_time = 1;

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 0.25;
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
frameCounter = 0;

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

% Fixation point settings
center = [windowRect(3)/2 windowRect(4)/2];	% coordinates of screen center (pixels)
ppd = pi * windowRect(3) / atan(mon_width/v_dist/2) / 360;    % pixels per degree

fix_cord = [center-fix_r*ppd center+fix_r*ppd];
fix_color{1} = [255 0 0];
fix_color{2} = [0 255 0];

% Define the parameter related to number of switch on fixation
nflipparam = 120 + round((rand - 0.5)*30)

% Define the frame where fixation point flips
tmp=repmat(round(rand(1,ceil(nFrames/nflipparam))),nflipparam,1);
tmp2=tmp(:);
for i = 2:nFrames
    tmp3(i)=abs(tmp2(i)-tmp2(i-1));
end

stim.tmp3 = tmp3;
stim.tmp2 = tmp2;

Screen('FillRect',window,[0 0 0],rect_upright);
Screen('FillRect',window,[0 0 0],rect_updown);
Screen(window,'TextFont','Arial'); 
Screen(window,'TextSize',24);      
Screen('DrawText', window, 'Press key to start', xCenter, (yCenter-40), 255);

% Draw fixation
Screen('FillOval', window, fix_color{1}, fix_cord);	% draw fixation dot (flip erases it)
Screen('Flip', window);

% Press any keys to begin
while 1
    % scan the keyboard for experimentor input
    [exKeyIsDown,exSecs,exKeyCode] = KbCheck(-3);
    if(exKeyIsDown)
        break; % out of while loop
    end;
    
end

% Draw fixation
Screen('FillOval', window, fix_color{1}, fix_cord);	% draw fixation dot (flip erases it)
Screen('FillRect',window,[0 0 0],rect_upright);
Screen('FillRect',window,[0 0 0],rect_updown);
Screen('Flip', window);

exp_start_time = GetSecs;

response.keyCode = zeros(nFrames,1);
frameCounter = 1;
stimCounter = 1;
WaitSecs(pre_wait_time);

for jb = 1:nTrials
    for k = 1:numPosition
        stim.position(stimCounter) = stimposindice(k ,jb);
        stim.onsetframe(stimCounter) = frameCounter;
        stim.contrast(stimCounter) = contrast_num;
        
        current_trial = stimCounter
        
        fprintf('Try Count: %d  Stimulus Pos: %d Stimulus contrast: %d', stimCounter,  stim.position(stimCounter),  stim.contrast(stimCounter));
        
        % Increment the counter
        stimCounter = 1 + stimCounter;
        
        
        for kk = 1:(framerate*stimulusperiod)
            Screen('FillRect',window,grey);
            
            % Draw our texture to the screen
            Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)),[], stimpos{stimposindice(k ,jb)});
            Screen('FillOval', window, fix_color{(tmp2(frameCounter)+1)}, fix_cord);	% draw fixation dot (flip erases it)
            
            Screen('FillRect',window,[255 255 255],rect_upright);
            Screen('FillRect',window,[255 255 255],rect_updown);
            
            % Flip to the screen
            vbl = Screen('Flip', window, vbl);
            if kk==1
              stim.onsetperiod(stimCounter-1) = GetSecs - exp_start_time;
            end
            
            frameCounter = frameCounter + 1;
            
            [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(-3);
            if(ssKeyIsDown)
                response.keyCode(frameCounter) = 1; % binary response for now
                if(ssKeyCode(quitProgKey)),
                    quitProg = 1;
                    break; % out of while loop
                end;
            end;
        end
        
        clear radialCheckerboardTexture
        Screen('FillRect',window,[0 0 0],rect_upright);
        Screen('FillRect',window,[0 0 0],rect_updown);
        Screen('FillOval', window, fix_color{(tmp2(frameCounter)+1)}, fix_cord);	% draw fixation dot (flip erases it)
        vbl = Screen('Flip', window, vbl);
        
        stim.offsetperiod((stimCounter-1)) = GetSecs - exp_start_time;
        stim.offsetframe(stimCounter-1) = frameCounter;
        frameCounter = frameCounter + 1;
       
        % Stimulus generation period
        mblack_x = zeros(mlength,1);
        mblack_y = zeros(mlength,1);
        
        for i = 1:mlength
            if mod((i+startnumber_m(stimCounter)),freq_pixel) < freq_pixel*0.5
                mblack_x(i) = 1;
            end
            if mod((i+startnumber_m2(stimCounter)),freq_pixel) < freq_pixel*0.5
                mblack_y(i) = 1;
            end
        end
        
        m = zeros(size(x));
        m2 = zeros(size(y));
        
        % Define contrast
        if k < numPosition
            contrast_num = mod(contrastorder(jb,stimposindice(k+1 ,jb)),2) + 1;
        else
            if jb<nTrials
                contrast_num = mod(contrastorder(jb+1,stimposindice(1 ,jb+1)),2) + 1;
            else
            end
        end
        
        m(find(mblack_x),find(mblack_y)) = contrast_effect(contrast_num);
        m(find(mblack_x==0),find(mblack_y==0)) = contrast_effect(contrast_num);
        m(find(mblack_x),find(mblack_y==0)) = 1 - contrast_effect(contrast_num);
        m(find(mblack_x==0),find(mblack_y)) = 1 - contrast_effect(contrast_num);
        
        circle = x.^2 + y.^2 <= xylim^2;
        checks = circle .* m + grey * ~circle;
        
        % Now we make this into a PTB texture
        radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
        
        stimend_time = GetSecs;
        lose_time = stimulusperiod - (stimend_time - (stim.onsetperiod(stimCounter-1)+exp_start_time));
        
        while GetSecs - ((stim.offsetperiod(stimCounter-1)+exp_start_time) + ((ITIrand(k*jb))/framerate) + lose_time ) < 0
            Screen('FillRect',window,[0 0 0],rect_upright);
            Screen('FillRect',window,[0 0 0],rect_updown);
            Screen('FillOval', window, fix_color{(tmp2(frameCounter)+1)}, fix_cord);	% draw fixation dot (flip erases it)
            vbl = Screen('Flip', window, vbl);
            [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(-3);
            if(ssKeyIsDown)
                response.keyCode(frameCounter) = 1; % binary response for now
            end;
            [exKeyIsDown,exSecs,exKeyCode] = KbCheck(-3);
            if(exKeyIsDown)
                if(exKeyCode(quitProgKey)),
                    quitProg = 1;
                    save(expinfo.savelog, 'stim','expinfo');
                    sca;
                    close all;
                    clear all;
                    break; % out of while loop
                end;
            end;
            frameCounter = frameCounter + 1;
        end
    end
end
% Clear up 
sca;
close all;

% Save parameters during experiment
stim.duration = stim.offsetperiod - stim.onsetperiod;
stim.changenumber = sum(tmp3)
save(expinfo.savelog, 'stim','expinfo','response');

% Plot key press
x = [1:1:frameCounter];
plot(x,response.keyCode(1:frameCounter), 'b', x, stim.tmp2(1:frameCounter), 'r');
xlabel('Number of frames','FontSize',16);
ylabel('Response or Stimuli', 'FontSize',16);
legend('Response','Stimulus');
Priority(oldPriority);
clear all;