function [refinedBBox, refineInfo] = refinePlateCandidateBBox(originalImg, grayImg, candidateBBox)
% refinePlateCandidateBBox  Refine a rough plate bbox using local text/edge structure.

    refineInfo = struct( ...
        'applied', false, ...
        'qualityScore', 0, ...
        'textCenterednessScore', 0, ...
        'textCoverageScore', 0, ...
        'tooSmall', false, ...
        'status', "not_started");

    refinedBBox = candidateBBox;

    if isempty(candidateBBox) || numel(candidateBBox) ~= 4
        refineInfo.status = "invalid_bbox";
        return;
    end

    if isempty(originalImg)
        refineInfo.status = "empty_image";
        return;
    end

    if nargin < 2 || isempty(grayImg)
        if size(originalImg, 3) == 3
            gray = rgb2gray(originalImg);
        else
            gray = originalImg;
        end
    else
        gray = grayImg;
    end

    if ~isa(gray, 'uint8')
        gray = im2uint8(mat2gray(double(gray)));
    end

    imgH = size(gray, 1);
    imgW = size(gray, 2);

    [x1, y1, x2, y2] = bboxToIndices(candidateBBox, imgW, imgH);
    roi = gray(y1:y2, x1:x2);

    if numel(roi) < 100
        refineInfo.status = "roi_too_small";
        return;
    end

    roiEq = adapthisteq(roi, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
    roiN = mat2gray(roiEq);
    e = edge(roiEq, 'Canny');

    tBright = adaptthresh(roiN, 0.54, 'ForegroundPolarity', 'bright', 'NeighborhoodSize', [17 17]);
    bwBright = imbinarize(roiN, tBright);
    bwBright = bwBright & e;
    bwBright = bwareaopen(bwBright, max(4, round(numel(bwBright) * 0.0012)));

    if nnz(bwBright) < 15
        refineInfo.status = "low_text_evidence";
        return;
    end

    colProj = sum(bwBright, 1);
    rowProj = sum(bwBright, 2);

    colThr = max(2, 0.20 * max(colProj));
    rowThr = max(2, 0.25 * max(rowProj));

    colIdx = find(colProj >= colThr);
    rowIdx = find(rowProj >= rowThr);
    if isempty(colIdx) || isempty(rowIdx)
        refineInfo.status = "projection_empty";
        return;
    end

    c1 = min(colIdx);
    c2 = max(colIdx);
    r1 = min(rowIdx);
    r2 = max(rowIdx);

    roiW = size(roi, 2);
    roiH = size(roi, 1);

    % Keep margin so we do not over-shrink to characters only.
    padX = max(6, round(0.10 * roiW));
    padY = max(4, round(0.18 * roiH));
    c1 = max(1, c1 - padX);
    c2 = min(roiW, c2 + padX);
    r1 = max(1, r1 - padY);
    r2 = min(roiH, r2 + padY);

    rw = c2 - c1 + 1;
    rh = r2 - r1 + 1;
    if rw < max(26, round(0.25 * candidateBBox(3))) || rh < max(10, round(0.35 * candidateBBox(4)))
        refineInfo.tooSmall = true;
        refineInfo.status = "refined_too_small";
        return;
    end

    newX = x1 + c1 - 1;
    newY = y1 + r1 - 1;
    newW = rw;
    newH = rh;
    refinedBBox = clampBBox([newX, newY, newW, newH], imgW, imgH);

    textCx = mean(colIdx) / max(roiW, 1);
    textCy = mean(rowIdx) / max(roiH, 1);
    centered = 1 - min(1, abs(textCx - 0.5) / 0.5) * 0.65 - min(1, abs(textCy - 0.55) / 0.55) * 0.35;
    centered = min(max(centered, 0), 1);
    coverage = nnz(bwBright) / max(1, numel(bwBright));
    coverageScore = min(max((coverage - 0.02) / 0.18, 0), 1);

    ar = refinedBBox(3) / max(refinedBBox(4), 1);
    arScore = max(0, 1 - abs(ar - 4.2) / 4.0);
    sizeRatio = (refinedBBox(3) * refinedBBox(4)) / max(candidateBBox(3) * candidateBBox(4), 1);
    sizeScore = max(0, 1 - abs(sizeRatio - 0.9) / 1.1);

    refineInfo.textCenterednessScore = centered;
    refineInfo.textCoverageScore = coverageScore;
    refineInfo.qualityScore = min(max(0.35 * centered + 0.25 * coverageScore + 0.20 * arScore + 0.20 * sizeScore, 0), 1);
    refineInfo.applied = true;
    refineInfo.status = "ok";
end


function [x1, y1, x2, y2] = bboxToIndices(bbox, imgW, imgH)
    x = bbox(1); y = bbox(2); w = bbox(3); h = bbox(4);
    x1 = max(1, floor(x));
    y1 = max(1, floor(y));
    x2 = min(imgW, ceil(x + w));
    y2 = min(imgH, ceil(y + h));
    if x2 < x1, x2 = x1; end
    if y2 < y1, y2 = y1; end
end


function b = clampBBox(b, imgW, imgH)
    x = max(1, b(1));
    y = max(1, b(2));
    w = max(1, b(3));
    h = max(1, b(4));
    if x + w > imgW
        w = max(1, imgW - x);
    end
    if y + h > imgH
        h = max(1, imgH - y);
    end
    b = [x, y, w, h];
end
