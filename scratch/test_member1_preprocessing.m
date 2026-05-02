clc;
clear;
close all;

% Resolve project root from this script location.
scriptPath = mfilename('fullpath');
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);

% Add the project src folder and subfolders to MATLAB path.
addpath(genpath(fullfile(projectRoot, 'src')));

fprintf('=== Member 1 Preprocessing Test ===\n');

% Build sample image path from the project root.
sampleImagePath = fullfile(projectRoot, 'images', 'test', 'sample_car.jpg');

% Stop safely if the sample image file does not exist.
if ~isfile(sampleImagePath)
    error('Sample image is missing: %s', sampleImagePath);
end

fprintf('Loading sample image: %s\n', sampleImagePath);
originalImg = imread(sampleImagePath);

fprintf('Running preprocessImage...\n');
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

% Read debug outputs safely even if some fields are missing.
grayImg = [];
enhancedImg = [];
if isstruct(preprocessDebug)
    if isfield(preprocessDebug, 'grayImg')
        grayImg = preprocessDebug.grayImg;
    end
    if isfield(preprocessDebug, 'enhancedImg')
        enhancedImg = preprocessDebug.enhancedImg;
    end
end

% Print processing status and optional error message.
if isstruct(preprocessDebug) && isfield(preprocessDebug, 'status')
    fprintf('Preprocessing status: %s\n', preprocessDebug.status);
else
    fprintf('Preprocessing status: Unknown\n');
end

if isstruct(preprocessDebug) && isfield(preprocessDebug, 'errorMessage') && ~isempty(preprocessDebug.errorMessage)
    fprintf(2, 'Preprocessing error: %s\n', preprocessDebug.errorMessage);
end

% Create output folder for Member 1 preprocessing evidence.
outputFolder = fullfile(projectRoot, 'output', 'figures', 'member1_preprocessing');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
fprintf('Output folder: %s\n', outputFolder);

% Save available preprocessing images for report evidence.
originalOutputPath = fullfile(outputFolder, 'member1_original.png');
imwrite(originalImg, originalOutputPath);
fprintf('Saved: %s\n', originalOutputPath);

grayOutputPath = fullfile(outputFolder, 'member1_grayscale.png');
if ~isempty(grayImg)
    imwrite(grayImg, grayOutputPath);
    fprintf('Saved: %s\n', grayOutputPath);
else
    fprintf(2, 'Skipped save (empty): %s\n', grayOutputPath);
end

enhancedOutputPath = fullfile(outputFolder, 'member1_enhanced.png');
if ~isempty(enhancedImg)
    imwrite(enhancedImg, enhancedOutputPath);
    fprintf('Saved: %s\n', enhancedOutputPath);
else
    fprintf(2, 'Skipped save (empty): %s\n', enhancedOutputPath);
end

preprocessedOutputPath = fullfile(outputFolder, 'member1_preprocessed.png');
if ~isempty(preprocessedImg)
    imwrite(preprocessedImg, preprocessedOutputPath);
    fprintf('Saved: %s\n', preprocessedOutputPath);
else
    fprintf(2, 'Skipped save (empty): %s\n', preprocessedOutputPath);
end

% Create a 2x2 figure for original and preprocessing stages.
figure('Name', 'Member 1 Preprocessing Test', 'NumberTitle', 'off');

subplot(2, 2, 1);
imshow(originalImg);
title('Original Image');

subplot(2, 2, 2);
if isempty(grayImg)
    imshow(zeros(size(originalImg, 1), size(originalImg, 2), 'uint8'));
    title('Grayscale Image (Unavailable)');
else
    imshow(grayImg);
    title('Grayscale Image');
end

subplot(2, 2, 3);
if isempty(enhancedImg)
    imshow(zeros(size(originalImg, 1), size(originalImg, 2), 'uint8'));
    title('Enhanced Image (Unavailable)');
else
    imshow(enhancedImg);
    title('Enhanced Image');
end

subplot(2, 2, 4);
if isempty(preprocessedImg)
    imshow(zeros(size(originalImg, 1), size(originalImg, 2), 'uint8'));
    title('Preprocessed Image (Unavailable)');
    fprintf(2, 'Preprocessed output is empty.\n');
else
    imshow(preprocessedImg);
    title('Preprocessed Image');
    fprintf('Preprocessed image generated successfully.\n');
end

fprintf('=== Test script finished ===\n');
