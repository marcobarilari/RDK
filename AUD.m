function AUD(subj, direction, emulate, debug)

% Play auditory motion 

if nargin == 0
    subj = 66;
    run = 1;
    aperture_style = 'none';
    direction = '-';
    emulate = true;
    debug = true;
end

addpath(fullfile(fileparts(mfilename('fullpath'))), 'subfun_AUD')
addpath(fullfile(fileparts(mfilename('fullpath'))), 'input')

task = 'AUD';

PARAMETERS = config(subj, run, task, aperture_style, direction);

%% Initialize variables
prev_keypr = 0;

BEHAVIOUR.response = [];
BEHAVIOUR.responseTime = [];

TARGET.was_event = false;

target_data = [];

CURRENT.Frame = 0;
CURRENT.Stim = 1;
CURRENT.angle_motion = PARAMETERS.angle_motion;

%% Setup
SetUpRand

PARAMETERS = eyeTrack(PARAMETERS, 'init');

% Event timings
% Events is a vector that says when (in seconds from the start of the
% experiment) a target should be presented.
events = createEventsTiming(PARAMETERS);

[trig_str, PARAMETERS] = configScanner(emulate, PARAMETERS);

% function AUD_parameters =  
% 
% end
% 
% 
% function AUD_design = getAudDesign
% 
% 
% 
% end

end