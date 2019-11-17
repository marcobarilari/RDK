function [X] = getX(nDots, matrix_size)
    % Gives random position to the dots in x and y
    X  =  rand(nDots,1) * matrix_size - matrix_size/2;
end