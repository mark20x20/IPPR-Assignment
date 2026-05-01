function binaryPlateImg = binarizePlate(plateImg)
binaryPlateImg = [];
if isempty(plateImg)
    return;
end

if ndims(plateImg) == 3 && size(plateImg, 3) == 3
    gray = rgb2gray(plateImg);
else
    gray = plateImg;
end

try
    binaryPlateImg = imbinarize(gray);
catch
    threshold = graythresh(gray);
    binaryPlateImg = imbinarize(gray, threshold);
end
end
