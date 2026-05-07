function [characterImages, characterBBoxes, segmentationDebug] = segmentCharacters(plateImg)
% segmentCharacters  Character segmentation using refinement + CC analysis.

    characterImages = {};
    characterBBoxes = [];
    segmentationDebug = struct( ...
        'inputPlate', plateImg, ...
        'inputPlateImg', plateImg, ...
        'refinedPlate', [], ...
        'refinedPlateImg', [], ...
        'grayImg', [], ...
        'enhancedImg', [], ...
        'binaryBright', [], ...
        'binaryDark', [], ...
        'selectedBinary', [], ...
        'selectedBinaryImg', [], ...
        'cleanedBinary', [], ...
        'cleanedBinaryImg', [], ...
        'characterBBoxes', [], ...
        'characterImages', {{}}, ...
        'segmentationTable', table(), ...
        'candidateTable', table(), ...
        'refineDebug', struct(), ...
        'binarizeDebug', struct(), ...
        'cleanDebug', struct(), ...
        'status', "not_started", ...
        'warnings', strings(0, 1), ...
        'selectedPolarity', "", ...
        'brightPolarityScore', NaN, ...
        'darkPolarityScore', NaN, ...
        'foregroundRatio', NaN, ...
        'rawComponentCount', 0, ...
        'acceptedCharacterCount', 0, ...
        'textBandYRange', [], ...
        'refinementApplied', false, ...
        'debugOutputDir', "");

    if isempty(plateImg)
        segmentationDebug.status = "empty_input";
        return;
    end

    try
        [refinedPlateImg, refineDebug] = refinePlateForSegmentation(plateImg);
        [binaryPlateImg, binDebug] = binarizePlate(refinedPlateImg);
        [cleanedBinary, cleanDebug] = cleanBinaryImage(binaryPlateImg);

        segmentationDebug.refinedPlateImg = refinedPlateImg;
        segmentationDebug.refinedPlate = refinedPlateImg;
        segmentationDebug.grayImg = binDebug.grayImg;
        segmentationDebug.enhancedImg = binDebug.enhancedImg;
        segmentationDebug.binaryBright = binDebug.binaryBright;
        segmentationDebug.binaryDark = binDebug.binaryDark;
        segmentationDebug.selectedBinaryImg = binaryPlateImg;
        segmentationDebug.selectedBinary = binaryPlateImg;
        segmentationDebug.cleanedBinaryImg = cleanedBinary;
        segmentationDebug.cleanedBinary = cleanedBinary;
        segmentationDebug.selectedPolarity = string(binDebug.selectedPolarity);
        segmentationDebug.brightPolarityScore = binDebug.brightPolarityScore;
        segmentationDebug.darkPolarityScore = binDebug.darkPolarityScore;
        segmentationDebug.foregroundRatio = binDebug.foregroundRatio;
        sameSize = isequal(size(refinedPlateImg), size(plateImg));
        segmentationDebug.refinementApplied = logical(refineDebug.refinementApplied) && ~sameSize;
        segmentationDebug.refineDebug = refineDebug;
        segmentationDebug.binarizeDebug = binDebug;
        segmentationDebug.cleanDebug = cleanDebug;

        if isempty(cleanedBinary)
            segmentationDebug.status = "cleaned_binary_empty";
            segmentationDebug.warnings(end + 1) = "Binary cleanup returned empty image.";
            saveInfo = saveSegmentationResult(segmentationDebug);
            segmentationDebug.debugOutputDir = string(saveInfo.outputDir);
            return;
        end

        cc = bwconncomp(cleanedBinary);
        stats = regionprops(cc, 'BoundingBox', 'Area', 'Extent', 'Solidity');
        segmentationDebug.rawComponentCount = cc.NumObjects;

        imgH = size(cleanedBinary, 1);
        imgW = size(cleanedBinary, 2);
        minArea = max(6, round(0.001 * imgH * imgW));

        rowBand = sum(cleanedBinary, 2);
        if max(rowBand) > 0
            rowNorm = rowBand / max(rowBand);
        else
            rowNorm = zeros(size(rowBand));
        end
        textRows = find(rowNorm > 0.30);
        if isempty(textRows)
            textBandY1 = 1;
            textBandY2 = imgH;
        else
            textBandY1 = min(textRows);
            textBandY2 = max(textRows);
        end
        textBandCenter = (textBandY1 + textBandY2) / 2;
        textBandHeight = max(1, textBandY2 - textBandY1 + 1);
        segmentationDebug.textBandYRange = [textBandY1, textBandY2];

        candId = (1:numel(stats))';
        x = zeros(numel(stats), 1);
        y = zeros(numel(stats), 1);
        w = zeros(numel(stats), 1);
        h = zeros(numel(stats), 1);
        area = zeros(numel(stats), 1);
        ar = zeros(numel(stats), 1);
        extent = zeros(numel(stats), 1);
        solidity = zeros(numel(stats), 1);
        isAccepted = false(numel(stats), 1);
        rejectReason = strings(numel(stats), 1);
        isInTextBand = false(numel(stats), 1);
        borderTouchRatio = zeros(numel(stats), 1);
        textBandScore = zeros(numel(stats), 1);
        isWideBlob = false(numel(stats), 1);
        isMergedCandidate = false(numel(stats), 1);

        for i = 1:numel(stats)
            bb = stats(i).BoundingBox;
            x(i) = bb(1);
            y(i) = bb(2);
            w(i) = bb(3);
            h(i) = bb(4);
            area(i) = stats(i).Area;
            ar(i) = w(i) / max(h(i), 1);
            extent(i) = stats(i).Extent;
            solidity(i) = stats(i).Solidity;
            rejectReason(i) = "accepted";
            cy = y(i) + h(i) / 2;
            borderPx = double(x(i) <= 1.5) + double(y(i) <= 1.5) + ...
                double((x(i) + w(i)) >= (imgW - 0.5)) + double((y(i) + h(i)) >= (imgH - 0.5));
            borderTouchRatio(i) = borderPx / 4.0;
            edgeXRatio = min(x(i), max(0, imgW - (x(i) + w(i)))) / max(imgW, 1);
            nearExtremeSide = edgeXRatio < 0.055;

            distToBand = abs(cy - textBandCenter);
            normBand = max(1, 0.5 * textBandHeight);
            textBandScore(i) = max(0, 1 - distToBand / normBand);
            isInTextBand(i) = textBandScore(i) >= 0.30;

            isWideBlob(i) = (w(i) > 0.23 * imgW) || (ar(i) > 1.25 && h(i) > 0.45 * imgH);
            isMergedCandidate(i) = (w(i) > 0.27 * imgW) || (ar(i) > 1.55);

            thinHorizontalFrame = (h(i) < 0.10 * imgH) && (w(i) > 0.30 * imgW);
            edgeHeavyTouch = (borderTouchRatio(i) >= 0.50) && (area(i) < 0.06 * imgH * imgW);
            borderLowBandNoise = (borderTouchRatio(i) >= 0.25) && nearExtremeSide && (textBandScore(i) < 0.52) && ...
                                 (area(i) < 0.032 * imgH * imgW) && (h(i) < 0.60 * imgH);
            longThinFrame = (ar(i) > 2.8) && (h(i) < 0.22 * imgH) && (w(i) > 0.22 * imgW);
            edgeBodyPatch = (borderTouchRatio(i) >= 0.25) && nearExtremeSide && (w(i) > 0.08 * imgW) && ...
                            (h(i) > 0.55 * imgH) && (textBandScore(i) < 0.90);

            if area(i) < minArea
                rejectReason(i) = "area_small";
            elseif h(i) < 0.25 * imgH || h(i) > 0.95 * imgH
                rejectReason(i) = "height_range";
            elseif w(i) < 0.01 * imgW || w(i) > 0.35 * imgW
                rejectReason(i) = "width_range";
            elseif thinHorizontalFrame
                rejectReason(i) = "frame_line";
            elseif longThinFrame
                rejectReason(i) = "frame_line_thin";
            elseif edgeHeavyTouch
                rejectReason(i) = "border_touch";
            elseif borderLowBandNoise
                rejectReason(i) = "border_low_textband_noise";
            elseif edgeBodyPatch
                rejectReason(i) = "edge_body_patch";
            elseif ar(i) > 1.9
                rejectReason(i) = "aspect_too_wide";
            elseif ar(i) < 0.08
                rejectReason(i) = "aspect_too_thin";
            elseif ~isInTextBand(i)
                rejectReason(i) = "outside_text_band";
            elseif isMergedCandidate(i)
                rejectReason(i) = "merged_blob";
            else
                isAccepted(i) = true;
            end
        end

        candidateTable = table(candId, x, y, w, h, area, ar, extent, solidity, isAccepted, rejectReason, ...
            isInTextBand, borderTouchRatio, textBandScore, isWideBlob, isMergedCandidate, ...
            'VariableNames', {'CandidateId', 'X', 'Y', 'Width', 'Height', 'Area', 'AspectRatio', ...
            'Extent', 'Solidity', 'IsAccepted', 'RejectReason', 'IsInTextBand', ...
            'BorderTouchRatio', 'TextBandScore', 'IsWideBlob', 'IsMergedCandidate'});
        segmentationDebug.candidateTable = candidateTable;
        segmentationDebug.segmentationTable = candidateTable;

        accepted = candidateTable(candidateTable.IsAccepted, :);
        if isempty(accepted)
            segmentationDebug.status = "no_valid_components";
            segmentationDebug.acceptedCharacterCount = 0;
            segmentationDebug.warnings(end + 1) = "No character-like connected components found.";
            saveInfo = saveSegmentationResult(segmentationDebug);
            segmentationDebug.debugOutputDir = string(saveInfo.outputDir);
            return;
        end

        accepted = sortrows(accepted, 'X', 'ascend');
        characterBBoxes = [accepted.X, accepted.Y, accepted.Width, accepted.Height];
        segmentationDebug.characterBBoxes = characterBBoxes;

        if size(refinedPlateImg, 3) == 3
            grayRefined = rgb2gray(refinedPlateImg);
        else
            grayRefined = refinedPlateImg;
        end
        grayRefined = im2uint8(grayRefined);

        for i = 1:height(accepted)
            bbox = [accepted.X(i), accepted.Y(i), accepted.Width(i), accepted.Height(i)];
            [x1, y1, x2, y2] = localBBoxToIndices(bbox, size(grayRefined, 2), size(grayRefined, 1));
            charImg = grayRefined(y1:y2, x1:x2);
            charImg = imresize(charImg, [50 30]);
            characterImages{end + 1} = charImg; %#ok<AGROW>
        end
        segmentationDebug.characterImages = characterImages;

        segmentationDebug.acceptedCharacterCount = numel(characterImages);
        segmentationDebug.status = "ok";

        saveInfo = saveSegmentationResult(segmentationDebug);
        segmentationDebug.debugOutputDir = string(saveInfo.outputDir);
    catch ME
        characterImages = {};
        characterBBoxes = [];
        segmentationDebug.status = "segment_failed: " + string(ME.message);
        segmentationDebug.warnings(end + 1) = "Unhandled segmentation exception.";
        try
            saveInfo = saveSegmentationResult(segmentationDebug);
            segmentationDebug.debugOutputDir = string(saveInfo.outputDir);
        catch
        end
    end
end


function [x1, y1, x2, y2] = localBBoxToIndices(bbox, imgW, imgH)
    x1 = max(1, floor(bbox(1)));
    y1 = max(1, floor(bbox(2)));
    x2 = min(imgW, ceil(bbox(1) + bbox(3)));
    y2 = min(imgH, ceil(bbox(2) + bbox(4)));
    if x2 < x1
        x2 = x1;
    end
    if y2 < y1
        y2 = y1;
    end
end
