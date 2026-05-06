function [bestBBox, candidateTable] = selectPlateCandidate(regions, imageSize)
% selectPlateCandidate  Selects the best license plate candidate region.
%
% Candidates from regionprops are scored using eight normalised geometric
% and intensity features. Hard filters eliminate obviously non-plate regions
% first, then the weighted score ranks survivors. The highest-scoring
% candidate is returned as the detected plate bounding box.
%
% Feature weights (sum = 1.00):
%   0.24  Aspect ratio      — plates are wide rectangles (target ~4:1)
%   0.20  Area ratio        — plates occupy a predictable image fraction
%   0.14  Rectangular extent— plates fill their bounding boxes well
%   0.12  Solidity          — compact, convex blobs preferred
%   0.10  Eccentricity      — elongated shapes preferred
%   0.11  Vertical position — plates usually in lower 40-80% of image
%   0.05  Horizontal centre — plates near horizontal centre of vehicle
%   0.04  Mean intensity    — weak signal; avoids very dark/bright noise
%
% Inputs:
%   regions   - struct array from regionprops (see detectPlateRegion)
%   imageSize - [height, width] of the source grayscale image
%
% Outputs:
%   bestBBox       - [x y width height] of winning candidate, [] if none
%   candidateTable - table of all accepted candidates sorted by score
%                    (useful for report experimental results section)
%
% Author : Member 2
% Module : src/plate_detection/selectPlateCandidate.m

    bestBBox       = [];
    candidateTable = table();

    if isempty(regions) || numel(imageSize) < 2
        return;
    end

    imgH    = imageSize(1);
    imgW    = imageSize(2);
    imgArea = imgH * imgW;

    % --- Hard filter thresholds -------------------------------------------
    % These are set wide enough to accommodate all plate types shown in the
    % assignment: normal single-row, two-row, military, diplomatic, special.
    MIN_PIXEL_W  = 15;     % ignore tiny noise blobs
    MIN_PIXEL_H  = 8;
    MIN_AR       = 1.4;    % two-row plates can be squarish (~2:1)
    MAX_AR       = 7.5;    % normal plates rarely exceed 5:1; allow margin
    MIN_AREA_R   = 0.0008; % very small fraction = noise or distant plate
    MAX_AREA_R   = 0.18;   % large fraction = car hood, window, road sign
    MIN_EXTENT   = 0.18;   % after closing the blob should be reasonably full
    MIN_SOLIDITY = 0.18;

    rows      = [];
    bestScore = -inf;

    for i = 1:numel(regions)

        bbox = regions(i).BoundingBox;
        if numel(bbox) ~= 4, continue; end

        x = bbox(1);  y = bbox(2);
        w = bbox(3);  h = bbox(4);

        % Pixel size gate
        if w < MIN_PIXEL_W || h < MIN_PIXEL_H, continue; end

        % Reject blobs outside image bounds (allow tiny decimal tolerance
        % from regionprops sub-pixel coordinates)
        if x < 0.5 || y < 0.5 || (x+w) > (imgW+1) || (y+h) > (imgH+1)
            continue;
        end

        aspectRatio = w / max(h, 1);
        areaRatio   = (w * h) / imgArea;

        if aspectRatio < MIN_AR  || aspectRatio > MAX_AR,  continue; end
        if areaRatio   < MIN_AREA_R || areaRatio > MAX_AREA_R, continue; end

        extent    = safeField(regions, i, 'Extent',       0.45);
        solidity  = safeField(regions, i, 'Solidity',     0.45);
        eccen     = safeField(regions, i, 'Eccentricity', 0.75);
        meanInt   = safeField(regions, i, 'MeanIntensity', 128);

        if extent   < MIN_EXTENT,   continue; end
        if solidity < MIN_SOLIDITY, continue; end

        % --- Normalised score components ----------------------------------

        % Aspect ratio: primary target 4.0 (normal plate).
        % Two-row plates (~2.2) get a secondary score at 70% weight so they
        % are not unfairly penalised against normal plates.
        aspectScore    = 1 - min(abs(aspectRatio - 4.0) / 4.0, 1);
        twoRowScore    = 1 - min(abs(aspectRatio - 2.2) / 2.2, 1);
        aspectScore    = max(aspectScore, 0.70 * twoRowScore);

        % Area: scales linearly up to 3.5% image area (typical close plate)
        areaScore      = min(areaRatio / 0.035, 1);

        % Compactness features
        extentScore    = min(extent   / 0.75, 1);
        solidityScore  = min(solidity / 0.85, 1);
        eccentScore    = min(eccen    / 0.95, 1);

        % Vertical position: plates most common around 55-70% image height.
        % Tolerance is wide (±45%) so motorcycle plates (higher) are included.
        centerY        = y + h / 2;
        vertScore      = 1 - min(abs((centerY / imgH) - 0.62) / 0.45, 1);

        % Horizontal centre: plates usually near vehicle centre line.
        centerX        = x + w / 2;
        horizScore     = 1 - min(abs((centerX / imgW) - 0.50) / 0.60, 1);

        % Intensity: weak preference for mid-tone regions; avoids black/white noise.
        intNorm        = double(meanInt) / 255;
        intensityScore = 1 - abs(intNorm - 0.55);

        % --- Weighted sum -------------------------------------------------
        score = 0.24 * aspectScore    + ...
                0.20 * areaScore      + ...
                0.14 * extentScore    + ...
                0.12 * solidityScore  + ...
                0.10 * eccentScore    + ...
                0.11 * vertScore      + ...
                0.05 * horizScore     + ...
                0.04 * intensityScore;

        rows = [rows; [i, x, y, w, h, aspectRatio, areaRatio, ...
                        extent, solidity, eccen, meanInt, score]]; %#ok<AGROW>

        if score > bestScore
            bestScore = score;
            bestBBox  = bbox;
        end
    end

    % Build sortable debug table
    if ~isempty(rows)
        candidateTable = array2table(rows, 'VariableNames', { ...
            'RegionIndex', 'X', 'Y', 'Width', 'Height', 'AspectRatio', ...
            'AreaRatio', 'Extent', 'Solidity', 'Eccentricity', ...
            'MeanIntensity', 'Score'});
        candidateTable = sortrows(candidateTable, 'Score', 'descend');
    end
end


function value = safeField(regions, index, fieldName, defaultValue)
% safeField  Safely reads a scalar regionprops field with a fallback value.
    value = defaultValue;
    if isfield(regions, fieldName)
        temp = regions(index).(fieldName);
        if ~isempty(temp) && isscalar(temp) && isfinite(double(temp))
            value = double(temp);
        end
    end
end
