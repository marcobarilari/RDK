function [TARGET] = drawTarget(TARGET, events, CURRENT, win, rect, PARAMETERS)

is_event = false;

TARGET.onset = false;
TARGET.offset = false;

was_event = TARGET.was_event;
event_size_pix = TARGET.event_size_pix;

% check that the current time is superior to the start time and inferior to the end time of at
% least one event
curr_events = events - CURRENT.time;
if  any( all( [curr_events > 0 , curr_events < PARAMETERS.event_duration], 2 ) )
    is_event = true;
end

if is_event
  
    % flicker the fixation dot
    X = 0;
    Y = 0;

    % actual target position in pixel
    X = rect(3)/2-X;
    Y = rect(4)/2-Y;

    % Draw event
    Screen('FillOval', win, ...
        PARAMETERS.event_color,...
        [X-event_size_pix/2 ...
        Y-event_size_pix/2 ...
        X+event_size_pix/2 ...
        Y+event_size_pix/2]);
    
else
    
    if was_event
        TARGET.offfset = true;
    end
    was_event = false;
    
end

TARGET.is_event = is_event;
TARGET.was_event = was_event;

end