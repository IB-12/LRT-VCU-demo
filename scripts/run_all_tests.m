function run_all_tests()
%RUN_ALL_TESTS Run all Simulink Test Manager suites headlessly.
%   This script discovers Simulink Test Manager files (.mldatx) under the
%   tests directory, executes them using the Test Manager API, emits a
%   readable console summary, and generates detailed PDF reports. The
%   function throws an error when any test does not pass so that automated
%   pipelines fail fast with clear messaging.
%
%   The script is intended to be executed from the repository root:
%       >> addpath('scripts');
%       >> run_all_tests
%
%   Outputs are written to the "test-results" folder so that CI pipelines
%   can upload them as artifacts.

% Ensure Simulink Test Manager starts from a clean state.
sltest.testmanager.clear;
sltest.testmanager.clearResults;
sltest.testmanager.close;

repoRoot = fileparts(mfilename('fullpath'));
repoRoot = fileparts(repoRoot); % move from scripts/ to repo root

% Discover all Simulink Test Manager files.
testRoot = fullfile(repoRoot, 'tests');
if ~isfolder(testRoot)
    error('run_all_tests:MissingTestsFolder', ...
        'Expected tests folder "%s" does not exist.', testRoot);
end

testFiles = dir(fullfile(testRoot, '**', '*.mldatx'));
if isempty(testFiles)
    error('run_all_tests:NoTestsFound', ...
        'No Simulink Test Manager files (.mldatx) were found under "%s".', testRoot);
end

reportsDir = fullfile(repoRoot, 'test-results');
if ~isfolder(reportsDir)
    mkdir(reportsDir);
else
    existingReports = dir(fullfile(reportsDir, '*.pdf'));
    if ~isempty(existingReports)
        delete(fullfile(reportsDir, '*.pdf'));
    end
end

fprintf('Discovered %d Simulink Test Manager file(s).\n', numel(testFiles));

allPassed = true;
failedSummaries = {};

for idx = 1:numel(testFiles)
    testFilePath = fullfile(testFiles(idx).folder, testFiles(idx).name);
    relPath = strrep(testFilePath, [repoRoot filesep], '');
    fprintf('\n=== Running Simulink tests: %s ===\n', relPath);

    % Reload in a clean session for repeatability.
    sltest.testmanager.clear;
    sltest.testmanager.clearResults;

    testFile = sltest.testmanager.load(testFilePath);
    resultSet = sltest.testmanager.run(testFile);

    % Summarise individual results for console visibility.
    results = resultSet.Results;
    if isempty(results)
        warning('run_all_tests:NoResultsReturned', ...
            'No individual test results returned for %s.', relPath);
    end

    for rIdx = 1:numel(results)
        result = results(rIdx);
        outcome = char(result.Outcome);
        fprintf('  - %s: %s\n', result.Name, outcome);
        if result.Outcome ~= sltest.testmanager.TestResultOutcomes.Passed
            allPassed = false;
            failedSummaries{end + 1} = sprintf('%s — %s', result.Name, outcome); %#ok<AGROW>
        end
    end

    % Generate a timestamped PDF report for archival/debugging.
    timestamp = datestr(datetime('now'), 'yyyymmdd_HHMMSS');
    [~, baseName] = fileparts(testFiles(idx).name);
    reportName = sprintf('%s_%s.pdf', baseName, timestamp);
    reportPath = fullfile(reportsDir, reportName);
    sltest.testmanager.Report(resultSet, reportPath, ...
        'IncludeComparisonSignalPlots', true, ...
        'IncludeTestCaseSummary', true, ...
        'LaunchReport', false);
    relReportPath = strrep(reportPath, [repoRoot filesep], '');
    fprintf('Saved detailed report to %s\n', relReportPath);

    % Close the loaded test file to avoid state leakage between iterations.
    sltest.testmanager.close;
end

if allPassed
    fprintf('\nAll Simulink tests passed successfully.\n');
else
    failureText = strjoin(failedSummaries, newline);
    error('run_all_tests:TestsFailed', ...
        'One or more Simulink tests failed:%s%s', newline, failureText);
end
end
