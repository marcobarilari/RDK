function [aperture_texture, CURRENT] = getApertureCfg(PARAMETERS, CURRENT, aperture_texture, matrix_size, rect)

style = PARAMETERS.aperture.style;

cycle_duration = PARAMETERS.aperture.cycle_duration;

CURRENT.apperture_angle = 90;

switch style
    
    case 'none'

        Screen('FillOval', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(matrix_size, 1, 2)], rect(3)/2, rect(4)/2 ));
               
    case 'wedge'

        CURRENT.angle = 90 - PARAMETERS.aperture.width/2;
        
        % Update angle for rotation of background and for apperture for wedge
        switch PARAMETERS.aperture.direction
            case '+'
                CURRENT.angle = CURRENT.angle + (CURRENT.time/cycle_duration) * 360;
            case '-'
                CURRENT.angle = CURRENT.angle - (CURRENT.time/cycle_duration) * 360;
        end
                
        Screen('FillArc', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(matrix_size, 1, 2)], rect(3)/2, rect(4)/2 ),...
            CURRENT.angle, PARAMETERS.aperture.width);

    case 'bar'
        
        CURRENT.position = PARAMETERS.aperture.bar_positions(CURRENT.volume);
        
        CURRENT.apperture_angle = PARAMETERS.aperture.direction(CURRENT.condition);
        
        % We let the stimulus through
        Screen('FillOval', aperture_texture, [0 0 0 0], CenterRect([0 0 repmat(matrix_size, 1, 2)], rect));
        
        % Then we add the position of the bar aperture
        Screen('FillRect', aperture_texture, PARAMETERS.gray, ...
            [0 0 CURRENT.position - PARAMETERS.aperture.bar_width_pix/2 rect(4)]);
        
        Screen('FillRect', aperture_texture, PARAMETERS.gray, ...
            [CURRENT.position + PARAMETERS.aperture.bar_width_pix/2 0 rect(3) rect(4)]);
        
        
    case 'ring'
        
        CURRENT = eccenLogSpeed(PARAMETERS, CURRENT);
        
        Screen('FillOval', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(CURRENT.ring.outer_scale_pix, 1, 2)], rect(3)/2, rect(4)/2 ));
        
        Screen('FillOval', aperture_texture, [repmat(PARAMETERS.gray, [1, 3]) 255], ...
            CenterRectOnPoint([0 0 repmat(CURRENT.ring.inner_scale_pix, 1, 2)], rect(3)/2, rect(4)/2 ));
        
        
end

end