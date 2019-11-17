function FOV = getFOV(PARAMETERS)

% horizontal dimension of viewable screen (cm)
mon_width = PARAMETERS.mon_width;
% viewing distance (cm)
view_dist = PARAMETERS.view_dist;

% left-to-right angle of visual field in scanner in degree
FOV = 2* atan( mon_width / 2 / view_dist) * 180/pi; 
end