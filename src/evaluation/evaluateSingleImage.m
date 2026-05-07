function resultRow = evaluateSingleImage(imagePath, expectedText, expectedState, vehicleType)
% evaluateSingleImage evaluates one image for detection/OCR/state prediction.
%
% Suggested usage for cropped plate samples:
%   resultRow = evaluateSingleImage(path, expectedText, expectedState, "plate_sample")
%
% Suggested usage for full vehicle images:
%   resultRow = evaluateSingleImage(path, expectedText, expectedState, "vehicle")

    expectedText = upper(strtrim(string(expectedText)));
    expectedState = strtrim(string(expectedState));
    vehicleType = strtrim(string(vehicleType));

    imageName = string(imagePath);
    if contains(imageName, filesep)
        [~, nameOnly, ext] = fileparts(imageName);
        imageName = nameOnly + ext;
    end

    ocrText = "UNKNOWN";
    predictedState = "UNKNOWN";
    detectionResult = "Failure";
    ocrResult = "Failure";
    stateResult = "UNKNOWN";
    overallResult = "Failure";
    notes = "";

    if ~isfile(imagePath)
        notes = "Image file not found.";
        resultRow = localBuildRow();
        return;
    end

    try
        inputImg = imread(imagePath);
    catch readErr
        notes = "Image read failed: " + string(readErr.message);
        resultRow = localBuildRow();
        return;
    end

    plateImg = [];

    isPlateSample = contains(lower(vehicleType), "plate") || contains(lower(vehicleType), "crop");

    try
        if isPlateSample
            plateImg = inputImg;
            detectionResult = "Success";
            notes = "Direct OCR on cropped plate sample.";
        else
            [preprocessedImg, ~] = preprocessImage(inputImg);
            [plateImg, ~, detectionDebug] = detectPlateRegion(preprocessedImg, inputImg);

            if ~isempty(plateImg)
                detectionResult = "Success";
            else
                detectionResult = "Failure";
            end

            if isstruct(detectionDebug) && isfield(detectionDebug, 'status')
                notes = "Detection status: " + string(detectionDebug.status);
            end
        end

        if ~isempty(plateImg)
            rawText = recognizePlateText(plateImg);
            ocrText = cleanRecognizedText(rawText);
            predictedState = identifyState(ocrText);
        end

    catch evalErr
        notes = strtrim(notes + " Evaluation error: " + string(evalErr.message));
    end

    ocrResult = localEvaluateOcr(ocrText, expectedText);
    stateResult = localEvaluateState(predictedState, expectedState);
    overallResult = localEvaluateOverall(ocrResult, stateResult);

    resultRow = localBuildRow();

    function row = localBuildRow()
    row = table( ...
        string(imageName), string(vehicleType), string(expectedText), string(ocrText), ...
        string(expectedState), string(predictedState), string(detectionResult), ...
        string(ocrResult), string(stateResult), string(overallResult), string(notes), ...
        'VariableNames', ["image_name","vehicle_type","expected_text","ocr_text", ...
        "expected_state","predicted_state","detection_result","ocr_result", ...
        "state_result","overall_result","notes"]);
    end
end

function result = localEvaluateOcr(ocrText, expectedText)
    ocrText = upper(strtrim(string(ocrText)));
    expectedText = upper(strtrim(string(expectedText)));

    if ocrText == "UNKNOWN" || strlength(ocrText) == 0
        result = "Failure";
        return;
    end

    if ocrText == expectedText
        result = "Correct";
        return;
    end

    overlapCount = 0;
    for k = 1:strlength(expectedText)
        if contains(ocrText, extractBetween(expectedText, k, k))
            overlapCount = overlapCount + 1;
        end
    end

    if overlapCount >= max(2, floor(double(strlength(expectedText)) * 0.5))
        result = "Partial";
    else
        result = "Incorrect";
    end
end

function result = localEvaluateState(predictedState, expectedState)
    predictedState = strtrim(string(predictedState));
    expectedState = strtrim(string(expectedState));

    if predictedState == "UNKNOWN" || strlength(predictedState) == 0
        result = "UNKNOWN";
    elseif strcmpi(predictedState, expectedState)
        result = "Correct";
    else
        result = "Incorrect";
    end
end

function result = localEvaluateOverall(ocrResult, stateResult)
    if ocrResult == "Correct" && stateResult == "Correct"
        result = "Success";
        return;
    end

    if ocrResult == "Partial" || (ocrResult ~= "Failure" && stateResult == "Correct")
        result = "Partial Success";
        return;
    end

    result = "Failure";
end
