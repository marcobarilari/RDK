function PARAMETERS = config(subj, run, task, aperture_style, direction)


%% Output directory
PARAMETERS.target_dir = fullfile(fileparts(mfilename('fullpath')), 'output');


%% Splash screens
PARAMETERS.welcome = 'Please fixate the black dot at all times!';
PARAMETERS.instruction = 'Press the button everytime it changes color!';


%% Feedback screens
PARAMETERS.hit = 'You responded %i / %i times when there was a target.';
PARAMETERS.miss = 'You did not respond %i / %i times when there was a target.';
PARAMETERS.FA = 'You responded %i times when there was no target.';
PARAMETERS.resp_win = 2; % duration of the response window


%% Dots details
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


%% Aperture details
PARAMETERS.aperture.style = aperture_style;

switch PARAMETERS.aperture.style
    
    case 'none'
        PARAMETERS.aperture.width = NaN;
        PARAMETERS.aperture.vols_per_cycle = NaN;
        PARAMETERS.aperture.direction = NaN;
        
    case 'bar'
        % aperture width in deg VA 
        PARAMETERS.aperture.width = 3;
        % aperture motion direction
        PARAMETERS.aperture.direction = 0;
            
    case 'ring'
        % aperture width in deg VA (bar or annulus)
        PARAMETERS.aperture.width = 3;
        PARAMETERS.aperture.direction = direction;
        PARAMETERS.aperture.vols_per_cycle = 12;
        
    case 'wedge'
        % aperture width in deg (wedge)
        PARAMETERS.aperture.width = 60;
        PARAMETERS.aperture.direction = direction;
        PARAMETERS.aperture.vols_per_cycle = 12;
end


%% Experiment parameters

PARAMETERS.fixation_size = .15; % in degrees VA

% Target parameters
% Changing those parameters might affect participant's performance
% Need to find a set of parameters that give 85-90% accuracy.

% Probability of a target event
PARAMETERS.prob_of_event = 0.5;
% Duration of a target event in ms
PARAMETERS.event_duration = 0.15;
% diameter of target circle in degrees VA
PARAMETERS.event_size = .15;
% rgb color of the target
PARAMETERS.event_color = [255 200 200];


%% Animation details
% proportion of screeen height occupied by the RDK
PARAMETERS.matrix_size = .99;
% number of animation frames in loop
PARAMETERS.n_frames = 800;
% Show new dot-images at each waitframes'th monitor refresh
PARAMETERS.wait_frames = 1;


%% Screen details
% horizontal dimension of viewable screen (cm)
PARAMETERS.mon_width = 21.5;
% viewing distance (cm)
PARAMETERS.view_dist = 30;


%% Engine parameters
% Screen used to display
PARAMETERS.screen = max(Screen('Screens'));
% Resolution [width height refresh_rate]
PARAMETERS.resolution = [800 600 60];
% Size of font
PARAMETERS.font_size = 40;
% Font to use
PARAMETERS.font_name = 'Comic Sans MS';
% Print the aperture texture for pRF
PARAMETERS.screen_capture = true;
% Print the screen to make a GIF of the experiment
PARAMETERS.print_gif = false;


%% Scanner parameters
% Seconds per volume
PARAMETERS.TR = 1;
% Dummy volumes
PARAMETERS.dummies = 0;
PARAMETERS.overrun = 0;


%% Eyetracker parameters
% do we use an eyetracker ?
PARAMETERS.eyetracker.do = false;

PARAMETERS.eyetracker.host = '10.41.111.213';  % SMI machine ip: '10.41.111.213'
PARAMETERS.eyetracker.port = 4444;
PARAMETERS.eyetracker.window = 1;


%% Compute some more parameters

addpath(fullfile(fileparts(mfilename('fullpath')), 'subfun'))
addpath(fullfile(fileparts(mfilename('fullpath')), 'subfun', 'diy'))

PARAMETERS.aperture.cycle_duration = PARAMETERS.TR * PARAMETERS.aperture.vols_per_cycle;

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