function [preprocessedImg, debugInfo] = preprocessImage(inputImg)
debugInfo = struct("grayImg", [], "enhancedImg", [], "filteredImg", [], "errorMessage", "");
preprocessedImg = [];

if isempty(inputImg)
    debugInfo.errorMessage = "Input image is empty.";
    return;
end

grayImg = convertToGray(inputImg);
enhancedImg = enhanceContrast(grayImg);
filteredImg = removeNoise(enhancedImg);

debugInfo.grayImg = grayImg;
debugInfo.enhancedImg = enhancedImg;
debugInfo.filteredImg = filteredImg;
preprocessedImg = filteredImg;
end
