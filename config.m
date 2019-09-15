function cfg = config()

% DOTS DETAILS
% dots per degree^2
cfg.dot_density = .5;
% max dot speed (deg/sec)
cfg.dot_speed   = 10;
% width of dot (deg)
cfg.dot_w = .5;
% fraction of dots to kill each frame (limited lifetime)
cfg.fraction_kill = 0.1;
% Amount of coherence
cfg.coherence = 1;
% 0 gives right, 90 gives down, 180 gives left and 270 up.
cfg.angle_motion = 270;

% ANIMATIONS DETAILS
% proportion of screeen height occupied by the RDK
cfg.matrix_size = .99;
% number of animation frames in loop
cfg.n_frames = 7200;
% Show new dot-images at each waitframes'th monitor refresh
cfg.wait_frames = 1;

% SCREEN DETAILS
% horizontal dimension of viewable screen (cm)
cfg.mon_width = 39;
% viewing distance (cm)
cfg.view_dist = 60;

% aperture width in deg VA
cfg.aperture_width = 4;

end