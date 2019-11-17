function events = createEventsTiming(PARAMETERS)
% e = PARAMETERS.TR : PARAMETERS.event_duration : (PARAMETERS.CyclesPerExpmt * PARAMETERS.VolsPerCycle * PARAMETERS.TR);
e = PARAMETERS.TR : PARAMETERS.event_duration : 100;
tmp = rand(length(e),1);
events = e(tmp < PARAMETERS.prob_of_event)';

% remove events that are less than 1.5 seconds appart
events( find(diff(events)<1)+1 ) = [];
end