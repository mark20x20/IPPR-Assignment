clc;
clear;
close all;

scriptPath = mfilename("fullpath");
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, "src")));

platePath = fullfile(projectRoot, "images", "test", "plate_samples", "plate_selangor_01.jpg");
if ~isfile(platePath)
    fprintf(2, "Plate sample not found: %s\n", platePath);
    fprintf("Segmentation test skipped safely. Add sample(s) under images/test/plate_samples/.\n");
    return;
end

plateImg = imread(platePath);
binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
[characterImages, characterBBoxes] = segmentCharacters(plateImg); %#ok<NASGU>

figure("Name", "Member 3 Segmentation Test", "NumberTitle", "off");
subplot(1,3,1); imshow(plateImg); title("Plate");
subplot(1,3,2); imshow(binaryPlateImg); title("Binary");
subplot(1,3,3); imshow(cleanedImg); title("Cleaned");

fprintf("Character candidates found: %d\n", size(characterBBoxes, 1));
