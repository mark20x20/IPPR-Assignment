clc;
clear;
close all;

scriptPath = mfilename("fullpath");
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, "src")));

imagePath = fullfile(projectRoot, "images", "test", "sample_car.jpg");
if ~isfile(imagePath)
    fprintf(2, "Sample image not found: %s\n", imagePath);
    fprintf("Plate detection test skipped safely.\n");
    return;
end

originalImg = imread(imagePath);
if size(originalImg, 3) == 3
    preprocessedImg = rgb2gray(originalImg);
else
    preprocessedImg = originalImg;
end

[plateImg, plateBBox, detectionDebug] = detectPlateRegion(preprocessedImg, originalImg); %#ok<NASGU,ASGLU>

figure("Name", "Member 2 Plate Detection Test", "NumberTitle", "off");
subplot(1,2,1); imshow(originalImg); title("Original");
subplot(1,2,2);
if ~isempty(plateImg)
    imshow(plateImg); title("Detected Plate");
else
    axis off; title("No Plate Detected (Safe Fallback)");
end

if isempty(plateBBox)
    fprintf("No plate bounding box found. Safe fallback returned.\n");
else
    fprintf("Plate bounding box: [%.1f %.1f %.1f %.1f]\n", plateBBox(1), plateBBox(2), plateBBox(3), plateBBox(4));
end
