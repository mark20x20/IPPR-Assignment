function candidateTable = buildCandidateTable(rawCandidates, imageSize, edgeImg, grayOrEnhancedImg)
% buildCandidateTable  Build a unified candidate table with common metrics.

    candidateTable = table();

    if isempty(rawCandidates) || numel(imageSize) < 2
        return;
    end

    imgH = imageSize(1);
    imgW = imageSize(2);
    imgArea = max(1, imgH * imgW);

    hasEdge = ~isempty(edgeImg) && islogical(edgeImg);
    hasGray = ~isempty(grayOrEnhancedImg);

    if hasEdge
        globalEdgeDensity = nnz(edgeImg) / numel(edgeImg);
    else
        globalEdgeDensity = 0.08;
    end

    MIN_PIXEL_W = max(12, round(imgW * 0.012));
    MIN_PIXEL_H = max(6, round(imgH * 0.008));
    MIN_AR_HARD = 0.4;
    MAX_AR_HARD = 10.0;
    MIN_AREA_R_HARD = 0.00008;
    MAX_AREA_R_HARD = 0.35;

    n = height(rawCandidates);

    AreaPixels = rawCandidates.Width .* rawCandidates.Height;
    AspectRatio = rawCandidates.Width ./ max(rawCandidates.Height, 1);
    AreaRatio = AreaPixels / imgArea;
    CenterXRatio = (rawCandidates.X + rawCandidates.Width ./ 2) / max(imgW, 1);
    CenterYRatio = (rawCandidates.Y + rawCandidates.Height ./ 2) / max(imgH, 1);

    EdgeDensity = nan(n, 1);
    InteriorEdgeRatio = nan(n, 1);
    ContrastStd = nan(n, 1);
    CharacterStructureScore = nan(n, 1);
    CharacterComponentCount = nan(n, 1);
    CharacterWidthCoverage = nan(n, 1);

    for i = 1:n
        [x1, y1, x2, y2] = bboxToIndices(rawCandidates.X(i), rawCandidates.Y(i), rawCandidates.Width(i), rawCandidates.Height(i), imgW, imgH);

        if hasEdge
            roiEdge = edgeImg(y1:y2, x1:x2);
            EdgeDensity(i) = nnz(roiEdge) / max(1, numel(roiEdge));
            InteriorEdgeRatio(i) = computeInteriorRatio(roiEdge, 0.15);
        else
            EdgeDensity(i) = 0.0;
            InteriorEdgeRatio(i) = 0.0;
        end

        if hasGray
            roiGray = double(grayOrEnhancedImg(y1:y2, x1:x2));
            ContrastStd(i) = std(roiGray(:));
            [CharacterStructureScore(i), CharacterComponentCount(i), CharacterWidthCoverage(i)] = ...
                computeCharacterStructureMetrics(uint8(roiGray));
        else
            ContrastStd(i) = NaN;
            CharacterStructureScore(i) = NaN;
            CharacterComponentCount(i) = NaN;
            CharacterWidthCoverage(i) = NaN;
        end
    end

    IsValid = true(n, 1);
    RejectReason = repmat("passed", n, 1);

    for i = 1:n
        x = rawCandidates.X(i);
        y = rawCandidates.Y(i);
        w = rawCandidates.Width(i);
        h = rawCandidates.Height(i);

        if ~all(isfinite([x, y, w, h])) || w <= 1 || h <= 1
            IsValid(i) = false;
            RejectReason(i) = "bbox_invalid";
        elseif x < 0.5 || y < 0.5 || (x + w) > (imgW + 1) || (y + h) > (imgH + 1)
            IsValid(i) = false;
            RejectReason(i) = "bbox_bounds";
        elseif w < MIN_PIXEL_W || h < MIN_PIXEL_H
            IsValid(i) = false;
            RejectReason(i) = "width_height";
        elseif AspectRatio(i) < MIN_AR_HARD || AspectRatio(i) > MAX_AR_HARD
            IsValid(i) = false;
            RejectReason(i) = "aspect_ratio";
        elseif AreaRatio(i) < MIN_AREA_R_HARD || AreaRatio(i) > MAX_AREA_R_HARD
            IsValid(i) = false;
            RejectReason(i) = "area_ratio";
        end
    end

    if ~ismember('SourceMethod', rawCandidates.Properties.VariableNames)
        SourceMethod = repmat("unknown", n, 1);
    else
        SourceMethod = string(rawCandidates.SourceMethod);
    end

    if ismember('SourceCount', rawCandidates.Properties.VariableNames)
        SourceCount = max(1, double(rawCandidates.SourceCount));
    else
        SourceCount = ones(n, 1);
    end

    candidateTable = table(rawCandidates.RegionIndex, SourceMethod, rawCandidates.X, rawCandidates.Y, ...
        rawCandidates.Width, rawCandidates.Height, AreaPixels, AspectRatio, AreaRatio, ...
        CenterXRatio, CenterYRatio, EdgeDensity, InteriorEdgeRatio, ContrastStd, ...
        SourceCount, IsValid, RejectReason, ...
        'VariableNames', {'RegionIndex', 'SourceMethod', 'X', 'Y', 'Width', 'Height', ...
        'AreaPixels', 'AspectRatio', 'AreaRatio', 'CenterXRatio', 'CenterYRatio', ...
        'EdgeDensity', 'InteriorEdgeRatio', 'ContrastStd', 'SourceCount', 'IsValid', 'RejectReason'});

    if ismember('Extent', rawCandidates.Properties.VariableNames)
        candidateTable.Extent = rawCandidates.Extent;
    else
        candidateTable.Extent = nan(n, 1);
    end

    if ismember('Solidity', rawCandidates.Properties.VariableNames)
        candidateTable.Solidity = rawCandidates.Solidity;
    else
        candidateTable.Solidity = nan(n, 1);
    end

    if ismember('MeanIntensity', rawCandidates.Properties.VariableNames)
        candidateTable.MeanIntensity = rawCandidates.MeanIntensity;
    else
        candidateTable.MeanIntensity = nan(n, 1);
    end

    if ismember('GroupType', rawCandidates.Properties.VariableNames)
        candidateTable.GroupType = string(rawCandidates.GroupType);
    else
        candidateTable.GroupType = repmat("single", n, 1);
    end

    if ismember('ParentCandidateIds', rawCandidates.Properties.VariableNames)
        candidateTable.ParentCandidateIds = string(rawCandidates.ParentCandidateIds);
    else
        candidateTable.ParentCandidateIds = strings(n, 1);
    end

    candidateTable.RawGlobalEdgeDensity = repmat(globalEdgeDensity, n, 1);
    candidateTable.CharacterStructureScore = CharacterStructureScore;
    candidateTable.CharacterComponentCount = CharacterComponentCount;
    candidateTable.CharacterWidthCoverage = CharacterWidthCoverage;

    if ismember('DarkRegionScore', rawCandidates.Properties.VariableNames)
        candidateTable.DarkRegionScore = rawCandidates.DarkRegionScore;
    else
        candidateTable.DarkRegionScore = nan(n, 1);
    end
    if ismember('BrightComponentCount', rawCandidates.Properties.VariableNames)
        candidateTable.BrightComponentCount = rawCandidates.BrightComponentCount;
    else
        candidateTable.BrightComponentCount = nan(n, 1);
    end
    if ismember('BrightWidthCoverage', rawCandidates.Properties.VariableNames)
        candidateTable.BrightWidthCoverage = rawCandidates.BrightWidthCoverage;
    else
        candidateTable.BrightWidthCoverage = nan(n, 1);
    end
    if ismember('BrightCentroidOffset', rawCandidates.Properties.VariableNames)
        candidateTable.BrightCentroidOffset = rawCandidates.BrightCentroidOffset;
    else
        candidateTable.BrightCentroidOffset = nan(n, 1);
    end
    if ismember('GroupGeometryPenalty', rawCandidates.Properties.VariableNames)
        candidateTable.GroupGeometryPenalty = rawCandidates.GroupGeometryPenalty;
    else
        candidateTable.GroupGeometryPenalty = zeros(n, 1);
    end

    darkContrastScore = nan(n, 1);
    if ismember('DarkRegionScore', candidateTable.Properties.VariableNames)
        dr = candidateTable.DarkRegionScore;
    else
        dr = nan(n, 1);
    end
    if ismember('BrightComponentCount', candidateTable.Properties.VariableNames)
        bc = candidateTable.BrightComponentCount;
    else
        bc = nan(n, 1);
    end
    if ismember('BrightWidthCoverage', candidateTable.Properties.VariableNames)
        bwc = candidateTable.BrightWidthCoverage;
    else
        bwc = nan(n, 1);
    end
    for i = 1:n
        if ~isfinite(dr(i)) && ~isfinite(bc(i)) && ~isfinite(bwc(i))
            continue;
        end
        cScore = max(0, 1 - abs(zeroNaN(bc(i)) - 6) / 6);
        wScore = min(max((zeroNaN(bwc(i)) - 0.20) / 0.55, 0), 1);
        darkContrastScore(i) = 0.55 * zeroNaN(dr(i)) + 0.25 * cScore + 0.20 * wScore;
    end
    candidateTable.DarkContrastScore = darkContrastScore;
end


function interiorR = computeInteriorRatio(roi, shrinkFrac)
    if nargin < 2
        shrinkFrac = 0.15;
    end

    totalEdges = nnz(roi);
    if totalEdges == 0
        interiorR = 0;
        return;
    end

    roiH = size(roi, 1);
    roiW = size(roi, 2);
    padH = max(1, round(roiH * shrinkFrac));
    padW = max(1, round(roiW * shrinkFrac));

    r1 = padH + 1;
    r2 = roiH - padH;
    c1 = padW + 1;
    c2 = roiW - padW;

    if r2 < r1 || c2 < c1
        interiorR = 0;
        return;
    end

    interiorEdges = nnz(roi(r1:r2, c1:c2));
    interiorR = interiorEdges / totalEdges;
end


function [x1, y1, x2, y2] = bboxToIndices(x, y, w, h, imgW, imgH)
    x1 = max(1, floor(x));
    y1 = max(1, floor(y));
    x2 = min(imgW, ceil(x + w));
    y2 = min(imgH, ceil(y + h));

    if x2 < x1
        x2 = x1;
    end
    if y2 < y1
        y2 = y1;
    end
end


function [score, compCount, widthCoverage] = computeCharacterStructureMetrics(roiGray)
    score = 0;
    compCount = 0;
    widthCoverage = 0;

    if isempty(roiGray) || size(roiGray, 1) < 8 || size(roiGray, 2) < 20
        return;
    end

    roiN = mat2gray(roiGray);
    t = adaptthresh(roiN, 0.45, 'NeighborhoodSize', [21 21]);
    bw = imbinarize(roiN, t);

    edgePix = nnz(bw);
    invPix = nnz(~bw);
    if invPix > edgePix
        bw = ~bw;
    end

    bw = bwareaopen(bw, max(6, round(numel(bw) * 0.002)));
    cc = bwconncomp(bw);
    if cc.NumObjects == 0
        return;
    end

    stats = regionprops(cc, 'BoundingBox', 'Area');
    roiH = size(bw, 1);
    roiW = size(bw, 2);

    keep = false(numel(stats), 1);
    cX = [];
    cY = [];
    widths = [];

    for k = 1:numel(stats)
        bb = stats(k).BoundingBox;
        w = bb(3);
        h = bb(4);
        ar = w / max(h, 1);
        a = stats(k).Area;

        if h < 0.18 * roiH || h > 0.95 * roiH
            continue;
        end
        if w < 0.01 * roiW || w > 0.45 * roiW
            continue;
        end
        if ar > 1.8
            continue;
        end
        if a < max(6, round(0.001 * roiH * roiW))
            continue;
        end

        keep(k) = true;
        cX(end + 1, 1) = bb(1) + w / 2; %#ok<AGROW>
        cY(end + 1, 1) = bb(2) + h / 2; %#ok<AGROW>
        widths(end + 1, 1) = w; %#ok<AGROW>
    end

    compCount = sum(keep);
    if compCount == 0
        score = 0;
        return;
    end

    minX = inf;
    maxX = -inf;
    for k = find(keep(:))'
        bb = stats(k).BoundingBox;
        minX = min(minX, bb(1));
        maxX = max(maxX, bb(1) + bb(3));
    end
    widthCoverage = max(0, min(1, (maxX - minX) / max(roiW, 1)));

    countScore = max(0, 1 - abs(compCount - 6) / 5);
    if compCount < 2
        countScore = countScore * 0.2;
    end
    if compCount > 12
        countScore = countScore * 0.5;
    end

    baselineSpread = std(cY) / max(roiH, 1);
    baselineScore = max(0, 1 - baselineSpread / 0.18);

    coverageScore = min(max((widthCoverage - 0.22) / 0.45, 0), 1);

    widthVar = std(widths) / max(mean(widths), 1);
    widthConsistencyScore = max(0, 1 - widthVar / 1.0);

    score = 0.35 * countScore + 0.30 * baselineScore + 0.25 * coverageScore + 0.10 * widthConsistencyScore;
    score = min(max(score, 0), 1);
end


function y = zeroNaN(x)
    y = x;
    if ~isfinite(y)
        y = 0;
    end
end
