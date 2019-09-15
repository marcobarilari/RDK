function ppd = getPPD(rect, mon_width, view_dist)
ppd = pi * (rect(3)-rect(1)) / atan(mon_width/view_dist/2) / 360;
end