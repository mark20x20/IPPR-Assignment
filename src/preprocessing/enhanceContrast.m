function enhancedImg = enhanceContrast(grayImg)
%ENHANCECONTRAST Improve grayscale image contrast using imadjust.

enhancedImg = [];

% Return empty output for empty input.
if isempty(grayImg)
    return;
end

% Enhance contrast to make plate edges more visible.
enhancedImg = imadjust(grayImg);
end
