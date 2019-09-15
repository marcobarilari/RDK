% Display a random dot kinetogram

clear
close all
clc

debug = 0;

% DOTS DETAILS
% dots per degree^2
dot_density = .5;
% max dot speed (deg/sec)
dot_speed   = 10;
% width of dot (deg)
dot_w = .5;
% fraction of dots to kill each frame (limited lifetime)
fraction_kill = 0.01;
% Amount of coherence
coherence = 1;
% 0 gives right, 90 gives down, 180 gives left and 270 up.
angle_motion = 270;
% decompose angle of motion into horizontal and vertical vector
hor_vector = cos(pi*angle_motion/180);
vert_vector = sin(pi*angle_motion/180);

% ANIMATIONS DETAILS
% proportion of screeen height occupied by the RDK
matrix_size = .95;
% number of animation frames in loop
n_frames = 7200;
% Show new dot-images at each waitframes'th monitor refresh
wait_frames = 1;

% SCREEN DETAILS
% horizontal dimension of viewable screen (cm)
mon_width = 39;
% viewing distance (cm)
view_dist = 60;

aperture_width = 400;

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
    s  =  dot_w * ppd;
    
    % Number of dots : surface of the RDK disc * density of dots
    nDots  =  getNumberDots(dot_w, matrix_size, dot_density, ppd);
    
    % Decide which dots are signal dots (1) and those are noise dots (0)
    dot_nature  =  rand(nDots,1) < coherence;
    
    
    % FIXATION CROSS
    cross_size  =  500;
    fix_cross  =  ones(100,100)*White;
    fix_cross(5:6, :) =  White;
    fix_cross(:, 5:6) =  White;
    fix_cross  =  Screen('MakeTexture', w, fix_cross);
    fix_coord  = [center(1)-cross_size, center(2)-cross_size, center(1)+cross_size, center(2)-cross_size];
    
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
    xy(~dot_nature,3:4) =  rand(sum(~dot_nature),2) * pfs;
    
    
    aperture_x  = [-500 -500 + aperture_width];
    
    %% START
    HideCursor;
    Priority(MaxPriority(w));
    
    % Do initial flip...
    vbl=Screen('Flip', w);
    
    for i  =  1:n_frames
        if (i>1)
            % Draw nice dots : change 1 to 0 to draw square dots
            Screen('DrawDots', w, xy_matrix, s, White, mat_center, 1);
            % Centered fixation cross
            Screen('DrawTexture', w, fix_cross,[],fix_coord);
            % Tell PTB that no further drawing commands will follow before Screen('Flip')
            Screen('DrawingFinished', w);
        end
        
        aperture_x  =  aperture_x + 1;
        
        if KbCheck % break out of loop
            break;
        end
        
        % Move the dots
        xy(:,1:2) =  xy(:,1:2) + xy(:,3:4);
        
        % calculate distance from matrix center for each dot
        [a, R] =  cart2pol(xy(:,1), xy(:,2));
        xy(:,5) =  R;
        
        % Finds if there is dots to reposition
        r_out  = (xy(:,5) > (matrix_size/2) | rand(nDots,1) < fraction_kill);
        
        % r_out  =  any([r_out xy(:,1)<aperture_x(1) xy(:,1)>aperture_x(2)], 2);
        
        r_out  =  find(r_out);
        
        % Number of dots to reposition
        n_out  =  length(r_out);
        
        if n_out
            % Gives random position to the dots in x and y
            % X  =  rand(n_out,1)*aperture_x(2)-aperture_x(1);
%             X = ( xy(r_out,1)-xy(r_out,3) ) * -1;
%             X = ( xy(r_out,1:2)-xy(r_out,3:4) ) * -1;
%             [Y] = getY(n_out, matrix_size, X);
            
            xy(r_out,1:2) = ( xy(r_out,1:2)-xy(r_out,3:4) ) * -1;
            
%             xy(r_out,1) =  X;
%             xy(r_out,2) =  Y;
%             clear X Y
            
            % Gives new velocities direction value to these dots
            % xy(r_out,3:4) =  rand(n_out,2) * 2 * pfs - pfs;
        end
        
        if mod(i,20) == 0
            angle_motion  =  angle_motion + 5;
            
            hor_vector  =  cos(pi*angle_motion/180);
            vert_vector  =  sin(pi*angle_motion/180);
            
            xy(dot_nature,3:4) = ...
                repmat([hor_vector vert_vector], sum(dot_nature), 1) * 2 * pfs;
        end
        
        xy_matrix  =  transpose(xy(:,1:2));
        
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
