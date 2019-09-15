function xy = dotsReseed(nDots, fraction_kill, matrix_size, xy)
r_reseed = rand(nDots,1) < fraction_kill;
if any(r_reseed)
    X = getX(sum(r_reseed), matrix_size);
    Y = getY(sum(r_reseed), matrix_size, X);
    
    xy(r_reseed,1) =  X;
    xy(r_reseed,2) =  Y;
    
end
end