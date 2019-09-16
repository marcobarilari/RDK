function aperture_cfg = getApertureCfg(aperture_style, aperture_speed_ppf, aperture_width, matrix_size, fix_cross_size_pix)
    switch aperture_style
        case 'none'
            aperture_cfg = [0 0];
        case 'bar'
            if aperture_speed_ppf > 0
                aperture_cfg = [matrix_size*-.45-aperture_width matrix_size*-.45];
            else
                aperture_cfg = [matrix_size*.45 matrix_size*.45+aperture_width];
            end
        case 'annulus'
            % define inner and outer radius of annulus aperture
            if aperture_speed_ppf > 0
                aperture_cfg = [fix_cross_size_pix*3-aperture_width fix_cross_size_pix * 3];
            else
                aperture_cfg = [matrix_size*.45 matrix_size*.45+aperture_width];
            end
            
        case 'wedge'
            % define inner and outer radius of annulus aperture
            if aperture_speed_ppf > 0
                aperture_cfg = [-.95 .05] * aperture_width;
            else
                aperture_cfg = [.95 -.05] * aperture_width;
            end
    end
end