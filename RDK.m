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
    direc = '-';
    emulate = true;
    debug = true;
end

if isempty(subj)
    subj = input('Subject number? ');
    run = input('Retinotopic run number? ');
end

task = 'RDK';


PARAMETERS = config(subj, run, task);

% DOTS DETAILS
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

% APERTURE
aperture_style = PARAMETERS.aperture_style;
% aperture width in deg VA
aperture_width = PARAMETERS.aperture_width;
% aperture speed deg VA / sec
aperture_speed = PARAMETERS.aperture_speed_VA;

% FIXATION
fix_cross_size_VA = PARAMETERS.fix_cross_size_VA;
fix_cross_lineWidth_VA = PARAMETERS.fix_cross_lineWidth_VA;
fix_cross_xDisp = PARAMETERS.fix_cross_xDisp;
fix_cross_yDisp = PARAMETERS.fix_cross_yDisp;

% ANIMATIONS DETAILS
% proportion of screeen height occupied by the RDK
matrix_size = PARAMETERS.matrix_size;
% number of animation frames in loop
n_frames = PARAMETERS.n_frames;
% Show new dot-images at each waitframes'th monitor refresh
wait_frames = PARAMETERS.wait_frames;


%% Setup
SetUpRand

PARAMETERS = eyeTrack(PARAMETERS, 'init');

% Event timings
% Events is a vector that says when (in seconds from the start of the
% experiment) a target should be presented.
events = createEventsTiming(PARAMETERS);

[trig_str, PARAMETERS] = configScanner(emulate, PARAMETERS);


% put everything into a try / catch in case the poop hits the fan
try
    
    
    %% Initialize PTB
    
    keyCodes = SetupKeyCodes;
    
    [win, rect, ~, ifi, PARAMETERS] = initPTB(PARAMETERS, debug);
    
    % Gets the coordinates of the center of the screen
    [center(1), center(2)] = RectCenter(rect);
    
    % Pixel per degree
    ppd = getPPD(rect, PARAMETERS);
    
    TARGET.event_size_pix = PARAMETERS.event_size * ppd;
    
    fixation_size_pix = PARAMETERS.fixation_size * ppd;
    
    
    
    %% set general RDK adn display details
    % diameter of circle covered by the RDK
    matrix_size = floor(rect(4) * matrix_size);
    
    % center of the RDK
    mat_center = [center(1), center(2)];
    
    % dot speed (pixels/frame)
    pfs = dot_speed * ppd * ifi;
    
    % dot size (pixels)
    dot_s = dot_w * ppd;
    
    % Number of dots : surface of the RDK disc * density of dots
    nDots = getNumberDots(dot_w, matrix_size, dot_density, ppd);
    
    % decide which dots are signal dots (1) and those are noise dots (0)
    dot_nature = rand(nDots,1) < coherence;
    
    % speed rotation of motion direction in degrees per frame
    spd_rot_mot_f = spd_rot_mot_sec * ifi;
    
    
    % aperture speed (pixels/frame)
    switch aperture_style
        case 'wedge'
            aperture_speed_ppf = aperture_speed * ifi;
        otherwise
            % bar/annulus aperture width and speed in pixel and frame unit
            aperture_speed_ppf = aperture_speed * ppd * ifi;
            aperture_width = aperture_width * ppd;
    end
        
    prev_keypr = 0;
    
    BEHAVIOUR.response = [];
    BEHAVIOUR.responseTime = [];
    
    %% initialize dots
    % Dot positions and speed matrix : colunm 1 to 5 gives respectively
    % x position, y position, x speed, y speed, and distance of the point the RDK center
    xy= zeros(nDots,5);
    
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
    
    
    %% initialize aperture
    % aperture configuration
    aperture_cfg = getApertureCfg(...
        aperture_style, aperture_speed_ppf, ...
        aperture_width, matrix_size, fixation_size_pix);
    
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
    
    eyeTrack(PARAMETERS, 'start');
    
    % Do initial flip...
    vbl = Screen('Flip', win);
    
    start_expmt = vbl;
    
    for i = 1:n_frames
        
        if QUIT
            return
        end
        
        % Finds if there is dots to reposition because out of the RDK
        xy = dotsROut(xy, matrix_size);
        
        % Kill some dots and reseed them at random position
        xy = dotsReseed(nDots, fraction_kill, matrix_size, xy);
        
        % calculate distance from matrix center for each dot
        xy = getDist2Center(xy);
        
        % find dots that are within the RDK area
        r_in = xy(:,5) <= matrix_size/2;
        
        % find the dots that do not overlap with fixation cross
        r_cross = xy(:,5) > fixation_size_pix * 2;
        
        % find the dots that are within the aperture area
        r_aperture = dotsInAperture(xy, aperture_style, aperture_cfg, aperture_speed_ppf);
        
        % only pass those that match all those conditions
        r_in = find( all([ ...
            r_in, ...
            r_cross, ...
            r_aperture] ,2) );
        
        % change of format for PTB
        xy_matrix = transpose(xy(r_in,1:2));
        
        
        %% Actual PTB stuff
        % sanity check
        if ~isempty(xy_matrix)
            % Draw nice dots : change 1 to 0 to draw square dots
            Screen('DrawDots', win, xy_matrix, dot_s, PARAMETERS.white, mat_center, 1);
        else
            warning('no dot to plot')
            break
        end
        
        
        % Centered fixation cross
%         Screen('DrawLines', win, fix_cross_coords, fix_cross_lineWidth_pix, PARAMETERS.white, mat_center, 1); % Draw the fixation cross
        
        % Draw gap around fixation
        Screen('FillOval', win, PARAMETERS.gray, ...
            CenterRect([0 0 fixation_size_pix+10 fixation_size_pix+10], rect));
        
        % Draw fixation
        Screen('FillOval', win, PARAMETERS.white, ...
            CenterRect([0 0 fixation_size_pix fixation_size_pix], rect));
        
        
        
        % Tell PTB that no further drawing commands will follow before Screen('Flip')
        Screen('DrawingFinished', win);
        
        % Show everything
        vbl = Screen('Flip', win, vbl + wait_frames*ifi);
        
        if PARAMETERS.print_gif
            filename = fullfile(pwd, 'screen_capture', 'RDK_');
            printScreen(win, filename, i)
        end
        
        
        [BEHAVIOUR, prev_keypr, QUIT] = getBehResp(keyCodes, win, PARAMETERS, rect, prev_keypr, BEHAVIOUR, start_expmt);
        
        
        %% Update everything
        % update aperture position
        aperture_cfg = aperture_cfg + aperture_speed_ppf;
        
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
