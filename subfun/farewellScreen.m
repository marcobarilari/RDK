function farewellScreen(win, PARAMETERS, rect)
Screen('FillRect', win, PARAMETERS.black, rect);
DrawFormattedText(win, 'Thank you!', 'center', 'center', PARAMETERS.white); 
Screen('Flip', win);
WaitSecs(PARAMETERS.TR * PARAMETERS.overrun);
end