function [aperture_texture, CURRENT] = getApertureCfg(PARAMETERS, CURRENT, aperture_texture, matrix_size, rect)

style = PARAMETERS.aperture.style;

cycle_duration = PARAMETERS.aperture.cycle_duration;

switch style
    
    case 'none'
        
        Screen('FillOval', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(matrix_size,1,2)], rect(3)/2, rect(4)/2 ));
               
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
            CenterRectOnPoint([0 0 repmat(matrix_size,1,2)], rect(3)/2, rect(4)/2 ),...
            CURRENT.angle, PARAMETERS.aperture.width);

    case 'bar'
        
        
    case 'ring'
        
        CURRENT = eccenLogSpeed(PARAMETERS, CURRENT);
        
        Screen('FillOval', aperture_texture, [0 0 0 0], ...
            CenterRectOnPoint([0 0 repmat(CURRENT.ring.outer_scale_pix,1,2)], rect(3)/2, rect(4)/2 ));
        
        Screen('FillOval', aperture_texture, [repmat(PARAMETERS.gray, [1,3]) 255], ...
            CenterRectOnPoint([0 0 repmat(CURRENT.ring.inner_scale_pix,1,2)], rect(3)/2, rect(4)/2 ));
        
        
end

end