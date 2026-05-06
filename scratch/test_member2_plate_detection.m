% test_member2_plate_detection.m
%
% Scratch test script — Member 2: License Plate Detection
%
% Tests the full Member 2 detection pipeline independently from the
% other team modules. Works even if Member 1's preprocessImage is not
% yet available (falls back to basic grayscale + imadjust).
%
% Run from the project root in MATLAB:
%   >> cd <project_root>
%   >> test_member2_plate_detection
%
% The script will:
%   1. Load a test image from images/test/sample_car.jpg
%   2. Optionally run Member 1 preprocessing if available
%   3. Run detectPlateRegion and all sub-functions
%   4. Display an 8-panel diagnostic figure
%   5. Print the candidate scoring table to the Command Window
%
% Author : Member 2

clc; clear; close all;
scriptPath = mfilename('fullpath');
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);
addpath(genpath(fullfile(projectRoot, 'src')));

% -------------------------------------------------------------------------
% 1. Load test image
% -------------------------------------------------------------------------
imagePath = fullfile(projectRoot, 'images', 'test', 'sample_car.jpg');

if ~isfile(imagePath)
    fprintf('[TEST M2] Test image not found: %s\n', imagePath);
    fprintf('[TEST M2] Add a vehicle image at images/test/sample_car.jpg and re-run.\n');
    return;
end

originalImg = imread(imagePath);
fprintf('[TEST M2] Image loaded: %s  [%d x %d x %d]\n', ...
    imagePath, size(originalImg, 1), size(originalImg, 2), size(originalImg, 3));

% -------------------------------------------------------------------------
% 2. Preprocessing — use Member 1 if available, else basic fallback
% -------------------------------------------------------------------------
if exist('preprocessImage', 'file') == 2
    [preprocessedImg, ~] = preprocessImage(originalImg);
    fprintf('[TEST M2] Used preprocessImage (Member 1).\n');
else
    fprintf('[TEST M2] preprocessImage not found — using basic fallback.\n');
    preprocessedImg = rgb2gray(originalImg);
    preprocessedImg = imadjust(preprocessedImg);
end

% -------------------------------------------------------------------------
% 3. Run Member 2 detection pipeline
% -------------------------------------------------------------------------
fprintf('[TEST M2] Running detectPlateRegion...\n');
tic;
[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg);
elapsed = toc;
plateFound = isfield(detectionDebug, 'plateFound') && detectionDebug.plateFound;

fprintf('[TEST M2] Status  : %s\n', detectionDebug.status);
fprintf('[TEST M2] Found   : %d\n', plateFound);
fprintf('[TEST M2] Time    : %.3f s\n', elapsed);
if plateFound
    fprintf('[TEST M2] BBox    : [%.0f %.0f %.0f %.0f]\n', plateBBox);
end

% -------------------------------------------------------------------------
% 4. Print candidate scoring table
% -------------------------------------------------------------------------
if ~isempty(detectionDebug.candidateTable)
    fprintf('\n--- Candidate Scoring Table (top candidates) ---\n');
    disp(detectionDebug.candidateTable(1:min(10, height(detectionDebug.candidateTable)), :));
else
    fprintf('[TEST M2] No candidates survived the filters.\n');
end

% -------------------------------------------------------------------------
% 5. Diagnostic figure (8 panels)
% -------------------------------------------------------------------------
fig = figure('Name', 'Member 2 — Plate Detection Diagnostic', ...
             'NumberTitle', 'off', 'Color', 'w');

% Panel 1: Original image
subplot(2, 4, 1);
imshow(originalImg);
title('1. Original Image', 'FontWeight', 'bold');

% Panel 2: Preprocessed (from M1 or fallback)
subplot(2, 4, 2);
imshow(preprocessedImg, []);
title('2. Preprocessed Input', 'FontWeight', 'bold');

% Panel 3: CLAHE enhanced
subplot(2, 4, 3);
if ~isempty(detectionDebug.enhancedImg)
    imshow(detectionDebug.enhancedImg);
else
    imshow(zeros(10, 10, 'uint8'));
end
title('3. CLAHE Enhanced', 'FontWeight', 'bold');

% Panel 4: Canny edges
subplot(2, 4, 4);
if ~isempty(detectionDebug.edgeImg)
    imshow(detectionDebug.edgeImg);
else
    imshow(false(10, 10));
end
title('4. Canny Edges', 'FontWeight', 'bold');

% Panel 5: After dual morphological closing
subplot(2, 4, 5);
if ~isempty(detectionDebug.closedImg)
    imshow(detectionDebug.closedImg);
else
    imshow(false(10, 10));
end
title('5. Dual Morph. Closing', 'FontWeight', 'bold');

% Panel 6: Cleaned binary (after fill, area open, border clear)
subplot(2, 4, 6);
if ~isempty(detectionDebug.cleanedImg)
    imshow(detectionDebug.cleanedImg);
else
    imshow(false(10, 10));
end
title('6. Cleaned Binary', 'FontWeight', 'bold');

% Panel 7: Original with detected bounding box overlaid
subplot(2, 4, 7);
imshow(originalImg);
title('7. Detected Region', 'FontWeight', 'bold');
if plateFound && ~isempty(plateBBox)
    hold on;
    rectangle('Position', plateBBox, 'EdgeColor', 'r', 'LineWidth', 3);
    text(plateBBox(1), plateBBox(2) - 6, 'Plate', ...
        'Color', 'r', 'FontWeight', 'bold', 'FontSize', 10);
    hold off;
end

% Panel 8: Cropped plate
subplot(2, 4, 8);
if plateFound && ~isempty(plateImg)
    imshow(plateImg, []);
    title('8. Cropped Plate', 'FontWeight', 'bold');
else
    imshow(zeros(50, 150, 'uint8'));
    title('8. Cropped Plate (none found)', 'FontWeight', 'bold');
end

sgtitle('Member 2 — License Plate Detection Pipeline', 'FontSize', 13, 'FontWeight', 'bold');
fprintf('\n[TEST M2] Diagnostic figure displayed. Done.\n');
