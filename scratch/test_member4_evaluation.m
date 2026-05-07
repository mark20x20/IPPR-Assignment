clc;
clear;
close all;

scriptPath = mfilename('fullpath');
scriptDir = fileparts(scriptPath);
projectRoot = fileparts(scriptDir);

addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));

paths = ensureOutputFolders();
csvPath = paths.evaluationCsv;

samples = {
    fullfile(projectRoot, 'images', 'test', 'plate_samples', 'plate_kl_01.jpg'), 'VAS1532', 'Selangor', 'plate_sample';
    fullfile(projectRoot, 'images', 'test', 'plate_samples', 'candidate_crop_rank_01.png'), 'JRD6561', 'Johor', 'plate_sample';
    fullfile(projectRoot, 'images', 'test', 'plate_samples', 'plate_selangor_01.jpg'), 'VLV2121', 'Selangor', 'plate_sample';
    fullfile(projectRoot, 'images', 'test', 'plate_samples', 'sample1.png'), 'JRD6561', 'Johor', 'plate_sample';
};

allRows = table();

fprintf('[M4 EVAL] Running %d sample(s).\n', size(samples, 1));
for i = 1:size(samples, 1)
    imagePath = samples{i, 1};
    expectedText = samples{i, 2};
    expectedState = samples{i, 3};
    vehicleType = samples{i, 4};

    row = evaluateSingleImage(imagePath, expectedText, expectedState, vehicleType);
    saveResultRow(row, csvPath);
    allRows = [allRows; row];

    fprintf('[M4 EVAL] %s | OCR=%s | State=%s | Overall=%s\n', ...
        row.image_name, row.ocr_result, row.state_result, row.overall_result);
end

successCount = sum(allRows.overall_result == "Success");
partialCount = sum(allRows.overall_result == "Partial Success");
failureCount = sum(allRows.overall_result == "Failure");
ocrExactCount = sum(allRows.ocr_result == "Correct");
stateCorrectCount = sum(allRows.state_result == "Correct");

fprintf('\n[M4 EVAL] Summary\n');
fprintf('  Success: %d\n', successCount);
fprintf('  Partial Success: %d\n', partialCount);
fprintf('  Failure: %d\n', failureCount);
fprintf('  OCR Exact Match: %d\n', ocrExactCount);
fprintf('  State Correct: %d\n', stateCorrectCount);
fprintf('  CSV: %s\n', csvPath);
fprintf('  Report Tables Root: %s\n', paths.reportTables);
