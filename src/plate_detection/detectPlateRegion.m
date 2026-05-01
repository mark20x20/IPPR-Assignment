function [plateImg, plateBBox, debugInfo] = detectPlateRegion(preprocessedImg, originalImg)
plateImg = [];
plateBBox = [];
debugInfo = struct("edgeImg", [], "closedImg", [], "filledImg", [], "cleanedImg", [], "regions", [], "status", "");

if isempty(preprocessedImg) || isempty(originalImg)
    debugInfo.status = "Input image is empty.";
    return;
end

try
    edgeImg = edge(preprocessedImg, "Canny");
    closedImg = imclose(edgeImg, strel("rectangle", [5 15]));
    filledImg = imfill(closedImg, "holes");
    cleanedImg = bwareaopen(filledImg, 100);
    regions = regionprops(cleanedImg, "BoundingBox", "Area");

    plateBBox = selectPlateCandidate(regions, size(preprocessedImg));
    plateImg = cropPlateRegion(originalImg, plateBBox);

    debugInfo.edgeImg = edgeImg;
    debugInfo.closedImg = closedImg;
    debugInfo.filledImg = filledImg;
    debugInfo.cleanedImg = cleanedImg;
    debugInfo.regions = regions;

    if isempty(plateImg)
        debugInfo.status = "No valid plate candidate found.";
    else
        debugInfo.status = "Plate candidate selected.";
    end
catch detectErr
    debugInfo.status = "Detection failed safely: " + string(detectErr.message);
    plateImg = [];
    plateBBox = [];
end
end
