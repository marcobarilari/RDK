% Display a random dot kinetogram

clear
close all
clc

debug = 0;

cfg = config();

% DOTS DETAILS
% dots per degree^2
dot_density = cfg.dot_density;
% max dot speed (deg/sec)
dot_speed   = cfg.dot_speed;
% width of dot (deg)
dot_w = cfg.dot_w;
% fraction of dots to kill each frame (limited lifetime)
fraction_kill = cfg.fraction_kill;
% Amount of coherence
coherence = cfg.coherence;
% 0 gives right, 90 gives down, 180 gives left and 270 up.
angle_motion = cfg.angle_motion;
% speed rotation of motion direction in degrees per second
spd_rot_mot_sec = cfg.spd_rot_mot_sec;

% FIXATION
fix_cross_size_VA = cfg.fix_cross_size_VA;
fix_cross_lineWidth_VA = cfg.fix_cross_lineWidth_VA;
fix_cross_xDisp = cfg.fix_cross_xDisp;
fix_cross_yDisp = cfg.fix_cross_yDisp;

% ANIMATIONS DETAILS
% proportion of screeen height occupied by the RDK
matrix_size = cfg.matrix_size;
% number of animation frames in loop
n_frames = cfg.n_frames;
% Show new dot-images at each waitframes'th monitor refresh
wait_frames = cfg.wait_frames;

% SCREEN DETAILS
% horizontal dimension of viewable screen (cm)
mon_width = cfg.mon_width;
% viewing distance (cm)
view_dist = cfg.view_dist;

aperture_width = cfg.aperture_width;

%%
AssertOpenGL;

if debug
    PsychDebugWindowConfiguration
else
    Screen('Preference', 'SkipSyncTests', 1) %#ok<*UNRCH>
    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
end

try
    
    
    %% open screen and get info
    screens=Screen('Screens');
    screen_number=max(screens);
    
    [w, rect] = Screen('OpenWindow', screen_number, 0, [], 32, 2);
    
    % Gets the coordinates of the center of the screen
    [center(1), center(2)] = RectCenter(rect);
    
    % Enable alpha blending with proper blend-function. We need it for drawing of smoothed points:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % frames per second
    fps=Screen('FrameRate',w);
    % interframe interval
    ifi=Screen('GetFlipInterval', w);
    if fps==0
        fps=1/ifi;
    end
    
    % Pixel per degree
    ppd  =  getPPD(rect, mon_width, view_dist);
    
    % Get color index for that screen
    Black  =  BlackIndex(w);
    White  =  WhiteIndex(w);
    
    
    %% set general RDK details
    % diameter of circle covered by the RDK
    matrix_size  =  floor(rect(4) * matrix_size);
    
    % center of the RDK
    mat_center  = [center(1), center(2)];
    
    % dot speed (pixels/frame)
    pfs  =  dot_speed * ppd / fps;
    
    % dot size (pixels)
    dot_s  =  dot_w * ppd;
    
    % Number of dots : surface of the RDK disc * density of dots
    nDots  =  getNumberDots(dot_w, matrix_size, dot_density, ppd);
    
    % Decide which dots are signal dots (1) and those are noise dots (0)
    dot_nature  =  rand(nDots,1) < coherence;
    
    % bar aperture width in pixel
    aperture_width = aperture_width * ppd;
    
    % fixation cross
    fix_cross_size_pix = fix_cross_size_VA * ppd;
    fix_cross_lineWidth_pix = fix_cross_lineWidth_VA * ppd;
    xCoords = [-fix_cross_size_pix fix_cross_size_pix 0 0] + fix_cross_xDisp;
    yCoords = [0 0 -fix_cross_size_pix fix_cross_size_pix] + fix_cross_yDisp;
    fix_cross_coords = [xCoords; yCoords];
    
    %% initialize dots
    % Dot positions and speed matrix : colunm 1 to 5 gives respectively
    % x position, y position, x speed, y speed, and distance of the point the RDK center
    xy= zeros(nDots,5);
    
    [X] = getX(nDots, matrix_size);
    [Y] = getY(nDots, matrix_size, X);
    
    xy(:,1) =  X;
    xy(:,2) =  Y;
    clear X Y
    
    % Gives a pre determinded horizontal and vertical speed to the signal dots
    xy(dot_nature,3:4) = ...
        repmat([hor_vector vert_vector], [sum(dot_nature), 1]) * pfs;
    
    % Gives a random horizontal and vertical speed to the other ones
    xy(~dot_nature,3:4) =  randn(sum(~dot_nature),2) * pfs;
    
    % calculate distance from matrix center for each dot
    xy = getDist2Center(xy);
    
    % aperture position
    aperture_x  = [matrix_size/-2 matrix_size/-2+aperture_width];
    
    %% initialize aperture
    % aperture configuration
    aperture_cfg = getApertureCfg(...
        aperture_style, aperture_speed_ppf, ...
        aperture_width, matrix_size, fix_cross_size_pix);
    
    %% START
    HideCursor;
    Priority(MaxPriority(w));
    
    % Do initial flip...
    vbl=Screen('Flip', w);
    
    for i  =  1:n_frames
        
        if KbCheck % break out of loop
            break;
        end
        
        % Finds if there is dots to reposition because out of the RDK
        xy = dotsROut(xy, matrix_size);
        
        % Kill some dots and reseed them at random position
        xy = dotsReseed(nDots, fraction_kill, matrix_size, xy);
        
        % calculate distance from matrix center for each dot
        [~, R] =  cart2pol(xy(:,1), xy(:,2));
        xy(:,5) =  R;
        
        % find the dots that are within the aread and only pass those to be
        % plotted
        r_in  = xy(:,5) <= matrix_size/2;
        
        % find the dots that do not overlap with fixation cross
        r_cross  = xy(:,5) > fix_cross_size_pix * 2;
        % find the dots that are within the aperture area
        r_aperture = dotsInAperture(xy, aperture_style, aperture_cfg);
        
        % find the dots that are within the aperture area and only pass those to be
        % plotted
        r_in  =  find( all([ ...
            r_in, ...
            r_cross, ...
            xy(:,1)>aperture_x(1), ...
            xy(:,1)<aperture_x(2)] ,2) );
        
        xy_matrix  =  transpose(xy(r_in,1:2));

        % Draw nice dots : change 1 to 0 to draw square dots
        Screen('DrawDots', w, xy_matrix, dot_s, White, mat_center, 1);
        % Centered fixation cross
        Screen('DrawLines', w, fix_cross_coords, fix_cross_lineWidth_pix, White, mat_center, 1);  % Draw the fixation cross
        % Tell PTB that no further drawing commands will follow before Screen('Flip')
        Screen('DrawingFinished', w);
        
        
        
        
        
        aperture_x  =  aperture_x + .5;
        
        % Move the dots
        xy(:,1:2) =  xy(:,1:2) + xy(:,3:4);
        
        
        
        % Gives new velocities direction value to these dots
        % xy(r_out,3:4) =  rand(n_out,2) * 2 * pfs - pfs;

        % 
        
        
        
        
        if mod(i,10) == 0
            angle_motion  =  angle_motion + 2;
            
            hor_vector  =  cos(pi*angle_motion/180);
            vert_vector  =  sin(pi*angle_motion/180);
            
            xy(dot_nature,3:4) = ...
                repmat([hor_vector vert_vector], sum(dot_nature), 1) * pfs;
        end
        
        % update motion direction
        angle_motion = angle_motion + spd_rot_mot_f;
        [hor_vector, vert_vector] = decompMotion(angle_motion);
        
        % update dot matrix
        xy = getXYMotion(xy, dot_nature, hor_vector, vert_vector, pfs);
        
        vbl=Screen('Flip', w, vbl + wait_frames*ifi);
        
    end
    
    Priority(0);
    ShowCursor
    Screen('CloseAll');
    
catch
    Priority(0);
    ShowCursor
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
