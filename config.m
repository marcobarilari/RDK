function cfg = config()

%% DOTS DETAILS
% dots per degree^2
cfg.dot_density = .15;
% max dot speed (deg/sec)
cfg.dot_speed   = 10;
% width of dot (deg)
cfg.dot_w = .5;
% fraction of dots to kill each frame (limited lifetime)
cfg.fraction_kill = 0.05;
% Amount of coherence
cfg.coherence = 1;
% starting motion direction: 0 gives right, 90 gives down, 180 gives left and 270 up.
cfg.angle_motion = 0;
% speed rotation of motion direction in degrees per second
cfg.spd_rot_mot_sec = 0;


%% MOVING APERTURE
cfg.aperture_style = 'none';
% cfg.aperture_style = 'annulus';
% cfg.aperture_style = 'bar';
% cfg.aperture_style = 'wedge';


%% FIXATION CROSS
cfg.fix_cross_size_VA = .5;    % fixation cross in visual angles
cfg.fix_cross_lineWidth_VA = 0.1;
cfg.fix_cross_xDisp = 0;
cfg.fix_cross_yDisp = 0;


%% ANIMATION DETAILS
% proportion of screeen height occupied by the RDK
cfg.matrix_size = .9;
% number of animation frames in loop
cfg.n_frames = 7200;
% Show new dot-images at each waitframes'th monitor refresh
cfg.wait_frames = 1;


%% SCREEN DETAILS
% horizontal dimension of viewable screen (cm)
cfg.mon_width = 39;
% viewing distance (cm)
cfg.view_dist = 60;



switch cfg.aperture_style
    case 'none'
        cfg.aperture_width = NaN;
        cfg.aperture_speed_VA = NaN;
        cfg.aperture_mot_dir = NaN;
        
    case 'bar'
        % aperture width in deg VA 
        cfg.aperture_width = 3;
        % aperture speed in deg VA / sec 
        cfg.aperture_speed_VA = -1;
        % aperture motion direction
        cfg.aperture_mot_dir = 0;
            
    case 'annulus'
        % aperture width in deg VA (bar or annulus)
        cfg.aperture_width = 3;
        % aperture speed in deg VA / sec 
        cfg.aperture_speed_VA = -1;
        
        cfg.aperture_mot_dir = NaN;
        
    case 'wedge'
        % aperture width in deg (wedge)
        cfg.aperture_width = 60;
        % aperture speed in deg / sec (wedge)
        cfg.aperture_speed_VA = 10;

        cfg.aperture_mot_dir = NaN;
end


end