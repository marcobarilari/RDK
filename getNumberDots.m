function nDots = getNumberDots(dot_w, matrix_size, dot_density, ppd)
% Number of dots : surface of the RDK disc / surface of one dot * density of dots
% matrix_size
    nDots = ceil(pi * (matrix_size/2/ppd)^2 / (pi * (dot_w/2)^2 ) * dot_density);
    if nDots<10
        nDots=10;
    end
end