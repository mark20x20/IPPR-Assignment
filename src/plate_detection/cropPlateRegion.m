function plateImg = cropPlateRegion(originalImg, plateBBox)
% cropPlateRegion  Crops the selected plate region from the original image.
%
% Adaptive padding is added around the detected bounding box to ensure the
% full plate border and characters are included even when the detector
% localises the plate slightly too tightly.
%
% Padding strategy:
%   Horizontal: 10% of bounding box width  (min 4 px)
%   Vertical:   22% of bounding box height (min 3 px)
% The larger vertical padding compensates for slight vertical drift in the
% closing+regionprops pipeline and for two-row plates where the detected
% blob height may clip the bottom row of characters.
%
% Inputs:
%   originalImg - source image (colour or grayscale) to crop from
%   plateBBox   - [x y width height] from selectPlateCandidate
%
% Output:
%   plateImg    - cropped image region, [] if inputs are invalid
%
% Author : Member 2
% Module : src/plate_detection/cropPlateRegion.m

    plateImg = [];

    % Guard: empty or malformed inputs return [] safely
    if isempty(originalImg) || isempty(plateBBox) || numel(plateBBox) ~= 4
        return;
    end

    imgH = size(originalImg, 1);
    imgW = size(originalImg, 2);

    x = double(plateBBox(1));
    y = double(plateBBox(2));
    w = double(plateBBox(3));
    h = double(plateBBox(4));

    % Guard: degenerate or non-finite bounding box
    if w <= 1 || h <= 1 || ~all(isfinite([x, y, w, h]))
        return;
    end

    % Compute adaptive padding
    padX = max(4, round(0.10 * w));
    padY = max(3, round(0.22 * h));

    % Clamp to image boundaries
    x1 = max(1,    floor(x - padX));
    y1 = max(1,    floor(y - padY));
    x2 = min(imgW, ceil(x + w + padX));
    y2 = min(imgH, ceil(y + h + padY));

    cropW = x2 - x1 + 1;
    cropH = y2 - y1 + 1;

    % Guard: crop region too small to be useful
    if cropW <= 2 || cropH <= 2
        return;
    end

    try
        % imcrop [x y width height] — subtract 1 because imcrop is inclusive
        plateImg = imcrop(originalImg, [x1, y1, cropW - 1, cropH - 1]);
    catch
        plateImg = [];
    end
end
