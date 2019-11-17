function PARAMETERS = config(subj, run, task)


%% Output directory
PARAMETERS.target_dir = fullfile(fileparts(mfilename('fullpath')), 'output');


%% Splash screens
PARAMETERS.welcome = 'Please fixate the black dot at all times!';
PARAMETERS.instruction = 'Press the button everytime it changes color!';


%% feedback screens
PARAMETERS.hit = 'You responded %i / %i times when there was a target.';
PARAMETERS.miss = 'You did not respond %i / %i times when there was a target.';
PARAMETERS.FA = 'You responded %i times when there was no target.';
PARAMETERS.resp_win = 2; % duration of the response window


%% Engine parameters
% Screen used to display
PARAMETERS.screen = max(Screen('Screens'));
% Resolution [width height refresh_rate]
PARAMETERS.resolution = [800 600 60];
% Size of font
PARAMETERS.font_size = 40;
% Font to use
PARAMETERS.font_name = 'Comic Sans MS';

PARAMETERS.screen_capture = true;

PARAMETERS.print_gif = false;


%% DOTS DETAILS
% dots per degree^2
PARAMETERS.dot_density = .15;
% max dot speed (deg/sec)
PARAMETERS.dot_speed   = 10;
% width of dot (deg)
PARAMETERS.dot_w = .5;
% fraction of dots to kill each frame (limited lifetime)
PARAMETERS.fraction_kill = 0.05;
% Amount of coherence
PARAMETERS.coherence = 1;
% starting motion direction: 0 gives right, 90 gives down, 180 gives left and 270 up.
PARAMETERS.angle_motion = 0;
% speed rotation of motion direction in degrees per second
PARAMETERS.spd_rot_mot_sec = 45/6;


%% MOVING APERTURE
 PARAMETERS.aperture_style = 'none';
% cfg.aperture_style = 'annulus';
% cfg.aperture_style = 'bar';
% cfg.aperture_style = 'wedge';


%% FIXATION CROSS
PARAMETERS.fix_cross_size_VA = .5;    % fixation cross in visual angles
PARAMETERS.fix_cross_lineWidth_VA = 0.1;
PARAMETERS.fix_cross_xDisp = 0;
PARAMETERS.fix_cross_yDisp = 0;


%% ANIMATION DETAILS
% proportion of screeen height occupied by the RDK
PARAMETERS.matrix_size = .9;
% number of animation frames in loop
PARAMETERS.n_frames = 500;
% Show new dot-images at each waitframes'th monitor refresh
PARAMETERS.wait_frames = 1;


%% SCREEN DETAILS
% horizontal dimension of viewable screen (cm)
PARAMETERS.mon_width = 21.5;
% viewing distance (cm)
PARAMETERS.view_dist = 30;


%% Scanner parameters
% Seconds per volume
PARAMETERS.TR = 1;
% Dummy volumes
PARAMETERS.dummies = 0;
PARAMETERS.overrun = 0;


%% Experiment parameters

PARAMETERS.fixation_size = .15; % in degrees VA

% Target parameters
% Changing those parameters might affect participant's performance
% Need to find a set of parameters that give 85-90% accuracy.

% Probability of a target event
PARAMETERS.prob_of_event = 0.1;
% Duration of a target event in ms
PARAMETERS.event_duration = 0.15;
% diameter of target circle in degrees VA
PARAMETERS.event_size = .15;
% rgb color of the target
PARAMETERS.even_color = [255 200 200];


%% Eyetracker parameters
% do we use an eyetracker ?
PARAMETERS.eyetracker.do = false;

PARAMETERS.eyetracker.host = '10.41.111.213';  % SMI machine ip: '10.41.111.213'
PARAMETERS.eyetracker.port = 4444;
PARAMETERS.eyetracker.window = 1;



%% Compute some parameters

addpath(fullfile(fileparts(mfilename('fullpath')), 'subfun'))
addpath(fullfile(fileparts(mfilename('fullpath')), 'subfun', 'diy'))


switch PARAMETERS.aperture_style
    case 'none'
        PARAMETERS.aperture_width = NaN;
        PARAMETERS.aperture_speed_VA = NaN;
        PARAMETERS.aperture_mot_dir = NaN;
        
    case 'bar'
        % aperture width in deg VA 
        PARAMETERS.aperture_width = 3;
        % aperture speed in deg VA / sec 
        PARAMETERS.aperture_speed_VA = -1;
        % aperture motion direction
        PARAMETERS.aperture_mot_dir = 0;
            
    case 'annulus'
        % aperture width in deg VA (bar or annulus)
        PARAMETERS.aperture_width = 3;
        % aperture speed in deg VA / sec 
        PARAMETERS.aperture_speed_VA = -1;
        
        PARAMETERS.aperture_mot_dir = NaN;
        
    case 'wedge'
        % aperture width in deg (wedge)
        PARAMETERS.aperture_width = 60;
        % aperture speed in deg / sec (wedge)
        PARAMETERS.aperture_speed_VA = 10;

        PARAMETERS.aperture_mot_dir = NaN;
end


subj = ['sub-', sprintf('%2.2d', subj)];
PARAMETERS.subj = subj;

run = ['run-', sprintf('%2.2d', run)];
PARAMETERS.run = run;

PARAMETERS.task = ['task-' task];

% create the output folders if not already present
% stick to BIDS structure (might need to implement session)
PARAMETERS.output_dir = fullfile(PARAMETERS.target_dir, subj, 'func');
[~,~,~] = mkdir(PARAMETERS.output_dir);

% create base name for output files
% departure from BIDS specification: append dates to base filenae
date_format = 'yyyymmdd-HHMM';
PARAMETERS.output_filename = fullfile(PARAMETERS.output_dir, ...
    sprintf('%s_%s_%s_%s', ...
    PARAMETERS.subj, ...
    PARAMETERS.task, ...
    PARAMETERS.run, ...
    datestr(now, date_format) ) );

% compute full field of view
PARAMETERS.FOV = getFOV(PARAMETERS);

% for octave: to prevent output being presented one screen at a time
if IsOctave
    more off
    pkg load image
end



end