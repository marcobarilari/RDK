function r_aperture = dotsInAperture(xy, aperture_style, aperture_cgf, aperture_speed_ppf)

switch aperture_style
    case 'none'
        % we show all the dots
        r_aperture  = [];
    case 'bar'
        r_aperture  = [...
            xy(:,1)>aperture_cgf(1), ...
            xy(:,1)<aperture_cgf(2)];
    case 'annulus'
        r_aperture  = [...
            xy(:,5)>aperture_cgf(1), ...
            xy(:,5)<aperture_cgf(2)];
    case 'wedge'
        [a, r] = cart2pol(xy(:,1), xy(:,2) * -1); % the minus one is there because of the way PTB draws dots
        a = convPolAngle(a);
        if aperture_speed_ppf < 0
            r_aperture  = [...
                a > aperture_cgf(1), ...
                a < aperture_cgf(2)];
        else
            r_aperture  = [...
                a > aperture_cgf(1), ...
                a < aperture_cgf(2)];
        end
        
end


end