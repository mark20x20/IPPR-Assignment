clc;
clear;
close all;

addpath(genpath("src"));

ensureOutputFolders();

imagePath = fullfile("images", "test", "sample_car.jpg");
if ~isfile(imagePath)
    fprintf(2, "Sample image not found: %s\n", imagePath);
    fprintf("Please add a test image at images/test/sample_car.jpg and run again.\n");
    return;
end

try
    originalImg = imread(imagePath);
catch readErr
    fprintf(2, "Failed to read sample image: %s\n", readErr.message);
    return;
end

[preprocessedImg, ~] = preprocessImage(originalImg);
[plateImg, ~, ~] = detectPlateRegion(preprocessedImg, originalImg);
[~, ~] = segmentCharacters(plateImg);

rawText = recognizePlateText(plateImg);
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);

fprintf("Recognized Text: %s\n", string(cleanedText));
fprintf("Identified State: %s\n", string(stateName));

displayPipelineResults(originalImg, plateImg, cleanedText, stateName);
