function [plateImg, plateBBox, plateFound, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
% detectPlateRegion  Detects and crops the most likely license plate region.
%
% Member 2 module: License Plate Detection
% Pipeline stage: runs after preprocessing (Member 1), output is consumed
% by segmentation (Member 3) and the GUI (Member 4).
%
% Approach: classical image processing only.
% Methods used:
%   - Adaptive histogram equalisation (CLAHE) for lighting robustness
%   - Gaussian smoothing for noise suppression
%   - Canny edge detection
%   - Dual morphological closing (single-row + two-row plate SE)
%   - Hole filling and border clearing
%   - Connected-component feature extraction (regionprops)
%   - Weighted geometric + intensity scoring
%
% NOT used (prohibited by assignment):
%   Haar Cascade, TensorFlow, YOLO, deep learning detectors,
%   template matching, pattern matching.
%
% Inputs:
%   preprocessedImg - grayscale or colour image from Member 1 preprocessing
%   originalImg     - original colour/grayscale image used for final crop
%
% Outputs:
%   plateImg   - cropped plate image (grayscale), [] if none found
%   plateBBox  - [x y width height] bounding box,  [] if none found
%   plateFound - logical scalar: true when a valid plate was detected
%   debugInfo  - struct of intermediate images and candidate data
%                (optional 4th output; not required by main.m)
%
% Usage (main pipeline):
%   [plateImg, plateBBox, plateFound] = detectPlateRegion(pre, orig);
%
% Usage (scratch / debug):
%   [plateImg, plateBBox, plateFound, dbg] = detectPlateRegion(pre, orig);
%
% Author : Member 2
% Module : src/plate_detection/detectPlateRegion.m

    % --- Safe fallback defaults -------------------------------------------
    plateImg   = [];
    plateBBox  = [];
    plateFound = false;

    debugInfo = struct( ...
        'grayImg',        [], ...
        'enhancedImg',    [], ...
        'edgeImg',        [], ...
        'closedImg',      [], ...
        'filledImg',      [], ...
        'cleanedImg',     [], ...
        'candidateMask',  [], ...
        'regions',        [], ...
        'candidateTable', table(), ...
        'status',         "Not started" ...
    );

    % --- Input validation -------------------------------------------------
    if nargin < 2 || isempty(preprocessedImg) || isempty(originalImg)
        debugInfo.status = "Input image is empty or missing.";
        warning('detectPlateRegion: empty input received. Returning fallback.');
        return;
    end

    try
        % =================================================================
        % STEP 1 — Convert to grayscale uint8
        % =================================================================
        grayImg = localToGrayUint8(preprocessedImg);

        % =================================================================
        % STEP 2 — Adaptive histogram equalisation (CLAHE)
        % Rayleigh distribution suits natural scenes where most pixels are
        % mid-tone; ClipLimit=0.015 avoids amplifying noise in flat regions.
        % This makes the function robust to over/under exposure and shadows.
        % =================================================================
        enhancedImg = adapthisteq(grayImg, ...
            'ClipLimit',    0.015, ...
            'Distribution', 'rayleigh');

        % =================================================================
        % STEP 3 — Gaussian smoothing (sigma = 1.0)
        % Removes high-frequency sensor noise before edge detection so
        % Canny does not create spurious edges from grain or JPEG artefacts.
        % =================================================================
        smoothImg = imgaussfilt(enhancedImg, 1.0);

        % =================================================================
        % STEP 4 — Canny edge detection (auto thresholds)
        % Canny is preferred over Sobel/Prewitt because:
        %   - Built-in Gaussian smoothing (double noise suppression)
        %   - Hysteresis thresholding reduces disconnected false edges
        %   - Produces thin, accurately localised edges at plate borders
        % Auto thresholds allow the function to adapt across image types.
        % =================================================================
        edgeImg = edge(smoothImg, 'Canny');

        % =================================================================
        % STEP 5 — Dual morphological closing
        % Two structuring elements handle both main plate geometries in
        % Malaysian vehicle registration:
        %   horizontalSE [4x28] — single-row plates (most states, cars)
        %   twoRowSE     [9x22] — two-row plates (motorcycles, some states)
        % The union of both closed images robustly captures both types.
        % =================================================================
        horizontalSE     = strel('rectangle', [4, 28]);
        twoRowSE         = strel('rectangle', [9, 22]);
        closedHorizontal = imclose(edgeImg, horizontalSE);
        closedTwoRow     = imclose(edgeImg, twoRowSE);
        closedImg        = closedHorizontal | closedTwoRow;

        % =================================================================
        % STEP 6 — Hole filling, noise removal, border clearing
        % imfill closes gaps inside blobs (plate interior text creates holes).
        % bwareaopen uses an image-proportional minimum area so the function
        % scales from close-up to distant vehicle shots without retuning.
        % imclearborder removes blobs touching the image frame — these are
        % almost always vehicle body panels or road markings, never plates.
        % =================================================================
        filledImg  = imfill(closedImg, 'holes');
        minArea    = max(150, round(numel(grayImg) * 0.0001));
        cleanedImg = bwareaopen(filledImg, minArea);
        cleanedImg = imclearborder(cleanedImg);

        % =================================================================
        % STEP 7 — Connected-component feature extraction (regionprops)
        % MeanIntensity is measured on the CLAHE-enhanced image so it
        % reflects local brightness independent of global exposure level.
        % =================================================================
        regions = regionprops(cleanedImg, enhancedImg, ...
            'BoundingBox', 'Area', 'Extent', 'Solidity', ...
            'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', ...
            'MeanIntensity');

        % =================================================================
        % STEP 8 — Weighted multi-feature candidate scoring and selection
        % =================================================================
        [plateBBox, candidateTable] = selectPlateCandidate(regions, size(grayImg));

        % =================================================================
        % STEP 9 — Adaptive-padding crop from original image
        % =================================================================
        plateImg = cropPlateRegion(originalImg, plateBBox);

        % Build binary candidate mask for visualisation / debug figure
        candidateMask = false(size(grayImg));
        if ~isempty(plateBBox)
            candidateMask = insertCandidateMask(candidateMask, plateBBox);
        end

        % Pack debug struct (used by scratch test and report figures)
        debugInfo.grayImg        = grayImg;
        debugInfo.enhancedImg    = enhancedImg;
        debugInfo.edgeImg        = edgeImg;
        debugInfo.closedImg      = closedImg;
        debugInfo.filledImg      = filledImg;
        debugInfo.cleanedImg     = cleanedImg;
        debugInfo.candidateMask  = candidateMask;
        debugInfo.regions        = regions;
        debugInfo.candidateTable = candidateTable;

        if isempty(plateImg)
            plateFound       = false;
            plateBBox        = [];
            debugInfo.status = "No valid plate candidate found. Safe fallback returned.";
            warning('detectPlateRegion: no plate candidate passed all filters.');
        else
            plateFound       = true;
            debugInfo.status = "Plate candidate detected and cropped successfully.";
            fprintf('[detectPlateRegion] Plate found at [%.0f %.0f %.0f %.0f]\n', plateBBox);
        end

    catch ME
        % Any unexpected error returns safe fallbacks — pipeline never crashes.
        plateImg         = [];
        plateBBox        = [];
        plateFound       = false;
        debugInfo.status = "Detection failed safely: " + string(ME.message);
        warning('detectPlateRegion: caught error — %s', ME.message);
    end
end


% =========================================================================
% LOCAL HELPER FUNCTIONS
% =========================================================================

function grayImg = localToGrayUint8(inputImg)
% localToGrayUint8  Converts any numeric image to uint8 grayscale.
    if size(inputImg, 3) == 3
        grayImg = rgb2gray(inputImg);
    else
        grayImg = inputImg;
    end
    if isa(grayImg, 'uint8'), return; end
    if isfloat(grayImg)
        grayImg = im2uint8(mat2gray(grayImg));
    else
        grayImg = im2uint8(mat2gray(double(grayImg)));
    end
end


function mask = insertCandidateMask(mask, bbox)
% insertCandidateMask  Sets pixels inside bbox region to true.
    imgH = size(mask, 1);
    imgW = size(mask, 2);
    x1 = max(1,    floor(bbox(1)));
    y1 = max(1,    floor(bbox(2)));
    x2 = min(imgW, ceil(bbox(1) + bbox(3)));
    y2 = min(imgH, ceil(bbox(2) + bbox(4)));
    if x2 > x1 && y2 > y1
        mask(y1:y2, x1:x2) = true;
    end
end
