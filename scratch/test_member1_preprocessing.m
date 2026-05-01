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
    fprintf("Preprocessing test skipped safely.\n");
    return;
end

originalImg = imread(imagePath);
[preprocessedImg, preprocessDebug] = preprocessImage(originalImg);

figure("Name", "Member 1 Preprocessing Test", "NumberTitle", "off");
subplot(2,2,1); imshow(originalImg); title("Original");
subplot(2,2,2); imshow(preprocessDebug.grayImg); title("Gray");
subplot(2,2,3); imshow(preprocessDebug.enhancedImg); title("Enhanced");
subplot(2,2,4); imshow(preprocessedImg); title("Filtered");
