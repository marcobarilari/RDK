function RDK(subj, direc, emulate, debug)

% Display a random dot kinetogram


% TO DO
% - wedge crashes when angles > 360
% - wedge crashes when direction wedge motion < 0
% - wedge starts with full wedge or not?
% - exponential width of expanding annulus
% - vertical bars and diagonal bars

clear
close all
clc

if nargin == 0
    subj = 66;
    run = 1;
    aperture_style = 'none';
    direc = '-';
    emulate = true;
    debug = true;
end

if isempty(subj)
    subj = input('Subject number? ');
    run = input('Retinotopic run number? ');
end

task = 'RDK';

PARAMETERS = config(subj, run, task, aperture_style);


%% DOTS DETAILS
% dots per degree^2
dot_density = PARAMETERS.dot_density;
% max dot speed (deg/sec)
dot_speed = PARAMETERS.dot_speed;
% width of dot (deg)
dot_w = PARAMETERS.dot_w;
% fraction of dots to kill each frame (limited lifetime)
fraction_kill = PARAMETERS.fraction_kill;
% Amount of coherence
coherence = PARAMETERS.coherence;
% 0 gives right, 90 gives down, 180 gives left and 270 up.
angle_motion = PARAMETERS.angle_motion;
% speed rotation of motion direction in degrees per second
spd_rot_mot_sec = PARAMETERS.spd_rot_mot_sec;


%% ANIMATIONS DETAILS
% proportion of screeen height occupied by the RDK
matrix_size = PARAMETERS.matrix_size;
% number of animation frames in loop
n_frames = PARAMETERS.n_frames;
% Show new dot-images at each waitframes'th monitor refresh
wait_frames = PARAMETERS.wait_frames;


%% Initialize variables
prev_keypr = 0;

BEHAVIOUR.response = [];
BEHAVIOUR.responseTime = [];

TARGET.was_event = false;

target_data = [];

CURRENT.Frame = 0;
CURRENT.Stim = 1;


%% Setup
SetUpRand

PARAMETERS = eyeTrack(PARAMETERS, 'init');

% Event timings
% Events is a vector that says when (in seconds from the start of the
% experiment) a target should be presented.
events = createEventsTiming(PARAMETERS)

[trig_str, PARAMETERS] = configScanner(emulate, PARAMETERS);

% put everything into a try / catch in case the poop hits the fan
try
    
    
    %% Initialize PTB
    
    keyCodes = setupKeyCodes;
    
    [win, rect, ~, ifi, PARAMETERS] = initPTB(PARAMETERS, debug);
    PARAMETERS.ifi = ifi;
    % Pixel per degree
    ppd = getPPD(rect, PARAMETERS);
    PARAMETERS.ppd = ppd;
    
    
    TARGET.event_size_pix = PARAMETERS.event_size * ppd;
    
    fixation_size_pix = PARAMETERS.fixation_size * ppd;
    
    
    %% Set general RDK and display details
    % diameter of circle covered by the RDK
    matrix_size = floor(rect(4) * matrix_size);
    
    % set center of the dot texture that will be created
    stim_rect = [0 0 repmat(matrix_size, 1, 2)];
    [center(1,1), center(1,2)] = RectCenter(stim_rect);
    
    % dot speed (pixels/frame) - pixel frame speed
    pfs = dot_speed * ppd * ifi;
    
    % dot size (pixels)
    dot_s = dot_w * ppd;
    
    % Number of dots : surface of the RDK disc * density of dots
    nDots = getNumberDots(dot_w, matrix_size, dot_density, ppd);
    
    % decide which dots are signal dots (1) and those are noise dots (0)
    dot_nature = rand(nDots,1) < coherence;
    
    % speed rotation of motion direction in degrees per frame
    spd_rot_mot_f = spd_rot_mot_sec * ifi;
    

    %% Initialize dots
    % Dot positions and speed matrix : colunm 1 to 5 gives respectively
    % x position, y position, x speed, y speed, and distance of the point the RDK center
    xy= zeros(nDots,5);
    
    % fills a square with dots and we will later remove those outside of
    % the frame
    [X] = getX(nDots, matrix_size);
    [Y] = getY(nDots, matrix_size, X);
    
    xy(:,1) = X;
    xy(:,2) = Y;
    clear X Y
    
    % decompose angle of start motion into horizontal and vertical vector
    [hor_vector, vert_vector] = decompMotion(angle_motion);
    
    % Gives a pre determinded horizontal and vertical speed to the signal dots
    xy = getXYMotion(xy, dot_nature, hor_vector, vert_vector, pfs);
    
    % Gives a random horizontal and vertical speed to the other ones
    xy(~dot_nature,3:4) = randn(sum(~dot_nature),2) * pfs;
    
    % calculate distance from matrix center for each dot
    xy = getDist2Center(xy);
    
    
    %% Initialize textures
    % Create dot texture
    dot_texture = Screen('MakeTexture', win, PARAMETERS.gray * ones(matrix_size));
    
    % Aperture texture
    aperture_texture = Screen('MakeTexture', win, PARAMETERS.gray * ones(rect([4 3])));


    %% Standby screen
    Screen('FillRect', win, PARAMETERS.gray, rect);
    
    DrawFormattedText(win, ...
        [PARAMETERS.welcome '\n \n' PARAMETERS.instruction '\n \n' trig_str], ...
        'center', 'center', PARAMETERS.white);
    
    Screen('Flip', win);
    
    HideCursor;
    
    Priority(MaxPriority(win));
    
    
    %% Wait for start of experiment
    if emulate == 1
        [~, key, ~] = KbPressWait;
        WaitSecs(PARAMETERS.TR * PARAMETERS.dummies);
    else
        [my_port] = waitForScanTrigger(PARAMETERS);
    end
    
    QUIT = experimentAborted(key, keyCodes, win, PARAMETERS, rect);
    
    
    %% Start
    eyeTrack(PARAMETERS, 'start');
    
    % Do initial flip...
    vbl = Screen('Flip', win);
    
    start_expmt = vbl;
    
    for i = 1:n_frames
        
        CURRENT.Time = GetSecs - start_expmt;
        
        if QUIT
            return
        end
        
        %% Remove dots that are too far out, kill dots, reseed dots, 
        % Finds if there are dots to reposition because out of the RDK
        xy = dotsROut(xy, matrix_size);
        
        % Kill some dots and reseed them at random position
        xy = dotsReseed(nDots, fraction_kill, matrix_size, xy);
        
        % calculate distance from matrix center for each dot
        xy = getDist2Center(xy);
        
        % find dots that are within the RDK area
        r_in = xy(:,5) <= matrix_size/2;
        
        % find the dots that do not overlap with fixation dot
        r_fixation = xy(:,5) > fixation_size_pix * 2;
        
        % only pass those that match all those conditions
        r_in = find( all([ ...
            r_in, ...
            r_fixation] ,2) );
        
        % change of format for PTB
        xy_matrix = transpose(xy(r_in,1:2)); %#ok<FNDSB>
        
        
        %% Create apperture texture for this frame
        Screen('Fillrect', aperture_texture, PARAMETERS.gray);
        
        Screen('FillOval', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(matrix_size,1,2)], rect(3)/2, rect(4)/2 ));

        aperture_cfg = getApertureCfg(PARAMETERS, matrix_size);
        
        
        %% Actual PTB stuff
        % sanity check before drawin the dots in the texture
        if ~isempty(xy_matrix)
            
            Screen('FillRect', dot_texture, PARAMETERS.gray);
            
            Screen('DrawDots', dot_texture, xy_matrix, dot_s, PARAMETERS.white, center, 1);
        else
            warning('no dot to plot')
            break
        end
        
        % Draw dot texture, aperture texture, fixation gap around fixation
        Screen('DrawTexture', win, dot_texture, stim_rect, CenterRect(stim_rect, rect));
        
        Screen('DrawTexture', win, aperture_texture);
        
        Screen('FillOval', win, PARAMETERS.gray, ...
            CenterRect([0 0 fixation_size_pix*2 fixation_size_pix*2], rect));
        
        Screen('FillOval', win, PARAMETERS.white, ...
            CenterRect([0 0 fixation_size_pix fixation_size_pix], rect));
        

        %% Draw target
        [TARGET] = drawTarget(TARGET, events, CURRENT, win, rect, PARAMETERS);
        
        
        %% Flip current frame
        % Tell PTB that no further drawing commands will follow before Screen('Flip')
        Screen('DrawingFinished', win);
        
        % Show everything
        vbl = Screen('Flip', win, vbl + wait_frames*ifi);
        
        % collect target actual presentation time and target position
        if TARGET.onset
            target_data(end+1,[1 3:5]) = vbl-start_expmt; %#ok<AGROW>
        elseif TARGET.offset
            target_data(end,2) = vbl-start_expmt;
        end
        
        if PARAMETERS.print_gif
            filename = fullfile(pwd, 'screen_capture', 'RDK_');
            printScreen(win, filename, i)
        end
        
        
        %% Behavioural response
        [BEHAVIOUR, prev_keypr, QUIT] = getBehResp(keyCodes, win, PARAMETERS, rect, prev_keypr, BEHAVIOUR, start_expmt);
        
        
        %% Update everything
        % update aperture position
%         aperture_cfg = aperture_cfg + aperture_speed_ppf;
        
        %         switch aperture_style
        %             case 'wedge'
        %                 aperture_cfg = rem(aperture_cfg, 360);
        %         end
        
        % Move the dots
        xy(:,1:2) = xy(:,1:2) + xy(:,3:4);
        
        % update motion direction
        angle_motion = angle_motion + spd_rot_mot_f;
        [hor_vector, vert_vector] = decompMotion(angle_motion);
        
        % update dot matrix
        xy = getXYMotion(xy, dot_nature, hor_vector, vert_vector, pfs);
        
        clear xy_matrix
        
    end
    
    farewellScreen(win, PARAMETERS, rect)
    
    end_expmt = Screen('Flip', win);
    
    %% Experiment duration
    dispExpDur(end_expmt, start_expmt)
    
    WaitSecs(1);
    
    if emulate ~= 1
        IOPort('ConfigureSerialPort', my_port, 'StopBackgroundRead');
        IOPort('Close', my_port);
    end
    
    eyeTrack(PARAMETERS, 'stop');
    
    cleanUp
    
catch
    cleanUp
    psychrethrow(psychlasterror);
end
