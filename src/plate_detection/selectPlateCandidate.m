function [bestBBox, candidateTable] = selectPlateCandidate(regions, imageSize, edgeImg)
% selectPlateCandidate  Compatibility wrapper for legacy regionprops callers.
% Public signature remains callable. Internally uses unified table + scoring.

    bestBBox = [];
    candidateTable = table();

    if isempty(regions) || numel(imageSize) < 2
        return;
    end

    numRegions = numel(regions);
    x = zeros(numRegions, 1);
    y = zeros(numRegions, 1);
    w = zeros(numRegions, 1);
    h = zeros(numRegions, 1);
    regionArea = zeros(numRegions, 1);
    extent = nan(numRegions, 1);
    solidity = nan(numRegions, 1);
    meanIntensity = nan(numRegions, 1);

    for i = 1:numRegions
        bbox = regions(i).BoundingBox;
        if numel(bbox) == 4
            x(i) = bbox(1);
            y(i) = bbox(2);
            w(i) = bbox(3);
            h(i) = bbox(4);
        end

        if isfield(regions, 'Area')
            regionArea(i) = regions(i).Area;
        else
            regionArea(i) = w(i) * h(i);
        end

        if isfield(regions, 'Extent')
            extent(i) = regions(i).Extent;
        end
        if isfield(regions, 'Solidity')
            solidity(i) = regions(i).Solidity;
        end
        if isfield(regions, 'MeanIntensity')
            meanIntensity(i) = regions(i).MeanIntensity;
        end
    end

    sourceMethod = repmat("edge_morph", numRegions, 1);
    rawCandidates = table((1:numRegions)', sourceMethod, x, y, w, h, regionArea, extent, solidity, meanIntensity, ...
        'VariableNames', {'RegionIndex', 'SourceMethod', 'X', 'Y', 'Width', 'Height', ...
        'RegionArea', 'Extent', 'Solidity', 'MeanIntensity'});

    [rawCandidates, ~] = groupHorizontalCandidates(rawCandidates, imageSize);
    candidateTable = buildCandidateTable(rawCandidates, imageSize, edgeImg, []);
    candidateTable = scorePlateCandidates(candidateTable);

    [bestBBox, ~, candidateTable] = selectBestScoredCandidate(candidateTable);

    setappdata(0, 'selectPlateCandidateDiagnostics', candidateTable);
end
