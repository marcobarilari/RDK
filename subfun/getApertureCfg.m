function aperture_cfg = getApertureCfg(PARAMETERS, matrix_size)

ppd = PARAMETERS.ppd;
ifi = PARAMETERS.ifi;

aperture_style = PARAMETERS.aperture_style;
% aperture width in pixels
aperture_width = PARAMETERS.aperture_width * ppd;
% aperture speed in pixel per fram
aperture_speed_ppf = PARAMETERS.aperture_speed_VA * ifi;

switch aperture_style
    
    case 'none'
        
        aperture_cfg = [0 0];
        
    case 'wedge'

        % define inner and outer radius of annulus aperture
        if aperture_speed_ppf > 0
            aperture_cfg = [-.95 .05] * aperture_width;
        else
            aperture_cfg = [.95* aperture_width 360-.05* aperture_width] ;
        end
        
    case 'bar'
        
        if aperture_speed_ppf > 0
            aperture_cfg = [matrix_size*-.4-aperture_width matrix_size*-.4];
        else
            aperture_cfg = [matrix_size*.45 matrix_size*.45+aperture_width];
        end
        
    case 'annulus'
        
        % define inner and outer radius of annulus aperture
        aperture_cfg = [matrix_size*.45 matrix_size*.45+aperture_width];
        
end

end