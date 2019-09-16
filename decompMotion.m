function [hor_vector, vert_vector] = decompMotion(angle_motion)
% decompose angle of start motion into horizontal and vertical vector
hor_vector = cos(pi*angle_motion/180);
vert_vector = sin(pi*angle_motion/180);
end