function grayImg = convertToGray(inputImg)
grayImg = [];
if isempty(inputImg)
    return;
end

if ndims(inputImg) == 3 && size(inputImg, 3) == 3
    grayImg = rgb2gray(inputImg);
else
    grayImg = inputImg;
end
end
