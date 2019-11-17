function [BEHAVIOUR, pre_keypr, QUIT] = getBehResp(keyCodes, win, PARAMETERS, rect, pre_keypr, BEHAVIOUR, start_expmt)

[Keypr, KeyTime, Key] = KbCheck;

QUIT = false;

if Keypr
    
    QUIT = experimentAborted(Key, keyCodes, win, PARAMETERS, rect);
    
    if ~pre_keypr
        pre_keypr = 1;
        if Key(keyCodes.Resp)
            keyNum = find(Key);
            % prevent that trigger+response or double response spoil Behaviour.Response dimensions!!
            keyNum = keyNum(1);
            BEHAVIOUR.Response = [BEHAVIOUR.response; keyNum];
            BEHAVIOUR.ResponseTime = [BEHAVIOUR.responseTime; KeyTime - start_expmt];
        end
    end
    
else
    if pre_keypr
        pre_keypr = 0;
    end
end
end