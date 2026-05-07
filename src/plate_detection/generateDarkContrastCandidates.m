function [rawCandidates, debugInfo] = generateDarkContrastCandidates(grayImg, edgeImg)
% generateDarkContrastCandidates  Method C candidate generation from dark/high-contrast regions.

    rawCandidates = table();
    debugInfo = struct( ...
        'darkRegionBinary', [], ...
        'numRegions', 0);

    if isempty(grayImg)
        return;
    end

    gray = localToGrayUint8(grayImg);
    grayN = mat2gray(gray);

    if isempty(edgeImg)
        edgeMask = edge(gray, 'Canny');
    else
        edgeMask = logical(edgeImg);
    end

    darkThresh = adaptthresh(grayN, 0.52, 'ForegroundPolarity', 'dark', 'NeighborhoodSize', [41 41]);
    darkMask = imbinarize(grayN, darkThresh);

    refWidth = 900;
    seScale = max(1, round(size(gray, 2) / refWidth));
    seClose = strel('rectangle', [3 * seScale, 18 * seScale]);
    seDilate = strel('rectangle', [2 * seScale, 10 * seScale]);
    darkMask = imclose(darkMask, seClose);
    darkMask = imdilate(darkMask, seDilate);

    minArea = max(40, round(numel(gray) * 0.00002));
    darkMask = bwareaopen(darkMask, minArea);

    debugInfo.darkRegionBinary = darkMask;

    cc = bwconncomp(darkMask);
    regions = regionprops(darkMask, gray, 'BoundingBox', 'Area', 'Extent', 'Solidity', 'MeanIntensity');
    debugInfo.numRegions = cc.NumObjects;

    if isempty(regions)
        return;
    end

    imgH = size(gray, 1);
    imgW = size(gray, 2);
    keep = false(numel(regions), 1);
    darkRegionScore = zeros(numel(regions), 1);
    brightComponentCount = zeros(numel(regions), 1);
    brightWidthCoverage = zeros(numel(regions), 1);
    brightCentroidOffset = zeros(numel(regions), 1);

    for i = 1:numel(regions)
        bb = regions(i).BoundingBox;
        x = bb(1); y = bb(2); w = bb(3); h = bb(4);

        if w < max(24, round(0.03 * imgW)) || h < max(10, round(0.012 * imgH))
            continue;
        end
        if h > 0.35 * imgH || w > 0.80 * imgW
            continue;
        end

        [x1, y1, x2, y2] = bboxToIndices(x, y, w, h, imgW, imgH);
        roiGray = double(gray(y1:y2, x1:x2));
        roiEdge = edgeMask(y1:y2, x1:x2);
        roiN = mat2gray(roiGray);

        darkRatio = nnz(roiN < 0.45) / max(1, numel(roiN));
        if darkRatio < 0.30
            continue;
        end

        tBright = adaptthresh(roiN, 0.55, 'ForegroundPolarity', 'bright', 'NeighborhoodSize', [19 19]);
        brightMask = imbinarize(roiN, tBright);
        brightMask = brightMask & roiEdge;
        brightMask = bwareaopen(brightMask, max(4, round(numel(brightMask) * 0.0015)));

        [compCount, widthCov, centroidOffset] = componentStats(brightMask);
        edgeDensity = nnz(roiEdge) / max(1, numel(roiEdge));

        scoreDark = min(max((darkRatio - 0.30) / 0.45, 0), 1);
        scoreComp = max(0, 1 - abs(compCount - 6) / 6);
        scoreCov = min(max((widthCov - 0.20) / 0.55, 0), 1);
        scoreEdge = min(max((edgeDensity - 0.04) / 0.20, 0), 1);
        centeringScore = max(0, 1 - centroidOffset / 0.40);
        drScore = 0.30 * scoreDark + 0.20 * scoreComp + 0.20 * scoreCov + 0.15 * scoreEdge + 0.15 * centeringScore;

        if compCount < 2 && widthCov < 0.15
            continue;
        end
        if widthCov < 0.18
            continue;
        end
        if centroidOffset > 0.38
            continue;
        end

        keep(i) = true;
        darkRegionScore(i) = min(max(drScore, 0), 1);
        brightComponentCount(i) = compCount;
        brightWidthCoverage(i) = widthCov;
        brightCentroidOffset(i) = centroidOffset;
    end

    regions = regions(keep);
    darkRegionScore = darkRegionScore(keep);
    brightComponentCount = brightComponentCount(keep);
    brightWidthCoverage = brightWidthCoverage(keep);
    brightCentroidOffset = brightCentroidOffset(keep);

    n = numel(regions);
    if n == 0
        return;
    end

    x = zeros(n, 1); y = zeros(n, 1); w = zeros(n, 1); h = zeros(n, 1);
    area = zeros(n, 1); extent = nan(n, 1); solidity = nan(n, 1); meanIntensity = nan(n, 1);
    for i = 1:n
        bb = regions(i).BoundingBox;
        x(i) = bb(1); y(i) = bb(2); w(i) = bb(3); h(i) = bb(4);
        area(i) = regions(i).Area;
        extent(i) = safeField(regions(i), 'Extent', NaN);
        solidity(i) = safeField(regions(i), 'Solidity', NaN);
        meanIntensity(i) = safeField(regions(i), 'MeanIntensity', NaN);
    end

    sourceMethod = repmat("dark_contrast", n, 1);
    groupType = repmat("single", n, 1);
    parentIds = strings(n, 1);
    sourceCount = ones(n, 1);

    rawCandidates = table((1:n)', sourceMethod, x, y, w, h, area, extent, solidity, meanIntensity, ...
        groupType, parentIds, sourceCount, darkRegionScore, brightComponentCount, brightWidthCoverage, brightCentroidOffset, ...
        'VariableNames', {'RegionIndex', 'SourceMethod', 'X', 'Y', 'Width', 'Height', ...
        'RegionArea', 'Extent', 'Solidity', 'MeanIntensity', 'GroupType', 'ParentCandidateIds', ...
        'SourceCount', 'DarkRegionScore', 'BrightComponentCount', 'BrightWidthCoverage', 'BrightCentroidOffset'});
end


function [compCount, widthCoverage, centroidOffset] = componentStats(bw)
    compCount = 0;
    widthCoverage = 0;
    centroidOffset = 1;
    if isempty(bw)
        return;
    end

    cc = bwconncomp(bw);
    if cc.NumObjects == 0
        return;
    end

    stats = regionprops(cc, 'BoundingBox', 'Area');
    roiH = size(bw, 1);
    roiW = size(bw, 2);
    keep = false(numel(stats), 1);
    minX = inf; maxX = -inf;
    cxAll = [];
    wAll = [];

    for k = 1:numel(stats)
        bb = stats(k).BoundingBox;
        w = bb(3); h = bb(4); a = stats(k).Area;
        ar = w / max(h, 1);
        if h < 0.16 * roiH || h > 0.95 * roiH
            continue;
        end
        if w < 0.01 * roiW || w > 0.42 * roiW
            continue;
        end
        if ar > 1.8
            continue;
        end
        if a < max(4, round(0.001 * roiH * roiW))
            continue;
        end
        keep(k) = true;
        minX = min(minX, bb(1));
        maxX = max(maxX, bb(1) + bb(3));
        cxAll(end + 1, 1) = bb(1) + bb(3) / 2; %#ok<AGROW>
        wAll(end + 1, 1) = bb(3) * bb(4); %#ok<AGROW>
    end

    compCount = sum(keep);
    if compCount > 0
        widthCoverage = max(0, min(1, (maxX - minX) / max(roiW, 1)));
        cwx = sum(cxAll .* wAll) / max(sum(wAll), 1);
        centroidOffset = abs((cwx / max(roiW, 1)) - 0.5) / 0.5;
        centroidOffset = min(max(centroidOffset, 0), 1);
    end
end


function [x1, y1, x2, y2] = bboxToIndices(x, y, w, h, imgW, imgH)
    x1 = max(1, floor(x));
    y1 = max(1, floor(y));
    x2 = min(imgW, ceil(x + w));
    y2 = min(imgH, ceil(y + h));
    if x2 < x1, x2 = x1; end
    if y2 < y1, y2 = y1; end
end


function grayOut = localToGrayUint8(inputImg)
    if size(inputImg, 3) == 3
        grayOut = rgb2gray(inputImg);
    else
        grayOut = inputImg;
    end
    if ~isa(grayOut, 'uint8')
        if isfloat(grayOut)
            grayOut = im2uint8(mat2gray(grayOut));
        else
            grayOut = im2uint8(mat2gray(double(grayOut)));
        end
    end
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
