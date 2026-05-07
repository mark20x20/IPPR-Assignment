% test_member3_segmentation  Member 3 segmentation test runner.

clear;
clc;
close all;

scriptPath = mfilename('fullpath');
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);
addpath(genpath(fullfile(projectRoot, 'src')));
paths = ensureOutputFolders();
fprintf('[TEST M3] Official debug root: %s\n', paths.segmentationDebugRoot);

sampleFolder = fullfile(projectRoot, 'images', 'test', 'plate_samples');

if ~isfolder(sampleFolder)
    fprintf('No plate samples found. Please add cropped plate images for Member 3 testing.\n');
    return;
end

imageFiles = [ ...
    dir(fullfile(sampleFolder, '*.jpg')); ...
    dir(fullfile(sampleFolder, '*.jpeg')); ...
    dir(fullfile(sampleFolder, '*.png')); ...
    dir(fullfile(sampleFolder, '*.bmp'))];

if isempty(imageFiles)
    fprintf('No plate samples found. Please add cropped plate images for Member 3 testing.\n');
    return;
end

fprintf('[TEST M3] Found %d sample(s) in %s\n', numel(imageFiles), sampleFolder);

for k = 1:numel(imageFiles)
    imagePath = fullfile(imageFiles(k).folder, imageFiles(k).name);
    plateImg = imread(imagePath);

    [characterImages, characterBBoxes, segDebug] = segmentCharacters(plateImg); %#ok<ASGLU>

    fprintf('[TEST M3] %s | chars=%d | status=%s\n', imageFiles(k).name, numel(characterImages), string(segDebug.status));
    if isfield(segDebug, 'debugOutputDir')
        fprintf('[TEST M3] Debug output folder: %s\n', string(segDebug.debugOutputDir));
    end
    if isfield(segDebug, 'acceptedCharacterCount')
        accCount = segDebug.acceptedCharacterCount;
    else
        accCount = numel(characterImages);
    end
    selPol = "";
    if isfield(segDebug, 'selectedPolarity')
        selPol = string(segDebug.selectedPolarity);
    end
    overlaySaved = "unknown";
    if isfield(segDebug, 'debugOutputDir') && strlength(string(segDebug.debugOutputDir)) > 0
        overlayPath = fullfile(char(segDebug.debugOutputDir), '09_character_boxes_overlay.png');
        overlaySaved = string(exist(overlayPath, 'file') == 2);
    end
    savedFileCount = 0;
    if isfield(segDebug, 'debugOutputDir') && strlength(string(segDebug.debugOutputDir)) > 0 && isfolder(char(segDebug.debugOutputDir))
        savedFileCount = numel(dir(fullfile(char(segDebug.debugOutputDir), '*.*'))) - 2;
    end
    fprintf('[TEST M3] saved_files=%d | accepted_character_count=%d | selected_polarity=%s | overlay_saved=%s\n', ...
        savedFileCount, accCount, selPol, overlaySaved);

    figure('Name', imageFiles(k).name);

    subplot(2, 3, 1);
    imshow(plateImg);
    title('Original Plate');

    subplot(2, 3, 2);
    if isfield(segDebug, 'refinedPlateImg') && ~isempty(segDebug.refinedPlateImg)
        imshow(segDebug.refinedPlateImg);
    else
        imshow(plateImg);
    end
    title('Refined Plate');

    subplot(2, 3, 3);
    if isfield(segDebug, 'selectedBinaryImg') && ~isempty(segDebug.selectedBinaryImg)
        imshow(segDebug.selectedBinaryImg);
    else
        imshow(false(size(plateImg, 1), size(plateImg, 2)));
    end
    title('Selected Binary');

    subplot(2, 3, 4);
    if isfield(segDebug, 'cleanedBinaryImg') && ~isempty(segDebug.cleanedBinaryImg)
        imshow(segDebug.cleanedBinaryImg);
    else
        imshow(false(size(plateImg, 1), size(plateImg, 2)));
    end
    title('Cleaned Binary');

    subplot(2, 3, [5 6]);
    if isfield(segDebug, 'refinedPlateImg') && ~isempty(segDebug.refinedPlateImg)
        base = segDebug.refinedPlateImg;
    else
        base = plateImg;
    end
    imshow(base);
    hold on;
    for i = 1:size(characterBBoxes, 1)
        rectangle('Position', characterBBoxes(i, :), 'EdgeColor', 'g', 'LineWidth', 2);
    end
    hold off;
    title('Character Boxes Overlay');
end
