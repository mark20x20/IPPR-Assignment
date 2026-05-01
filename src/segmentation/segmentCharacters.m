function [characterImages, characterBBoxes] = segmentCharacters(plateImg)
characterImages = {};
characterBBoxes = [];

if isempty(plateImg)
    return;
end

binaryPlateImg = binarizePlate(plateImg);
cleanedImg = cleanBinaryImage(binaryPlateImg);
if isempty(cleanedImg)
    return;
end

try
    cc = bwconncomp(cleanedImg);
    props = regionprops(cc, "BoundingBox", "Area");
    if isempty(props)
        return;
    end

    boxes = reshape([props.BoundingBox], 4, []).';
    imgH = size(cleanedImg, 1);
    imgW = size(cleanedImg, 2);

    valid = false(size(boxes, 1), 1);
    for i = 1:size(boxes, 1)
        w = boxes(i, 3);
        h = boxes(i, 4);
        ar = w / max(h, 1);
        valid(i) = w > 2 && h > 5 && h < 0.95 * imgH && ar > 0.1 && ar < 1.5;
    end
    boxes = boxes(valid, :);
    if isempty(boxes)
        return;
    end
    boxes = sortrows(boxes, 1);
    characterBBoxes = boxes;

    for i = 1:size(boxes, 1)
        charImg = imcrop(plateImg, boxes(i, :));
        if ~isempty(charImg)
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
