function PARAMETERS = eyeTrack(PARAMETERS, action)

if PARAMETERS.eyetracker.do == 1
    
    switch action
        
        % initialize iView eye tracker
        case 'init'
            
            PARAMETERS.ivx = [];
            
            host = PARAMETERS.eyetracker.host;
            port = PARAMETERS.eyetracker.port;
            window = PARAMETERS.eyetracker.window;
            
            ivx = iviewxinitdefaults2(window, 9,[], host, port);
            ivx.backgroundColour = 0;
            [~, ivx] = iViewX('openconnection', ivx);
            [success, PARAMETERS.ivx] = iViewX('checkconnection', ivx);
            if success ~= 1
                error('connection to eye tracker failed');
            end
            
            PARAMETERS.ivx = ivx;
            
        % start iView eye tracker
        case 'start'
            
            ivx = PARAMETERS.ivx;
            
            % to clear data buffer
            iViewX('clearbuffer', ivx);
            % start recording
            iViewX('startrecording', ivx);
            iViewX('message', ivx, ...
                [...
                'Start_Ret_', ...
                sprintf('%s_%s_%s', ...
                PARAMETERS.subj, ...
                PARAMETERS.task, ...
                PARAMETERS.run)]);
            iViewX('incrementsetnumber', ivx, 0);
            
        % stop tracker
        case 'stop'
            
            ivx = PARAMETERS.ivx;
            
            iViewX('stoprecording', ivx);
            
            % save data file
            strFile = [PARAMETERS.output_filename, '_eyetrack.idf'];
            iViewX('datafile', ivx, strFile);
            
            %close iView connection
            iViewX('closeconnection', ivx);
            
    end
    
end