function [rawCandidates, debugInfo] = generateVerticalEdgeCandidates(grayImg, edgeImg)
% generateVerticalEdgeCandidates  Method B candidate generation from vertical edge density.

    rawCandidates = table();
    debugInfo = struct( ...
        'verticalEdgeResponse', [], ...
        'verticalEdgeBinary', [], ...
        'verticalEdgeCleaned', [], ...
        'numRegions', 0);

    if isempty(grayImg)
        return;
    end

    gray = localToGrayUint8(grayImg);
    grayD = double(gray);

    if isempty(edgeImg)
        edgeSupport = edge(gray, 'Canny');
    else
        edgeSupport = logical(edgeImg);
    end

    sobelV = fspecial('sobel')';
    verticalResp = abs(imfilter(grayD, sobelV, 'replicate', 'same'));
    verticalRespN = mat2gray(verticalResp);

    t = adaptthresh(verticalRespN, 0.45, 'NeighborhoodSize', [31 31]);
    bw = imbinarize(verticalRespN, t);
    bw = bw & edgeSupport;

    refWidth = 900;
    seScale = max(1, round(size(gray, 2) / refWidth));
    seH1 = strel('rectangle', [2 * seScale, 14 * seScale]);
    seH2 = strel('rectangle', [3 * seScale, 10 * seScale]);
    bw = imclose(bw, seH1);
    bw = imdilate(bw, seH2);

    minArea = max(30, round(numel(gray) * 0.000015));
    bw = bwareaopen(bw, minArea);

    topMargin = max(1, round(size(bw, 1) * 0.03));
    bw(1:topMargin, :) = false;

    cc = bwconncomp(bw);
    regions = regionprops(bw, gray, 'BoundingBox', 'Area', 'Extent', 'Solidity', 'MeanIntensity');

    debugInfo.verticalEdgeResponse = im2uint8(verticalRespN);
    debugInfo.verticalEdgeBinary = bw;
    debugInfo.verticalEdgeCleaned = bw;
    debugInfo.numRegions = cc.NumObjects;

    if isempty(regions)
        return;
    end

    imgH = size(gray, 1);
    imgW = size(gray, 2);
    maxRegionArea = 0.16 * imgH * imgW;
    keep = false(numel(regions), 1);
    for i = 1:numel(regions)
        bb = regions(i).BoundingBox;
        w = bb(3);
        h = bb(4);
        ar = w / max(h, 1);
        a = regions(i).Area;

        if a < minArea
            continue;
        end
        if a > maxRegionArea
            continue;
        end
        if h > 0.55 * imgH
            continue;
        end
        if (w <= 6 && h > 40)
            continue;
        end
        if (ar > 14.0 && h < 18)
            continue;
        end
        % Conservative cleanup: suppress tiny bottom-strip fragments.
        if (h < 12) && (w < 55) && ((bb(2) + h / 2) > 0.84 * imgH)
            continue;
        end
        keep(i) = true;
    end

    regions = regions(keep);
    numRegions = numel(regions);
    if numRegions == 0
        return;
    end

    x = zeros(numRegions, 1);
    y = zeros(numRegions, 1);
    w = zeros(numRegions, 1);
    h = zeros(numRegions, 1);
    area = zeros(numRegions, 1);
    extent = nan(numRegions, 1);
    solidity = nan(numRegions, 1);
    meanIntensity = nan(numRegions, 1);

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

    sourceMethod = repmat("vertical_edge", numRegions, 1);
    groupType = repmat("single", numRegions, 1);
    parentIds = strings(numRegions, 1);
    sourceCount = ones(numRegions, 1);

    rawCandidates = table((1:numRegions)', sourceMethod, x, y, w, h, area, extent, solidity, meanIntensity, ...
        groupType, parentIds, sourceCount, ...
        'VariableNames', {'RegionIndex', 'SourceMethod', 'X', 'Y', 'Width', 'Height', ...
        'RegionArea', 'Extent', 'Solidity', 'MeanIntensity', 'GroupType', 'ParentCandidateIds', 'SourceCount'});
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
