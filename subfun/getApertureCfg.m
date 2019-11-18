function [aperture_texture, CURRENT] = getApertureCfg(PARAMETERS, CURRENT, aperture_texture, matrix_size, rect)

ppd = PARAMETERS.ppd;
ifi = PARAMETERS.ifi;

aperture_style = PARAMETERS.aperture_style;

% aperture width in pixels
aperture_width = PARAMETERS.aperture_width * ppd;

% aperture speed in pixel per fram
aperture_speed_ppf = PARAMETERS.aperture_speed_VA * ifi;

switch aperture_style
    
    case 'none'
        
        Screen('FillOval', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(matrix_size,1,2)], rect(3)/2, rect(4)/2 ));
               
    case 'wedge'
        
        cycle_duration = PARAMETERS.TR * PARAMETERS.vols_per_cycle;
        
        CURRENT.angle = 90 - PARAMETERS.aperture_width/2;
        
        % Update angle for rotation of background and for apperture for wedge
        switch PARAMETERS.direction
            case '+'
                CURRENT.angle = CURRENT.angle + (CURRENT.time/cycle_duration) * 360;
            case '-'
                CURRENT.angle = CURRENT.angle - (CURRENT.time/cycle_duration) * 360;
        end
                
        Screen('FillArc', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(matrix_size,1,2)], rect(3)/2, rect(4)/2 ),...
            CURRENT.angle, PARAMETERS.aperture_width);

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