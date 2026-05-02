function [preprocessedImg, debugInfo] = preprocessImage(inputImg)
%PREPROCESSIMAGE Run grayscale conversion, contrast enhancement, and denoising.

% Initialize outputs and debug fields for safe reporting.
debugInfo = struct("grayImg", [], "enhancedImg", [], "filteredImg", [], "errorMessage", "", "status", "Failed");
preprocessedImg = [];

% Stop early when input image is missing.
if isempty(inputImg)
    debugInfo.errorMessage = "Input image is empty.";
    return;
end

% Convert input image to grayscale first.
grayImg = convertToGray(inputImg);
debugInfo.grayImg = grayImg;
if isempty(grayImg)
    debugInfo.errorMessage = "Grayscale conversion failed.";
    return;
end

% Enhance contrast to make key structures clearer.
enhancedImg = enhanceContrast(grayImg);
debugInfo.enhancedImg = enhancedImg;
if isempty(enhancedImg)
    debugInfo.errorMessage = "Contrast enhancement failed.";
    return;
end

% Apply median filtering to suppress small noise.
filteredImg = removeNoise(enhancedImg);
debugInfo.filteredImg = filteredImg;
if isempty(filteredImg)
    debugInfo.errorMessage = "Noise removal failed.";
    return;
end

% Return final result and mark successful processing.
preprocessedImg = filteredImg;
debugInfo.status = "Success";
end
