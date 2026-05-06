function [characterImages, characterBBoxes] = segmentCharacters(plateImg)
%SEGMENTCHARACTERS Segment possible characters from a cropped license plate.
%
% This function is the main Member 3 segmentation function.
% It uses classical image processing methods only:
%   1. Adaptive binarization
%   2. Morphological cleaning
%   3. Connected component analysis
%   4. Geometric filtering
%   5. Character ordering
%
% Input:
%   plateImg - cropped license plate image
%
% Output:
%   characterImages - cell array of resized binary character images
%   characterBBoxes - bounding boxes of detected characters [x y width height]
%
% Fallback:
%   If segmentation fails, this function returns {} and [] instead of crashing.

characterImages = {};
characterBBoxes = [];

if isempty(plateImg)
    return;
end

try
    % Step 1: Convert cropped plate into a binary image.
    binaryPlateImg = binarizePlate(plateImg);

    % Step 2: Clean binary image using light morphology.
    cleanedImg = cleanBinaryImage(binaryPlateImg);

    if isempty(cleanedImg)
        return;
    end

    % Step 3: Extract connected components as character candidates.
    props = regionprops(cleanedImg, "BoundingBox", "Area", "Extent");

    if isempty(props)
        return;
    end

    imgH = size(cleanedImg, 1);
    imgW = size(cleanedImg, 2);

    boxes = [];

    % Step 4: Filter candidates using character-like geometry.
    % These thresholds are relative to the plate size, so they work better
    % across different image resolutions.
    for i = 1:numel(props)
        box = props(i).BoundingBox;
        w = box(3);
        h = box(4);

        aspectRatio = w / max(h, 1);
        areaRatio = props(i).Area / (imgH * imgW);

        isCharacter = ...
            h >= 0.20 * imgH && ...
            h <= 0.95 * imgH && ...
            w >= 0.012 * imgW && ...
            w <= 0.35 * imgW && ...
            aspectRatio >= 0.08 && ...
            aspectRatio <= 1.30 && ...
            areaRatio >= 0.0008 && ...
            areaRatio <= 0.22 && ...
            props(i).Extent >= 0.08 && ...
            props(i).Extent <= 0.95;

        if isCharacter
            boxes = [boxes; box]; %#ok<AGROW>
        end
    end

    if isempty(boxes)
        return;
    end

    % Step 5: Remove small noise boxes using median character height.
    medianHeight = median(boxes(:, 4));
    keep = boxes(:, 4) >= 0.50 * medianHeight;
    boxes = boxes(keep, :);

    if isempty(boxes)
        return;
    end

    % Step 6: Sort character boxes.
    % Single-line plates are sorted left-to-right.
    % Two-line plates are sorted top row first, then bottom row.
    boxes = sortCharacterBoxes(boxes);

    characterBBoxes = boxes;

    % Step 7: Crop and normalize each detected character.
    for i = 1:size(characterBBoxes, 1)
        charImg = imcrop(cleanedImg, characterBBoxes(i, :));

        if ~isempty(charImg)
            charImg = imresize(charImg, [50 30]);
            characterImages{end + 1} = charImg; %#ok<AGROW>
        end
    end

    if isempty(characterImages)
        characterBBoxes = [];
    end

catch
    characterImages = {};
    characterBBoxes = [];
end

end


function sortedBoxes = sortCharacterBoxes(boxes)
%SORTCHARACTERBOXES Sort character boxes for one-line or two-line plates.
%
% For single-line plates:
%   Characters are sorted from left to right.
%
% For two-line plates:
%   Characters are split into top and bottom rows using vertical center
%   positions, then each row is sorted left to right.

if isempty(boxes)
    sortedBoxes = [];
    return;
end

centersY = boxes(:, 2) + boxes(:, 4) / 2;
medianHeight = median(boxes(:, 4));

verticalSpread = max(centersY) - min(centersY);

if verticalSpread > 0.65 * medianHeight
    rowThreshold = median(centersY);

    topRow = boxes(centersY <= rowThreshold, :);
    bottomRow = boxes(centersY > rowThreshold, :);

    topRow = sortrows(topRow, 1);
    bottomRow = sortrows(bottomRow, 1);

    sortedBoxes = [topRow; bottomRow];
else
    sortedBoxes = sortrows(boxes, 1);
end

end
