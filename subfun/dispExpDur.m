function dispExpDur(end_expmt, start_expmt)
disp(' ');
expmt_dur = end_expmt - start_expmt;
expmt_dur_min = floor(expmt_dur/60);
expmt_dur_sec = mod(expmt_dur, 60);
disp(['Experiment lasted ' n2s(expmt_dur_min) ' minutes, ' n2s(expmt_dur_sec) ' seconds']);
disp(' ');
end