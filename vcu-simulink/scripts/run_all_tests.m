% scripts/run_all_tests.m
% If you use Simulink Test (Test Manager), point to your .mldatx test file and run headless:
% Example:
% sltest.testmanager.clear;
% tf = sltest.testmanager.load('tests/assi_flash/assi_flash_tests.mldatx');
% res = sltest.testmanager.run;
% assert(all([res.Results.Outcome] == sltest.testmanager.TestResultOutcomes.Passed), 'Some tests failed.');
disp('Add Simulink Test Manager headless run here once tests exist.');
