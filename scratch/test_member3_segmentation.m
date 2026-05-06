%TEST_MEMBER3_SEGMENTATION Visual and evaluation test for Member 3.
%
% Run this script from the project root.
%
% It will:
%   1. Load cropped plate images from images/test/plate_samples/
%   2. Run segmentation
%   3. Display binary, cleaned, and bounding-box results
%   4. Save result images into scratch/member3_results/
%   5. Save a CSV evaluation table

clear;
clc;
close all;

addpath(genpath("src"));

sampleFolder = fullfile("images", "test", "plate_samples");
outputFolder = fullfile("scratch", "member3_results");

if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

if ~isfolder(sampleFolder)
    error("Plate sample folder not found: %s", sampleFolder);
end

imageFiles = [ ...
    dir(fullfile(sampleFolder, "*.jpg")); ...
    dir(fullfile(sampleFolder, "*.jpeg")); ...
    dir(fullfile(sampleFolder, "*.png")); ...
    dir(fullfile(sampleFolder, "*.bmp")) ...
];

if isempty(imageFiles)
    error("No plate sample images found in: %s", sampleFolder);
end

fileNames = strings(numel(imageFiles), 1);
detectedCounts = zeros(numel(imageFiles), 1);
expectedCounts = zeros(numel(imageFiles), 1);
countDifference = zeros(numel(imageFiles), 1);
status = strings(numel(imageFiles), 1);

for k = 1:numel(imageFiles)
    imagePath = fullfile(imageFiles(k).folder, imageFiles(k).name);
    plateImg = imread(imagePath);

    [charImages, charBoxes] = segmentCharacters(plateImg);

    % Optional expected count:
    % If the filename contains the expected plate text before an underscore,
    % this script estimates expected characters from it.
    % Example: "WXY1234_sample1.jpg" gives expected count 7.
    [~, nameOnly, ~] = fileparts(imageFiles(k).name);
    parts = split(nameOnly, "_");
    expectedText = erase(parts(1), "-");
    expectedText = erase(expectedText, " ");
    estimatedExpectedCount = strlength(expectedText);

    if estimatedExpectedCount <= 0
        estimatedExpectedCount = NaN;
    end

    detectedCount = numel(charImages);

    fileNames(k) = string(imageFiles(k).name);
    detectedCounts(k) = detectedCount;
    expectedCounts(k) = estimatedExpectedCount;

    if isnan(estimatedExpectedCount)
        countDifference(k) = NaN;
        status(k) = "NO_EXPECTED_COUNT";
    else
        countDifference(k) = detectedCount - estimatedExpectedCount;

        if detectedCount == estimatedExpectedCount
            status(k) = "MATCH";
        else
            status(k) = "CHECK";
        end
    end

    figure("Name", imageFiles(k).name);

    subplot(2, 2, 1);
    imshow(plateImg);
    title("Original Cropped Plate");

    subplot(2, 2, 2);
    binaryImg = binarizePlate(plateImg);
    imshow(binaryImg);
    title("Binarized Plate");

    subplot(2, 2, 3);
    cleanedImg = cleanBinaryImage(binaryImg);
    imshow(cleanedImg);
    title("Cleaned Binary Image");

    subplot(2, 2, 4);
    imshow(plateImg);
    title("Detected Character Boxes");
    hold on;

    for i = 1:size(charBoxes, 1)
        rectangle("Position", charBoxes(i, :), ...
            "EdgeColor", "g", ...
            "LineWidth", 2);
    end

    hold off;

    outputImagePath = fullfile(outputFolder, nameOnly + "_segmentation.png");
    saveSegmentationResult(plateImg, charBoxes, outputImagePath);

    fprintf("Image: %s | Detected characters: %d | Status: %s\n", ...
        imageFiles(k).name, detectedCount, status(k));
end

resultsTable = table(fileNames, expectedCounts, detectedCounts, ...
    countDifference, status);

csvPath = fullfile(outputFolder, "member3_segmentation_results.csv");
writetable(resultsTable, csvPath);

fprintf("\nSaved result images and CSV to: %s\n", outputFolder);
