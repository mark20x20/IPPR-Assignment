function bestBBox = selectPlateCandidate(regions, imageSize)
bestBBox = [];
if isempty(regions) || numel(imageSize) < 2
    return;
end

bestScore = -inf;
imgH = imageSize(1);
imgW = imageSize(2);

for i = 1:numel(regions)
    bbox = regions(i).BoundingBox;
    if numel(bbox) ~= 4
        continue;
    end
    w = bbox(3);
    h = bbox(4);
    if w <= 0 || h <= 0
        continue;
    end
    aspectRatio = w / h;
    if aspectRatio < 2.0 || aspectRatio > 6.0
        continue;
    end
    if bbox(1) < 1 || bbox(2) < 1 || (bbox(1) + w) > imgW || (bbox(2) + h) > imgH
        continue;
    end
    areaScore = w * h;
    score = areaScore - abs(aspectRatio - 4.0) * 100;
    if score > bestScore
        bestScore = score;
        bestBBox = bbox;
    end
end
end
