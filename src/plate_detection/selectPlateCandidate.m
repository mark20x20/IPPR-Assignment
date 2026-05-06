function [bestBBox, candidateTable] = selectPlateCandidate(regions, imageSize, edgeImg)
% selectPlateCandidate  Selects the best license plate candidate region.
%
% Inputs:
%   regions   - struct array from regionprops
%   imageSize - [height, width] of source grayscale image
%   edgeImg   - binary Canny edge map from detectPlateRegion
%
% Outputs:
%   bestBBox       - [x y width height] of winning candidate, [] if none
%   candidateTable - surviving candidates sorted by normalised area with diagnostics

    bestBBox       = [];
    candidateTable = table();

    if isempty(regions) || numel(imageSize) < 2
        return;
    end

    hasEdge = nargin >= 3 && ~isempty(edgeImg) && islogical(edgeImg);

    imgH    = imageSize(1);
    imgW    = imageSize(2);
    imgArea = imgH * imgW;

    if hasEdge
        globalEdgeDensity = sum(edgeImg(:)) / max(numel(edgeImg), 1);
    else
        globalEdgeDensity = 0.08;   % safe fallback
    end

    % (A) Image-geometry adaptive thresholds.
    % Pixel-size gates scale with image dimensions.
    MIN_PIXEL_W = max(20, round(imgW * 0.022));
    MIN_PIXEL_H = max(8,  round(imgH * 0.010));

    % (B) Edge-statistics adaptive thresholds.
    % Gates adapt to scene contrast.
    MIN_EDGE_DENSITY = max(0.03, globalEdgeDensity * 0.40);
    MAX_EDGE_DENSITY = min(0.70, globalEdgeDensity * 3.50);
    MIN_STRIP_STD    = max(0.008, globalEdgeDensity * 0.12);

    % (C) Scale-invariant geometry ratios.
    MIN_AR         = 1.5;
    MAX_AR         = 6.5;
    MIN_AREA_R     = 0.0003;
    MAX_AREA_R     = 0.12;
    MIN_EXTENT     = 0.36;
    MIN_SOLIDITY   = 0.45;
    MIN_INTERIOR_R = 0.30;

    imgAspect = imgW / max(imgH, 1);

    fprintf('[selectPlateCandidate] imgW=%d imgH=%d imgAspect=%.2f | ', ...
            imgW, imgH, imgAspect);
    fprintf('globalEdgeDensity=%.4f | ', globalEdgeDensity);
    fprintf('MIN_PIXEL_W=%d MIN_PIXEL_H=%d | ', MIN_PIXEL_W, MIN_PIXEL_H);
    fprintf('MIN_EDGE_DENSITY=%.4f MAX_EDGE_DENSITY=%.4f MIN_STRIP_STD=%.4f\n', ...
            MIN_EDGE_DENSITY, MAX_EDGE_DENSITY, MIN_STRIP_STD);

    rows        = [];
    diagRows    = [];
    diagReasons = strings(0, 1);

    % Survivor lists for post-loop winner selection.
    survBBoxes      = {};
    survAreaPixels  = [];
    survArDeviation = [];
    survAspectRatio = [];

    for i = 1:numel(regions)

        bbox = regions(i).BoundingBox;
        reason = "passed";
        survived = false;
        x = NaN; y = NaN; w = NaN; h = NaN;
        aspectRatio = NaN; areaRatio = NaN;
        extent = NaN; solidity = NaN;
        edgeDensity = NaN; stripStd = NaN; interiorR = NaN;

        if numel(bbox) ~= 4
            reason = "bbox_format";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        x = bbox(1);
        y = bbox(2);
        w = bbox(3);
        h = bbox(4);

        if w < MIN_PIXEL_W || h < MIN_PIXEL_H
            reason = "width_height";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        if x < 0.5 || y < 0.5 || (x + w) > (imgW + 1) || (y + h) > (imgH + 1)
            reason = "bbox_bounds";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        aspectRatio = w / max(h, 1);
        areaRatio   = (w * h) / imgArea;

        if aspectRatio < MIN_AR || aspectRatio > MAX_AR
            reason = "aspect_ratio";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        if areaRatio < MIN_AREA_R || areaRatio > MAX_AREA_R
            reason = "area_ratio";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        extent   = safeField(regions, i, 'Extent',   0.45);
        solidity = safeField(regions, i, 'Solidity', 0.45);

        if extent < MIN_EXTENT
            reason = "extent";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        if solidity < MIN_SOLIDITY
            reason = "solidity";
            diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
            diagReasons(end + 1, 1) = reason; %#ok<AGROW>
            continue;
        end

        if hasEdge
            x1e = max(1,    floor(x));
            y1e = max(1,    floor(y));
            x2e = min(imgW, ceil(x + w));
            y2e = min(imgH, ceil(y + h));

            roi = edgeImg(y1e:y2e, x1e:x2e);

            edgeDensity = sum(roi(:)) / max(numel(roi), 1);
            if edgeDensity < MIN_EDGE_DENSITY || edgeDensity > MAX_EDGE_DENSITY
                reason = "edge_density";
                diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                    extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
                diagReasons(end + 1, 1) = reason; %#ok<AGROW>
                continue;
            end

            stripStd = computeStripStd(roi, 5);
            if stripStd < MIN_STRIP_STD
                reason = "strip_std";
                diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                    extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
                diagReasons(end + 1, 1) = reason; %#ok<AGROW>
                continue;
            end

            interiorR = computeInteriorRatio(roi, 0.15);
            if interiorR < MIN_INTERIOR_R
                reason = "interior_ratio";
                diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                    extent, solidity, edgeDensity, stripStd, interiorR, 0]]; %#ok<AGROW>
                diagReasons(end + 1, 1) = reason; %#ok<AGROW>
                continue;
            end
        else
            edgeDensity = 0.18;
            stripStd    = 0.08;
            interiorR   = 0.65;
        end

        survived = true;

        % Geometric diagnostics kept for the table.
        centerXRatio = (x + w / 2) / imgW;
        centerYRatio = (y + h / 2) / imgH;

        leftD   = x / imgW;
        rightD  = (imgW - (x + w)) / imgW;
        topD    = y / imgH;
        bottomD = (imgH - (y + h)) / imgH;

        minBorderDist     = min([leftD, rightD, topD, bottomD]);
        edgeDistanceScore = min(minBorderDist / 0.06, 1);

        % Score column stores normalised pixel area.
        % Individual sub-score columns are zeroed; the weighted formula
        % is replaced by the post-loop priority selection below.
        normArea    = (w * h) / imgArea;
        arDeviation = abs(aspectRatio - 3.8);

        % Record survivor for winner selection after the loop.
        survBBoxes{end + 1}       = bbox; %#ok<AGROW>
        survAreaPixels(end + 1)   = w * h; %#ok<AGROW>
        survArDeviation(end + 1)  = arDeviation; %#ok<AGROW>
        survAspectRatio(end + 1)  = aspectRatio; %#ok<AGROW>

        % 27-column row — sub-score slots zeroed to preserve table schema.
        rows = [rows; [i, x, y, w, h, aspectRatio, areaRatio, extent, ...
                        solidity, 0, edgeDensity, stripStd, interiorR, ...
                        centerXRatio, centerYRatio, edgeDistanceScore, ...
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, normArea]]; %#ok<AGROW>
        diagRows = [diagRows; [i, x, y, w, h, aspectRatio, areaRatio, ...
            extent, solidity, edgeDensity, stripStd, interiorR, double(survived)]]; %#ok<AGROW>
        diagReasons(end + 1, 1) = reason; %#ok<AGROW>
    end

    % --- Winner selection (replaces weighted scoring) ---
    % Priority 1: Among survivors with clearly plate-shaped AR [2.5, 5.5],
    %             select the one with the largest pixel area.
    % Priority 2: If no survivor falls in [2.5, 5.5], select the one with
    %             the smallest deviation from the typical Malaysian AR of 3.8.
    if ~isempty(survBBoxes)
        plateLike = survAspectRatio >= 2.5 & survAspectRatio <= 5.5;
        if any(plateLike)
            candidates = find(plateLike);
            [~, rel]  = max(survAreaPixels(plateLike));
            winnerIdx = candidates(rel);
        else
            [~, winnerIdx] = min(survArDeviation);
        end
        bestBBox = survBBoxes{winnerIdx};
        fprintf('[selectPlateCandidate] Winner: AR=%.2f areaPixels=%d bbox=[%.0f %.0f %.0f %.0f]\n', ...
                survAspectRatio(winnerIdx), survAreaPixels(winnerIdx), bestBBox);
    end

    if ~isempty(rows)
        candidateTable = array2table(rows, 'VariableNames', { ...
            'RegionIndex', 'X', 'Y', 'Width', 'Height', 'AspectRatio', ...
            'AreaRatio', 'Extent', 'Solidity', 'Eccentricity', ...
            'EdgeDensity', 'StripStd', 'InteriorRatio', ...
            'CenterXRatio', 'CenterYRatio', 'EdgeDistanceScore', ...
            'AspectScore', 'EdgeDensityScore', 'EdgeUniformScore', 'AreaScore', ...
            'VerticalScore', 'InteriorScore', 'ExtentScore', 'HorizontalScore', ...
            'EccentricityScore', 'SolidityScore', 'Score'});

        candidateTable = sortrows(candidateTable, 'Score', 'descend');
    end

    if ~isempty(diagRows)
        diagTable = array2table(diagRows, 'VariableNames', { ...
            'RegionIndex', 'X', 'Y', 'Width', 'Height', 'AspectRatio', ...
            'AreaRatio', 'Extent', 'Solidity', 'EdgeDensity', 'StripStd', ...
            'InteriorRatio', 'Survived'});
        diagTable.RejectReason = diagReasons;
        setappdata(0, 'selectPlateCandidateDiagnostics', diagTable);
    else
        setappdata(0, 'selectPlateCandidateDiagnostics', table());
    end
end


function stripStd = computeStripStd(roi, nStrips)
    if nargin < 2
        nStrips = 5;
    end

    roiH = size(roi, 1);
    if roiH < nStrips
        stripStd = 0;
        return;
    end

    stripEdges = linspace(1, roiH + 1, nStrips + 1);
    densities  = zeros(1, nStrips);

    for s = 1:nStrips
        r1 = floor(stripEdges(s));
        r2 = max(r1, floor(stripEdges(s + 1)) - 1);
        strip = roi(r1:r2, :);
        densities(s) = sum(strip(:)) / max(numel(strip), 1);
    end

    stripStd = std(densities);
end


function interiorR = computeInteriorRatio(roi, shrinkFrac)
    if nargin < 2
        shrinkFrac = 0.15;
    end

    totalEdges = sum(roi(:));
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

    interiorEdges = sum(sum(roi(r1:r2, c1:c2)));
    interiorR     = double(interiorEdges) / double(totalEdges);
end


function value = safeField(regions, index, fieldName, defaultValue)
    value = defaultValue;

    if isfield(regions, fieldName)
        temp = regions(index).(fieldName);
        if ~isempty(temp) && isscalar(temp) && isfinite(double(temp))
            value = double(temp);
        end
    end
end
