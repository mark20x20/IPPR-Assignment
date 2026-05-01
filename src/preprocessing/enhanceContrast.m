function enhancedImg = enhanceContrast(grayImg)
enhancedImg = [];
if isempty(grayImg)
    return;
end

try
    enhancedImg = imadjust(grayImg);
catch
    enhancedImg = grayImg;
end
end
