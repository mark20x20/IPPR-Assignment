function [rawCandidates, methodDebug] = generateEdgeMorphCandidates(preprocessedImg)
% generateEdgeMorphCandidates  Generate plate candidates using edge+morphology.
% Method A only (Phase 1).

    rawCandidates = table();
    methodDebug = struct( ...
        'grayImg', [], ...
        'enhancedImg', [], ...
        'edgeImg', [], ...
        'closedImg', [], ...
        'filledImg', [], ...
        'cleanedImg', [], ...
        'regions', [], ...
        'numConnectedComponents', 0, ...
        'numRegionsBeforeFiltering', 0);

    if isempty(preprocessedImg)
        return;
    end

    grayImg = localToGrayUint8(preprocessedImg);
    enhancedImg = adapthisteq(grayImg, 'ClipLimit', 0.015, 'Distribution', 'rayleigh');

    smoothImg = imgaussfilt(enhancedImg, 1.0);
    edgeImg = edge(smoothImg, 'Canny');

    refWidth = 900;
    seScale = max(1, round(size(grayImg, 2) / refWidth));
    horizontalSE = strel('rectangle', [2 * seScale, 18 * seScale]);
    twoRowSE = strel('rectangle', [4 * seScale, 14 * seScale]);

    closedHorizontal = imclose(edgeImg, horizontalSE);
    closedTwoRow = imclose(edgeImg, twoRowSE);
    closedImg = closedHorizontal | closedTwoRow;

    minArea = max(40, round(numel(grayImg) * 0.00002));
    cleanedImg = bwareaopen(closedImg, minArea);
    cleanedImg = removeOversizedComponents(cleanedImg, 0.25);
    filledImg = imfill(cleanedImg, 'holes');
    cleanedImg = filledImg;

    topMargin = max(1, round(size(cleanedImg, 1) * 0.04));
    cleanedImg(1:topMargin, :) = false;

    bridgeSE = strel('rectangle', [2, 1]);
    cleanedImg = imerode(cleanedImg, bridgeSE);
    cleanedImg = bwareaopen(cleanedImg, minArea);

    cc = bwconncomp(cleanedImg);
    regions = regionprops(cleanedImg, enhancedImg, ...
        'BoundingBox', 'Area', 'Extent', 'Solidity', ...
        'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', ...
        'MeanIntensity');

    methodDebug.grayImg = grayImg;
    methodDebug.enhancedImg = enhancedImg;
    methodDebug.edgeImg = edgeImg;
    methodDebug.closedImg = closedImg;
    methodDebug.filledImg = filledImg;
    methodDebug.cleanedImg = cleanedImg;
    methodDebug.regions = regions;
    methodDebug.numConnectedComponents = cc.NumObjects;
    methodDebug.numRegionsBeforeFiltering = numel(regions);

    if isempty(regions)
        return;
    end

    numRegions = numel(regions);
    x = zeros(numRegions, 1);
    y = zeros(numRegions, 1);
    w = zeros(numRegions, 1);
    h = zeros(numRegions, 1);
    area = zeros(numRegions, 1);
    extent = zeros(numRegions, 1);
    solidity = zeros(numRegions, 1);
    meanIntensity = zeros(numRegions, 1);

    for i = 1:numRegions
        bbox = regions(i).BoundingBox;
        x(i) = bbox(1);
        y(i) = bbox(2);
        w(i) = bbox(3);
        h(i) = bbox(4);
        area(i) = regions(i).Area;
        extent(i) = safeField(regions(i), 'Extent', NaN);
        solidity(i) = safeField(regions(i), 'Solidity', NaN);
        meanIntensity(i) = safeField(regions(i), 'MeanIntensity', NaN);
    end

    sourceMethod = repmat("edge_morph", numRegions, 1);
    rawCandidates = table((1:numRegions)', sourceMethod, x, y, w, h, area, extent, solidity, meanIntensity, ...
        'VariableNames', {'RegionIndex', 'SourceMethod', 'X', 'Y', 'Width', 'Height', ...
        'RegionArea', 'Extent', 'Solidity', 'MeanIntensity'});
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


function value = safeField(region, fieldName, defaultValue)
    value = defaultValue;
    if isfield(region, fieldName)
        temp = region.(fieldName);
        if ~isempty(temp) && isscalar(temp) && isfinite(double(temp))
            value = double(temp);
        end
    end
end
