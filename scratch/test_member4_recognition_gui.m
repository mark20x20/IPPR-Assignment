clc;
clear;
close all;

scriptPath = mfilename('fullpath');
scriptDir = fileparts(scriptPath);
projectRoot = fileparts(scriptDir);

addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
paths = ensureOutputFolders();
fprintf('Official recognition debug root: %s\n', paths.recognitionDebugRoot);

fprintf('=== OCR Environment Diagnostics ===\n');
fprintf('MATLAB version: %s\n', version);
ocrWhich = which('ocr');
if isempty(ocrWhich)
    ocrWhich = 'NOT_FOUND';
end
fprintf('which(''ocr''): %s\n', ocrWhich);
fprintf('exist(''ocr'',''file''): %d\n', exist('ocr', 'file'));

cvInstalled = false;
try
    v = ver;
    names = string({v.Name});
    cvInstalled = any(contains(lower(names), 'computer vision toolbox'));
catch
    cvInstalled = false;
end
fprintf('Computer Vision Toolbox detected: %s\n', string(cvInstalled));
if exist('ocr', 'file') ~= 2
    fprintf(2, 'OCR availability warning: ocr() not found in this environment.\n');
end

syntheticResult = "";
syntheticError = "";
try
    synthImg = uint8(255 * ones(180, 700));
    synthImg = insertText(synthImg, [40 50], 'JRD6561', 'FontSize', 72, ...
        'BoxOpacity', 0, 'TextColor', 'black');
    synthGray = rgb2gray(synthImg);

    try
        synthOcr = ocr(synthGray, 'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
    catch
        try
            synthOcr = ocr(synthGray, CharacterSet="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
        catch
            synthOcr = ocr(synthGray);
        end
    end

    syntheticResult = strtrim(string(synthOcr.Text));
    if strlength(syntheticResult) == 0
        syntheticResult = "<EMPTY>";
    end
catch synthErr
    syntheticError = string(synthErr.identifier) + ": " + string(synthErr.message);
end

fprintf('Synthetic OCR result: %s\n', string(syntheticResult));
if strlength(syntheticError) > 0
    fprintf(2, 'Synthetic OCR error: %s\n', syntheticError);
end
fprintf('=== End OCR Environment Diagnostics ===\n\n');

sampleDir = fullfile(projectRoot, 'images', 'test', 'plate_samples');
if ~isfolder(sampleDir)
    fprintf('No plate sample folder found: %s\n', sampleDir);
    return;
end

imageFiles = [dir(fullfile(sampleDir, '*.jpg')); dir(fullfile(sampleDir, '*.jpeg')); dir(fullfile(sampleDir, '*.png')); dir(fullfile(sampleDir, '*.bmp'))];

if isempty(imageFiles)
    fprintf('No plate samples found. Please add cropped plate images for Member 4 testing.\n');
    return;
end

fprintf('Running Member 4 recognition test on %d sample(s).\n', numel(imageFiles));

for i = 1:numel(imageFiles)
    imgPath = fullfile(imageFiles(i).folder, imageFiles(i).name);

    try
        plateImg = imread(imgPath);
    catch readErr
        fprintf(2, '[M4 TEST] Failed to read %s: %s\n', imageFiles(i).name, readErr.message);
        continue;
    end

    try
        [rawText, ocrDebug] = recognizePlateText(plateImg);
    catch recErr
        rawText = "UNKNOWN";
        ocrDebug = struct();
        ocrDebug.status = "ocr_call_failed";
        ocrDebug.selectedIndex = 0;
        ocrDebug.selectedCandidateName = "";
        ocrDebug.outputDir = "";
        ocrDebug.candidateNames = strings(0,1);
        ocrDebug.rawResults = strings(0,1);
        ocrDebug.cleanedResults = strings(0,1);
        ocrDebug.scores = [];
        ocrDebug.ocrErrorMessages = strings(0,1);
        fprintf(2, '[M4 TEST] OCR failed for %s: %s\n', imageFiles(i).name, recErr.message);
    end

    cleanedText = cleanRecognizedText(rawText);
    stateName = identifyState(cleanedText);

    fprintf('\n==============================\n');
    fprintf('[M4 TEST] Image: %s\n', imageFiles(i).name);
    fprintf('Debug output folder: %s\n', string(ocrDebug.outputDir));
    fprintf('Final Raw OCR: %s\n', string(rawText));
    fprintf('Final Cleaned: %s\n', string(cleanedText));
    fprintf('Final State: %s\n', string(stateName));
    fprintf('OCR Status: %s\n', string(localGetField(ocrDebug, 'status', "")));
    fprintf('Selected Candidate Index: %d\n', double(localGetField(ocrDebug, 'selectedIndex', 0)));
    fprintf('Selected Candidate Name: %s\n', string(localGetField(ocrDebug, 'selectedCandidateName', "")));

    candidateNames = string(localGetField(ocrDebug, 'candidateNames', strings(0,1)));
    rawResults = string(localGetField(ocrDebug, 'rawResults', strings(0,1)));
    cleanedResults = string(localGetField(ocrDebug, 'cleanedResults', strings(0,1)));
    errorResults = string(localGetField(ocrDebug, 'ocrErrorMessages', strings(0,1)));
    scores = localGetField(ocrDebug, 'scores', []);

    numRows = max([numel(candidateNames), numel(rawResults), numel(cleanedResults), numel(errorResults), numel(scores)]);
    if numRows > 0
        fprintf('OCR Candidates:\n');
        for k = 1:numRows
            nameValue = "";
            rawValue = "";
            cleanValue = "";
            errValue = "";
            scoreValue = NaN;

            if k <= numel(candidateNames), nameValue = candidateNames(k); end
            if k <= numel(rawResults), rawValue = rawResults(k); end
            if k <= numel(cleanedResults), cleanValue = cleanedResults(k); end
            if k <= numel(errorResults), errValue = errorResults(k); end
            if k <= numel(scores), scoreValue = scores(k); end

            fprintf('  [%d] %-40s | raw="%s" | cleaned="%s" | score=%.3f | error="%s"\n', ...
                k, char(nameValue), char(rawValue), char(cleanValue), scoreValue, char(errValue));
        end
    else
        fprintf('OCR Candidates: none\n');
    end

    localWriteSummary(ocrDebug, imageFiles(i).name, rawText, cleanedText, stateName, syntheticResult, syntheticError);
end

fprintf('\nMember 4 recognition test completed.\n');

function value = localGetField(s, fieldName, defaultValue)
    if isstruct(s) && isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end

function localWriteSummary(ocrDebug, imageName, rawText, cleanedText, stateName, syntheticResult, syntheticError)
    outputDir = string(localGetField(ocrDebug, 'outputDir', ""));
    if strlength(outputDir) == 0 || ~isfolder(outputDir)
        return;
    end

    selectedIndex = double(localGetField(ocrDebug, 'selectedIndex', 0));
    selectedName = string(localGetField(ocrDebug, 'selectedCandidateName', ""));
    status = string(localGetField(ocrDebug, 'status', ""));
    allUnknown = logical(localGetField(ocrDebug, 'allCandidatesUnknown', false));
    imagePaths = string(localGetField(ocrDebug, 'candidateImagePaths', strings(0,1)));

    savedCount = 0;
    for i = 1:numel(imagePaths)
        if strlength(imagePaths(i)) > 0 && isfile(imagePaths(i))
            savedCount = savedCount + 1;
        end
    end

    summaryPath = fullfile(char(outputDir), 'summary.txt');
    fid = fopen(summaryPath, 'w');
    if fid < 0
        return;
    end

    fprintf(fid, 'output_dir=%s\n', char(outputDir));
    fprintf(fid, 'input_image_name=%s\n', imageName);
    fprintf(fid, 'final_raw_ocr=%s\n', char(string(rawText)));
    fprintf(fid, 'final_cleaned_text=%s\n', char(string(cleanedText)));
    fprintf(fid, 'final_state=%s\n', char(string(stateName)));
    fprintf(fid, 'ocr_status=%s\n', char(status));
    fprintf(fid, 'selected_candidate_index=%d\n', selectedIndex);
    fprintf(fid, 'selected_candidate_name=%s\n', char(selectedName));
    fprintf(fid, 'all_candidates_unknown=%s\n', char(string(allUnknown)));
    fprintf(fid, 'synthetic_ocr_test_result=%s\n', char(string(syntheticResult)));
    fprintf(fid, 'synthetic_ocr_error=%s\n', char(string(syntheticError)));
    fprintf(fid, 'saved_candidate_image_count=%d\n', savedCount);

    fclose(fid);
end
