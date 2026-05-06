% test_full_pipeline_m1_m2_m3_m4.m
% Integration test for Member 1, Member 2, Member 3, and Member 4 modules.

clc;
clear;
close all;

% Resolve project root from script location.
scriptPath = mfilename('fullpath');
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);

% Add project source folders.
addpath(genpath(fullfile(projectRoot, 'src')));

fprintf('=== Full Pipeline Test (M1 -> M2 -> M3 -> M4) Started ===\n');

% Build sample image path.
imagePath = fullfile(projectRoot, 'images', 'test', 'sample_car.jpg');
fprintf('Image path: %s\n', imagePath);

if ~isfile(imagePath)
    error('Sample image not found: %s', imagePath);
end

% 1) Load test image
originalImg = imread(imagePath);
fprintf('Image size: %d x %d x %d\n', size(originalImg, 1), size(originalImg, 2), size(originalImg, 3));

% 2) Member 1 preprocessing
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg); %#ok<ASGLU>
if isstruct(preprocessDebug) && isfield(preprocessDebug, 'status')
    fprintf('Member 1 preprocessing status: %s\n', string(preprocessDebug.status));
else
    fprintf('Member 1 preprocessing status: (status not provided)\n');
end

% 3) Member 2 plate detection
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);

detectionStatusText = "(status not provided)";
if isstruct(detectionDebug) && isfield(detectionDebug, 'status')
    detectionStatusText = string(detectionDebug.status);
end
fprintf('Member 2 detection status: %s\n', detectionStatusText);

plateFound = ~isempty(plateImg);
if isstruct(detectionDebug) && isfield(detectionDebug, 'plateFound')
    plateFound = logical(detectionDebug.plateFound);
end

isValidBBox = isnumeric(plateBBox) && numel(plateBBox) == 4 && all(isfinite(plateBBox));
if isValidBBox
    fprintf('Plate bounding box: [%.0f %.0f %.0f %.0f]\n', plateBBox);
else
    fprintf('Plate bounding box: (not available)\n');
end
fprintf('Plate found: %s\n', string(plateFound));

% Default safe fallback values for Member 3 and Member 4.
characterImages = {};
characterBBoxes = [];
rawText = "UNKNOWN";
cleanedText = "UNKNOWN";
predictedState = "UNKNOWN";

% 4) Member 3 segmentation only when plate exists
if plateFound && ~isempty(plateImg)
    [characterImages, characterBBoxes] = segmentCharacters(plateImg);
else
    fprintf('Segmentation skipped: no valid plate detected.\n');
end
fprintf('Member 3 character candidate count: %d\n', numel(characterImages));

% 5) Member 4 recognition only when plate exists
if plateFound && ~isempty(plateImg)
    try
        rawTextLocal = recognizePlateText(plateImg);
        if ~isempty(rawTextLocal) && strlength(string(rawTextLocal)) > 0
            rawText = string(rawTextLocal);
            cleanedText = cleanRecognizedText(rawText);
            predictedState = identifyState(cleanedText);

            if strlength(cleanedText) == 0 || cleanedText == ""
                rawText = "UNKNOWN";
                cleanedText = "UNKNOWN";
                predictedState = "UNKNOWN";
            end
        end
    catch recogErr
        fprintf('Member 4 recognition error: %s\n', recogErr.message);
        rawText = "UNKNOWN";
        cleanedText = "UNKNOWN";
        predictedState = "UNKNOWN";
    end
else
    fprintf('OCR skipped: no valid plate detected.\n');
end

fprintf('Member 4 raw OCR text: %s\n', string(rawText));
fprintf('Member 4 cleaned OCR text: %s\n', string(cleanedText));
fprintf('Member 4 predicted state: %s\n', string(predictedState));

% Local integration summary table (safe fallback instead of forcing evaluation call).
bboxText = "N/A";
if isValidBBox
    bboxText = sprintf('[%.0f %.0f %.0f %.0f]', plateBBox);
end

integrationSummary = table( ...
    string(imagePath), ...
    logical(plateFound), ...
    string(bboxText), ...
    double(numel(characterImages)), ...
    string(rawText), ...
    string(cleanedText), ...
    string(predictedState), ...
    string(detectionStatusText), ...
    'VariableNames', {'image_name', 'plate_found', 'plate_bbox', 'character_count', ...
                      'raw_text', 'cleaned_text', 'predicted_state', 'detection_status'});

disp('--- Local Integration Summary ---');
disp(integrationSummary);

% 6) Summary figure
fig = figure('Name', 'Full Pipeline M1-M2-M3-M4', 'NumberTitle', 'off', 'Color', 'w');

subplot(2, 4, 1);
imshow(originalImg);
title('1. Original Image', 'FontWeight', 'bold');

subplot(2, 4, 2);
if ~isempty(preprocessedImg)
    imshow(preprocessedImg, []);
else
    imshow(zeros(20, 20, 'uint8'));
end
title('2. Preprocessed Image', 'FontWeight', 'bold');

subplot(2, 4, 3);
imshow(originalImg);
title('3. Detection Overlay', 'FontWeight', 'bold');
if isValidBBox
    hold on;
    rectangle('Position', plateBBox, 'EdgeColor', 'r', 'LineWidth', 2);
    hold off;
end

subplot(2, 4, 4);
if ~isempty(plateImg)
    imshow(plateImg, []);
    title('4. Detected Plate', 'FontWeight', 'bold');
else
    axis off;
    text(0.5, 0.5, 'No plate detected', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    title('4. Detected Plate', 'FontWeight', 'bold');
end

subplot(2, 4, 5);
if ~isempty(plateImg)
    imshow(plateImg, []);
    title('5. Character Boxes', 'FontWeight', 'bold');
    if isnumeric(characterBBoxes) && ~isempty(characterBBoxes) && size(characterBBoxes, 2) >= 4
        hold on;
        for i = 1:size(characterBBoxes, 1)
            rectangle('Position', characterBBoxes(i, :), 'EdgeColor', 'g', 'LineWidth', 2);
        end
        hold off;
    end
else
    axis off;
    text(0.5, 0.5, 'Segmentation skipped', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    title('5. Character Boxes', 'FontWeight', 'bold');
end

subplot(2, 4, 6);
axis off;
ocrText = sprintf(['Raw OCR: %s\n', ...
                   'Cleaned OCR: %s\n', ...
                   'Predicted State: %s'], ...
                   string(rawText), string(cleanedText), string(predictedState));
text(0.01, 0.95, ocrText, 'VerticalAlignment', 'top', 'FontSize', 10);
title('6. OCR / State Result', 'FontWeight', 'bold');

subplot(2, 4, 7);
if isstruct(detectionDebug) && isfield(detectionDebug, 'cleanedImg') && ~isempty(detectionDebug.cleanedImg)
    imshow(detectionDebug.cleanedImg);
    title('7. Detection Binary', 'FontWeight', 'bold');
else
    axis off;
    text(0.5, 0.5, 'No binary debug', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    title('7. Detection Binary', 'FontWeight', 'bold');
end

subplot(2, 4, 8);
axis off;
statusText = sprintf([ ...
    'Plate found: %s\n', ...
    'BBox: %s\n', ...
    'Character candidates: %d\n', ...
    'Raw OCR text: %s\n', ...
    'Cleaned OCR text: %s\n', ...
    'Predicted state: %s\n', ...
    'Detection status: %s'], ...
    string(plateFound), bboxText, numel(characterImages), ...
    string(rawText), string(cleanedText), string(predictedState), char(detectionStatusText));
text(0.01, 0.95, statusText, 'VerticalAlignment', 'top', 'FontSize', 10);
title('8. Pipeline Summary', 'FontWeight', 'bold');

sgtitle('Full Pipeline Integration: Member 1 -> Member 2 -> Member 3 -> Member 4', ...
    'FontWeight', 'bold');

% Save evidence figure.
outputFolder = fullfile(projectRoot, 'output', 'figures', 'full_pipeline_m1_m2_m3_m4');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
outputFigurePath = fullfile(outputFolder, 'full_pipeline_m1_m2_m3_m4_result.png');
saveas(fig, outputFigurePath);
fprintf('Evidence figure saved: %s\n', outputFigurePath);

fprintf('=== Full Pipeline Test (M1 -> M2 -> M3 -> M4) Finished ===\n');
