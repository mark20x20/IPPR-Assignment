function cleanedImg = cleanBinaryImage(binaryImg)
cleanedImg = [];
if isempty(binaryImg)
    return;
end

try
    cleanedImg = imopen(binaryImg, strel("rectangle", [2 2]));
    cleanedImg = imclose(cleanedImg, strel("rectangle", [2 2]));
    cleanedImg = imfill(cleanedImg, "holes");
    cleanedImg = bwareaopen(cleanedImg, 20);
catch
    cleanedImg = binaryImg;
end
end
