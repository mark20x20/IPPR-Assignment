function varargout = recognizePlateText(plateImg)
% recognizePlateText performs OCR on a cropped plate image using multiple
% preprocessing variants and plate-like text scoring.
%
% Input:
%   plateImg - cropped license plate image (RGB or grayscale)
%
% Output:
%   rawText  - best raw OCR text string, or "UNKNOWN" if failed
%   ocrDebug - optional debug struct with OCR candidates and scores

    rawText = "UNKNOWN";
    ocrDebug = localDefaultOcrDebug();

    if isempty(plateImg)
        ocrDebug.status = "empty_input";
        varargout = localPackOutputs(rawText, ocrDebug, nargout);
        return;
    end

    try
        grayImg = im2gray(plateImg);
    catch
        if size(plateImg, 3) == 3
            grayImg = rgb2gray(plateImg);
        else
            grayImg = plateImg;
        end
    end

    grayImg = im2uint8(grayImg);
    grayImg = localNormalizeForOcr(grayImg);

    [candidateImgs, candidateNames] = localMakeOcrCandidateImages(grayImg);
    [outputDir, imagePaths] = localExportCandidateImages(plateImg, candidateImgs, candidateNames);

    ocrDebug.outputDir = outputDir;
    ocrDebug.candidateImagePaths = string(imagePaths);
    ocrDebug.candidateNames = string(candidateNames);

    numCandidates = numel(candidateImgs);
    rawResults = strings(numCandidates, 1);
    cleanedResults = strings(numCandidates, 1);
    scores = -inf(numCandidates, 1);
    errorMessages = strings(numCandidates, 1);

    bestIdx = 0;
    bestScore = -inf;

    for i = 1:numCandidates
        [rawCandidate, ocrError] = localRunOcrSafely(candidateImgs{i});
        rawResults(i) = rawCandidate;
        errorMessages(i) = ocrError;

        cleanedCandidate = cleanRecognizedText(rawCandidate);
        cleanedResults(i) = cleanedCandidate;

        scoreCandidate = localPlateTextScore(cleanedCandidate);
        scores(i) = scoreCandidate;

        if scoreCandidate > bestScore
            bestScore = scoreCandidate;
            bestIdx = i;
        end
    end

    ocrDebug.rawResults = rawResults;
    ocrDebug.cleanedResults = cleanedResults;
    ocrDebug.scores = scores;
    ocrDebug.ocrErrorMessages = errorMessages;

    if bestIdx > 0 && isfinite(bestScore)
        selectedRaw = strtrim(rawResults(bestIdx));
        if strlength(selectedRaw) == 0
            selectedRaw = "UNKNOWN";
        end

        rawText = selectedRaw;
        ocrDebug.selectedIndex = bestIdx;
        ocrDebug.selectedCandidateName = string(candidateNames{bestIdx});
        ocrDebug.selectedRawText = rawResults(bestIdx);
        ocrDebug.selectedCleanedText = cleanedResults(bestIdx);

        if all(cleanedResults == "UNKNOWN")
            ocrDebug.status = "all_candidates_unknown";
            ocrDebug.allCandidatesUnknown = true;
        else
            ocrDebug.status = "ok";
            ocrDebug.allCandidatesUnknown = false;
        end
    else
        ocrDebug.status = "no_valid_ocr_candidate";
        ocrDebug.allCandidatesUnknown = true;
    end

    localSaveOcrCandidatesCsv(outputDir, candidateNames, rawResults, cleanedResults, scores, errorMessages, imagePaths);

    varargout = localPackOutputs(rawText, ocrDebug, nargout);
end

function out = localPackOutputs(rawText, ocrDebug, requestedOutputs)
    if requestedOutputs <= 1
        out = {rawText};
    else
        out = {rawText, ocrDebug};
    end
end

function debug = localDefaultOcrDebug()
    debug = struct();
    debug.candidateNames = strings(0, 1);
    debug.rawResults = strings(0, 1);
    debug.cleanedResults = strings(0, 1);
    debug.scores = [];
    debug.ocrErrorMessages = strings(0, 1);
    debug.candidateImagePaths = strings(0, 1);
    debug.selectedIndex = 0;
    debug.selectedCandidateName = "";
    debug.selectedRawText = "UNKNOWN";
    debug.selectedCleanedText = "UNKNOWN";
    debug.status = "not_run";
    debug.outputDir = "";
    debug.allCandidatesUnknown = false;
end

function normalized = localNormalizeForOcr(grayImg)
    blurred = medfilt2(grayImg, [3 3], 'symmetric');
    normalized = imadjust(blurred);
end

function [imgs, names] = localMakeOcrCandidateImages(grayImg)
    scale = 4;
    base = imresize(grayImg, scale, 'bicubic');
    enhanced = imadjust(base);
    eqImg = adapthisteq(base);
    sharpened = imsharpen(base, 'Radius', 1.0, 'Amount', 1.2);

    bwLocal = imbinarize(enhanced, adaptthresh(enhanced, 0.45));
    bwGlobal = imbinarize(eqImg);

    bwTextBlack1 = localEnsureBlackTextOnWhite(bwLocal);
    bwTextBlack2 = localEnsureBlackTextOnWhite(bwGlobal);

    cleaned1 = bwareaopen(bwTextBlack1, 12);

    imgs = {
        base, ...
        enhanced, ...
        eqImg, ...
        sharpened, ...
        bwTextBlack1, ...
        bwTextBlack2, ...
        cleaned1 ...
    };

    names = {
        'gray_resized_x4', ...
        'contrast_enhanced_x4', ...
        'adaptive_histeq_x4', ...
        'sharpened_x4', ...
        'binary_black_text_white_bg_adaptive', ...
        'binary_black_text_white_bg_global', ...
        'binary_black_text_white_bg_cleaned' ...
    };
end

function outBw = localEnsureBlackTextOnWhite(inBw)
    inBw = logical(inBw);
    ratio = nnz(inBw) / numel(inBw);

    if ratio > 0.5
        outBw = ~inBw;
    else
        outBw = inBw;
    end

    blackRatio = nnz(~outBw) / numel(outBw);
    if blackRatio > 0.5
        outBw = ~outBw;
    end
end

function [rawText, errorMessage] = localRunOcrSafely(img)
    rawText = "UNKNOWN";
    errorMessage = "";

    try
        if islogical(img)
            ocrImg = uint8(img) * 255;
        else
            ocrImg = im2uint8(mat2gray(img));
        end

        firstError = "";
        secondError = "";

        try
            % A) char-vector name/value syntax
            ocrResult = ocr(ocrImg, 'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
        catch errA
            firstError = string(errA.identifier) + ": " + string(errA.message);
            try
                % B) string name/value syntax
                ocrResult = ocr(ocrImg, CharacterSet="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
            catch errB
                secondError = string(errB.identifier) + ": " + string(errB.message);
                try
                    % C) plain OCR fallback for maximum compatibility
                    ocrResult = ocr(ocrImg);
                catch errC
                    thirdError = string(errC.identifier) + ": " + string(errC.message);
                    errorMessage = "attemptA=" + firstError + " | attemptB=" + secondError + " | attemptC=" + thirdError;
                    return;
                end
            end
        end

        textValue = strtrim(string(ocrResult.Text));
        if strlength(textValue) > 0
            rawText = textValue;
            if strlength(firstError) > 0 || strlength(secondError) > 0
                errorMessage = "fallback_used";
                if strlength(firstError) > 0
                    errorMessage = errorMessage + " | attemptA=" + firstError;
                end
                if strlength(secondError) > 0
                    errorMessage = errorMessage + " | attemptB=" + secondError;
                end
            end
        else
            errorMessage = "ocr_returned_empty_text";
        end
    catch err
        errorMessage = string(err.identifier) + ": " + string(err.message);
    end
end

function score = localPlateTextScore(cleanedText)
    value = upper(strtrim(string(cleanedText)));

    if strlength(value) == 0 || value == "UNKNOWN"
        score = -20;
        return;
    end

    textLen = strlength(value);
    hasDigit = ~isempty(regexp(value, '\d', 'once'));
    hasLetter = ~isempty(regexp(value, '[A-Z]', 'once'));
    startsWithLetter = ~isempty(regexp(value, '^[A-Z]', 'once'));

    score = 0;

    if textLen >= 5 && textLen <= 8
        score = score + 4.0;
    elseif textLen == 4 || textLen == 9
        score = score + 1.5;
    else
        score = score - 3.0;
    end

    if hasLetter && hasDigit
        score = score + 3.0;
    elseif hasLetter || hasDigit
        score = score - 1.0;
    else
        score = score - 3.0;
    end

    if startsWithLetter
        score = score + 2.0;
    else
        score = score - 2.0;
    end

    if ~hasDigit
        score = score - 2.0;
    end

    if ~isempty(regexp(value, '^[A-Z]{1,3}\d{1,4}[A-Z]?$', 'once'))
        score = score + 2.0;
    end

    if ~isempty(regexp(value, '(.)\1\1', 'once'))
        score = score - 1.0;
    end
end

function [outputDir, imagePaths] = localExportCandidateImages(plateImg, candidateImgs, ~)
    outputDir = localMakeOutputDir();

    fileNames = {
        '01_original_plate.png', ...
        '02_gray_resized_x4.png', ...
        '03_contrast_enhanced_x4.png', ...
        '04_adaptive_histeq_x4.png', ...
        '05_sharpened_x4.png', ...
        '06_binary_black_text_white_bg_adaptive.png', ...
        '07_binary_black_text_white_bg_global.png', ...
        '08_binary_black_text_white_bg_cleaned.png' ...
    };

    imagePaths = strings(numel(fileNames) - 1, 1);

    localSafeWriteImage(fullfile(outputDir, fileNames{1}), plateImg);

    for i = 1:numel(candidateImgs)
        filePath = fullfile(outputDir, fileNames{i + 1});
        localSafeWriteImage(filePath, candidateImgs{i});
        imagePaths(i) = string(filePath);
    end
end

function outDir = localMakeOutputDir()
    paths = getProjectPaths();
    outRoot = paths.recognitionDebugRoot;
    if ~exist(outRoot, 'dir')
        mkdir(outRoot);
    end

    stamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
    runName = "run_" + stamp;
    outDir = fullfile(outRoot, char(runName));
    mkdir(outDir);
end

function localSaveOcrCandidatesCsv(outputDir, candidateNames, rawResults, cleanedResults, scores, errorMessages, imagePaths)
    numRows = numel(candidateNames);
    candidateIndex = (1:numRows)';

    T = table(candidateIndex, string(candidateNames(:)), string(rawResults(:)), string(cleanedResults(:)), ...
        double(scores(:)), string(errorMessages(:)), string(imagePaths(:)), ...
        'VariableNames', {'CandidateIndex', 'CandidateName', 'RawOCR', 'CleanedText', 'Score', 'ErrorMessage', 'CandidateImagePath'});

    writetable(T, fullfile(outputDir, 'ocr_candidates.csv'));
end

function localSafeWriteImage(filePath, img)
    try
        if islogical(img)
            outImg = uint8(img) * 255;
        else
            outImg = img;
            if ~isa(outImg, 'uint8')
                outImg = im2uint8(mat2gray(outImg));
            end
        end
        imwrite(outImg, filePath);
    catch
        % Keep silent here; diagnostics will be in OCR candidate CSV/error fields.
    end
end
