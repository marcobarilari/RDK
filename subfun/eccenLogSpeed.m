function [CURRENT] = eccenLogSpeed(PARAMETERS, CURRENT)
%vary CurrScale so that expansion speed is log over eccentricity
% cf. Tootell 1997; Swisher 2007; Warnking 2002 etc

cycle_duration = PARAMETERS.aperture.cycle_duration;

cs_func_fact = PARAMETERS.ring.cs_func_fact;

max_ecc = PARAMETERS.ring.max_ecc;

switch PARAMETERS.aperture.direction
    case '+'
        % current visual angle linear in time
        outer_scale_VA = 0 + mod(CURRENT.time, cycle_duration)/cycle_duration * max_ecc;
        % ensure some foveal stimulation at beginning (which is hidden by fixation cross otherwise)
        if outer_scale_VA < PARAMETERS.fixation_size
            outer_scale_VA = PARAMETERS.fixation_size * 2.1;
        end
    case '-'
        outer_scale_VA = max_ecc - mod(CURRENT.time, cycle_duration)/cycle_duration * max_ecc;
        if outer_scale_VA > max_ecc
            outer_scale_VA = max_ecc;
        end
end

% near-exp visual angle
outer_scale_VA2 = ((outer_scale_VA+exp(1)) * log(outer_scale_VA+exp(1)) - (outer_scale_VA+exp(1))) * max_ecc * cs_func_fact;
outer_scale_pix = outer_scale_VA2 * PARAMETERS.ppd; % in pixel

%width of apperture changes logarithmically with eccentricity of inner ring
old_inner_scale_VA = outer_scale_VA - PARAMETERS.aperture.width;
if old_inner_scale_VA < (PARAMETERS.fixation_size * 2)
    old_inner_scale_VA = PARAMETERS.fixation_size * 2;
end

% growing with inner ring ecc
ring_width_VA = PARAMETERS.aperture.width + log(old_inner_scale_VA+1);
inner_scale_VA = outer_scale_VA2 - ring_width_VA;

if inner_scale_VA < 0
    inner_scale_VA = 0;
end

inner_scale_pix =  inner_scale_VA * PARAMETERS.ppd; % in pixel


CURRENT.ring.outer_scale_pix = outer_scale_pix;
CURRENT.ring.inner_scale_pix = inner_scale_pix;
CURRENT.ring.outer_scale_VA2 = outer_scale_VA2;
CURRENT.ring.inner_scale_VA = inner_scale_VA;


end