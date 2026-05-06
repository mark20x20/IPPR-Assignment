function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
% detectPlateRegion  Detects and crops the most likely license plate region.
%
% Member 2 module: License Plate Detection
% Classical image processing only.

    plateImg  = [];
    plateBBox = [];

    debugInfo = struct( ...
        'grayImg', [], ...
        'enhancedImg', [], ...
        'edgeImg', [], ...
        'closedImg', [], ...
        'filledImg', [], ...
        'cleanedImg', [], ...
        'candidateMask', [], ...
        'regions', [], ...
        'numConnectedComponents', 0, ...
        'numRegionsBeforeFiltering', 0, ...
        'regionStatsSummary', struct(), ...
        'candidateDiagnostics', table(), ...
        'rejectReasonSummary', table(), ...
        'candidateTable', table(), ...
        'plateFound', false, ...
        'status', "Not started" ...
    );

    if nargin < 2 || isempty(preprocessedImg) || isempty(originalImg)
        debugInfo.status = "Input image is empty or missing.";
        warning('detectPlateRegion: empty input received. Returning fallback.');
        return;
    end

    try
        grayImg = localToGrayUint8(preprocessedImg);

        MAX_WORKING_WIDTH = 900;
        [imgH, imgW] = size(grayImg); %#ok<ASGLU>
        if imgW > MAX_WORKING_WIDTH
            scaleFactor      = MAX_WORKING_WIDTH / imgW;
            grayImg          = imresize(grayImg, scaleFactor);
            preprocessedImg  = imresize(preprocessedImg, scaleFactor);
            originalImgSmall = imresize(originalImg, scaleFactor);
        else
            scaleFactor      = 1.0;
            originalImgSmall = originalImg;
        end

        enhancedImg = adapthisteq(grayImg, ...
            'ClipLimit', 0.015, ...
            'Distribution', 'rayleigh');

        smoothImg = imgaussfilt(enhancedImg, 1.0);

        edgeImg = edge(smoothImg, 'Canny');

        refWidth     = 900;
        seScale      = max(1, round(size(grayImg, 2) / refWidth));
        horizontalSE = strel('rectangle', [2 * seScale, 18 * seScale]);
        twoRowSE     = strel('rectangle', [4 * seScale, 14 * seScale]);

        closedHorizontal = imclose(edgeImg, horizontalSE);
        closedTwoRow     = imclose(edgeImg, twoRowSE);
        closedImg        = closedHorizontal | closedTwoRow;

        % Remove oversized components before hole-filling to avoid deleting
        % a car-wide silhouette created by global fill.
        minArea = max(40, round(numel(grayImg) * 0.00002));
        cleanedImg = bwareaopen(closedImg, minArea);
        cleanedImg = removeOversizedComponents(cleanedImg, 0.25);
        filledImg = imfill(cleanedImg, 'holes');
        cleanedImg = filledImg;
        topMargin = max(1, round(size(cleanedImg, 1) * 0.04));
        borderMask = false(size(cleanedImg));
        borderMask(1:topMargin, :) = true;
        cleanedImg(borderMask & cleanedImg) = false;
        bridgeSE   = strel('rectangle', [2, 1]);
        cleanedImg = imerode(cleanedImg, bridgeSE);
        cleanedImg = bwareaopen(cleanedImg, minArea);
        cc = bwconncomp(cleanedImg);
        debugInfo.numConnectedComponents = cc.NumObjects;

        regions = regionprops(cleanedImg, enhancedImg, ...
            'BoundingBox', 'Area', 'Extent', 'Solidity', ...
            'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', ...
            'MeanIntensity');
        debugInfo.numRegionsBeforeFiltering = numel(regions);
        debugInfo.regionStatsSummary = buildRegionStatsSummary(regions, size(grayImg));

        % CRITICAL FIX:
        % Pass edgeImg so selectPlateCandidate activates edge-based filtering.
        [plateBBoxSmall, candidateTable] = selectPlateCandidate(regions, size(grayImg), edgeImg);
        candidateDiagnostics = getappdata(0, 'selectPlateCandidateDiagnostics');
        if istable(candidateDiagnostics)
            debugInfo.candidateDiagnostics = candidateDiagnostics;
            if ~isempty(candidateDiagnostics) && any(strcmp(candidateDiagnostics.Properties.VariableNames, 'RejectReason'))
                rejectReasons = string(candidateDiagnostics.RejectReason);
                [uReasons, ~, idx] = unique(rejectReasons);
                counts = accumarray(idx, 1);
                debugInfo.rejectReasonSummary = table(uReasons, counts, ...
                    'VariableNames', {'Reason', 'Count'});
                debugInfo.rejectReasonSummary = sortrows(debugInfo.rejectReasonSummary, 'Count', 'descend');
            end
        end

        plateImg = cropPlateRegion(originalImgSmall, plateBBoxSmall);
        plateBBox = plateBBoxSmall;
        if ~isempty(plateBBoxSmall) && scaleFactor < 1.0
            plateBBox = [ ...
                plateBBoxSmall(1) / scaleFactor, ...
                plateBBoxSmall(2) / scaleFactor, ...
                plateBBoxSmall(3) / scaleFactor, ...
                plateBBoxSmall(4) / scaleFactor];
            plateImg = cropPlateRegion(originalImg, plateBBox);
        end

        candidateMask = false(size(grayImg));
        if ~isempty(plateBBox)
            candidateMask = insertCandidateMask(candidateMask, plateBBox);
        end

        debugInfo.grayImg         = grayImg;
        debugInfo.enhancedImg     = enhancedImg;
        debugInfo.edgeImg         = edgeImg;
        debugInfo.closedImg       = closedImg;
        debugInfo.filledImg       = filledImg;
        debugInfo.cleanedImg      = cleanedImg;
        debugInfo.candidateMask   = candidateMask;
        debugInfo.regions         = regions;
        debugInfo.candidateTable  = candidateTable;

        if isempty(plateImg)
            debugInfo.plateFound = false;
            plateBBox = [];
            debugInfo.status = "No valid plate candidate found. Safe fallback returned.";
            warning('detectPlateRegion: no plate candidate passed all filters.');
        else
            debugInfo.plateFound = true;
            debugInfo.status = "Plate candidate detected and cropped successfully.";
            fprintf('[detectPlateRegion] Plate found at [%.0f %.0f %.0f %.0f]\n', plateBBox);
        end

    catch ME
        plateImg = [];
        plateBBox = [];
        debugInfo.plateFound = false;
        debugInfo.status = "Detection failed safely: " + string(ME.message);
        warning('detectPlateRegion: caught error - %s', ME.message);
    end
end


function bwOut = removeOversizedComponents(bwIn, maxAreaRatio)
    bwOut = bwIn;
    if isempty(bwIn)
        return;
    end

    cc = bwconncomp(bwIn);
    if cc.NumObjects == 0
        return;
    end

    imgArea = numel(bwIn);
    maxArea = maxAreaRatio * imgArea;
    stats = regionprops(cc, 'Area');

    keepMask = true(size(bwIn));
    for k = 1:cc.NumObjects
        if stats(k).Area > maxArea
            keepMask(cc.PixelIdxList{k}) = false;
        end
    end

    bwOut = bwIn & keepMask;
end


function stats = buildRegionStatsSummary(regions, imageSize)
    stats = struct( ...
        'numRegions', 0, ...
        'imageArea', imageSize(1) * imageSize(2), ...
        'areaMin', NaN, ...
        'areaMedian', NaN, ...
        'areaMax', NaN, ...
        'aspectMin', NaN, ...
        'aspectMedian', NaN, ...
        'aspectMax', NaN ...
    );

    if isempty(regions)
        return;
    end

    areas = [regions.Area]';
    bboxes = reshape([regions.BoundingBox], 4, []).';
    widths = bboxes(:, 3);
    heights = max(bboxes(:, 4), 1);
    aspects = widths ./ heights;

    stats.numRegions   = numel(regions);
    stats.areaMin      = min(areas);
    stats.areaMedian   = median(areas);
    stats.areaMax      = max(areas);
    stats.aspectMin    = min(aspects);
    stats.aspectMedian = median(aspects);
    stats.aspectMax    = max(aspects);
end


function grayImg = localToGrayUint8(inputImg)
    if size(inputImg, 3) == 3
        grayImg = rgb2gray(inputImg);
    else
        grayImg = inputImg;
    end

    if isa(grayImg, 'uint8')
        return;
    end

    if isfloat(grayImg)
        grayImg = im2uint8(mat2gray(grayImg));
    else
        grayImg = im2uint8(mat2gray(double(grayImg)));
    end
end


function mask = insertCandidateMask(mask, bbox)
    imgH = size(mask, 1);
    imgW = size(mask, 2);

    x1 = max(1, floor(bbox(1)));
    y1 = max(1, floor(bbox(2)));
    x2 = min(imgW, ceil(bbox(1) + bbox(3)));
    y2 = min(imgH, ceil(bbox(2) + bbox(4)));

    if x2 > x1 && y2 > y1
        mask(y1:y2, x1:x2) = true;
    end
end
