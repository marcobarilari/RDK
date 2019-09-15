function [xy] = dotsROut(xy, matrix_size)
r_out  = xy(:,5) > matrix_size/2;
% If there are we reset them at a diametrically opposite position
if any(r_out)
    %             xy(r_out,1:2) = xy(r_out,1:2) * -1;
    
    X = getX(sum(r_out), matrix_size);
    Y = getY(sum(r_out), matrix_size, X);
    
    xy(r_out,1) =  X;
    xy(r_out,2) =  Y;

    
end
end