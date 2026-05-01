function resultRow = evaluateSingleImage(imagePath, expectedText, expectedState, vehicleType)
imageName = string(imagePath);
if contains(imageName, filesep)
    [~, nameOnly, ext] = fileparts(imageName);
    imageName = nameOnly + ext;
end

expectedText = string(expectedText);
expectedState = string(expectedState);
vehicleType = string(vehicleType);

ocrText = "UNKNOWN";
predictedState = "UNKNOWN";
detectionResult = "Failure";
ocrResult = "Failure";
stateResult = "Failure";
overallResult = "Failure";
notes = "";

if ~isfile(imagePath)
    notes = "Image file not found.";
    resultRow = createResultTable();
    return;
end

try
    originalImg = imread(imagePath);
    [preprocessedImg, ~] = preprocessImage(originalImg);
    [plateImg, ~, ~] = detectPlateRegion(preprocessedImg, originalImg);
    [~, ~] = segmentCharacters(plateImg);
    ocrText = cleanRecognizedText(recognizePlateText(plateImg));
    predictedState = identifyState(ocrText);

    if ~isempty(plateImg)
        detectionResult = "Success";
    end
    if ocrText ~= "UNKNOWN"
        ocrResult = "Success";
    end
    if predictedState ~= "UNKNOWN"
        stateResult = "Success";
    end

    if ocrText == upper(expectedText)
        ocrResult = "Match";
    end
    if predictedState == expectedState
        stateResult = "Match";
    end

    if detectionResult == "Success" && (ocrResult == "Match" || stateResult == "Match")
        overallResult = "Success";
    end
catch evalErr
    notes = "Evaluation error: " + string(evalErr.message);
end

resultRow = createResultTable();

    function t = createResultTable()
        t = table(imageName, vehicleType, expectedText, ocrText, expectedState, predictedState, ...
            detectionResult, ocrResult, stateResult, overallResult, notes, ...
            "VariableNames", ["image_name","vehicle_type","expected_text","ocr_text","expected_state", ...
            "predicted_state","detection_result","ocr_result","state_result","overall_result","notes"]);
    end
end
