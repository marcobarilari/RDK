function ppd = getPPD(rect, PARAMETERS)

% horizontal dimension of viewable screen (cm)
mon_width = PARAMETERS.mon_width;
% viewing distance (cm)
view_dist = PARAMETERS.view_dist;

ppd = pi * (rect(3)-rect(1)) / atan(mon_width/view_dist/2) / 360;
end