function grayImg = convertToGray(inputImg)
%CONVERTTOGRAY Convert RGB image to grayscale or return grayscale input.

grayImg = [];

% Return empty output for empty input.
if isempty(inputImg)
    return;
end

% Convert RGB input to grayscale for simpler processing.
if ndims(inputImg) == 3 && size(inputImg, 3) == 3
    grayImg = rgb2gray(inputImg);
else
    % Keep grayscale input unchanged.
    grayImg = inputImg;
end
end
