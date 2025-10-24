% scripts/build_inputs_assi_flash.m
% Create and save canonical input signals (timetable/timeseries) for tests.
% Example:
% Ts = 0.001; t = (0:Ts:1.0)';
% btn = zeros(size(t)); btn(t >= 0.10) = 1;  % single rising edge at 0.10 s
% btn_B3 = timetable(seconds(t), btn, 'VariableNames', 'btn');
% save('tests/assi_flash/inputs/single_press.mat','btn_B3');
disp('Add code to generate test input signals here.');
