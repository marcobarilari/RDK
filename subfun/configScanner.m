function [trig_str, PARAMETERS] = configScanner(emulate, PARAMETERS)
if emulate
    % Emulate scanner
    trig_str = 'Press key to start...';
    % In manual start there are no dummies
    PARAMETERS.dummies = 0;
    PARAMETERS.overrun = 0;
else
    % Real scanner
    trig_str = 'Stand by for scan...';
end
end