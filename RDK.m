% RDK
% Display a random dot kinetogram and then shos the density of th dots

% Usage: RDK
% TO DO LIST :
% set a level of coherence in motion

clear all; close all; clc

DotDensity = .5; % dots per degree^2
dot_speed   = 5; % max dot speed (deg/sec)
dot_w       = 0.3; % width of dot (deg)

f_kill      = 0.01; % fraction of dots to kill each frame (limited lifetime)

Coherence = 0.9; % Amount of coherence
AngleCoherence = 90; % 0 gives right, 90 gives up, 180 gives left and 270 down.

MatrixSize = .75; % proportion of Screeen height occuied by the RDK

nframes     = 240; % number of animation frames in loop

waitframes = 1;     % Show new dot-images at each waitframes'th monitor refresh

mon_width   = 39;   % horizontal dimension of viewable screen (cm)
v_dist      = 60;   % viewing distance (cm)


%%
HorVector = cos(pi*AngleCoherence/180);
VertVector = sin(pi*AngleCoherence/180);

AssertOpenGL;

PsychDebugWindowConfiguration;

try

    screens=Screen('Screens');
    screenNumber=max(screens);

    [w, rect] = Screen('OpenWindow', screenNumber, 0, [], 32, 2);
    [center(1), center(2)] = RectCenter(rect); % Gets the coordinates of the center of the screen

    % Enable alpha blending with proper blend-function. We need it for drawing of smoothed points:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    fps=Screen('FrameRate',w); % frames per second
    ifi=Screen('GetFlipInterval', w); % interframe interval
    if fps==0
        fps=1/ifi;
    end

    Black = BlackIndex(w);
    White = WhiteIndex(w);


    % Pixel per degree
    ppd = pi * (rect(3)-rect(1)) / atan(mon_width/v_dist/2) / 360;


    % Size of circle covered by the RDK
    MatrixSize = floor(rect(4)*MatrixSize);
    % Center of the RDK
    MatCenter=[center(1),center(2)];

    % dot speed (pixels/frame)
    pfs = dot_speed * ppd / fps;

    % dot size (pixels)
    s = dot_w * ppd;

    % Number of dots : surface of the RDK disc * density of dots
    nDots = ceil(pi * (MatrixSize/2/ppd)^2 * DotDensity);
    if nDots<10
        nDots=10;
    end

    % Decide which dots are signal dots (1) and those are noise dots (0)
    DotNature = rand(nDots,1)<Coherence;


    % FIXATION CROSS
    FixCr=ones(10,10)*0;
    FixCr(5:6,:)=255;
    FixCr(:,5:6)=255;
    fixcross = Screen('MakeTexture',w,FixCr);
    fix_cord = [center(1)-5,center(2)-5,center(1)+5,center(2)-5];


    %DOTS
    % Dot positions and speed matrix : colunm 1 to 5 gives rexpectively x
    % position, y position, x speed, y speed, and distance of the point
    % the RDK center
    xy=zeros(nDots,5);

    % Gives random position to the dots in x and y
    X = rand(nDots,1)*MatrixSize-MatrixSize/2;
    temp = ((MatrixSize/2)^2-X.^2).^0.5; % Pythagorus is your friend
    Y = rand(nDots,1).*temp*2-temp;

    xy(:,1) = X;
    xy(:,2) = Y;
    clear X Y temp


    % Gives a pre determinded horizontal and vertical speed to the signal
    % dots
    xy(DotNature,3:4) = repmat([HorVector VertVector], sum(DotNature), 1) * 2 * pfs - pfs;
    % Gives a random horizontal and vertical speed to the other ones
    xy(~DotNature,3:4) = rand(sum(~DotNature),2) * 2 * pfs - pfs;


    %%%%%%%%%
    % START %
    %%%%%%%%%
    HideCursor;
    Priority(MaxPriority(w));

    % Do initial flip...
    vbl=Screen('Flip', w);

    for i = 1:nframes
        if (i>1)
            % Draw nice dots : change 1 to 0 to draw square dots
            Screen('DrawDots', w, xymatrix, s, White, MatCenter,1);
            % Centered fixation cross
            Screen('DrawTexture', w, fixcross,[],fix_cord);
            % Tell PTB that no further drawing commands will follow before Screen('Flip')
            Screen('DrawingFinished', w);
        end

        if KbCheck % break out of loop
            break;
        end

        % Move the dots
        xy(:,1:2) = xy(:,1:2) + xy(:,3:4);

        % calculate distance from matrix center for each dot
        [a, R] = cart2pol(xy(:,1), xy(:,2));
        xy(:,5) = R;

        % Finds if there is dots to reposition
        r_out  = find(xy(:,5) > (MatrixSize/2) | rand(nDots,1) < f_kill);
        % Number of dots to reposition
        n_out = length(r_out);

        if n_out
            % Gives random position to the dots in x and y
            X = rand(n_out,1)*MatrixSize-MatrixSize/2;
            temp = ((MatrixSize/2)^2-X.^2).^0.5;
            Y = rand(n_out,1).*temp*2-temp;

            xy(r_out,1) = X;
            xy(r_out,2) = Y;
            clear X Y

            % Gives new velocities direction value to these dots
            xy(r_out,3:4) = rand(n_out,2) * 2 * pfs - pfs;
        end

        xymatrix = transpose(xy(:,1:2));

        vbl=Screen('Flip', w, vbl + waitframes*ifi);

    end;

    Priority(0);
    ShowCursor
    Screen('CloseAll');

catch
    Priority(0);
    ShowCursor
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
