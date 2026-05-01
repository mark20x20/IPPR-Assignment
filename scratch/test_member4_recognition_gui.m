clc;
clear;
close all;

scriptPath = mfilename("fullpath");
scriptFolder = fileparts(scriptPath);
projectRoot = fileparts(scriptFolder);
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, "src")));
ensureOutputFolders();

rawText = "BMS8147";
cleanedText = cleanRecognizedText(rawText);
stateName = identifyState(cleanedText);

fprintf("Cleaned Text: %s\n", cleanedText);
fprintf("Identified State: %s\n", stateName);

platePath = fullfile(projectRoot, "images", "test", "plate_samples", "plate_selangor_01.jpg");
if isfile(platePath)
    plateImg = imread(platePath);
    rawOcrText = recognizePlateText(plateImg);
    cleanedOcrText = cleanRecognizedText(rawOcrText);
    stateFromOcr = identifyState(cleanedOcrText);
    displayPipelineResults(plateImg, plateImg, cleanedOcrText, stateFromOcr);

    resultRow = evaluateSingleImage(platePath, cleanedOcrText, stateFromOcr, "plate_sample");
    saveResultRow(resultRow, "results_template.csv");
    fprintf("Recognition and evaluation test completed.\n");
else
    fprintf("No plate sample found. OCR image test skipped safely.\n");
end

try
    if exist("launch_gui", "file") == 2
        launch_gui();
    else
        run(fullfile(projectRoot, "launch_gui.m"));
    end
    fprintf("GUI launch test executed.\n");
catch guiErr
    fprintf(2, "GUI launch failed safely: %s\n", guiErr.message);
end
