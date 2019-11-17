function [win, rect, old_res, ifi, PARAMETERS] = initPTB(PARAMETERS, debug)

AssertOpenGL;


if debug
    PsychDebugWindowConfiguration
else
    Screen('Preference', 'SkipSyncTests', 1) %#ok<*UNRCH>
    old_enable_flag = Screen('Preference', 'SuppressAllWarnings', 1);
end

screen_id = PARAMETERS.screen;

no_screens = length(Screen('Screens'));
if ismac && no_screens > 1 % only if projector is also a screen
    old_res = Screen('Resolution', screen_id, ...
    PARAMETERS.resolution(1), PARAMETERS.resolution(2), PARAMETERS.resolution(3));
end

[win, rect] = Screen('OpenWindow', PARAMETERS.screen, [127 127 127], [], 32, 2);
Screen('TextFont', win, PARAMETERS.font_name);
Screen('TextSize', win, PARAMETERS.font_size);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Get color index for that screen
PARAMETERS.black = BlackIndex(win);
PARAMETERS.white = WhiteIndex(win);
PARAMETERS.gray = (BlackIndex(win) + WhiteIndex(win))/ 2;

% interframe interval
ifi = Screen('GetFlipInterval', win);

end