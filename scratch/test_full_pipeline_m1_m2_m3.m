% test_full_pipeline_m1_m2_m3.m
% Integration test for Member 1, Member 2, and Member 3 modules.

clc;
clear;
close all;

% Resolve project root from script location.
scriptPath = mfilename('fullpath');
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);

% Add project source folders.
addpath(genpath(fullfile(projectRoot, 'src')));

fprintf('=== Full Pipeline Test (M1 -> M2 -> M3) Started ===\n');

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
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);
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

% 4) Member 3 segmentation (only when plate exists)
characterImages = {};
characterBBoxes = [];
if plateFound && ~isempty(plateImg)
    [characterImages, characterBBoxes] = segmentCharacters(plateImg);
else
    fprintf('Segmentation skipped: no valid plate detected.\n');
end
fprintf('Member 3 character candidate count: %d\n', numel(characterImages));

% 5) Summary figure
fig = figure('Name', 'Full Pipeline M1-M2-M3', 'NumberTitle', 'off', 'Color', 'w');

subplot(2, 3, 1);
imshow(originalImg);
title('1. Original Image', 'FontWeight', 'bold');

subplot(2, 3, 2);
if ~isempty(preprocessedImg)
    imshow(preprocessedImg, []);
else
    imshow(zeros(20, 20, 'uint8'));
end
title('2. Preprocessed Image', 'FontWeight', 'bold');

subplot(2, 3, 3);
imshow(originalImg);
title('3. Detection Overlay', 'FontWeight', 'bold');
if isValidBBox
    hold on;
    rectangle('Position', plateBBox, 'EdgeColor', 'r', 'LineWidth', 2);
    hold off;
end

subplot(2, 3, 4);
if ~isempty(plateImg)
    imshow(plateImg, []);
    title('4. Detected Plate', 'FontWeight', 'bold');
else
    axis off;
    text(0.5, 0.5, 'No plate detected', ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    title('4. Detected Plate', 'FontWeight', 'bold');
end

subplot(2, 3, 5);
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
    text(0.5, 0.5, 'Segmentation skipped', ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    title('5. Character Boxes', 'FontWeight', 'bold');
end

subplot(2, 3, 6);
axis off;
if isValidBBox
    bboxText = sprintf('[%.0f %.0f %.0f %.0f]', plateBBox);
else
    bboxText = 'N/A';
end
summaryText = sprintf([ ...
    'Plate found: %s\n', ...
    'BBox: %s\n', ...
    'Character candidates: %d\n', ...
    'Detection status: %s'], ...
    string(plateFound), bboxText, numel(characterImages), char(detectionStatusText));
text(0.01, 0.8, summaryText, 'VerticalAlignment', 'top', 'FontSize', 10);
title('6. Summary', 'FontWeight', 'bold');

sgtitle('Full Pipeline Integration: Member 1 -> Member 2 -> Member 3', ...
    'FontWeight', 'bold');

% Save optional evidence figure.
outputFolder = fullfile(projectRoot, 'output', 'figures', 'full_pipeline_m1_m2_m3');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
outputFigurePath = fullfile(outputFolder, 'full_pipeline_m1_m2_m3_result.png');
saveas(fig, outputFigurePath);
fprintf('Evidence figure saved: %s\n', outputFigurePath);

fprintf('=== Full Pipeline Test (M1 -> M2 -> M3) Finished ===\n');
