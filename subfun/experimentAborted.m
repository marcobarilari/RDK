function QUIT = experimentAborted(Key, KeyCodes, Win, PARAMETERS, Rect)

QUIT = false;

if Key(KeyCodes.Escape)
    % Abort screen
    Screen('FillRect', Win, PARAMETERS.black, Rect);
    DrawFormattedText(Win, 'Experiment was aborted!', 'center', 'center', ...
        PARAMETERS.white);
    CleanUp
    disp(' ');
    disp('Experiment aborted by user!');
    disp(' ');
    QUIT = true;
    return
end

end